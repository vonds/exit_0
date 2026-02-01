#!/bin/bash

# Lab 510: Start/Stop Services + Enable/Disable at Boot (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 510: Manage systemd Services (Start/Stop/Enable)"
LAB_ID="lab510"
LAB_XP=51000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab510:~$ "

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
  center_text "A server is being prepared for production. You must manage services using systemctl."
  center_text "You will start/stop/restart services, enable/disable them at boot, verify status,"
  center_text "list enabled services, and use journalctl for troubleshooting."
  echo
  center_text "Targets:"
  center_text "- crond (baseline service control)"
  center_text "- sshd (verify enable/active state)"
  center_text "- httpd (service start/stop/restart + logs)"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Start the httpd service."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "sudo systemctl start httpd" ]]; then
    print_error "Incorrect. Use: sudo systemctl start httpd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 2: Verify httpd is active (running) using systemctl status with no pager."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo systemctl status httpd --no-pager" ]]; then
    print_error "Incorrect. Use: sudo systemctl status httpd --no-pager"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  ● httpd.service - The Apache HTTP Server"
  echo "     Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; vendor preset: disabled)"
  echo "     Active: active (running)"
  echo

  echo "  Step 3: Enable httpd to start automatically at boot."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo systemctl enable httpd" ]]; then
    print_error "Incorrect. Use: sudo systemctl enable httpd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service."
  echo

  echo "  Step 4: Confirm httpd is enabled."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "systemctl is-enabled httpd" && "$cmd4" != "sudo systemctl is-enabled httpd" ]]; then
    print_error "Incorrect. Use: systemctl is-enabled httpd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  enabled"
  echo

  echo "  Step 5: Restart httpd in a single step."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo systemctl restart httpd" ]]; then
    print_error "Incorrect. Use: sudo systemctl restart httpd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 6: Stop the httpd service."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo systemctl stop httpd" ]]; then
    print_error "Incorrect. Use: sudo systemctl stop httpd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 7: Verify httpd is inactive (dead)."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo systemctl status httpd --no-pager" ]]; then
    print_error "Incorrect. Use: sudo systemctl status httpd --no-pager"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  ● httpd.service - The Apache HTTP Server"
  echo "     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)"
  echo "     Active: inactive (dead)"
  echo

  echo "  Step 8: Disable httpd so it does not start automatically at boot."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo systemctl disable httpd" ]]; then
    print_error "Incorrect. Use: sudo systemctl disable httpd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Removed /etc/systemd/system/multi-user.target.wants/httpd.service."
  echo

  echo "  Step 9: Confirm httpd is disabled."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "systemctl is-enabled httpd" && "$cmd9" != "sudo systemctl is-enabled httpd" ]]; then
    print_error "Incorrect. Use: systemctl is-enabled httpd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  disabled"
  echo

  echo "  Step 10: Start the crond service."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "sudo systemctl start crond" ]]; then
    print_error "Incorrect. Use: sudo systemctl start crond"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 11: Enable crond to start at boot."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "sudo systemctl enable crond" ]]; then
    print_error "Incorrect. Use: sudo systemctl enable crond"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Created symlink /etc/systemd/system/multi-user.target.wants/crond.service → /usr/lib/systemd/system/crond.service."
  echo

  echo "  Step 12: Verify crond is active and enabled."
  read -p "$PROMPT" cmd12
  echo
  if [[ "$cmd12" != "sudo systemctl status crond --no-pager" ]]; then
    print_error "Incorrect. Use: sudo systemctl status crond --no-pager"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  ● crond.service - Command Scheduler"
  echo "     Loaded: loaded (/usr/lib/systemd/system/crond.service; enabled; vendor preset: enabled)"
  echo "     Active: active (running)"
  echo

  echo "  Step 13: List all enabled services (unit files) on the system."
  read -p "$PROMPT" cmd13
  echo
  if [[ "$cmd13" != "systemctl list-unit-files --type=service --state=enabled" ]]; then
    print_error "Incorrect. Use: systemctl list-unit-files --type=service --state=enabled"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  UNIT FILE                 STATE   VENDOR PRESET"
  echo "  crond.service              enabled enabled"
  echo "  sshd.service               enabled enabled"
  echo "  ..."
  echo

  echo "  Step 14: Check logs for httpd using journalctl (last 10 lines)."
  read -p "$PROMPT" cmd14
  echo
  if [[ "$cmd14" != "sudo journalctl -u httpd -n 10 --no-pager" ]]; then
    print_error "Incorrect. Use: sudo journalctl -u httpd -n 10 --no-pager"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  $(date '+%b %e %H:%M:%S') rhel-lab510 systemd[1]: Starting The Apache HTTP Server..."
  echo "  $(date '+%b %e %H:%M:%S') rhel-lab510 httpd[2310]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name"
  echo "  $(date '+%b %e %H:%M:%S') rhel-lab510 systemd[1]: Started The Apache HTTP Server."
  echo

  echo "  Step 15: Verify sshd is enabled to start at boot."
  read -p "$PROMPT" cmd15
  echo
  if [[ "$cmd15" != "systemctl is-enabled sshd" && "$cmd15" != "sudo systemctl is-enabled sshd" ]]; then
    print_error "Incorrect. Use: systemctl is-enabled sshd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  enabled"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- started/stopped/restarted services with systemctl"
  print_info "- enabled/disabled services at boot and verified with is-enabled"
  print_info "- checked service state using status --no-pager"
  print_info "- listed enabled unit files"
  print_info "- used journalctl -u for service troubleshooting"
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
