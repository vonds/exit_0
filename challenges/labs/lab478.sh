#!/bin/bash

# Lab 478: RHCSA Fundamentals — Access Shell & Use Correct Command Syntax (8–12 prompts)
# Focus: logging in, navigating the filesystem, correct command syntax,
# file manipulation, redirection, sudo usage, viewing/editing files,
# and shell efficiency basics exactly as RHCSA expects.
#
# Key skills: ssh, cd, ls, mkdir, rmdir, cp, mv, rm, wildcards, redirection,
# sudo, cat, vim, history, bash fundamentals.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 478: Access Shell & Issue Commands Correctly"
LAB_ID="lab478"
LAB_XP=47800
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab478:~$ "

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
  center_text "You are logged in as examuser on a RHEL system."
  center_text "You must demonstrate correct shell usage and command syntax"
  center_text "across common RHCSA-level tasks."
  echo
  center_text "Goal: navigate the filesystem, manage files, use wildcards,"
  center_text "redirect output, run privileged commands, and edit files correctly."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Verify shell access
  echo "  Step 1: Confirm your current working directory."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "pwd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  /home/examuser"
  echo

  # STEP 2: Navigate and list files
  echo "  Step 2: Change to /var/log and list all files including hidden ones."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "cd /var/log && ls -a" ]]; then
    print_error "Incorrect. Use correct command chaining and options."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  .  ..  boot.log  messages  secure  dnf.log  .journal"
  echo

  # STEP 3: Create and remove directory
  echo "  Step 3: Create a directory named testdir in your home directory."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "mkdir ~/testdir" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  echo "  Step 4: Remove the directory testdir."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "rmdir ~/testdir" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 5: Copy and rename file
  echo "  Step 5: Copy /etc/hosts to your home directory and name it myhosts."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "cp /etc/hosts ~/myhosts" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 6: Use wildcard
  echo "  Step 6: List all files in /var/log starting with the letter 'm'."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "ls /var/log/m*" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  messages  maillog"
  echo

  # STEP 7: Redirect output
  echo "  Step 7: Append the listing of /var/log to logfiles.txt in your home directory."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "ls /var/log >> ~/logfiles.txt" ]]; then
    print_error "Incorrect. Use append redirection."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 8: View file contents
  echo "  Step 8: Display the contents of /etc/passwd."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "cat /etc/passwd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  root:x:0:0:root:/root:/bin/bash"
  echo "  examuser:x:1000:1000::/home/examuser:/bin/bash"
  echo

  # STEP 9: Edit file
  echo "  Step 9: Open /etc/hosts in vim to edit it."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo vim /etc/hosts" ]]; then
    print_error "Incorrect. This requires elevated privileges."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (editor opened)"
  echo "  (added entry and saved)"
  echo

  # STEP 10: Re-run last command
  echo "  Step 10: Re-run the last command using shell history."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "!!" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  sudo vim /etc/hosts"
  echo

  print_success "Well done."
  print_info "You demonstrated core RHCSA shell competency by:"
  print_info "- navigating directories using absolute paths"
  print_info "- using correct command syntax and options"
  print_info "- managing files and directories safely"
  print_info "- using wildcards and output redirection"
  print_info "- running privileged commands with sudo"
  print_info "- viewing and editing system files"
  print_info "- using shell history efficiently"
  print_info "You earned $LAB_XP XP for completing this lab."
  award_xp $LAB_XP

  XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON"); export XP; export LEVEL
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
