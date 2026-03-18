#!/bin/bash

# Lab 541G: Schedule Tasks with systemd Timer Units (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 541G: Schedule Tasks with systemd Timers"
LAB_ID="lab541g"
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
  center_text "ServerA must run a periodic system check using systemd timers."
  center_text "Create a script that logs the current date, then configure"
  center_text "a systemd service and timer so the script runs every minute."
  echo

  center_text "Requirements:"
  center_text "- Script: /usr/local/bin/system-check.sh"
  center_text "- Log file: /var/log/system-check.log"
  center_text "- Timer frequency: every 1 minute"
  echo

  center_text "Press Enter to begin..."
  read _
  draw_lab_ui


  echo "  Step 1: Inspect the directory where local admin scripts are commonly stored."
  read -p "$PROMPT" cmd1
  echo

  if [[ "$cmd1" != "ls /usr/local/bin" ]]; then
    print_error "Incorrect. Use: ls /usr/local/bin"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 2: Create the system-check script that appends the current date to the log."
  read -p "$PROMPT" cmd2
  echo

  if [[ "$cmd2" != "echo 'date >> /var/log/system-check.log' | sudo tee /usr/local/bin/system-check.sh > /dev/null" ]]; then
    print_error "Incorrect."
    print_info "Use: echo 'date >> /var/log/system-check.log' | sudo tee /usr/local/bin/system-check.sh > /dev/null"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 3: Make the script executable."
  read -p "$PROMPT" cmd3
  echo

  if [[ "$cmd3" != "sudo chmod +x /usr/local/bin/system-check.sh" ]]; then
    print_error "Incorrect. Use: sudo chmod +x /usr/local/bin/system-check.sh"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 4: Verify the script exists and is executable."
  read -p "$PROMPT" cmd4
  echo

  if [[ "$cmd4" != "ls -l /usr/local/bin/system-check.sh" ]]; then
    print_error "Incorrect. Use: ls -l /usr/local/bin/system-check.sh"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  -rwxr-xr-x 1 root root 31 Mar 14 10:55 /usr/local/bin/system-check.sh"
  echo


  echo "  Step 5: Create the systemd service unit that runs the script."
  read -p "$PROMPT" cmd5
  echo

  if [[ "$cmd5" != "echo -e '[Unit]\nDescription=System Check\n\n[Service]\nType=oneshot\nExecStart=/usr/local/bin/system-check.sh' | sudo tee /etc/systemd/system/system-check.service > /dev/null" ]]; then
    print_error "Incorrect."
    print_info "Create the service unit using tee."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 6: Verify the new service unit file."
  read -p "$PROMPT" cmd6
  echo

  if [[ "$cmd6" != "cat /etc/systemd/system/system-check.service" ]]; then
    print_error "Incorrect. Use: cat /etc/systemd/system/system-check.service"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "[Unit]"
  echo "Description=System Check"
  echo
  echo "[Service]"
  echo "Type=oneshot"
  echo "ExecStart=/usr/local/bin/system-check.sh"
  echo


  echo "  Step 7: Create the systemd timer unit that runs every minute."
  read -p "$PROMPT" cmd7
  echo

  if [[ "$cmd7" != "echo -e '[Unit]\nDescription=Run system check every minute\n\n[Timer]\nOnBootSec=1min\nOnUnitActiveSec=1min\n\n[Install]\nWantedBy=timers.target' | sudo tee /etc/systemd/system/system-check.timer > /dev/null" ]]; then
    print_error "Incorrect."
    print_info "Create the timer unit using tee."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 8: Reload systemd so it detects the new unit files."
  read -p "$PROMPT" cmd8
  echo

  if [[ "$cmd8" != "sudo systemctl daemon-reload" ]]; then
    print_error "Incorrect. Use: sudo systemctl daemon-reload"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 9: Enable and start the timer."
  read -p "$PROMPT" cmd9
  echo

  if [[ "$cmd9" != "sudo systemctl enable --now system-check.timer" ]]; then
    print_error "Incorrect. Use: sudo systemctl enable --now system-check.timer"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  Created symlink /etc/systemd/system/timers.target.wants/system-check.timer → /etc/systemd/system/system-check.timer."
  echo


  echo "  Step 10: Verify the timer is active."
  read -p "$PROMPT" cmd10
  echo

  if [[ "$cmd10" != "systemctl list-timers --all" ]]; then
    print_error "Incorrect. Use: systemctl list-timers --all"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  NEXT                        LEFT  LAST PASSED UNIT               ACTIVATES"
  echo "  Mon 2026-03-14 11:00:00 EDT  50s   n/a  n/a    system-check.timer system-check.service"
  echo


  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- created a system check script"
  print_info "- created a systemd service unit"
  print_info "- created a systemd timer unit"
  print_info "- reloaded systemd"
  print_info "- enabled and started the timer"
  print_info "- verified the scheduled task"
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