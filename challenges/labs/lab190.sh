#!/bin/bash

# Lab 190: Find and Inspect Log Data (find, grep, wc)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 190: Find and Inspect Log Data"
LAB_ID="lab190"
LAB_XP=8600
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  root@lab190:~# "

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

fail_step() {
  print_error "$1"
  read -p "Press Enter to try again..." _
}

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "Locate log files, search for errors, count matches, and inspect file sizes."
  echo
  center_text "Press Enter to begin..."
  read _

  draw_lab_ui

  echo "  Step 1: Find all .log files under /var/log/httpd."
  read -p "$PROMPT" cmd1
  echo
  [[ "$cmd1" == "find /var/log/httpd -name '*.log'" ]] || { fail_step "Use: find /var/log/httpd -name '*.log'"; continue; }

  echo "  /var/log/httpd/access.log"
  echo "  /var/log/httpd/error.log"
  echo

  echo "  Step 2: Search /var/log/httpd/error.log for the word ERROR."
  read -p "$PROMPT" cmd2
  echo
  [[ "$cmd2" == "grep ERROR /var/log/httpd/error.log" ]] || { fail_step "Use: grep ERROR /var/log/httpd/error.log"; continue; }

  echo "  [Mon Jul 21 09:14:02] ERROR: failed to open config file"
  echo "  [Mon Jul 21 09:14:05] ERROR: permission denied on /var/www/private"
  echo "  [Mon Jul 21 09:14:07] ERROR: service startup aborted"
  echo

  echo "  Step 3: Count how many ERROR lines are in /var/log/httpd/error.log."
  read -p "$PROMPT" cmd3
  echo
  [[ "$cmd3" == "grep -c ERROR /var/log/httpd/error.log" ]] || { fail_step "Use: grep -c ERROR /var/log/httpd/error.log"; continue; }
  echo "  3"
  echo

  echo "  Step 4: Show the total number of lines in /var/log/httpd/error.log."
  read -p "$PROMPT" cmd4
  echo
  [[ "$cmd4" == "wc -l /var/log/httpd/error.log" ]] || { fail_step "Use: wc -l /var/log/httpd/error.log"; continue; }
  echo "  12 /var/log/httpd/error.log"
  echo

  echo "  Step 5: Search recursively under /var/log/httpd for the word denied."
  read -p "$PROMPT" cmd5
  echo
  [[ "$cmd5" == "grep -r denied /var/log/httpd" ]] || { fail_step "Use: grep -r denied /var/log/httpd"; continue; }
  echo "  /var/log/httpd/error.log:[Mon Jul 21 09:14:05] ERROR: permission denied on /var/www/private"
  echo

  echo "  Step 6: Display the size of /var/log/httpd/error.log in human-readable form."
  read -p "$PROMPT" cmd6
  echo
  [[ "$cmd6" == "ls -lh /var/log/httpd/error.log" ]] || { fail_step "Use: ls -lh /var/log/httpd/error.log"; continue; }
  echo "  -rw-r--r--. 1 root root 2.1K Jul 21 09:14 /var/log/httpd/error.log"
  echo

  print_success "Nice work!"
  print_info "You earned $LAB_XP XP for completing this lab."
  award_xp $LAB_XP
  XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON"); export XP; export LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've successfully completed this lab $completion_count time(s)."
  echo
  center_text "1) Retry"
  center_text "2) Return to Menu"
  echo
  read -p "  > " choice
  [[ "$choice" == "2" ]] && exit 0
done