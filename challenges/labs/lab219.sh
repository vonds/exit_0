#!/bin/bash

# Lab 219: Sticky Bit Demo on /tmp (SIMULATED & SAFE)
# SAFETY: This lab does NOT change your system. It only validates typed commands and prints canned outputs.
#         No real users, files, or permissions are modified.
# Output policy: Show only realistic, canned command output. Silent steps print nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 219: Sticky Bit on /tmp"
LAB_ID="lab219"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated actors and paths
USER_A="user100"
USER_B="user200"
TMP="/tmp"
TESTFILE="$TMP/${USER_A}.note"

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
  center_text "Goal: Prove how the sticky bit on $TMP prevents users from deleting others’ files."
  center_text "You’ll create a file as $USER_A, try to delete it as $USER_B (fail), then delete it as owner."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Inspect /tmp permissions (look for the trailing 't' → 1777)
  draw_lab_ui
  echo "  Step 1: Show the permissions on $TMP."
  echo "          Expected: ls -ld $TMP"
  read -p "  lab@lab219:~$ " cmd1
  [[ "$cmd1" != "ls -ld /tmp" ]] && { print_error "Use: ls -ld /tmp"; read -p "Press Enter to try again..." _; continue; }
  echo "drwxrwxrwt 10 root root 4096 Jul 22 11:10 /tmp"
  echo

  # Step 2: Confirm sticky bit numerically (1777)
  echo "  Step 2: Show numeric mode to confirm 1777."
  echo "          Expected: stat -c '%a %n' $TMP"
  read -p "  lab@lab219:~$ " cmd2
  [[ "$cmd2" != "stat -c '%a %n' /tmp" ]] && { print_error "Use: stat -c '%a %n' /tmp"; read -p "Press Enter to try again..." _; continue; }
  echo "1777 /tmp"
  echo

  # Step 3: Create a file in /tmp as user100 (owner = user100)
  echo "  Step 3: Create a test file owned by $USER_A."
  echo "          Expected: sudo -u $USER_A touch $TESTFILE"
  read -p "  lab@lab219:~$ " cmd3
  [[ "$cmd3" != "sudo -u user100 touch /tmp/user100.note" ]] && { print_error "Use: sudo -u user100 touch /tmp/user100.note"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 4: Verify ownership of the file
  echo "  Step 4: Verify the file’s owner and group."
  echo "          Expected: ls -l $TESTFILE"
  read -p "  lab@lab219:~$ " cmd4
  [[ "$cmd4" != "ls -l /tmp/user100.note" ]] && { print_error "Use: ls -l /tmp/user100.note"; read -p "Press Enter to try again..." _; continue; }
  echo "-rw-r--r-- 1 user100 user100 0 Jul 22 11:12 /tmp/user100.note"
  echo

  # Step 5: Try to delete as a different user (should fail due to sticky bit)
  echo "  Step 5: Attempt to remove it as $USER_B (should be blocked by sticky bit)."
  echo "          Expected: sudo -u $USER_B rm $TESTFILE"
  read -p "  lab@lab219:~$ " cmd5
  [[ "$cmd5" != "sudo -u user200 rm /tmp/user100.note" ]] && { print_error "Use: sudo -u user200 rm /tmp/user100.note"; read -p "Press Enter to try again..." _; continue; }
  echo "rm: cannot remove '/tmp/user100.note': Operation not permitted"
  echo

  # Step 6: Confirm the file still exists
  echo "  Step 6: Show that the file remains."
  echo "          Expected: ls -l $TESTFILE"
  read -p "  lab@lab219:~$ " cmd6
  [[ "$cmd6" != "ls -l /tmp/user100.note" ]] && { print_error "Use: ls -l /tmp/user100.note"; read -p "Press Enter to try again..." _; continue; }
  echo "-rw-r--r-- 1 user100 user100 0 Jul 22 11:12 /tmp/user100.note"
  echo

  # Step 7: Delete as the owner (allowed)
  echo "  Step 7: Remove the file as $USER_A (owner)."
  echo "          Expected: sudo -u $USER_A rm $TESTFILE"
  read -p "  lab@lab219:~$ " cmd7
  [[ "$cmd7" != "sudo -u user100 rm /tmp/user100.note" ]] && { print_error "Use: sudo -u user100 rm /tmp/user100.note"; read -p "Press Enter to try again..." _; continue; }
  # (rm success prints nothing)
  echo

  # Step 8: Verify it’s gone
  echo "  Step 8: Confirm removal."
  echo "          Expected: ls -l $TESTFILE"
  read -p "  lab@lab219:~$ " cmd8
  [[ "$cmd8" != "ls -l /tmp/user100.note" ]] && { print_error "Use: ls -l /tmp/user100.note"; read -p "Press Enter to try again..." _; continue; }
  echo "ls: cannot access '/tmp/user100.note': No such file or directory"
  echo

  # Step 9 (bonus): Show root can delete regardless
  echo "  Step 9 (bonus): Recreate and remove as root (allowed)."
  echo "          Expected: sudo -u $USER_A touch $TESTFILE"
  read -p "  lab@lab219:~$ " cmd9a
  [[ "$cmd9a" != "sudo -u user100 touch /tmp/user100.note" ]] && { print_error "Use: sudo -u user100 touch /tmp/user100.note"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "          Expected: sudo rm $TESTFILE"
  read -p "  lab@lab219:~$ " cmd9b
  [[ "$cmd9b" != "sudo rm /tmp/user100.note" ]] && { print_error "Use: sudo rm /tmp/user100.note"; read -p "Press Enter to try again..." _; continue; }
  # (rm success prints nothing)
  echo

  print_success "Nice work! You demonstrated how the sticky bit on /tmp protects users’ files."
  print_info "You earned $LAB_XP XP for completing this lab."
  award_xp $LAB_XP
  XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON"); export XP; export LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've successfully completed this lab $completion_count time(s)."
  echo
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " post_choice
  [[ "$post_choice" == "2" ]] && exit 0
done
