#!/bin/bash

# Lab 351: RHEL Troubleshooting — SELinux + firewalld blocking httpd on port 8080
# RHEL focus: systemd service failure, httpd Listen directive, SELinux port labeling (semanage),
# and firewalld port allowance (firewall-cmd).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 351"
LAB_ID="lab351"
LAB_XP=35100
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"

[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

draw_lab_ui() {
  clear
  center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
  center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
  echo
  echo
}

record_lab_completion() {
  tmpfile=$(mktemp)
  jq --arg lab "$LAB_ID" '.[$lab] += 1 // 1' "$LAB_TRACK_FILE" > "$tmpfile" && mv "$tmpfile" "$LAB_TRACK_FILE"
}

get_lab_completion_count() {
  jq -r --arg lab "$LAB_ID" '.[$lab] // 0' "$LAB_TRACK_FILE"
}

PROMPT="student@lab351:~$ > "

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "RHEL Troubleshooting — httpd moved to TCP/8080 but the site is down."
  center_text "Interactive: diagnose systemd failure, fix SELinux port labeling, and open the firewall."
  echo
  center_text "Press Enter to begin."
  read _
  draw_lab_ui

  # STEP 1
  echo "  Step 1: Check the status of the web server service."
  read -p "  $PROMPT" cmd1
  if [[ "$cmd1" != "systemctl status httpd" && "$cmd1" != "sudo systemctl status httpd" ]]; then
    print_error "Incorrect. Use: systemctl status httpd"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "● httpd.service - The Apache HTTP Server"
  echo "     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)"
  echo "     Active: failed (Result: exit-code) since Fri 2025-12-19 14:12:07 EST; 8s ago"
  echo "       Docs: man:httpd.service(8)"
  echo "    Process: 2149 ExecStart=/usr/sbin/httpd \$OPTIONS -DFOREGROUND (code=exited, status=1/FAILURE)"
  echo "   Main PID: 2149 (code=exited, status=1/FAILURE)"
  echo ""
  echo "Dec 19 14:12:07 rhel-lab httpd[2149]: (13)Permission denied: AH00072: make_sock: could not bind to address [::]:8080"
  echo "Dec 19 14:12:07 rhel-lab httpd[2149]: (13)Permission denied: AH00072: make_sock: could not bind to address 0.0.0.0:8080"
  echo "Dec 19 14:12:07 rhel-lab httpd[2149]: AH00015: Unable to open logs"
  echo "Dec 19 14:12:07 rhel-lab systemd[1]: httpd.service: Main process exited, code=exited, status=1/FAILURE"
  echo "Dec 19 14:12:07 rhel-lab systemd[1]: httpd.service: Failed with result 'exit-code'."

  # STEP 2
  echo
  echo "  Step 2: Confirm which port Apache is configured to listen on."
  read -p "  $PROMPT" cmd2
  if [[ "$cmd2" != "grep -n '^Listen' /etc/httpd/conf/httpd.conf" && "$cmd2" != "sudo grep -n '^Listen' /etc/httpd/conf/httpd.conf" ]]; then
    print_error "Incorrect. Use: grep -n '^Listen' /etc/httpd/conf/httpd.conf"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "45:Listen 8080"

  # STEP 3
  echo
  echo "  Step 3: Check which TCP ports SELinux allows httpd to bind to."
  read -p "  $PROMPT" cmd3
  if [[ "$cmd3" != "semanage port -l | grep http_port_t" && "$cmd3" != "sudo semanage port -l | grep http_port_t" ]]; then
    print_error "Incorrect. Use: semanage port -l | grep http_port_t"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443"

  # STEP 4
  echo
  echo "  Step 4: Add TCP/8080 to the SELinux http_port_t type."
  read -p "  $PROMPT" cmd4
  if [[ "$cmd4" != "sudo semanage port -a -t http_port_t -p tcp 8080" && "$cmd4" != "semanage port -a -t http_port_t -p tcp 8080" ]]; then
    print_error "Incorrect. Use: sudo semanage port -a -t http_port_t -p tcp 8080"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "Added port tcp/8080 to type http_port_t."

  # STEP 5
  echo
  echo "  Step 5: Restart the web server service."
  read -p "  $PROMPT" cmd5
  if [[ "$cmd5" != "sudo systemctl restart httpd" && "$cmd5" != "systemctl restart httpd" ]]; then
    print_error "Incorrect. Use: sudo systemctl restart httpd"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "● httpd.service - The Apache HTTP Server"
  echo "     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)"
  echo "     Active: active (running) since Fri 2025-12-19 14:13:02 EST; 2s ago"
  echo "   Main PID: 2217 (httpd)"
  echo "     Status: \"Running, listening on: 0.0.0.0:8080\""

  # STEP 6
  echo
  echo "  Step 6: Check which ports are currently allowed through firewalld."
  read -p "  $PROMPT" cmd6
  if [[ "$cmd6" != "sudo firewall-cmd --list-ports" && "$cmd6" != "firewall-cmd --list-ports" ]]; then
    print_error "Incorrect. Use: sudo firewall-cmd --list-ports"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo ""

  # STEP 7
  echo
  echo "  Step 7: Permanently allow TCP/8080 through the firewall."
  read -p "  $PROMPT" cmd7
  if [[ "$cmd7" != "sudo firewall-cmd --permanent --add-port=8080/tcp" && "$cmd7" != "firewall-cmd --permanent --add-port=8080/tcp" ]]; then
    print_error "Incorrect. Use: sudo firewall-cmd --permanent --add-port=8080/tcp"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "success"

  # STEP 8
  echo
  echo "  Step 8: Reload firewalld to apply the permanent change."
  read -p "  $PROMPT" cmd8
  if [[ "$cmd8" != "sudo firewall-cmd --reload" && "$cmd8" != "firewall-cmd --reload" ]]; then
    print_error "Incorrect. Use: sudo firewall-cmd --reload"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "success"

  print_success "Excellent work!"
  print_info "You earned $LAB_XP XP for completing this lab!"
  award_xp $LAB_XP
  XP=$(jq '.XP' "$SAVE_JSON")
  LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
  export XP
  export LEVEL
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

  if [[ "$choice" == "2" ]]; then
    exit 0
  fi
done
