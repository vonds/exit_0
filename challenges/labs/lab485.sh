#!/bin/bash

# Lab 485: RHCSA Permissions — List, Set, and Change Standard ugo/rwx Permissions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 485: ugo/rwx Permissions (chmod/chown + special bits)"
LAB_ID="lab485"
LAB_XP=48500
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab485:~$ "

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
  center_text "A project directory is being prepared for collaboration."
  center_text "You must set correct file and directory permissions and"
  center_text "apply special bits where appropriate."
  echo
  center_text "Resources (already exist):"
  center_text "- ~/perm485/ (directory exists)"
  center_text "- ~/perm485/example.txt"
  center_text "- ~/perm485/script.sh"
  center_text "- ~/perm485/private/ (directory exists)"
  center_text "- ~/perm485/shared/  (directory exists)"
  center_text "- ~/perm485/tmp/     (directory exists)"
  echo
  center_text "Goal: list permissions, change permissions (symbolic + numeric),"
  center_text "set ownership, and apply setuid/setgid/sticky correctly."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: List permissions
  echo "  Step 1: List permissions for example.txt and script.sh."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "ls -l /home/examuser/perm485/example.txt /home/examuser/perm485/script.sh" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  -rw-rw-r--. 1 examuser examuser   84 Jan 21 10:03 /home/examuser/perm485/example.txt"
  echo "  -rw-r--r--. 1 examuser examuser  231 Jan 21 10:03 /home/examuser/perm485/script.sh"
  echo

  # STEP 2: Symbolic - add execute for owner on script.sh
  echo "  Step 2: Add execute permission for the owner on script.sh (symbolic mode)."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "chmod u+x /home/examuser/perm485/script.sh" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 3: Verify script.sh permissions changed
  echo "  Step 3: Verify script.sh is now executable by the owner."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "ls -l /home/examuser/perm485/script.sh" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  -rwxr--r--. 1 examuser examuser 231 Jan 21 10:03 /home/examuser/perm485/script.sh"
  echo

  # STEP 4: Symbolic - remove group write from example.txt
  echo "  Step 4: Remove write permission from group on example.txt (symbolic mode)."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "chmod g-w /home/examuser/perm485/example.txt" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 5: Numeric mode - set script.sh to 755
  echo "  Step 5: Set script.sh permissions to 755 (numeric/octal mode)."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "chmod 755 /home/examuser/perm485/script.sh" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 6: Directory permissions - set private to 700 and verify
  echo "  Step 6: Set ~/perm485/private directory permissions to 700 and verify."
  echo "          (Do it with one command line.)"
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "chmod 700 /home/examuser/perm485/private && ls -ld /home/examuser/perm485/private" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  drwx------. 2 examuser examuser 6 Jan 21 10:03 /home/examuser/perm485/private"
  echo

  # STEP 7: Change ownership (owner + group) on example.txt
  echo "  Step 7: Change owner to adminuser and group to admingroup for example.txt."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo chown adminuser:admingroup /home/examuser/perm485/example.txt" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 8: Verify ownership change
  echo "  Step 8: Verify example.txt ownership and permissions."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "ls -l /home/examuser/perm485/example.txt" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  -rw-r--r--. 1 adminuser admingroup 84 Jan 21 10:03 /home/examuser/perm485/example.txt"
  echo

  # STEP 9: Setgid on shared directory + verify
  echo "  Step 9: Set the setgid bit on ~/perm485/shared and verify with ls -ld."
  echo "          (Do it with one command line.)"
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "chmod g+s /home/examuser/perm485/shared && ls -ld /home/examuser/perm485/shared" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  drwxrwsr-x. 2 examuser examuser 6 Jan 21 10:03 /home/examuser/perm485/shared"
  echo

  # STEP 10: Sticky bit on tmp directory + verify
  echo "  Step 10: Set the sticky bit on ~/perm485/tmp and verify with ls -ld."
  echo "           (Do it with one command line.)"
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "chmod +t /home/examuser/perm485/tmp && ls -ld /home/examuser/perm485/tmp" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  drwxrwxrwt. 2 examuser examuser 6 Jan 21 10:03 /home/examuser/perm485/tmp"
  echo

  # STEP 11: Setuid on a binary (simulated local admin helper) + verify
  echo "  Step 11: Set the setuid bit on /usr/local/bin/example485 and verify with ls -l."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "sudo chmod u+s /usr/local/bin/example485 && ls -l /usr/local/bin/example485" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  -rwsr-xr-x. 1 root root 18136 Jan 21 09:55 /usr/local/bin/example485"
  echo

  print_success "Nice work."
  print_info "You practiced RHCSA-critical permission skills:"
  print_info "- reading ugo/rwx permissions with ls -l"
  print_info "- changing permissions using symbolic and numeric chmod"
  print_info "- applying directory permissions correctly (r=list, w=create/delete, x=enter)"
  print_info "- changing ownership with chown"
  print_info "- setting special bits: setuid, setgid (dir group inheritance), sticky (safe shared dir)"
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
