#!/bin/bash

# Lab 467: RHEL Scheduling — at + cron + anacron (Manual Entry Practice)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 467: at + cron + anacron (Manual Entries)"
LAB_ID="lab467"
LAB_XP=46700
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"

[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@rhel-lab467:~$ "

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

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "Scenario:"
  center_text "This system has leftover scheduled jobs and missing maintenance automation."
  center_text "You must clean up at jobs, then manually AUTHOR cron/anacron entries."
  echo
  center_text "Requirements (you must type the schedule lines yourself):"
  center_text "- View at queue and remove job 1"
  center_text "- Root cron: daily 21:30 touch test_passed"
  center_text "- Root cron: monthly 1st 00:00 touch monthly"
  center_text "- Root cron: weekly Sunday 11:00 touch weekly"
  center_text "- Anacron: 10 days, 5 min delay, job=db_cleanup, touch /root/anacron_created_this"
  center_text "- student cron: Sundays 06:00 and 23:00 sudo systemctl restart nginx"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  # STEP 1: View at queue (CHANGED: no redirect)
  echo "  Step 1: View the current at job queue."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "atq" && \
        "$cmd1" != "sudo atq" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  1\tThu Jan 15 06:30:00 2026 a student"
  echo

  # STEP 2: Remove at job 1 (UNCHANGED)
  echo "  Step 2: Remove at job with ID 1."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "atrm 1" && \
        "$cmd2" != "sudo atrm 1" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # STEP 3: Open root crontab ONCE
  echo "  Step 3: Open ROOT crontab editor."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo crontab -e" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (editor opened)"
  echo

  # STEP 4: User manually types cron line 1
  echo "  Step 4: In that editor, type the cron entry for:"
  echo "          Daily at 21:30 → /usr/bin/touch test_passed"
  read -p "  (type the exact cron line): " cron1
  if [[ "$cron1" != "30 21 * * * /usr/bin/touch test_passed" ]]; then
    print_error "Incorrect cron entry."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # STEP 5: User manually types cron line 2
  echo "  Step 5: Still in the same editor, type the cron entry for:"
  echo "          Monthly on the 1st at 00:00 → /usr/bin/touch monthly"
  read -p "  (type the exact cron line): " cron2
  if [[ "$cron2" != "0 0 1 * * /usr/bin/touch monthly" ]]; then
    print_error "Incorrect cron entry."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # STEP 6: User manually types cron line 3
  echo "  Step 6: Still in the same editor, type the cron entry for:"
  echo "          Weekly on Sunday at 11:00 → /usr/bin/touch weekly"
  read -p "  (type the exact cron line): " cron3
  if [[ "$cron3" != "0 11 * * 0 /usr/bin/touch weekly" ]]; then
    print_error "Incorrect cron entry."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo
  echo "  (now save and exit the editor)"
  echo

  # STEP 7: Edit anacrontab
  echo "  Step 7: Open /etc/anacrontab for editing."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo vi /etc/anacrontab" && \
        "$cmd7" != "sudo vim /etc/anacrontab" && \
        "$cmd7" != "sudo nano /etc/anacrontab" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (editor opened)"
  echo

  # STEP 8: User manually types anacron line
  echo "  Step 8: In that editor, type the anacron entry for:"
  echo "          Every 10 days, 5 min delay, job=db_cleanup → /usr/bin/touch /root/anacron_created_this"
  read -p "  (type the exact anacron line): " anacron1
  if [[ "$anacron1" != "10 5 db_cleanup /usr/bin/touch /root/anacron_created_this" ]]; then
    print_error "Incorrect anacron entry."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo
  echo "  (now save and exit the editor)"
  echo

  # STEP 9: Open student crontab ONCE
  echo "  Step 9: Open the 'student' user's crontab editor."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo -u student crontab -e" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (editor opened)"
  echo

  # STEP 10: User manually types student cron line 1
  echo "  Step 10: In that editor, type the cron entry for:"
  echo "           Sundays at 06:00 → sudo systemctl restart nginx"
  read -p "  (type the exact cron line): " scron1
  if [[ "$scron1" != "0 6 * * 0 sudo systemctl restart nginx" ]]; then
    print_error "Incorrect cron entry."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # STEP 11: User manually types student cron line 2
  echo "  Step 11: Still in the same editor, type the cron entry for:"
  echo "           Sundays at 23:00 → sudo systemctl restart nginx"
  read -p "  (type the exact cron line): " scron2
  if [[ "$scron2" != "0 23 * * 0 sudo systemctl restart nginx" ]]; then
    print_error "Incorrect cron entry."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo
  echo "  (now save and exit the editor)"
  echo

  # STEP 12: Verify root crontab
  echo "  Step 12: Verify root crontab."
  read -p "$PROMPT" cmd12
  echo
  if [[ "$cmd12" != "sudo crontab -l" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  30 21 * * * /usr/bin/touch test_passed"
  echo "  0 0 1 * * /usr/bin/touch monthly"
  echo "  0 11 * * 0 /usr/bin/touch weekly"
  echo

  # STEP 13: Verify student crontab
  echo "  Step 13: Verify student crontab."
  read -p "$PROMPT" cmd13
  echo
  if [[ "$cmd13" != "sudo -u student crontab -l" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  0 6 * * 0 sudo systemctl restart nginx"
  echo "  0 23 * * 0 sudo systemctl restart nginx"
  echo

  print_success "Great job."
  print_info "You manually authored scheduling entries like RHCSA expects:"
  print_info "- viewed and removed at jobs"
  print_info "- wrote multiple root cron entries in one session"
  print_info "- added an anacron job correctly"
  print_info "- wrote student cron entries that run privileged actions via sudo"
  print_info "You earned $LAB_XP XP for completing this lab."
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

  [[ "$choice" == "2" ]] && exit 0
done
