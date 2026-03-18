#!/bin/bash

# Lab 541I: Locate and Copy Large Files Using find (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 541I: Locate and Copy Large Files with find"
LAB_ID="lab541i"
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
  center_text "ServerA contains several large configuration files."
  center_text "Locate files in /etc larger than 3MiB and copy them"
  center_text "to a directory named /find/largefiles."
  echo

  center_text "Requirements:"
  center_text "- Search directory: /etc"
  center_text "- File size: greater than 3MiB"
  center_text "- Destination: /find/largefiles"
  center_text "- Do not overwrite existing files"
  echo

  center_text "Press Enter to begin..."
  read _
  draw_lab_ui


  echo "  Step 1: Inspect the /etc directory."
  read -p "$PROMPT" cmd1
  echo

  if [[ "$cmd1" != "ls /etc" ]]; then
    print_error "Incorrect. Use: ls /etc"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (many configuration directories and files)"
  echo


  echo "  Step 2: Create the destination directory if it does not already exist."
  read -p "$PROMPT" cmd2
  echo

  if [[ "$cmd2" != "sudo mkdir -p /find/largefiles" ]]; then
    print_error "Incorrect. Use: sudo mkdir -p /find/largefiles"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 3: Locate files in /etc larger than 3MiB."
  read -p "$PROMPT" cmd3
  echo

  if [[ "$cmd3" != "find /etc -type f -size +3M" ]]; then
    print_error "Incorrect. Use: find /etc -type f -size +3M"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  /etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt"
  echo "  /etc/ssl/certs/ca-bundle.crt"
  echo


  echo "  Step 4: Copy the large files to /find/largefiles without overwriting existing files."
  read -p "$PROMPT" cmd4
  echo

  if [[ "$cmd4" != "sudo find /etc -type f -size +3M -exec cp -n {} /find/largefiles/ \;" ]]; then
    print_error "Incorrect."
    print_info "Use: sudo find /etc -type f -size +3M -exec cp -n {} /find/largefiles/ \\;"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  '/etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt' -> '/find/largefiles/ca-bundle.trust.crt'"
  echo "  '/etc/ssl/certs/ca-bundle.crt' -> '/find/largefiles/ca-bundle.crt'"
  echo


  echo "  Step 5: Verify that the files were copied to the destination directory."
  read -p "$PROMPT" cmd5
  echo

  if [[ "$cmd5" != "ls /find/largefiles" ]]; then
    print_error "Incorrect. Use: ls /find/largefiles"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  ca-bundle.crt"
  echo "  ca-bundle.trust.crt"
  echo


  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- inspected the /etc directory"
  print_info "- created the destination directory"
  print_info "- located files larger than 3MiB"
  print_info "- copied them without overwriting existing files"
  print_info "- verified the copied files"
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