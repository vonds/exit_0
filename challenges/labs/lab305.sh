#!/bin/bash

# Lab 305: Scheduling Jobs with 'at' – Objective 107.2

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 305"
LAB_ID="lab305"
LAB_XP=31200
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

PROMPT="student@lab305:~$ > "

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "Objective 107.2 — Scheduling Jobs with 'at'"
  center_text "Focus: Scheduling, viewing, removing jobs, and managing access control."
  echo
  center_text "Press Enter to begin."
  read _
  draw_lab_ui

  echo "  Step 1: Schedule a job to run immediately using 'at now'."
  read -p "  $PROMPT" cmd1
  echo
  if [[ "$cmd1" != "at now" ]]; then
    print_error "Incorrect. Use: at now"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  at> df -h"
  echo "  at> <EOT>"
  echo "  job 7 at Tue Feb 18 12:05:00 2025"
  echo

  echo "  Step 2: Schedule a job to run one hour from now."
  read -p "  $PROMPT" cmd2
  echo
  if [[ "$cmd2" != "at now + 1 hour" ]]; then
    print_error "Incorrect. Use: at now + 1 hour"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  at> echo 'Backup completed' > /home/student/backup.log"
  echo "  at> <EOT>"
  echo "  job 8 at Tue Feb 18 13:05:00 2025"
  echo

  echo "  Step 3: Schedule a job using a specific time format (e.g., 13:30)."
  read -p "  $PROMPT" cmd3
  echo
  if [[ "$cmd3" != "at 13:30" ]]; then
    print_error "Incorrect. Use: at 13:30"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  at> echo 'System scan initiated' >> /home/student/system.log"
  echo "  at> <EOT>"
  echo "  job 9 at Tue Feb 18 13:30:00 2025"
  echo

  echo "  Step 4: List all pending 'at' jobs waiting to run."
  read -p "  $PROMPT" cmd4
  echo
  if [[ "$cmd4" != "atq" && "$cmd4" != "at -l" ]]; then
    print_error "Incorrect. Use: atq or at -l"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  7  Tue Feb 18 12:05:00 2025 a student"
  echo "  8  Tue Feb 18 13:05:00 2025 a student"
  echo "  9  Tue Feb 18 13:30:00 2025 a student"
  echo

  echo "  Step 5: Remove job number 8 from the queue."
  read -p "  $PROMPT" cmd5
  echo
  if [[ "$cmd5" != "atrm 8" && "$cmd5" != "at -d 8" ]]; then
    print_error "Incorrect. Use: atrm 8  (or)  at -d 8"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  job 8 removed"
  echo

  echo "  Step 6: Verify that job 8 has been deleted."
  read -p "  $PROMPT" cmd6
  echo
  if [[ "$cmd6" != "atq" && "$cmd6" != "at -l" ]]; then
    print_error "Incorrect. Use: atq or at -l"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  7  Tue Feb 18 12:05:00 2025 a student"
  echo "  9  Tue Feb 18 13:30:00 2025 a student"
  echo

  echo "  Step 7: Display which access control files exist for the 'at' scheduler."
  read -p "  $PROMPT" cmd7
  echo
  if [[ "$cmd7" != "ls /etc/at.*" && "$cmd7" != "ls /etc/at.* 2>/dev/null" ]]; then
    print_error "Incorrect. Use: ls /etc/at.*"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  /etc/at.deny"
  echo

  echo "  Step 8: View the contents of /etc/at.deny."
  read -p "  $PROMPT" cmd8
  echo
  if [[ "$cmd8" != "cat /etc/at.deny" ]]; then
    print_error "Incorrect. Use: cat /etc/at.deny"
    read -p "Press Enter to continue..." _
    continue
  fi
  # Many systems ship an empty /etc/at.deny; print a blank line to simulate
  echo "  "
  echo

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
