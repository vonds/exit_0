#!/bin/bash

# Lab 497: Partition Management (MBR + GPT) — List, Create, Delete

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 497: Manage Partitions (MBR + GPT)"
LAB_ID="lab497"
LAB_XP=49700
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab497:~$ "

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
  center_text "A new VM has two attached disks for storage practice:"
  center_text "- /dev/sdc uses MBR (dos) partitioning"
  center_text "- /dev/sdd uses GPT partitioning"
  center_text "You must list partitions, create and delete partitions, and refresh the partition table."
  echo
  center_text "Notes:"
  center_text "- This lab is simulated to match RHCSA-style workflows."
  center_text "- Always be careful with real disks in production."
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  # STEP 1: List partitions on MBR disk using fdisk
  echo "  Step 1: List partitions on the MBR disk using fdisk."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "sudo fdisk -l /dev/sdc" ]]; then
    print_error "Incorrect. Use: sudo fdisk -l /dev/sdc"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Disk /dev/sdc: 12 GiB, 12884901888 bytes, 25165824 sectors"
  echo "  Disk model: VBOX HARDDISK"
  echo "  Units: sectors of 1 * 512 = 512 bytes"
  echo "  Sector size (logical/physical): 512 bytes / 512 bytes"
  echo "  I/O size (minimum/optimal): 512 bytes / 512 bytes"
  echo "  Disklabel type: dos"
  echo "  Disk identifier: 0x6a2c91bf"
  echo
  echo "  Device     Boot Start      End  Sectors  Size Id Type"
  echo "  /dev/sdc1        2048  1050623  1048576  512M 83 Linux"
  echo "  /dev/sdc2     1050624 25165823 241151... 11.5G 8e Linux LVM"
  echo

  # STEP 2: Create a new 1G primary partition on /dev/sdc with fdisk (interactive)
  echo "  Step 2: Create a new 1G primary partition on the MBR disk using fdisk."
  echo "  Requirement: Use fdisk interactive workflow."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo fdisk /dev/sdc" ]]; then
    print_error "Incorrect. Use: sudo fdisk /dev/sdc"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Welcome to fdisk (util-linux 2.37.4)."
  echo "  Changes will remain in memory only, until you decide to write them."
  echo "  Be careful before using the write command."
  echo
  echo "  Command (m for help): n"
  echo "  Partition type"
  echo "     p   primary (2 primary, 0 extended, 2 free)"
  echo "     e   extended (container for logical partitions)"
  echo "  Select (default p): p"
  echo "  Partition number (3,4, default 3):"
  echo "  First sector (1050624-25165823, default 1050624):"
  echo "  Last sector, +sectors or +size{K,M,G,T,P} (1050624-25165823, default 25165823): +1G"
  echo
  echo "  Created a new partition 3 of type 'Linux' and of size 1 GiB."
  echo
  echo "  Command (m for help): w"
  echo "  The partition table has been altered."
  echo "  Calling ioctl() to re-read partition table."
  echo "  Syncing disks."
  echo

  # STEP 3: Refresh partition table (partprobe)
  echo "  Step 3: Refresh the kernel partition table for /dev/sdc."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo partprobe /dev/sdc" ]]; then
    print_error "Incorrect. Use: sudo partprobe /dev/sdc"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  "
  echo

  # STEP 4: Verify new MBR partition exists
  echo "  Step 4: Verify the new partition exists on /dev/sdc."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo fdisk -l /dev/sdc" ]]; then
    print_error "Incorrect. Use: sudo fdisk -l /dev/sdc"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Disk /dev/sdc: 12 GiB, 12884901888 bytes, 25165824 sectors"
  echo "  Disklabel type: dos"
  echo
  echo "  Device     Boot   Start      End  Sectors  Size Id Type"
  echo "  /dev/sdc1          2048  1050623  1048576  512M 83 Linux"
  echo "  /dev/sdc2       1050624  5242879  4192256    2G 8e Linux LVM"
  echo "  /dev/sdc3       5242880  7340031  2097152    1G 83 Linux"
  echo "  /dev/sdc4       7340032 25165823 17825792  8.5G 8e Linux LVM"
  echo

  # STEP 5: Delete the new MBR partition with fdisk
  echo "  Step 5: Delete partition 3 on the MBR disk using fdisk."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo fdisk /dev/sdc" ]]; then
    print_error "Incorrect. Use: sudo fdisk /dev/sdc"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Command (m for help): d"
  echo "  Partition number (1-4, default 4): 3"
  echo
  echo "  Partition 3 has been deleted."
  echo
  echo "  Command (m for help): w"
  echo "  The partition table has been altered."
  echo "  Calling ioctl() to re-read partition table."
  echo "  Syncing disks."
  echo

  # STEP 6: List partitions on GPT disk using parted
  echo "  Step 6: List partitions on the GPT disk using parted."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo parted /dev/sdd print" ]]; then
    print_error "Incorrect. Use: sudo parted /dev/sdd print"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Model: ATA VBOX HARDDISK (scsi)"
  echo "  Disk /dev/sdd: 21.5GB"
  echo "  Sector size (logical/physical): 512B/512B"
  echo "  Partition Table: gpt"
  echo "  Disk Flags:"
  echo
  echo "  Number  Start   End     Size    File system  Name  Flags"
  echo "   1      1049kB  1075MB  1074MB               data1"
  echo "   2      1075MB  21.5GB  20.4GB               data2"
  echo

  # STEP 7: Create a new 2G GPT partition using gdisk (interactive)
  echo "  Step 7: Create a new 2G partition on the GPT disk using gdisk."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo gdisk /dev/sdd" ]]; then
    print_error "Incorrect. Use: sudo gdisk /dev/sdd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  GPT fdisk (gdisk) version 1.0.7"
  echo
  echo "  Partition table scan:"
  echo "    MBR: protective"
  echo "    BSD: not present"
  echo "    APM: not present"
  echo "    GPT: present"
  echo
  echo "  Found valid GPT with protective MBR; using GPT."
  echo
  echo "  Command (? for help): n"
  echo "  Partition number (3-128, default 3):"
  echo "  First sector (34-41943006, default = 4194304) or {+-}size{KMGTP}:"
  echo "  Last sector (4194304-41943006, default = 41943006) or {+-}size{KMGTP}: +2G"
  echo "  Current type is 'Linux filesystem'"
  echo "  Hex code or GUID (L to show codes, Enter = 8300):"
  echo
  echo "  Command (? for help): w"
  echo "  Final checks complete. About to write GPT data. THIS WILL OVERWRITE EXISTING PARTITIONS!!"
  echo "  Do you want to proceed? (Y/N): y"
  echo "  OK; writing new GUID partition table (GPT) to /dev/sdd."
  echo

  # STEP 8: Refresh partition table (partprobe)
  echo "  Step 8: Refresh the kernel partition table for /dev/sdd."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo partprobe /dev/sdd" ]]; then
    print_error "Incorrect. Use: sudo partprobe /dev/sdd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  "
  echo

  # STEP 9: Verify new GPT partition exists (parted print)
  echo "  Step 9: Verify the new GPT partition exists."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo parted /dev/sdd print" ]]; then
    print_error "Incorrect. Use: sudo parted /dev/sdd print"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Model: ATA VBOX HARDDISK (scsi)"
  echo "  Disk /dev/sdd: 21.5GB"
  echo "  Partition Table: gpt"
  echo
  echo "  Number  Start   End     Size    File system  Name  Flags"
  echo "   1      1049kB  1075MB  1074MB               data1"
  echo "   2      1075MB  21.5GB  20.4GB               data2"
  echo "   3      21.5GB  23.6GB  2147MB               "
  echo

  # STEP 10: Delete the new GPT partition using gdisk
  echo "  Step 10: Delete partition 3 on the GPT disk using gdisk."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "sudo gdisk /dev/sdd" ]]; then
    print_error "Incorrect. Use: sudo gdisk /dev/sdd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Command (? for help): d"
  echo "  Partition number (1-3): 3"
  echo
  echo "  Command (? for help): w"
  echo "  Do you want to proceed? (Y/N): y"
  echo "  OK; writing new GUID partition table (GPT) to /dev/sdd."
  echo

  # STEP 11: Create a GPT partition using parted (non-interactive)
  echo "  Step 11: Create a 3GB partition on /dev/sdd using parted (non-interactive)."
  echo "  Requirement: Use parted -s with mkpart."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "sudo parted -s /dev/sdd mkpart primary 5GiB 8GiB" ]]; then
    print_error "Incorrect. Use: sudo parted -s /dev/sdd mkpart primary 5GiB 8GiB"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  "
  echo

  # STEP 12: Refresh and verify with parted print
  echo "  Step 12: Refresh and verify the new partition with parted."
  read -p "$PROMPT" cmd12
  echo
  if [[ "$cmd12" != "sudo partprobe /dev/sdd && sudo parted /dev/sdd print" ]]; then
    print_error "Incorrect. Use: sudo partprobe /dev/sdd && sudo parted /dev/sdd print"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Model: ATA VBOX HARDDISK (scsi)"
  echo "  Disk /dev/sdd: 21.5GB"
  echo "  Partition Table: gpt"
  echo
  echo "  Number  Start   End     Size    File system  Name  Flags"
  echo "   1      1049kB  1075MB  1074MB               data1"
  echo "   2      1075MB  21.5GB  20.4GB               data2"
  echo "   3      5369MB  8589MB  3220MB               primary"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- listed MBR partitions with fdisk"
  print_info "- created and deleted an MBR partition using fdisk"
  print_info "- listed GPT partitions with parted"
  print_info "- created and deleted a GPT partition using gdisk"
  print_info "- created a GPT partition using parted"
  print_info "- refreshed partition tables with partprobe"
  print_info "You earned $LAB_XP XP."

  award_xp $LAB_XP
  XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
  export XP LEVEL
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
