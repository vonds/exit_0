#!/bin/bash

# Lab 165: SELinux & httpd — Serve Web Content and Fix SELinux Denials

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 165: SELinux & httpd — Web Content + Denial Fixes"
LAB_ID="lab165"
LAB_XP=16500
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab165:~$ "

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
  center_text "You are deploying Apache (httpd) on a RHEL system."
  center_text "The service starts, but SELinux policy can block access"
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Install httpd
  echo "  Step 1: Install Apache (httpd) using dnf."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "sudo dnf install -y httpd" && "$cmd1" != "dnf install -y httpd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Updating Subscription Management repositories."
  echo "  Last metadata expiration check: 0:02:31 ago on Tue Feb 24 06:10:02 2026."
  echo "  Dependencies resolved."
  echo "  ================================================================================"
  echo "   Package             Architecture     Version                     Repository  Size"
  echo "  ================================================================================"
  echo "  Installing:"
  echo "   httpd               x86_64           2.4.57-8.el9_4               rhel-9-baseos   49 k"
  echo "  Installing dependencies:"
  echo "   apr                 x86_64           1.7.0-12.el9                 rhel-9-baseos  126 k"
  echo "   apr-util            x86_64           1.6.1-23.el9                 rhel-9-baseos   94 k"
  echo "   httpd-core          x86_64           2.4.57-8.el9_4               rhel-9-baseos  1.6 M"
  echo "   httpd-filesystem    noarch           2.4.57-8.el9_4               rhel-9-baseos   15 k"
  echo "   httpd-tools         x86_64           2.4.57-8.el9_4               rhel-9-baseos   88 k"
  echo ""
  echo "  Transaction Summary"
  echo "  ================================================================================"
  echo "  Install  6 Packages"
  echo ""
  echo "  Total download size: 2.0 M"
  echo "  Installed size: 6.9 M"
  echo "  Running transaction check"
  echo "  Transaction check succeeded."
  echo "  Running transaction test"
  echo "  Transaction test succeeded."
  echo "  Running transaction"
  echo "    Installing       : httpd-filesystem                                      1/6"
  echo "    Installing       : apr                                                   2/6"
  echo "    Installing       : apr-util                                              3/6"
  echo "    Installing       : httpd-tools                                           4/6"
  echo "    Installing       : httpd-core                                            5/6"
  echo "    Installing       : httpd                                                 6/6"
  echo "    Verifying        : httpd                                                 1/6"
  echo "    Verifying        : httpd-core                                            2/6"
  echo "    Verifying        : httpd-filesystem                                      3/6"
  echo "    Verifying        : httpd-tools                                           4/6"
  echo "    Verifying        : apr                                                   5/6"
  echo "    Verifying        : apr-util                                              6/6"
  echo ""
  echo "  Installed:"
  echo "    httpd-2.4.57-8.el9_4.x86_64"
  echo ""
  echo "  Complete!"
  echo


  # STEP 2: Enable and start httpd
  echo "  Step 2: Enable and start the httpd service."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo systemctl enable --now httpd" && "$cmd2" != "systemctl enable --now httpd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service."
  echo

  # STEP 3: Allow HTTP through the firewall
  echo "  Step 3: Allow HTTP service through the firewall."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo firewall-cmd --permanent --add-service=http" && "$cmd3" != "firewall-cmd --permanent --add-service=http" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  echo "  Reload the firewall rules:"
  read -p "$PROMPT" cmd3b
  echo
  if [[ "$cmd3b" != "sudo firewall-cmd --reload" && "$cmd3b" != "firewall-cmd --reload" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  # STEP 4: Create a test web page
  echo "  Step 4: Create a test page at /var/www/html/index.html."
  echo "  Write 'SELinux + httpd lab (165)' into /var/www/html/index.html"
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "echo 'SELinux + httpd lab (165)' | sudo tee /var/www/html/index.html" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  SELinux + httpd lab (165)"
  echo

  # STEP 5: Verify local access with curl
  echo "  Step 5: Verify Apache is serving content using curl."
  echo "  Type the command to request http://localhost/ with curl:"
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "curl http://localhost/" && "$cmd5" != "curl -s http://localhost/" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  SELinux + httpd lab (165)"
  echo

  # STEP 6: Move web root to /webdata and update config
  echo "  Step 6: Create the /webdata directory."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo mkdir -p /webdata" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  echo "  Move index.html from /var/www/html to /webdata:"
  read -p "$PROMPT" cmd6b
  echo
  if [[ "$cmd6b" != "sudo mv /var/www/html/index.html /webdata/index.html" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  echo "  Open the Apache config file to update DocumentRoot and Directory permissions."
  echo "  Use the path /etc/httpd/conf/httpd.conf (vim or nano with sudo):"
  read -p "$PROMPT" cmd6c
  echo
  if [[ "$cmd6c" != "sudo vim /etc/httpd/conf/httpd.conf" && "$cmd6c" != "sudo nano /etc/httpd/conf/httpd.conf" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  DocumentRoot \"/webdata\""
  echo "  <Directory \"/webdata\">"
  echo "      AllowOverride None"
  echo "      Require all granted"
  echo "  </Directory>"
  echo
  echo "  Restart httpd to apply the config change:"
  read -p "$PROMPT" cmd6d
  echo
  if [[ "$cmd6d" != "sudo systemctl restart httpd" && "$cmd6d" != "systemctl restart httpd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  # STEP 7: Confirm failure + check audit log
  echo "  Step 7: Confirm access fails and check for SELinux denials."
  echo "  Fetch only HTTP headers from http://localhost/"
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "curl -I http://localhost/" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  HTTP/1.1 403 Forbidden"
  echo "  Server: Apache"
  echo
  echo "  View the last 5 lines of /var/log/audit/audit.log (use sudo if needed):"
  read -p "$PROMPT" cmd7b
  echo
  if [[ "$cmd7b" != "sudo tail -n 5 /var/log/audit/audit.log" && "$cmd7b" != "tail -n 5 /var/log/audit/audit.log" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  type=AVC msg=audit(1708771602.411:218): avc:  denied  { read } for  pid=1824 comm=\"httpd\" name=\"index.html\" dev=\"sda2\" ino=2516587 scontext=system_u:system_r:httpd_t:s0 tcontext=unconfined_u:object_r:default_t:s0 tclass=file"
  echo

  # STEP 8: Fix labeling with semanage + restorecon
  echo "  Step 8: Fix SELinux labeling for /webdata using semanage fcontext and restorecon."
  echo "  Add an SELinux file context rule labeling /webdata as httpd_sys_content_t:"
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo semanage fcontext -a -t httpd_sys_content_t '/webdata(/.*)?'" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  echo "  Apply the new contexts recursively to /webdata:"
  read -p "$PROMPT" cmd8b
  echo
  if [[ "$cmd8b" != "sudo restorecon -Rv /webdata" && "$cmd8b" != "restorecon -Rv /webdata" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  restorecon reset /webdata context unconfined_u:object_r:default_t:s0->unconfined_u:object_r:httpd_sys_content_t:s0"
  echo "  restorecon reset /webdata/index.html context unconfined_u:object_r:default_t:s0->unconfined_u:object_r:httpd_sys_content_t:s0"
  echo

  # STEP 9: Verify fix + enable boolean for UserDir
  echo "  Step 9: Verify access is restored and enable the SELinux boolean for UserDir content."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "curl http://localhost/" && "$cmd9" != "curl -s http://localhost/" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  SELinux + httpd lab (165)"
  echo
  echo "  Permanently enable the httpd_enable_homedirs boolean:"
  read -p "$PROMPT" cmd9b
  echo
  if [[ "$cmd9b" != "sudo setsebool -P httpd_enable_homedirs on" && "$cmd9b" != "setsebool -P httpd_enable_homedirs on" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  echo "  Create your directory (public_html) in your home folder:"
  read -p "$PROMPT" cmd9c
  echo
  if [[ "$cmd9c" != "mkdir -p ~/public_html" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  echo "  Type the command to create an index.html in ~/public_html:"
  read -p "$PROMPT" cmd9d
  echo
  if [[ "$cmd9d" != "echo 'UserDir works (SELinux boolean enabled)' > ~/public_html/index.html" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  echo "  Restore SELinux contexts on /home/examuser/public_html:"
  read -p "$PROMPT" cmd9e
  echo
  if [[ "$cmd9e" != "sudo restorecon -Rv /home/examuser/public_html" && "$cmd9e" != "restorecon -Rv /home/examuser/public_html" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  restorecon reset /home/examuser/public_html context unconfined_u:object_r:default_t:s0->unconfined_u:object_r:httpd_user_content_t:s0"
  echo "  restorecon reset /home/examuser/public_html/index.html context unconfined_u:object_r:default_t:s0->unconfined_u:object_r:httpd_user_content_t:s0"
  echo

  # STEP 10: Validate contexts + boolean state
  echo "  Step 10: Validate SELinux contexts and confirm boolean state for /webdata and its index.html:"
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "ls -Z /webdata /webdata/index.html" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  unconfined_u:object_r:httpd_sys_content_t:s0 /webdata"
  echo "  unconfined_u:object_r:httpd_sys_content_t:s0 /webdata/index.html"
  echo
  echo "  Type the command to display the state of httpd_enable_homedirs:"
  read -p "$PROMPT" cmd10b
  echo
  if [[ "$cmd10b" != "getsebool httpd_enable_homedirs" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  httpd_enable_homedirs --> on"
  echo

  print_success "Well done."
  print_info "You demonstrated how SELinux policy directly controls Apache behavior by diagnosing"
  print_info AVC denials, correcting file contexts, and enabling the proper boolean to restore secure web access.""
  print_info "You earned $LAB_XP XP for completing this lab."
  award_xp $LAB_XP

  XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON"); export XP; export LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've completed this lab $completion_count time(s)."
  echo
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " choice
  [[ "$choice" == "2" ]] && exit 0
done