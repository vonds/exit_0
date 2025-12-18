#!/bin/bash

# Lab 205: Delete the sdb1 partition (Configure Local Storage)
# Output policy: Only show real command output. Silent commands produce no output.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 205: Delete sdb1"
LAB_ID="lab205"
LAB_XP=18000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

DISK="/dev/sdb"

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
  center_text "Goal: Delete the existing /dev/sdb1 partition and verify removal."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Show current partitions
  draw_lab_ui
  echo "  Step 1: List partitions on $DISK."
  echo "          Expected: lsblk $DISK"
  read -p "  lab@lab205:~$ " s1
  [[ "$s1" != "lsblk /dev/sdb" ]] && { print_error "Use: lsblk /dev/sdb"; read -p "Press Enter to try again..." _; continue; }
  echo "NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT"
  echo "sdb      8:16   0   10G  0 disk"
  echo "└─sdb1   8:17   0    2G  0 part"
  echo

  # Step 2: Delete sdb1 (silent)
  echo "  Step 2: Delete partition sdb1."
  echo "          Expected: parted -s $DISK rm 1"
  read -p "  lab@lab205:~$ " s2
  [[ "$s2" != "parted -s /dev/sdb rm 1" ]] && { print_error "Use: parted -s /dev/sdb rm 1"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 3: Notify kernel (silent)
  echo "  Step 3: Inform kernel of partition change."
  echo "          Expected: partprobe $DISK"
  read -p "  lab@lab205:~$ " s3
  [[ "$s3" != "partprobe /dev/sdb" ]] && { print_error "Use: partprobe /dev/sdb"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 4: Verify removal
  echo "  Step 4: Confirm sdb1 is gone."
  echo "          Expected: lsblk $DISK"
  read -p "  lab@lab205:~$ " s4
  [[ "$s4" != "lsblk /dev/sdb" ]] && { print_error "Use: lsblk /dev/sdb"; read -p "Press Enter to try again..." _; continue; }
  echo "NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT"
  echo "sdb      8:16   0   10G  0 disk"
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
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " post_choice
  [[ "$post_choice" == "2" ]] && exit 0
done
