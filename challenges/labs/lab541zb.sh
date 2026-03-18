#!/bin/bash

# Lab 541ZB: Configure Default File Permissions with umask (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 541ZB: Configure Default File Permissions with umask"
LAB_ID="lab541zb"
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
  center_text "User harry must have stricter default file permissions."
  center_text "Any new file created should have permissions:"
  center_text "rw-r----- (640)."
  echo
  center_text "This must persist across logins."
  echo
  center_text "Hint:"
  center_text "Default file permissions are controlled using umask."
  echo

  center_text "Press Enter to begin..."
  read _
  draw_lab_ui


  echo "  Step 1: Confirm the user harry exists."
  read -p "$PROMPT" cmd1
  echo

  if [[ "$cmd1" != "id harry" ]]; then
    print_error "Incorrect. Use: id harry"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  uid=1008(harry) gid=1008(harry) groups=1008(harry)"
  echo


  echo "  Step 2: Configure harry's persistent umask."
  read -p "$PROMPT" cmd2
  echo

  if [[ "$cmd2" != "echo 'umask 027' | sudo tee -a /home/harry/.bashrc > /dev/null" ]]; then
    print_error "Incorrect."
    print_info "Use: echo 'umask 027' | sudo tee -a /home/harry/.bashrc > /dev/null"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 3: Verify the configuration was added."
  read -p "$PROMPT" cmd3
  echo

  if [[ "$cmd3" != "grep umask /home/harry/.bashrc" ]]; then
    print_error "Incorrect. Use: grep umask /home/harry/.bashrc"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  umask 027"
  echo


  echo "  Step 4: Switch to the harry user."
  read -p "$PROMPT" cmd4
  echo

  if [[ "$cmd4" != "su - harry" ]]; then
    print_error "Incorrect. Use: su - harry"
    read -p "Press Enter to retry..." _
    continue
  fi

  PROMPT="  harry@servera:~$ "
  echo


  echo "  Step 5: Confirm the umask value."
  read -p "$PROMPT" cmd5
  echo

  if [[ "$cmd5" != "umask" ]]; then
    print_error "Incorrect. Use: umask"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  0027"
  echo


  echo "  Step 6: Create a test file."
  read -p "$PROMPT" cmd6
  echo

  if [[ "$cmd6" != "touch testfile" ]]; then
    print_error "Incorrect. Use: touch testfile"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 7: Verify the file permissions."
  read -p "$PROMPT" cmd7
  echo

  if [[ "$cmd7" != "ls -l testfile" ]]; then
    print_error "Incorrect. Use: ls -l testfile"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  -rw-r----- 1 harry harry 0 Mar 15 16:42 testfile"
  echo


  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- configured a persistent umask for harry"
  print_info "- ensured new files are created with 640 permissions"
  print_info "- verified the configuration after login"
  print_info "- confirmed the new file permissions"
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