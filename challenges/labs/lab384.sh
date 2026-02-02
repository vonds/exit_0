#!/bin/bash

# Lab 384: SELinux Troubleshooting — Service Fails Only When Enforcing (4–8 prompts)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 384: SELinux Troubleshooting — Enforcing-Only Service Failure"
LAB_ID="lab384"
LAB_XP=38400
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@rhel-lab384:~$ "

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
  center_text "A web service called webapp fails ONLY when SELinux is Enforcing."
  center_text "Users report: 'The app works after we set SELinux to Permissive.'"
  center_text "You must prove SELinux is the trigger, locate the AVC denial,"
  center_text "fix the labeling correctly, return to Enforcing, and verify the app."
  echo
  center_text "Verification target: http://localhost:8080"
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Confirm SELinux mode
  echo "  Step 1: Confirm whether SELinux is Enforcing or Permissive."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "getenforce" && \
        "$cmd1" != "sestatus" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd1" == "getenforce" ]]; then
    echo "  Enforcing"
  else
    echo "  SELinux status:                 enabled"
    echo "  Current mode:                   enforcing"
    echo "  Mode from config file:          enforcing"
  fi
  echo

  # STEP 2: Show the failure when Enforcing
  echo "  Step 2: Check the service state and confirm it is failing."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "systemctl status webapp" && \
        "$cmd2" != "sudo systemctl status webapp" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  ● webapp.service - Internal WebApp"
  echo "       Loaded: loaded (/etc/systemd/system/webapp.service; enabled)"
  echo "       Active: failed (Result: exit-code)"
  echo "      Process: 1842 ExecStart=/usr/local/bin/webapp (code=exited, status=13)"
  echo "  Feb 01 21:58:12 rhel-lab384 webapp[1842]: ERROR: Permission denied opening /var/www/webapp/index.html"
  echo "  Feb 01 21:58:12 rhel-lab384 systemd[1]: webapp.service: Main process exited, code=exited, status=13"
  echo "  Feb 01 21:58:12 rhel-lab384 systemd[1]: webapp.service: Failed with result 'exit-code'."
  echo

  # STEP 3: Prove it succeeds when Permissive
  echo "  Step 3: Temporarily set SELinux to Permissive and restart the service to confirm the symptom."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo setenforce 0" && \
        "$cmd3" != "setenforce 0" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (SELinux set to Permissive)"
  echo
  echo "  Now restart the service."
  read -p "$PROMPT" cmd3b
  echo
  if [[ "$cmd3b" != "sudo systemctl restart webapp" && \
        "$cmd3b" != "systemctl restart webapp" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (service restarted)"
  echo
  echo "  Confirm it is running now."
  read -p "$PROMPT" cmd3c
  echo
  if [[ "$cmd3c" != "systemctl status webapp" && \
        "$cmd3c" != "sudo systemctl status webapp" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  ● webapp.service - Internal WebApp"
  echo "       Loaded: loaded (/etc/systemd/system/webapp.service; enabled)"
  echo "       Active: active (running)"
  echo "       Main PID: 1910 (webapp)"
  echo "        Tasks: 4"
  echo
  echo

  # STEP 4: Find the AVC denial
  echo "  Step 4: Find the SELinux denial (AVC) that explains why the service fails in Enforcing."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo ausearch -m avc -ts recent" && \
        "$cmd4" != "ausearch -m avc -ts recent" && \
        "$cmd4" != "sudo journalctl -t setroubleshoot --since \"10 minutes ago\"" && \
        "$cmd4" != "journalctl -t setroubleshoot --since \"10 minutes ago\"" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd4" == *"ausearch -m avc"* ]]; then
    echo "  ----"
    echo "  time->Sun Feb  1 21:58:12 2026"
    echo "  type=AVC msg=audit(1738465092.412:811): avc:  denied  { read } for  pid=1842 comm=\"webapp\""
    echo "      name=\"index.html\" dev=\"dm-0\" ino=1049382 scontext=system_u:system_r:webapp_t:s0"
    echo "      tcontext=unconfined_u:object_r:default_t:s0 tclass=file permissive=0"
    echo "  ----"
  else
    echo "  Feb 01 21:58:12 rhel-lab384 setroubleshoot[2055]: SELinux is preventing /usr/local/bin/webapp from read access on the file /var/www/webapp/index.html."
    echo "  Feb 01 21:58:12 rhel-lab384 setroubleshoot[2055]: *****  Plugin restorecon (99.5 confidence) suggests   ************************"
    echo "  Feb 01 21:58:12 rhel-lab384 setroubleshoot[2055]: Restore file context with: restorecon -Rv /var/www/webapp"
  fi
  echo

  # STEP 5: Fix the labeling properly
  echo "  Step 5: Fix the SELinux file context for the web content under /var/www/webapp."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo restorecon -Rv /var/www/webapp" && \
        "$cmd5" != "restorecon -Rv /var/www/webapp" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  restorecon reset /var/www/webapp context unconfined_u:object_r:default_t:s0->system_u:object_r:httpd_sys_content_t:s0"
  echo "  restorecon reset /var/www/webapp/index.html context unconfined_u:object_r:default_t:s0->system_u:object_r:httpd_sys_content_t:s0"
  echo

  # STEP 6: Return to Enforcing and verify service + endpoint
  echo "  Step 6: Return SELinux to Enforcing, restart the service, and verify the app responds."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo setenforce 1" && \
        "$cmd6" != "setenforce 1" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (SELinux set to Enforcing)"
  echo
  echo "  Restart the service."
  read -p "$PROMPT" cmd6b
  echo
  if [[ "$cmd6b" != "sudo systemctl restart webapp" && \
        "$cmd6b" != "systemctl restart webapp" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (service restarted)"
  echo
  echo "  Verify the endpoint over HTTP."
  read -p "$PROMPT" cmd6c
  echo
  if [[ "$cmd6c" != "curl -I http://localhost:8080" && \
        "$cmd6c" != "curl -I http://localhost:8080/" && \
        "$cmd6c" != "curl -sS http://localhost:8080 | head" && \
        "$cmd6c" != "curl -sS http://localhost:8080/ | head" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd6c" == "curl -I"* ]]; then
    echo "  HTTP/1.1 200 OK"
    echo "  Content-Type: text/html; charset=UTF-8"
    echo "  Server: webapp"
  else
    echo "  <html>"
    echo "  <head><title>WebApp</title></head>"
    echo "  <body>OK</body>"
    echo "  </html>"
  fi
  echo

  print_success "Nice work."
  print_info "You resolved an enforcing-only outage by:"
  print_info "- confirming SELinux mode and service failure"
  print_info "- proving permissive mode masks the issue"
  print_info "- locating the AVC denial for the blocked access"
  print_info "- correcting the file labeling with restorecon"
  print_info "- returning to Enforcing and validating the app"
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
