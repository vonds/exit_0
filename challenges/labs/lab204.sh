#!/bin/bash

# Lab 204: Set MBR (msdos) label on /dev/sdc and create a 100MB primary partition (Configure Local Storage)
# Output policy: Only show real command output. Silent commands produce no output.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 204: MBR + 100MB Partition on /dev/sdc"
LAB_ID="lab204"
LAB_XP=20000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

DISK="/dev/sdc"

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
  center_text "Goal: Put an MBR (msdos) label on $DISK and create a 100MB primary partition, then verify."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Create msdos label (silent)
  draw_lab_ui
  echo "  Step 1: Set the disk label to msdos on $DISK."
  echo "          Expected: parted -s $DISK mklabel msdos"
  read -p "  lab@lab204:~$ " s1
  [[ "$s1" != "parted -s /dev/sdc mklabel msdos" ]] && { print_error "Use: parted -s /dev/sdc mklabel msdos"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 2: Create 100MB primary partition (silent)
  echo "  Step 2: Create a 100MB primary partition."
  echo "          Expected: parted -s $DISK mkpart primary ext4 1MiB 101MiB"
  read -p "  lab@lab204:~$ " s2
  [[ "$s2" != "parted -s /dev/sdc mkpart primary ext4 1MiB 101MiB" ]] && { print_error "Use: parted -s /dev/sdc mkpart primary ext4 1MiB 101MiB"; read -p "Press Enter to try again..." _; continue; }
  echo

  # (optional) notify kernel (silent)
  echo "  Step 3: Inform the kernel of partition changes."
  echo "          Expected: partprobe $DISK"
  read -p "  lab@lab204:~$ " s3
  [[ "$s3" != "partprobe /dev/sdc" ]] && { print_error "Use: partprobe /dev/sdc"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 4: Verify with lsblk (shows tree)
  echo "  Step 4: Verify partition table with lsblk."
  echo "          Expected: lsblk $DISK"
  read -p "  lab@lab204:~$ " s4
  [[ "$s4" != "lsblk /dev/sdc" ]] && { print_error "Use: lsblk /dev/sdc"; read -p "Press Enter to try again..." _; continue; }
  echo "NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT"
  echo "sdc      8:32   0   10G  0 disk"
  echo "└─sdc1   8:33   0  100M  0 part"
  echo

  # Step 5: Verify with fdisk -l (shows classic MBR layout)
  echo "  Step 5: Confirm details with fdisk."
  echo "          Expected: fdisk -l $DISK"
  read -p "  lab@lab204:~$ " s5
  [[ "$s5" != "fdisk -l /dev/sdc" ]] && { print_error "Use: fdisk -l /dev/sdc"; read -p "Press Enter to try again..." _; continue; }
  echo "Disk /dev/sdc: 10 GiB, 10737418240 bytes, 20971520 sectors"
  echo "Disk model: VDISK"
  echo "Units: sectors of 1 * 512 = 512 bytes"
  echo "Sector size (logical/physical): 512 bytes / 512 bytes"
  echo "I/O size (minimum/optimal): 512 bytes / 512 bytes"
  echo "Disklabel type: dos"
  echo "Disk identifier: 0xabcdef01"
  echo
  echo "Device     Boot Start   End Sectors  Size Id Type"
  echo "/dev/sdc1        2048 206847  204800  100M 83 Linux"
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
