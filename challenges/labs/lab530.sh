#!/bin/bash

# Lab 530: Use SELinux Booleans to Modify System SELinux Settings (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 530: SELinux Booleans (RHCSA)"
LAB_ID="lab530"
LAB_XP=53000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab530:~$ "

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
  center_text "A web service needs a controlled exception in SELinux policy behavior."
  center_text "Instead of changing policy, you must use SELinux booleans."
  center_text "You will list booleans, toggle one temporarily, verify,"
  center_text "then set it persistently and confirm it survives a reboot conceptually."
  echo
  center_text "Targets:"
  center_text "- getsebool -a (list booleans)"
  center_text "- getsebool <name> (check one boolean)"
  center_text "- setsebool <name> on|off (temporary change)"
  center_text "- setsebool -P <name> on|off (persistent change)"
  center_text "- semanage boolean -l (list with descriptions)"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Confirm SELinux is enabled and note current mode."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "sestatus" ]]; then
    print_error "Incorrect. Use: sestatus"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  SELinux status:                 enabled"
  echo "  Current mode:                   enforcing"
  echo

  echo "  Step 2: List all SELinux booleans related to httpd."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo getsebool -a | grep httpd" ]]; then
    print_error "Incorrect. Use: sudo getsebool -a | grep httpd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  httpd_can_network_connect --> off"
  echo "  httpd_can_sendmail --> off"
  echo "  httpd_enable_cgi --> on"
  echo

  echo "  Step 3: Check the current state of httpd_can_network_connect."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "getsebool httpd_can_network_connect" ]]; then
    print_error "Incorrect. Use: getsebool httpd_can_network_connect"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  httpd_can_network_connect --> off"
  echo

  echo "  Step 4: Enable httpd_can_network_connect temporarily (no -P)."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo setsebool httpd_can_network_connect on" ]]; then
    print_error "Incorrect. Use: sudo setsebool httpd_can_network_connect on"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 5: Verify httpd_can_network_connect is now on."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "getsebool httpd_can_network_connect" ]]; then
    print_error "Incorrect. Use: getsebool httpd_can_network_connect"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  httpd_can_network_connect --> on"
  echo

  echo "  Step 6: Show boolean descriptions (use semanage) and confirm httpd_can_network_connect exists."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo semanage boolean -l | grep httpd_can_network_connect" ]]; then
    print_error "Incorrect. Use: sudo semanage boolean -l | grep httpd_can_network_connect"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  httpd_can_network_connect  (on ,  off)  Allow httpd to connect to the network"
  echo

  echo "  Step 7: Make httpd_can_network_connect persistent across reboots."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo setsebool -P httpd_can_network_connect on" ]]; then
    print_error "Incorrect. Use: sudo setsebool -P httpd_can_network_connect on"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 8: Verify the boolean is on (state check)."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "getsebool httpd_can_network_connect" ]]; then
    print_error "Incorrect. Use: getsebool httpd_can_network_connect"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  httpd_can_network_connect --> on"
  echo

  echo "  Step 9: Disable httpd_can_sendmail persistently (example hardening)."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo setsebool -P httpd_can_sendmail off" ]]; then
    print_error "Incorrect. Use: sudo setsebool -P httpd_can_sendmail off"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 10: Verify httpd_can_sendmail is off."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "getsebool httpd_can_sendmail" ]]; then
    print_error "Incorrect. Use: getsebool httpd_can_sendmail"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  httpd_can_sendmail --> off"
  echo

  echo "  Step 11: List FTP-related booleans (pattern search)."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "sudo getsebool -a | grep ftp" ]]; then
    print_error "Incorrect. Use: sudo getsebool -a | grep ftp"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  ftp_home_dir --> off"
  echo "  ftpd_anon_write --> off"
  echo "  ftpd_use_passive_mode --> on"
  echo

  echo "  Step 12: Explain persistence check: show how you would confirm after reboot."
  echo "          Type the command you would run after reboot to confirm the boolean is still on."
  read -p "$PROMPT" cmd12
  echo
  if [[ "$cmd12" != "getsebool httpd_can_network_connect" ]]; then
    print_error "Incorrect. Use: getsebool httpd_can_network_connect"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  httpd_can_network_connect --> on"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- listed and filtered SELinux booleans"
  print_info "- toggled a boolean temporarily with setsebool"
  print_info "- made a boolean persistent using setsebool -P"
  print_info "- verified boolean state with getsebool"
  print_info "- used semanage boolean -l to view descriptions"
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
