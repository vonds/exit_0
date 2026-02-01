#!/bin/bash

# Lab 524: Manage Default File Permissions Using umask (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 524: Default File Permissions (umask) (RHCSA)"
LAB_ID="lab524"
LAB_XP=52400
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab524:~$ "

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
  center_text "You are securing a multi-user system. Default file permissions must"
  center_text "be controlled so new files and directories are not overly permissive."
  center_text "You will inspect, modify, persist, and verify umask behavior."
  echo
  center_text "Targets:"
  center_text "- understand default file vs directory permissions"
  center_text "- inspect current umask"
  center_text "- set umask temporarily"
  center_text "- verify permissions with touch and mkdir"
  center_text "- set umask persistently"
  center_text "- confirm behavior after change"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Display the current umask value."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "umask" ]]; then
    print_error "Incorrect. Use: umask"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  0022"
  echo

  echo "  Step 2: Temporarily set the umask to 0027 for this shell session."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "umask 0027" ]]; then
    print_error "Incorrect. Use: umask 0027"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 3: Verify the new umask value is active."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "umask" ]]; then
    print_error "Incorrect. Use: umask"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  0027"
  echo

  echo "  Step 4: Create a new empty file named testfile_umask."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "touch testfile_umask" ]]; then
    print_error "Incorrect. Use: touch testfile_umask"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 5: Create a new directory named testdir_umask."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "mkdir testdir_umask" ]]; then
    print_error "Incorrect. Use: mkdir testdir_umask"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 6: Verify permissions of the file and directory."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "ls -l testfile_umask testdir_umask" ]]; then
    print_error "Incorrect. Use: ls -l testfile_umask testdir_umask"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  -rw-r----- 1 examuser examuser 0 testfile_umask"
  echo "  drwxr-x--- 2 examuser examuser 6 testdir_umask"
  echo

  echo "  Step 7: Remove the test file and directory."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "rm -f testfile_umask && rmdir testdir_umask" ]]; then
    print_error "Incorrect. Use: rm -f testfile_umask && rmdir testdir_umask"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 8: Edit the global profile to persist a umask of 0007."
  echo "          This ensures files are 660 and directories are 770 for all users."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo vi /etc/profile" ]]; then
    print_error "Incorrect. Use: sudo vi /etc/profile"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (Add or modify line: umask 0007)"
  echo

  echo "  Step 9: Reload the profile configuration in the current shell."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "source /etc/profile" ]]; then
    print_error "Incorrect. Use: source /etc/profile"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 10: Verify the new umask value is now 0007."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "umask" ]]; then
    print_error "Incorrect. Use: umask"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  0007"
  echo

  echo "  Step 11: Create a new file and directory to verify persistent behavior."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "touch testfile_persist && mkdir testdir_persist" ]]; then
    print_error "Incorrect. Use: touch testfile_persist && mkdir testdir_persist"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 12: Verify permissions reflect umask 0007."
  read -p "$PROMPT" cmd12
  echo
  if [[ "$cmd12" != "ls -l testfile_persist testdir_persist" ]]; then
    print_error "Incorrect. Use: ls -l testfile_persist testdir_persist"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  -rw-rw---- 1 examuser examuser 0 testfile_persist"
  echo "  drwxrwx--- 2 examuser examuser 6 testdir_persist"
  echo

  echo "  Step 13: Clean up the test file and directory."
  read -p "$PROMPT" cmd13
  echo
  if [[ "$cmd13" != "rm -f testfile_persist && rmdir testdir_persist" ]]; then
    print_error "Incorrect. Use: rm -f testfile_persist && rmdir testdir_persist"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- inspected and explained umask behavior"
  print_info "- applied a temporary umask and verified file/directory permissions"
  print_info "- configured a persistent global umask"
  print_info "- validated default permissions using real filesystem objects"
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
