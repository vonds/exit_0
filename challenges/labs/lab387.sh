#!/bin/bash

# Lab 387: SELinux + Apache — Fix Web Service Serving Content from Nonstandard Path (4–8 prompts)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 387: Fix httpd Serving from Nonstandard Path (SELinux)"
LAB_ID="lab387"
LAB_XP=38700
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@rhel-lab387:~$ "

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
  center_text "The company moved the intranet site document root to /srv/intranet."
  center_text "Apache (httpd) is running, but users report a 403 Forbidden."
  center_text "You must identify the root cause and fix it the RHEL way:"
  center_text "- verify httpd is listening"
  center_text "- confirm the DocumentRoot points to the nonstandard path"
  center_text "- correct SELinux labeling for the new content location"
  center_text "- verify the site returns 200 OK"
  echo
  center_text "Nonstandard web root: /srv/intranet"
  center_text "Verification target: http://localhost/"
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Confirm httpd is running
  echo "  Step 1: Confirm httpd is running."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "systemctl status httpd" && \
        "$cmd1" != "sudo systemctl status httpd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  ● httpd.service - The Apache HTTP Server"
  echo "       Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; preset: enabled)"
  echo "       Active: active (running) since Sun 2026-02-01 22:31:10 EST; 1min 12s ago"
  echo "         Docs: man:httpd.service(8)"
  echo "     Main PID: 2143 (httpd)"
  echo "       Status: \"Running, listening on: port 80\""
  echo "        Tasks: 177 (limit: 4650)"
  echo "       Memory: 22.1M"
  echo "          CPU: 268ms"
  echo "     CGroup: /system.slice/httpd.service"
  echo "             ├─2143 /usr/sbin/httpd -DFOREGROUND"
  echo "             ├─2145 /usr/sbin/httpd -DFOREGROUND"
  echo "             ├─2146 /usr/sbin/httpd -DFOREGROUND"
  echo "             ├─2147 /usr/sbin/httpd -DFOREGROUND"
  echo "             └─2148 /usr/sbin/httpd -DFOREGROUND"
  echo

  # STEP 2: Verify the user-facing symptom (403)
  echo "  Step 2: Verify the symptom by requesting the home page."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "curl -I http://localhost/" && \
        "$cmd2" != "curl -I http://localhost" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  HTTP/1.1 403 Forbidden"
  echo "  Date: Sun, 01 Feb 2026 03:32:25 GMT"
  echo "  Server: Apache/2.4.57 (Red Hat Enterprise Linux)"
  echo "  Content-Length: 199"
  echo "  Content-Type: text/html; charset=iso-8859-1"
  echo

  # STEP 3: Confirm DocumentRoot points to /srv/intranet
  echo "  Step 3: Confirm httpd is configured to serve from /srv/intranet."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo grep -R '^DocumentRoot' -n /etc/httpd/conf /etc/httpd/conf.d" && \
        "$cmd3" != "grep -R '^DocumentRoot' -n /etc/httpd/conf /etc/httpd/conf.d" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  /etc/httpd/conf.d/intranet.conf:3:DocumentRoot '/srv/intranet'"
  echo

  # STEP 4: Inspect file context (likely wrong)
  echo "  Step 4: Check the SELinux context on the new web root."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "ls -Zd /srv/intranet" && \
        "$cmd4" != "ls -Z /srv/intranet/index.html" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd4" == "ls -Zd /srv/intranet" ]]; then
    echo "  unconfined_u:object_r:default_t:s0 /srv/intranet"
  else
    echo "  unconfined_u:object_r:default_t:s0 /srv/intranet/index.html"
  fi
  echo

  # STEP 5: Confirm AVC denial in logs (realistic)
  echo "  Step 5: Confirm the denial in the logs (AVC)."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo ausearch -m avc -ts recent" && \
        "$cmd5" != "ausearch -m avc -ts recent" && \
        "$cmd5" != "sudo journalctl -t setroubleshoot --since '15 minutes ago'" && \
        "$cmd5" != "journalctl -t setroubleshoot --since '15 minutes ago'" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd5" == *"ausearch -m avc"* ]]; then
    echo "  ----"
    echo "  time->Sun Feb  1 22:32:25 2026"
    echo "  type=AVC msg=audit(1738467145.221:1047): avc:  denied  { read } for  pid=2143 comm=\"httpd\""
    echo "      name='index.html' dev='dm-0' ino=1180367 scontext=system_u:system_r:httpd_t:s0"
    echo "      tcontext=unconfined_u:object_r:default_t:s0 tclass=file permissive=0"
    echo "  ----"
  else
    echo "  Feb 01 22:32:25 rhel-lab387 setroubleshoot[2981]: SELinux is preventing /usr/sbin/httpd from read access on the file /srv/intranet/index.html."
    echo "  Feb 01 22:32:25 rhel-lab387 setroubleshoot[2981]: *****  Plugin restorecon (99.5 confidence) suggests   ************************"
    echo "  Feb 01 22:32:25 rhel-lab387 setroubleshoot[2981]: Restore file context with: restorecon -Rv /srv/intranet"
    echo "  Feb 01 22:32:25 rhel-lab387 setroubleshoot[2981]: *****  Plugin catchall_boolean (1.2 confidence) suggests   ********************"
    echo "  Feb 01 22:32:25 rhel-lab387 setroubleshoot[2981]: If you want to allow httpd to read user content, you must turn on the httpd_enable_homedirs boolean."
  fi
  echo

  # STEP 6: Apply proper persistent context mapping + restore
  echo "  Step 6: Apply the correct SELinux labeling for the nonstandard path and restore contexts."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo semanage fcontext -a -t httpd_sys_content_t '/srv/intranet(/.*)?'" && \
        "$cmd6" != "semanage fcontext -a -t httpd_sys_content_t '/srv/intranet(/.*)?'" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (fcontext rule added)"
  echo
  echo "  Now restore contexts."
  read -p "$PROMPT" cmd6b
  echo
  if [[ "$cmd6b" != "sudo restorecon -Rv /srv/intranet" && \
        "$cmd6b" != "restorecon -Rv /srv/intranet" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  restorecon reset /srv/intranet context unconfined_u:object_r:default_t:s0->system_u:object_r:httpd_sys_content_t:s0"
  echo "  restorecon reset /srv/intranet/index.html context unconfined_u:object_r:default_t:s0->system_u:object_r:httpd_sys_content_t:s0"
  echo

  # STEP 7: Verify the fix (200 OK)
  echo "  Step 7: Verify the site now returns 200 OK."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "curl -I http://localhost/" && \
        "$cmd7" != "curl -I http://localhost" && \
        "$cmd7" != "curl -sS http://localhost/ | head" && \
        "$cmd7" != "curl -sS http://localhost | head" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd7" == "curl -I"* ]]; then
    echo "  HTTP/1.1 200 OK"
    echo "  Date: Sun, 01 Feb 2026 03:34:02 GMT"
    echo "  Server: Apache/2.4.57 (Red Hat Enterprise Linux)"
    echo "  Last-Modified: Sun, 01 Feb 2026 03:20:11 GMT"
    echo "  ETag: '2f-5b12a9c6b8c40'"
    echo "  Accept-Ranges: bytes"
    echo "  Content-Length: 47"
    echo "  Content-Type: text/html; charset=UTF-8"
  else
    echo "  <html>"
    echo "  <head><title>Intranet</title></head>"
    echo "  <body>intranet ok</body>"
    echo "  </html>"
  fi
  echo

  print_success "Nice work."
  print_info "You fixed a real nonstandard DocumentRoot outage by:"
  print_info "- confirming httpd was healthy but returning 403"
  print_info "- confirming DocumentRoot points to /srv/intranet"
  print_info "- proving SELinux denial via AVC logs"
  print_info "- applying a persistent fcontext rule (semanage fcontext)"
  print_info "- restoring contexts (restorecon)"
  print_info "- verifying 200 OK from the endpoint"
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
  read -p "  > " post_choice
  [[ "$post_choice" == "2" ]] && exit 0
done
