#!/bin/bash

# Lab 123: RHEL Storage Basics — Partition a New Disk with parted (MBR/msdos), Verify, Remove
# Focus: labeling an uninitialized disk with an MBR (msdos) partition table, creating a primary partition,
# verifying with parted/lsblk//proc/partitions, and safely removing the partition.
# Key skills: parted (print/mklabel/mkpart/rm), lsblk, and /proc/partitions verification.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 123: Partition /dev/sdb with msdos (MBR) using parted"
LAB_ID="lab123"
LAB_XP=12300
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"

[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

draw_lab_ui() {
  clear
  center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
  center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
  echo
  echo
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
  center_text "A new 100MB disk (/dev/sdb) was added to a RHEL VM for a legacy appliance."
  center_text "The appliance requires an MBR (msdos) partition table, not GPT."
  center_text "Your job is to label the disk, create a small primary partition for testing,"
  center_text "verify the kernel sees it, then remove the partition to return the disk to a clean state."
  echo
  center_text "Notes:"
  center_text "- Assume /dev/sdb exists and is uninitialized (no disk label yet)."
  center_text "- Use sudo where required."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Show current partition information (expect 'unrecognized disk label')
  echo "  Step 1: View current partition information on /dev/sdb (expect an error about the disk label)."
  read -p "  lab@rhel-lab123:~$ " cmd1
  echo
  if [[ "$cmd1" != "sudo parted /dev/sdb print" && \
        "$cmd1" != "parted /dev/sdb print" && \
        "$cmd1" != "sudo parted -s /dev/sdb print" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Error: /dev/sdb: unrecognised disk label"
  echo "  Model: Virtio Block Device (virtblk)"
  echo "  Disk /dev/sdb: 105MB"
  echo "  Sector size (logical/physical): 512B/512B"
  echo "  Partition Table: unknown"
  echo "  Disk Flags:"
  echo

  # STEP 2: Assign disk label msdos (MBR)
  echo "  Step 2: Assign an MBR partition table (msdos) to /dev/sdb."
  read -p "  lab@rhel-lab123:~$ " cmd2
  echo
  if [[ "$cmd2" != "sudo parted /dev/sdb mklabel msdos" && \
        "$cmd2" != "sudo parted -s /dev/sdb mklabel msdos" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 3: Confirm the label application with print
  echo "  Step 3: Confirm the disk label is now msdos."
  read -p "  lab@rhel-lab123:~$ " cmd3
  echo
  if [[ "$cmd3" != "sudo parted /dev/sdb print" && \
        "$cmd3" != "parted /dev/sdb print" && \
        "$cmd3" != "sudo parted -s /dev/sdb print" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Model: Virtio Block Device (virtblk)"
  echo "  Disk /dev/sdb: 105MB"
  echo "  Sector size (logical/physical): 512B/512B"
  echo "  Partition Table: msdos"
  echo "  Disk Flags:"
  echo
  echo "  Number  Start  End  Size  Type  File system  Flags"
  echo

  # STEP 4: Create a 100MB primary partition starting at 1MB
  echo "  Step 4: Create a 100MB primary partition starting at 1MB using mkpart."
  read -p "  lab@rhel-lab123:~$ " cmd4
  echo
  if [[ "$cmd4" != "sudo parted /dev/sdb mkpart primary 1MiB 101MiB" && \
        "$cmd4" != "sudo parted -s /dev/sdb mkpart primary 1MiB 101MiB" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Information: You may need to update /etc/fstab."
  echo

  # STEP 5: Verify with parted print
  echo "  Step 5: Verify the new partition exists with parted print."
  read -p "  lab@rhel-lab123:~$ " cmd5
  echo
  if [[ "$cmd5" != "sudo parted /dev/sdb print" && \
        "$cmd5" != "sudo parted -s /dev/sdb print" && \
        "$cmd5" != "parted /dev/sdb print" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Model: Virtio Block Device (virtblk)"
  echo "  Disk /dev/sdb: 105MB"
  echo "  Sector size (logical/physical): 512B/512B"
  echo "  Partition Table: msdos"
  echo "  Disk Flags:"
  echo
  echo "  Number  Start   End     Size    Type     File system  Flags"
  echo "   1      1.05MiB 101MiB  100MiB  primary"
  echo

  # STEP 6: Confirm with lsblk (device file sdb1)
  echo "  Step 6: Confirm the kernel created /dev/sdb1 using lsblk."
  read -p "  lab@rhel-lab123:~$ " cmd6
  echo
  if [[ "$cmd6" != "lsblk" && \
        "$cmd6" != "lsblk /dev/sdb" && \
        "$cmd6" != "lsblk -o NAME,SIZE,TYPE,MOUNTPOINTS /dev/sdb" && \
        "$cmd6" != "lsblk -o NAME,SIZE,TYPE,MOUNTPOINTS" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS"
  echo "  sda      8:0    0   20G  0 disk"
  echo "  ├─sda1   8:1    0    1G  0 part /boot"
  echo "  └─sda2   8:2    0   19G  0 part /"
  echo "  sdb      8:16   0  100M  0 disk"
  echo "  └─sdb1   8:17   0   95M  0 part"
  echo

  # STEP 7: Verify /proc/partitions updated
  echo "  Step 7: Confirm /proc/partitions contains entries for sdb and sdb1."
  read -p "  lab@rhel-lab123:~$ " cmd7
  echo
  if [[ "$cmd7" != "cat /proc/partitions | grep -E 'sdb$|sdb1$'" && \
        "$cmd7" != "grep -E 'sdb$|sdb1$' /proc/partitions" && \
        "$cmd7" != "cat /proc/partitions | grep sdb" && \
        "$cmd7" != "grep sdb /proc/partitions" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "     8       16     102400 sdb"
  echo "     8       17      97280 sdb1"
  echo

  # STEP 8: Remove partition 1 with parted rm
  echo "  Step 8: Remove partition number 1 from /dev/sdb."
  read -p "  lab@rhel-lab123:~$ " cmd8
  echo
  if [[ "$cmd8" != "sudo parted /dev/sdb rm 1" && \
        "$cmd8" != "sudo parted -s /dev/sdb rm 1" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 9: Confirm deletion with parted print
  echo "  Step 9: Confirm the partition is gone with parted print."
  read -p "  lab@rhel-lab123:~$ " cmd9
  echo
  if [[ "$cmd9" != "sudo parted /dev/sdb print" && \
        "$cmd9" != "sudo parted -s /dev/sdb print" && \
        "$cmd9" != "parted /dev/sdb print" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Model: Virtio Block Device (virtblk)"
  echo "  Disk /dev/sdb: 105MB"
  echo "  Sector size (logical/physical): 512B/512B"
  echo "  Partition Table: msdos"
  echo "  Disk Flags:"
  echo
  echo "  Number  Start  End  Size  Type  File system  Flags"
  echo

  # STEP 10: Verify removal via /proc/partitions and lsblk
  echo "  Step 10: Verify the partition entry is removed (check /proc/partitions and lsblk)."
  read -p "  lab@rhel-lab123:~$ " cmd10
  echo
  if [[ "$cmd10" != "lsblk /dev/sdb" && \
        "$cmd10" != "lsblk -o NAME,SIZE,TYPE,MOUNTPOINTS /dev/sdb" && \
        "$cmd10" != "grep -E 'sdb$|sdb1$' /proc/partitions" && \
        "$cmd10" != "cat /proc/partitions | grep -E 'sdb$|sdb1$'" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd10" == lsblk* ]]; then
    echo "  NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS"
    echo "  sdb      8:16   0  100M  0 disk"
  else
    echo "     8       16     102400 sdb"
  fi
  echo

  print_success "Great job."
  print_info "You handled a real-world disk prep workflow for legacy requirements:"
  print_info "- validated the symptom with parted print"
  print_info "- applied an MBR/msdos label with mklabel"
  print_info "- created a primary partition with precise boundaries (1MiB to 101MiB)"
  print_info "- verified partition visibility via parted, lsblk, and /proc/partitions"
  print_info "- removed the partition cleanly and verified the kernel view updated"
  print_info "You earned $LAB_XP XP for completing this lab."
  award_xp $LAB_XP

  XP=$(jq '.XP' "$SAVE_JSON")
  LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
  export XP
  export LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've successfully completed this lab $completion_count time(s)."
  echo
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " choice

  [[ "$choice" == "2" ]] && exit 0
done
