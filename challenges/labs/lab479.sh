#!/bin/bash

# Lab 479: RHCSA Fundamentals — Input/Output Redirection (>, >>, <, |, 2>, &>, /dev/null)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 479: I/O Redirection & Pipes"
LAB_ID="lab479"
LAB_XP=47900
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab479:~$ "

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
  center_text "You must capture command output, chain commands, and manage errors"
  center_text "using standard redirection and pipes exactly like RHCSA expects."
  echo
  center_text "Artifacts you will create in your home directory:"
  center_text "- output.txt, count.txt, errors.txt, combined.txt, out.txt, err.txt, myfile.txt"
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Overwrite stdout to a file
  echo "  Step 1: Redirect the output of 'ls /etc' to ~/output.txt (overwrite)."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "ls /etc > ~/output.txt" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (stdout redirected to /home/examuser/output.txt)"
  echo

  # STEP 2: Append stdout to a file
  echo "  Step 2: Append the output of 'date' to ~/output.txt."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "date >> ~/output.txt" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (appended one line to /home/examuser/output.txt)"
  echo

  # STEP 3: Create a file to use for stdin redirection
  echo "  Step 3: Create ~/myfile.txt containing exactly the word: hello"
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "echo hello > ~/myfile.txt" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (wrote 1 line to /home/examuser/myfile.txt)"
  echo

  # STEP 4: Use stdin redirection
  echo "  Step 4: Display ~/myfile.txt using input redirection."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "cat < ~/myfile.txt" && "$cmd4" != "cat < myfile.txt" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  hello"
  echo

  # STEP 5: Pipe output to another command
  echo "  Step 5: List /var/log and show only the first 10 lines."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "ls /var/log | head -n 10" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  README"
  echo "  audit"
  echo "  boot.log"
  echo "  chrony"
  echo "  dnf.log"
  echo "  firewalld"
  echo "  lastlog"
  echo "  maillog"
  echo "  messages"
  echo "  secure"
  echo

  # STEP 6: Pipe and redirect result to a file
  echo "  Step 6: Count entries in /etc and write the number to ~/count.txt."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "ls /etc | wc -l > ~/count.txt" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (wrote line count to /home/examuser/count.txt)"
  echo

  # STEP 7: Redirect stderr (overwrite)
  echo "  Step 7: Redirect errors from listing a non-existent directory to ~/errors.txt (overwrite)."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "ls /invalid/directory 2> ~/errors.txt" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (stderr redirected to /home/examuser/errors.txt)"
  echo

  # STEP 8: Redirect stderr (append)
  echo "  Step 8: Append errors from another invalid listing to ~/errors.txt."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "ls /another/invalid/directory 2>> ~/errors.txt" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (appended stderr to /home/examuser/errors.txt)"
  echo

  # STEP 9: Redirect both stdout and stderr to one file
  echo "  Step 9: List /var/log and /invalid/directory and send ALL output to ~/combined.txt."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "ls /var/log /invalid/directory &> ~/combined.txt" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (stdout+stderr redirected to /home/examuser/combined.txt)"
  echo

  # STEP 10: Suppress stdout
  echo "  Step 10: Discard stdout from listing /etc."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "ls /etc > /dev/null" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (stdout discarded)"
  echo

  # STEP 11: Redirect stdout and stderr to different files
  echo "  Step 11: List /var/log and /invalid/directory, sending stdout to ~/out.txt and stderr to ~/err.txt."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "ls /var/log /invalid/directory > ~/out.txt 2> ~/err.txt" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (stdout redirected to /home/examuser/out.txt)"
  echo "  (stderr redirected to /home/examuser/err.txt)"
  echo

  # STEP 12: Append stdout and stderr separately
  echo "  Step 12: Append stdout and stderr separately from the same command."
  echo "          Append /var/log output to ~/out.txt and append errors to ~/err.txt."
  read -p "$PROMPT" cmd12
  echo
  if [[ "$cmd12" != "ls /var/log /invalid/directory >> ~/out.txt 2>> ~/err.txt" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (stdout appended to /home/examuser/out.txt)"
  echo "  (stderr appended to /home/examuser/err.txt)"
  echo

  print_success "Nice work."
  print_info "You demonstrated RHCSA-critical I/O skills by:"
  print_info "- redirecting stdout with > and >>"
  print_info "- redirecting stdin with <"
  print_info "- chaining commands with pipes |"
  print_info "- redirecting stderr with 2> and 2>>"
  print_info "- combining stdout+stderr with &>"
  print_info "- suppressing output with /dev/null"
  print_info "- separating streams into different files"
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
