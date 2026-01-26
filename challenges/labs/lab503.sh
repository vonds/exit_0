#!/bin/bash

# Lab 503: Create, Mount, Unmount, and Use vfat, ext4, and xfs Filesystems

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 503: Filesystem Creation & Persistent Mounting"
LAB_ID="lab503"
LAB_XP=50300
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab503:~$ "

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
  center_text "Three new block devices were attached to the system."
  center_text "You must create filesystems, mount them, configure persistence,"
  center_text "and verify everything safely without rebooting."
  echo
  center_text "Targets:"
  center_text "- /dev/sdb1 → ext4 → /mnt/data"
  center_text "- /dev/sdc1 → xfs  → /mnt/backup"
  center_text "- /dev/sdd1 → vfat → /mnt/usb"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Create an ext4 filesystem on /dev/sdb1."
  read -p "$PROMPT" cmd1
  echo
  [[ "$cmd1" != "sudo mkfs.ext4 /dev/sdb1" ]] && { print_error "Use: sudo mkfs.ext4 /dev/sdb1"; read -p "Press Enter..." _; continue; }
  echo "mke2fs 1.46.5 (30-Dec-2021)"
  echo "Creating filesystem with 5242880 4k blocks and 1310720 inodes"
  echo "Filesystem UUID: 1f2a3b4c-1111-2222-3333-444455556666"
  echo

  echo "  Step 2: Create an xfs filesystem on /dev/sdc1."
  read -p "$PROMPT" cmd2
  echo
  [[ "$cmd2" != "sudo mkfs.xfs /dev/sdc1" ]] && { print_error "Use: sudo mkfs.xfs /dev/sdc1"; read -p "Press Enter..." _; continue; }
  echo "meta-data=/dev/sdc1  isize=512  agcount=4, agsize=327680 blks"
  echo

  echo "  Step 3: Create a vfat filesystem on /dev/sdd1."
  read -p "$PROMPT" cmd3
  echo
  [[ "$cmd3" != "sudo mkfs.vfat /dev/sdd1" ]] && { print_error "Use: sudo mkfs.vfat /dev/sdd1"; read -p "Press Enter..." _; continue; }
  echo "mkfs.fat 4.2 (2021-01-31)"
  echo

  echo "  Step 4: Create mount point directories."
  read -p "$PROMPT" cmd4
  echo
  [[ "$cmd4" != "sudo mkdir -p /mnt/data /mnt/backup /mnt/usb" ]] && { print_error "Use: sudo mkdir -p /mnt/data /mnt/backup /mnt/usb"; read -p "Press Enter..." _; continue; }
  echo

  echo "  Step 5: Mount ext4 filesystem."
  read -p "$PROMPT" cmd5
  echo
  [[ "$cmd5" != "sudo mount /dev/sdb1 /mnt/data" ]] && { print_error "Use: sudo mount /dev/sdb1 /mnt/data"; read -p "Press Enter..." _; continue; }
  echo

  echo "  Step 6: Mount xfs filesystem."
  read -p "$PROMPT" cmd6
  echo
  [[ "$cmd6" != "sudo mount /dev/sdc1 /mnt/backup" ]] && { print_error "Use: sudo mount /dev/sdc1 /mnt/backup"; read -p "Press Enter..." _; continue; }
  echo

  echo "  Step 7: Mount vfat filesystem."
  read -p "$PROMPT" cmd7
  echo
  [[ "$cmd7" != "sudo mount /dev/sdd1 /mnt/usb" ]] && { print_error "Use: sudo mount /dev/sdd1 /mnt/usb"; read -p "Press Enter..." _; continue; }
  echo

  echo "  Step 8: Identify UUID and LABEL values."
  read -p "$PROMPT" cmd8
  echo
  [[ "$cmd8" != "sudo blkid" && "$cmd8" != "blkid" ]] && { print_error "Use: sudo blkid"; read -p "Press Enter..." _; continue; }
  echo "/dev/sdb1: UUID=\"1f2a3b4c-1111-2222-3333-444455556666\" TYPE=\"ext4\""
  echo "/dev/sdc1: UUID=\"7a8b9c0d-aaaa-bbbb-cccc-ddddeeeeffff\" TYPE=\"xfs\""
  echo "/dev/sdd1: LABEL=\"USBDrive\" UUID=\"0abc1234-5678-90ab-cdef-112233445566\" TYPE=\"vfat\""
  echo

  echo "  Step 9: Edit /etc/fstab."
  read -p "$PROMPT" cmd9
  echo
  [[ "$cmd9" != "sudo vim /etc/fstab" && "$cmd9" != "vim /etc/fstab" ]] && { print_error "Use: sudo vim /etc/fstab"; read -p "Press Enter..." _; continue; }
  echo

  echo "  Step 10: Add ext4 fstab entry."
  read -p "$PROMPT" fstab1
  echo
  [[ "$fstab1" != "UUID=1f2a3b4c-1111-2222-3333-444455556666  /mnt/data  ext4  defaults  0  2" ]] && { print_error "Incorrect ext4 fstab entry."; read -p "Press Enter..." _; continue; }
  echo

  echo "  Step 11: Add xfs fstab entry."
  read -p "$PROMPT" fstab2
  echo
  [[ "$fstab2" != "UUID=7a8b9c0d-aaaa-bbbb-cccc-ddddeeeeffff  /mnt/backup  xfs  defaults  0  2" ]] && { print_error "Incorrect xfs fstab entry."; read -p "Press Enter..." _; continue; }
  echo

  echo "  Step 12: Add vfat fstab entry using LABEL."
  read -p "$PROMPT" fstab3
  echo
  [[ "$fstab3" != "LABEL=USBDrive  /mnt/usb  vfat  defaults  0  0" ]] && { print_error "Incorrect vfat fstab entry."; read -p "Press Enter..." _; continue; }
  echo

  echo "  Step 13: Test /etc/fstab safely."
  read -p "$PROMPT" cmd13
  echo
  [[ "$cmd13" != "sudo mount -a" && "$cmd13" != "mount -a" ]] && { print_error "Use: sudo mount -a"; read -p "Press Enter..." _; continue; }
  echo

  echo "  Step 14: Verify mounts."
  read -p "$PROMPT" cmd14
  echo
  [[ "$cmd14" != "df -h /mnt/data /mnt/backup /mnt/usb" ]] && { print_error "Use: df -h /mnt/data /mnt/backup /mnt/usb"; read -p "Press Enter..." _; continue; }
  echo "Filesystem      Size  Used Avail Use% Mounted on"
  echo "/dev/sdb1        20G   28M   19G   1% /mnt/data"
  echo "/dev/sdc1        10G   81M  9.9G   1% /mnt/backup"
  echo "/dev/sdd1       1.0G  4.0K  1.0G   1% /mnt/usb"
  echo

  echo "  Step 15: Unmount all filesystems."
  read -p "$PROMPT" cmd15
  echo
  [[ "$cmd15" != "sudo umount /mnt/data /mnt/backup /mnt/usb" ]] && { print_error "Use: sudo umount /mnt/data /mnt/backup /mnt/usb"; read -p "Press Enter..." _; continue; }
  echo

  print_success "Outstanding."
  print_info "You created and managed ext4, xfs, and vfat filesystems with persistence."
  print_info "You earned $LAB_XP XP."

  award_xp $LAB_XP
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've completed this lab $completion_count time(s)."
  echo
  center_text "1) Retry"
  center_text "2) Return to menu"
  echo
  read -p "  > " choice
  [[ "$choice" == "2" ]] && exit 0
done
