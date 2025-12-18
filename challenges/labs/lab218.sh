#!/bin/bash

# Lab 218: Create group/shared directory with setgid permissions (SIMULATED & SAFE)
# SAFETY: This lab does NOT modify your system. It only checks typed commands and prints canned outputs.
#         No real users/groups, permissions, or files are changed.
# Output policy: Show only realistic, canned command output. Silent steps print nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 218: Shared Group Dir with setgid"
LAB_ID="lab218"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated targets (placeholders)
GROUP="sharedgrp"
SHARE="/srv/shared"

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
  center_text "Goal: Create a collaborative directory $SHARE owned by group $GROUP with the setgid bit so"
  center_text "new files/dirs inherit the group. Verify the bit and group inheritance with test files."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Create a collaboration group (SIMULATED — no output on success)
  draw_lab_ui
  echo "  Step 1: Create the group $GROUP."
  echo "          Expected: sudo groupadd $GROUP"
  read -p "  lab@lab218:~$ " cmd1
  [[ "$cmd1" != "sudo groupadd sharedgrp" ]] && { print_error "Use: sudo groupadd sharedgrp"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 2: Create the shared directory (SIMULATED — mkdir prints nothing)
  echo "  Step 2: Create the shared directory $SHARE."
  echo "          Expected: sudo mkdir -p $SHARE"
  read -p "  lab@lab218:~$ " cmd2
  [[ "$cmd2" != "sudo mkdir -p /srv/shared" ]] && { print_error "Use: sudo mkdir -p /srv/shared"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 3: Set group ownership (SIMULATED — chgrp prints nothing)
  echo "  Step 3: Set group ownership to $GROUP."
  echo "          Expected: sudo chgrp $GROUP $SHARE"
  read -p "  lab@lab218:~$ " cmd3
  [[ "$cmd3" != "sudo chgrp sharedgrp /srv/shared" ]] && { print_error "Use: sudo chgrp sharedgrp /srv/shared"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 4: Enable setgid bit and collaborative perms (SIMULATED — chmod prints nothing)
  echo "  Step 4: Enable setgid (2xxx) and set mode 2775."
  echo "          Expected: sudo chmod 2775 $SHARE"
  read -p "  lab@lab218:~$ " cmd4
  [[ "$cmd4" != "sudo chmod 2775 /srv/shared" ]] && { print_error "Use: sudo chmod 2775 /srv/shared"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 5: Verify the setgid bit (look for 's' in group exec position)
  echo "  Step 5: Verify permissions and group on the directory."
  echo "          Expected: ls -ld $SHARE"
  read -p "  lab@lab218:~$ " cmd5
  [[ "$cmd5" != "ls -ld /srv/shared" ]] && { print_error "Use: ls -ld /srv/shared"; read -p "Press Enter to try again..." _; continue; }
  echo "drwxrwsr-x 2 root sharedgrp 4096 Jul 22 11:00 /srv/shared"
  echo

  # Step 6: Create a file in the shared dir as another user (SIMULATED — no output)
  echo "  Step 6: Create a test file as user 'alice' under $SHARE."
  echo "          Expected: sudo -u alice touch $SHARE/alice.txt"
  read -p "  lab@lab218:~$ " cmd6
  [[ "$cmd6" != "sudo -u alice touch /srv/shared/alice.txt" ]] && { print_error "Use: sudo -u alice touch /srv/shared/alice.txt"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 7: Confirm the file inherited the group from the directory
  echo "  Step 7: List files to confirm group inheritance."
  echo "          Expected: ls -l $SHARE"
  read -p "  lab@lab218:~$ " cmd7
  [[ "$cmd7" != "ls -l /srv/shared" ]] && { print_error "Use: ls -l /srv/shared"; read -p "Press Enter to try again..." _; continue; }
  echo "total 0"
  echo "-rw-r--r-- 1 alice sharedgrp 0 Jul 22 11:01 alice.txt"
  echo

  # Step 8: Create a subdirectory as 'bob' to show setgid inheritance on new dirs
  echo "  Step 8: Create a subdirectory as user 'bob' and verify it inherits setgid + group."
  echo "          Expected: sudo -u bob mkdir $SHARE/bobdir"
  read -p "  lab@lab218:~$ " cmd8a
  [[ "$cmd8a" != "sudo -u bob mkdir /srv/shared/bobdir" ]] && { print_error "Use: sudo -u bob mkdir /srv/shared/bobdir"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "          Expected: ls -ld $SHARE/bobdir"
  read -p "  lab@lab218:~$ " cmd8b
  [[ "$cmd8b" != "ls -ld /srv/shared/bobdir" ]] && { print_error "Use: ls -ld /srv/shared/bobdir"; read -p "Press Enter to try again..." _; continue; }
  echo "drwxrwsr-x 2 bob sharedgrp 4096 Jul 22 11:02 /srv/shared/bobdir"
  echo

  # Step 9: (Bonus) Show only the permission bits for clarity
  echo "  Step 9 (bonus): Show numeric mode."
  echo "          Expected: stat -c '%a %n' $SHARE"
  read -p "  lab@lab218:~$ " cmd9
  [[ "$cmd9" != "stat -c '%a %n' /srv/shared" ]] && { print_error "Use: stat -c '%a %n' /srv/shared"; read -p "Press Enter to try again..." _; continue; }
  echo "2775 /srv/shared"
  echo

  print_success "Nice work! Shared directory configured with setgid; new content inherits the group."
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
