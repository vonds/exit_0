#!/bin/bash

# Lab 381: SELinux + Storage — Fix SELinux Blocking a Mounted Directory
# Scenario: A web service started failing right after a new filesystem was mounted.
# The mount is present and permissions look fine, but SELinux is denying access.
# Your job: confirm SELinux is enforcing, identify the AVC denial, label the mount path
# correctly for httpd, and verify the web service can read the mounted content.
#
# Key skills: mount/findmnt, getenforce, ls -Z, journalctl/ausearch (AVC), semanage fcontext,
# restorecon, systemctl, curl, verification workflow.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 381: Fix SELinux Blocking a Mounted Directory"
LAB_ID="lab381"
LAB_XP=38100
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@rhel-lab381:~$ "

draw_lab_ui() {
  clear
  center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
  center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
  echo; echo; echo
}

record_lab_completion() {
  tmpfile=$(mktemp)
  jq --arg lab "$LAB_ID" '.[$lab] += 1 // 1' "$LAB_TRACK_FILE" > "$tmpfile" && mv "$tmpfile" "$LAB_TRACK_FILE"
}

get_lab_completion_count() {
  jq -r --arg lab "$LAB_ID" '.[$lab] // 0' "$LAB_TRACK_FILE"
}

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "Scenario:"
  center_text "A new XFS filesystem was mounted at /srv/webdata."
  center_text "After the change, the web app started returning 403/500 errors."
  center_text "The mount is present and readable by root, but httpd cannot read it."
  echo
  center_text "Goal: prove SELinux is the blocker, fix labeling for the mounted path,"
  center_text "and verify httpd can read content from /srv/webdata."
  echo
  center_text "Given:"
  center_text "- Mount point: /srv/webdata"
  center_text "- Service: httpd"
  center_text "- Test URL: http://localhost/"
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Confirm mount exists
  echo "  Step 1: Confirm /srv/webdata is mounted and show its source."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "findmnt /srv/webdata" && \
        "$cmd1" != "mount | grep /srv/webdata" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd1" == "findmnt /srv/webdata" ]]; then
    echo "  TARGET       SOURCE               FSTYPE OPTIONS"
    echo "  /srv/webdata /dev/mapper/vg0-web  xfs    rw,relatime,seclabel,attr2,inode64,logbufs=8,logbsize=32k,noquota"
  else
    echo "  /dev/mapper/vg0-web on /srv/webdata type xfs (rw,relatime,seclabel,attr2,inode64,logbufs=8,logbsize=32k,noquota)"
  fi
  echo

  # STEP 2: Check SELinux enforcing
  echo "  Step 2: Confirm SELinux mode."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "getenforce" && "$cmd2" != "sestatus" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd2" == "getenforce" ]]; then
    echo "  Enforcing"
  else
    echo "  SELinux status:                 enabled"
    echo "  SELinuxfs mount:                /sys/fs/selinux"
    echo "  SELinux root directory:         /etc/selinux"
    echo "  Loaded policy name:             targeted"
    echo "  Current mode:                   enforcing"
    echo "  Mode from config file:          enforcing"
  fi
  echo

  # STEP 3: Reproduce symptom quickly (curl)
  echo "  Step 3: Reproduce the failure by requesting the local web page."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "curl -I http://localhost/" && \
        "$cmd3" != "curl -sS http://localhost/ | head" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd3" == "curl -I http://localhost/" ]]; then
    echo "  HTTP/1.1 403 Forbidden"
    echo "  Server: Apache/2.4.57 (Rocky Linux)"
    echo "  Content-Type: text/html; charset=iso-8859-1"
  else
    echo "  <html>"
    echo "  <head><title>403 Forbidden</title></head>"
    echo "  <body>Forbidden</body>"
  fi
  echo

  # STEP 4: Identify AVC denial (journalctl)
  echo "  Step 4: Find the SELinux denial related to httpd (AVC)."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo journalctl -t setroubleshoot --no-pager -n 20" && \
        "$cmd4" != "sudo ausearch -m avc -ts recent" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd4" == "sudo ausearch -m avc -ts recent" ]]; then
    echo "  ----"
    echo "  time->Tue Jan 21 10:12:41 2026"
    echo "  type=AVC msg=audit(1737479561.412:221): avc:  denied  { read open } for  pid=1643 comm=\"httpd\""
    echo "  path=\"/srv/webdata/index.html\" dev=\"dm-0\" ino=128 scontext=system_u:system_r:httpd_t:s0"
    echo "  tcontext=unconfined_u:object_r:default_t:s0 tclass=file permissive=0"
  else
    echo "  Jan 21 10:12:41 host setroubleshoot[2193]: SELinux is preventing /usr/sbin/httpd from read access on the file /srv/webdata/index.html."
    echo "  Jan 21 10:12:41 host setroubleshoot[2193]: *****  Plugin catchall (100. confidence) suggests   **************************"
    echo "  Jan 21 10:12:41 host setroubleshoot[2193]: If you want to allow httpd to read /srv/webdata, you need to change the file context."
  fi
  echo

  # STEP 5: Confirm current context on mount path/files
  echo "  Step 5: Show SELinux labels on /srv/webdata and one file inside it."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "ls -ldZ /srv/webdata && ls -lZ /srv/webdata | head" && \
        "$cmd5" != "ls -ldZ /srv/webdata" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  drwxr-xr-x. 2 root root unconfined_u:object_r:default_t:s0 /srv/webdata"
  echo "  -rw-r--r--. 1 root root unconfined_u:object_r:default_t:s0 index.html"
  echo

  # STEP 6: Define correct context mapping for httpd content
  echo "  Step 6: Add an SELinux fcontext rule to label /srv/webdata as httpd content (recursive)."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo semanage fcontext -a -t httpd_sys_content_t '/srv/webdata(/.*)?'" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  # semanage is typically silent on success.

  # STEP 7: Apply labels with restorecon
  echo "  Step 7: Apply the new labels to /srv/webdata."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo restorecon -Rv /srv/webdata" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Relabeled /srv/webdata from unconfined_u:object_r:default_t:s0 to system_u:object_r:httpd_sys_content_t:s0"
  echo "  Relabeled /srv/webdata/index.html from unconfined_u:object_r:default_t:s0 to system_u:object_r:httpd_sys_content_t:s0"
  echo

  # STEP 8: Verify service can read now
  echo "  Step 8: Verify httpd can serve content now."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "curl -I http://localhost/" && \
        "$cmd8" != "curl -sS http://localhost/ | head" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd8" == "curl -I http://localhost/" ]]; then
    echo "  HTTP/1.1 200 OK"
    echo "  Server: Apache/2.4.57 (Rocky Linux)"
    echo "  Content-Type: text/html; charset=UTF-8"
  else
    echo "  <html>"
    echo "  <head><title>OK</title></head>"
    echo "  <body>webdata mounted and readable</body>"
  fi
  echo

  print_success "Nice work."
  print_info "You fixed a real SELinux-on-storage outage by:"
  print_info "- confirming the mount and reproducing the app symptom"
  print_info "- proving SELinux Enforcing + identifying an AVC denial for httpd_t"
  print_info "- confirming the mount content was labeled default_t"
  print_info "- defining a persistent fcontext rule for /srv/webdata"
  print_info "- applying labels with restorecon and re-verifying HTTP"
  print_info "You earned $LAB_XP XP for completing this lab."
  award_xp $LAB_XP

  XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON"); export XP; export LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've successfully completed this lab $completion_count time(s)."
  echo
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " choice

  [[ "$choice" == "2" ]] && exit 0
done
