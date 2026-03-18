#!/bin/bash

# Lab 541ZA: Configure Apache to Run on a Non-Standard Port with SELinux and Firewall (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 541ZA: Apache on Non-Standard Port with SELinux"
LAB_ID="lab541za"
LAB_XP=54100
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@servera:~$ "

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
  center_text "The Apache web server must run on TCP port 82 instead of"
  center_text "the default port 80."
  echo
  center_text "Tasks:"
  center_text "- Configure Apache to listen on port 82"
  center_text "- Restart httpd (it will fail due to SELinux)"
  center_text "- Allow httpd to bind to TCP port 82 with SELinux"
  center_text "- Allow TCP port 82 through the firewall"
  center_text "- Restart the service successfully"
  echo

  center_text "Press Enter to begin..."
  read _
  draw_lab_ui


  echo "  Step 1: Modify Apache configuration to listen on port 82."
  read -p "$PROMPT" cmd1
  echo

  if [[ "$cmd1" != "sudo sed -i 's/^Listen 80/Listen 82/' /etc/httpd/conf/httpd.conf" ]]; then
    print_error "Incorrect."
    print_info "Use: sudo sed -i 's/^Listen 80/Listen 82/' /etc/httpd/conf/httpd.conf"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 2: Verify the Apache configuration now uses port 82."
  read -p "$PROMPT" cmd2
  echo

  if [[ "$cmd2" != "grep '^Listen' /etc/httpd/conf/httpd.conf" ]]; then
    print_error "Incorrect. Use: grep '^Listen' /etc/httpd/conf/httpd.conf"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Listen 82"
  echo


  echo "  Step 3: Attempt to restart the Apache service."
  read -p "$PROMPT" cmd3
  echo

  if [[ "$cmd3" != "sudo systemctl restart httpd" ]]; then
    print_error "Incorrect. Use: sudo systemctl restart httpd"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  Job for httpd.service failed because the control process exited with error code."
  echo


  echo "  Step 4: Allow Apache to bind to TCP port 82 using SELinux."
  read -p "$PROMPT" cmd4
  echo

  if [[ "$cmd4" != "sudo semanage port -a -t http_port_t -p tcp 82" ]]; then
    print_error "Incorrect."
    print_info "Use: sudo semanage port -a -t http_port_t -p tcp 82"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 5: Verify the SELinux port configuration."
  read -p "$PROMPT" cmd5
  echo

  if [[ "$cmd5" != "sudo semanage port -l | grep http_port_t" ]]; then
    print_error "Incorrect. Use: sudo semanage port -l | grep http_port_t"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  http_port_t  tcp  80, 81, 82, 443, 488, 8008, 8009, 8443"
  echo


  echo "  Step 6: Allow TCP port 82 through the firewall."
  read -p "$PROMPT" cmd6
  echo

  if [[ "$cmd6" != "sudo firewall-cmd --add-port=82/tcp --permanent" ]]; then
    print_error "Incorrect. Use: sudo firewall-cmd --add-port=82/tcp --permanent"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  success"
  echo


  echo "  Step 7: Reload the firewall to apply the new rule."
  read -p "$PROMPT" cmd7
  echo

  if [[ "$cmd7" != "sudo firewall-cmd --reload" ]]; then
    print_error "Incorrect. Use: sudo firewall-cmd --reload"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  success"
  echo


  echo "  Step 8: Restart the Apache service again."
  read -p "$PROMPT" cmd8
  echo

  if [[ "$cmd8" != "sudo systemctl restart httpd" ]]; then
    print_error "Incorrect. Use: sudo systemctl restart httpd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  [no output]"
  echo


  echo "  Step 9: Verify Apache is listening on port 82."
  read -p "$PROMPT" cmd9
  echo

  if [[ "$cmd9" != "ss -tlnp | grep 82" ]]; then
    print_error "Incorrect. Use: ss -tlnp | grep 82"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  LISTEN 0 511 *:82 *:* users:(('httpd',pid=1432,fd=4))"
  echo


  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- configured Apache to listen on a non-standard port"
  print_info "- diagnosed the service restart failure"
  print_info "- configured SELinux port labeling"
  print_info "- allowed traffic through the firewall"
  print_info "- restarted Apache successfully"
  print_info "You earned $LAB_XP XP."

  award_xp $LAB_XP
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