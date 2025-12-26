#!/bin/bash

# Lab 361: RHEL Troubleshooting — identify why a cron job never runs (wrong permissions + not executable)
# RHCSA focus: verifying cron service status, inspecting cron entries, checking file ownership/permissions,
# confirming script paths and environment, testing execution, fixing permissions, and verifying cron runs.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 361"
LAB_ID="lab361"
LAB_XP=36100
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

PROMPT="student@lab361:~$ > "

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "RHEL Troubleshooting — a scheduled job should write a heartbeat file every minute, but it never appears."
  center_text "Interactive: diagnose why the cron job never runs and restore normal execution."
  echo
  center_text "Press Enter to begin."
  read _
  draw_lab_ui

  # STEP 1
  echo "  Step 1: Confirm the cron service is running."
  read -p "  $PROMPT" cmd1
  if [[ "$cmd1" != "systemctl status crond" && "$cmd1" != "sudo systemctl status crond" ]]; then
    print_error "Incorrect. Use: systemctl status crond"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  ● crond.service - Command Scheduler"
  echo "     Loaded: loaded (/usr/lib/systemd/system/crond.service; enabled; vendor preset: enabled)"
  echo "     Active: active (running) since Fri 2025-12-21 13:10:12 EST; 3min ago"
  echo "       Docs: man:crond(8)"
  echo "  Main PID: 1023 (crond)"

  # STEP 2
  echo
  echo "  Step 2: Check the user's crontab to see what is scheduled."
  read -p "  $PROMPT" cmd2
  if [[ "$cmd2" != "sudo crontab -u devstudent -l" ]]; then
    print_error "Incorrect. Use: sudo crontab -u devstudent -l"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  * * * * * /opt/heartbeat/heartbeat.sh"

  # STEP 3
  echo
  echo "  Step 3: Verify the target script exists and inspect its permissions."
  read -p "  $PROMPT" cmd3
  if [[ "$cmd3" != "ls -l /opt/heartbeat/heartbeat.sh" && "$cmd3" != "sudo ls -l /opt/heartbeat/heartbeat.sh" ]]; then
    print_error "Incorrect. Use: ls -l /opt/heartbeat/heartbeat.sh"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  -rw-r--r--. 1 root root 132 Dec 21 13:01 /opt/heartbeat/heartbeat.sh"

  # STEP 4
  echo
  echo "  Step 4: Try running the script as the user to reproduce the failure."
  read -p "  $PROMPT" cmd4
  if [[ "$cmd4" != "sudo -u devstudent /opt/heartbeat/heartbeat.sh" ]]; then
    print_error "Incorrect. Use: sudo -u devstudent /opt/heartbeat/heartbeat.sh"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  sudo: /opt/heartbeat/heartbeat.sh: command not found"

  # STEP 5
  echo
  echo "  Step 5: Confirm whether the script is executable (and fix permissions if needed)."
  read -p "  $PROMPT" cmd5
  if [[ "$cmd5" != "sudo chmod +x /opt/heartbeat/heartbeat.sh" ]]; then
    print_error "Incorrect. Use: sudo chmod +x /opt/heartbeat/heartbeat.sh"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  "

  # STEP 6
  echo
  echo "  Step 6: Inspect the script to confirm it uses absolute paths and writes output somewhere deterministic."
  read -p "  $PROMPT" cmd6
  if [[ "$cmd6" != "sudo head -n 10 /opt/heartbeat/heartbeat.sh" ]]; then
    print_error "Incorrect. Use: sudo head -n 10 /opt/heartbeat/heartbeat.sh"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  #!/bin/bash"
  echo "  /usr/bin/date --iso-8601=seconds > /var/log/heartbeat.log"

  # STEP 7
  echo
  echo "  Step 7: Run the script as the user again (it should now execute)."
  read -p "  $PROMPT" cmd7
  if [[ "$cmd7" != "sudo -u devstudent /opt/heartbeat/heartbeat.sh" ]]; then
    print_error "Incorrect. Use: sudo -u devstudent /opt/heartbeat/heartbeat.sh"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  /usr/bin/date: cannot open '/var/log/heartbeat.log' for writing: Permission denied"

  # STEP 8
  echo
  echo "  Step 8: Fix the logging location so the cron job can write successfully (use a directory the user owns)."
  read -p "  $PROMPT" cmd8
  if [[ "$cmd8" != "sudo sed -i 's#/var/log/heartbeat.log#/home/devstudent/heartbeat.log#' /opt/heartbeat/heartbeat.sh" ]]; then
    print_error "Incorrect. Use: sudo sed -i 's#/var/log/heartbeat.log#/home/devstudent/heartbeat.log#' /opt/heartbeat/heartbeat.sh"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  "

  # STEP 9
  echo
  echo "  Step 9: Run the script as the user and confirm it writes the log."
  read -p "  $PROMPT" cmd9
  if [[ "$cmd9" != "sudo -u devstudent /opt/heartbeat/heartbeat.sh" ]]; then
    print_error "Incorrect. Use: sudo -u devstudent /opt/heartbeat/heartbeat.sh"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  "

  # STEP 10
  echo
  echo "  Step 10: Verify the log exists and contains a timestamp."
  read -p "  $PROMPT" cmd10
  if [[ "$cmd10" != "tail -n 1 /home/devstudent/heartbeat.log" && "$cmd10" != "sudo tail -n 1 /home/devstudent/heartbeat.log" ]]; then
    print_error "Incorrect. Use: tail -n 1 /home/devstudent/heartbeat.log"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  2025-12-21T13:14:55-05:00"

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
