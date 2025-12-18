#!/bin/bash

# Lab 306: Scheduling User Jobs with Cron – Objective 107.2
# LPIC-1 focus: user crontab edit/list/remove, environment lines, field order, spool location.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 306"
LAB_ID="lab306"
LAB_XP=33800
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

PROMPT="student@lab306:~$ > "

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "Objective 107.2 — Scheduling User Jobs with Cron"
  center_text "Interactive: edit, add entry, list, inspect spool, remove, verify."
  echo
  center_text "Press Enter to begin."
  read _
  draw_lab_ui

  # STEP 1: Open user crontab editor (no output in reality)
  echo "  Step 1: Open your personal cron table for editing."
  read -p "  $PROMPT" cmd1
  if [[ "$cmd1" != "crontab -e" ]]; then
    print_error "Incorrect. Try again."
    read -p "Press Enter to continue..." _
    continue
  fi

  # STEP 2: Add environment line for shell (editor input; no output)
  echo
  echo "  Step 2: In the editor, set the shell used by cron for this table."
  echo "          Type the exact environment line you would add."
  read -p "  $PROMPT" cmd2
  if [[ "$cmd2" != "SHELL=/bin/bash" ]]; then
    print_error "Incorrect. Try again."
    read -p "Press Enter to continue..." _
    continue
  fi

  # STEP 3: Add environment line to direct mail output (editor input; no output)
  echo
  echo "  Step 3: In the editor, direct job output to this user’s mailbox."
  read -p "  $PROMPT" cmd3
  if [[ "$cmd3" != "MAILTO=student" ]]; then
    print_error "Incorrect. Try again."
    read -p "Press Enter to continue..." _
    continue
  fi

  # STEP 4: Add a daily 14:15 job writing df output to ~/df.out (no output)
  echo
  echo "  Step 4: Add a cron entry that runs daily at 14:15 and writes disk usage"
  echo "          to /home/student/df.out using an absolute command path."
  read -p "  $PROMPT" cmd4
  if [[ "$cmd4" != "15 14 * * * /bin/df -h > /home/student/df.out" ]]; then
    print_error "Incorrect. Review field order: minute hour day month day-of-week command."
    read -p "Press Enter to continue..." _
    continue
  fi

  # STEP 5: List current user crontab (realistic output)
  echo
  echo "  Step 5: List all entries in your user crontab."
  read -p "  $PROMPT" cmd5
  if [[ "$cmd5" != "crontab -l" ]]; then
    print_error "Incorrect. Use: crontab -l"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo
  echo "  SHELL=/bin/bash"
  echo "  MAILTO=student"
  echo "  15 14 * * * /bin/df -h > /home/student/df.out"

  # STEP 6: Show spool directory containing user crontabs (realistic output: filenames only)
  echo
  echo "  Step 6: List the directory that stores per-user cron tables on this system."
  echo "          Use the canonical path for your distro."
  read -p "  $PROMPT" cmd6
  if [[ "$cmd6" != "ls /var/spool/cron" && "$cmd6" != "ls /var/spool/cron/" && "$cmd6" != "ls /var/spool/cron/crontabs" && "$cmd6" != "ls /var/spool/cron/crontabs/" ]]; then
    print_error "Incorrect. Try a valid cron spool path."
    read -p "Press Enter to continue..." _
    continue
  fi
  # realistic filenames only (no path prefixes)
  echo
  echo "  student"

  # STEP 7: Cat the stored crontab file (realistic output: file contents)
  echo
  echo "  Step 7: Display your stored cron table file directly from the spool."
  read -p "  $PROMPT" cmd7
  if [[ "$cmd7" != "cat /var/spool/cron/student" && "$cmd7" != "cat /var/spool/cron/crontabs/student" ]]; then
    print_error "Incorrect. Use the correct absolute path to your stored crontab."
    read -p "Press Enter to continue..." _
    continue
  fi
  echo
  echo "  SHELL=/bin/bash"
  echo "  MAILTO=student"
  echo "  15 14 * * * /bin/df -h > /home/student/df.out"

  # STEP 8: Remove user crontab (no output)
  echo
  echo "  Step 8: Remove your user crontab entirely."
  read -p "  $PROMPT" cmd8
  if [[ "$cmd8" != "crontab -r" ]]; then
    print_error "Incorrect. Use: crontab -r"
    read -p "Press Enter to continue..." _
    continue
  fi
  # no output on success

  # STEP 9: Verify no crontab remains (realistic output)
  echo
  echo "  Step 9: Verify that your user has no cron entries remaining."
  read -p "  $PROMPT" cmd9
  if [[ "$cmd9" != "crontab -l" ]]; then
    print_error "Incorrect. Use: crontab -l"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo
  echo "  no crontab for student"

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
