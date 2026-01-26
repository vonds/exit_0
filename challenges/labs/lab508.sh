#!/bin/bash

# Lab 508: Diagnose and Correct File Permission Problems

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 508: Diagnose and Correct File Permission Problems"
LAB_ID="lab508"
LAB_XP=50800
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab508:~$ "

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
  center_text "Users report permission denied errors and inability to modify shared files."
  center_text "You must diagnose and fix multiple permission and ownership problems."
  echo
  center_text "Targets:"
  center_text "- /var/www/html/index.html"
  center_text "- /shared/project"
  center_text "- /shared/temp"
  center_text "- /var/log/app"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Diagnose permissions on /var/www/html/index.html."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "ls -l /var/www/html/index.html" ]]; then
    print_error "Incorrect. Use: ls -l /var/www/html/index.html"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  -rw-r--r-- 1 root root 12345 /var/www/html/index.html"
  echo

  echo "  Step 2: Allow group members to write to the file."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo chmod g+w /var/www/html/index.html" ]]; then
    print_error "Incorrect. Use: sudo chmod g+w /var/www/html/index.html"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 3: Verify updated permissions."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "ls -l /var/www/html/index.html" ]]; then
    print_error "Incorrect. Use: ls -l /var/www/html/index.html"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  -rw-rw-r-- 1 root root 12345 /var/www/html/index.html"
  echo

  echo "  Step 4: Change ownership so the web service can manage the file."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo chown www-data /var/www/html/index.html" ]]; then
    print_error "Incorrect. Use: sudo chown www-data /var/www/html/index.html"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 5: Verify ownership."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "ls -l /var/www/html/index.html" ]]; then
    print_error "Incorrect. Use: ls -l /var/www/html/index.html"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  -rw-rw-r-- 1 www-data root 12345 /var/www/html/index.html"
  echo

  echo "  Step 6: Fix group permissions on /shared/project."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo chmod 2775 /shared/project" ]]; then
    print_error "Incorrect. Use: sudo chmod 2775 /shared/project"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 7: Verify directory permissions."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "ls -ld /shared/project" ]]; then
    print_error "Incorrect. Use: ls -ld /shared/project"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  drwxrwsr-x 2 root projectgroup 4096 /shared/project"
  echo

  echo "  Step 8: Configure sticky bit on /shared/temp."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo chmod 1777 /shared/temp" ]]; then
    print_error "Incorrect. Use: sudo chmod 1777 /shared/temp"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 9: Verify sticky bit."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "ls -ld /shared/temp" ]]; then
    print_error "Incorrect. Use: ls -ld /shared/temp"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  drwxrwxrwt 2 root root 4096 /shared/temp"
  echo

  echo "  Step 10: Diagnose permission denied on /var/log/app."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "ls -ld /var/log/app" ]]; then
    print_error "Incorrect. Use: ls -ld /var/log/app"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  drwxr-xr-- 2 root root 4096 /var/log/app"
  echo

  echo "  Step 11: Correct execute permissions."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "sudo chmod o+x /var/log/app" ]]; then
    print_error "Incorrect. Use: sudo chmod o+x /var/log/app"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 12: Verify fixed permissions."
  read -p "$PROMPT" cmd12
  echo
  if [[ "$cmd12" != "ls -ld /var/log/app" ]]; then
    print_error "Incorrect. Use: ls -ld /var/log/app"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  drwxr-xr-x 2 root root 4096 /var/log/app"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- diagnosed file permission issues"
  print_info "- corrected ownership and permissions"
  print_info "- configured special permission bits"
  print_info "- resolved access errors safely"
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
