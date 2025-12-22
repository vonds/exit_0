#!/bin/bash

# Lab 356: RHEL Troubleshooting — filesystem mounted read-only (remount fails until root cause is fixed)
# RHCSA focus: detecting read-only mounts (mount/findmnt), checking kernel/system logs (journalctl -k / dmesg),
# identifying the cause (filesystem errors / needs fsck), recovering by repairing filesystem,
# remounting read-write, and verifying normal write operations.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 356"
LAB_ID="lab356"
LAB_XP=35600
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

PROMPT="student@lab356:~$ > "

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "RHEL Troubleshooting — users report they cannot write to /data (read-only filesystem)."
  center_text "Interactive: confirm read-only mount, identify the cause, repair safely, and recover read-write access."
  echo
  center_text "Press Enter to begin."
  read _
  draw_lab_ui

  # STEP 1
  echo "  Step 1: Confirm /data is mounted read-only."
  read -p "  $PROMPT" cmd1
  if [[ "$cmd1" != "findmnt /data" && "$cmd1" != "mount | grep ' on /data '" ]]; then
    print_error "Incorrect. Use: findmnt /data  (or: mount | grep ' on /data ')"
    read -p "Press Enter to continue..." _
    continue
  fi
  if [[ "$cmd1" == "findmnt /data" ]]; then
    echo "  TARGET SOURCE    FSTYPE OPTIONS"
    echo "  /data  /dev/sdb1 xfs    ro,relatime,seclabel,attr2,inode64,logbufs=8,logbsize=32k,noquota"
  else
    echo "  /dev/sdb1 on /data type xfs (ro,relatime,seclabel,attr2,inode64,logbufs=8,logbsize=32k,noquota)"
  fi

  # STEP 2
  echo
  echo "  Step 2: Attempt a safe remount read-write (it should fail due to underlying errors)."
  read -p "  $PROMPT" cmd2
  if [[ "$cmd2" != "sudo mount -o remount,rw /data" && "$cmd2" != "mount -o remount,rw /data" ]]; then
    print_error "Incorrect. Use: sudo mount -o remount,rw /data"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  mount: /data: cannot remount /dev/sdb1 read-write, is write-protected."
  echo "  mount: /data: cannot remount /dev/sdb1 read-write."

  # STEP 3
  echo
  echo "  Step 3: Check the kernel log for filesystem errors that forced a read-only mount."
  read -p "  $PROMPT" cmd3
  if [[ "$cmd3" != "journalctl -k -b | tail -n 20" && "$cmd3" != "dmesg | tail -n 20" ]]; then
    print_error "Incorrect. Use: journalctl -k -b | tail -n 20  (or: dmesg | tail -n 20)"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  Dec 21 11:02:41 rhel-lab kernel: XFS (sdb1): Metadata CRC error detected at xfs_agi_read_verify+0x5a/0x90 [xfs]"
  echo "  Dec 21 11:02:41 rhel-lab kernel: XFS (sdb1): Unmount and run xfs_repair"
  echo "  Dec 21 11:02:41 rhel-lab kernel: XFS (sdb1): log mount/recovery failed: error -117"
  echo "  Dec 21 11:02:41 rhel-lab kernel: XFS (sdb1): Filesystem has been shut down due to log error (0x2)."
  echo "  Dec 21 11:02:41 rhel-lab kernel: XFS (sdb1): Please unmount the filesystem and rectify the problem(s)."
  echo "  Dec 21 11:02:41 rhel-lab kernel: XFS (sdb1): Remounting filesystem read-only"

  # STEP 4
  echo
  echo "  Step 4: Identify the block device that backs /data."
  read -p "  $PROMPT" cmd4
  if [[ "$cmd4" != "findmnt -n -o SOURCE /data" && "$cmd4" != "lsblk -f" ]]; then
    print_error "Incorrect. Use: findmnt -n -o SOURCE /data  (or: lsblk -f)"
    read -p "Press Enter to continue..." _
    continue
  fi
  if [[ "$cmd4" == "findmnt -n -o SOURCE /data" ]]; then
    echo "  /dev/sdb1"
  else
    echo "  NAME   FSTYPE FSVER LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINTS"
    echo "  sda"
    echo "  ├─sda1 xfs          boot  6b9d3b8a-7d4a-4c6a-8f4c-3e8b6f2d2a11  380M    23%   /boot"
    echo "  └─sda2 xfs          root  4f1c2d8e-9c0a-4a9a-a3d1-7f3c2b1a0e55  28G     22%   /"
    echo "  sdb"
    echo "  └─sdb1 xfs          data  9c9c9c9c-aaaa-bbbb-cccc-121212121212                /data"
  fi

  # STEP 5
  echo
  echo "  Step 5: Unmount /data so it can be repaired."
  read -p "  $PROMPT" cmd5
  if [[ "$cmd5" != "sudo umount /data" && "$cmd5" != "umount /data" ]]; then
    print_error "Incorrect. Use: sudo umount /data"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  "

  # STEP 6
  echo
  echo "  Step 6: Repair the XFS filesystem on the device."
  read -p "  $PROMPT" cmd6
  if [[ "$cmd6" != "sudo xfs_repair /dev/sdb1" ]]; then
    print_error "Incorrect. Use: sudo xfs_repair /dev/sdb1"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  Phase 1 - find and verify superblock..."
  echo "  Phase 2 - using internal log"
  echo "  - zero log..."
  echo "  - scan filesystem freespace and inode maps..."
  echo "  Phase 3 - for each AG..."
  echo "  - scan and clear agi unlinked lists..."
  echo "  - process known inodes and perform inode discovery..."
  echo "  Phase 4 - check for duplicate blocks..."
  echo "  Phase 5 - rebuild AG headers and trees..."
  echo "  Phase 6 - check inode connectivity..."
  echo "  Phase 7 - verify and correct link counts..."
  echo "  done"

  # STEP 7
  echo
  echo "  Step 7: Mount /data again."
  read -p "  $PROMPT" cmd7
  if [[ "$cmd7" != "sudo mount /data" && "$cmd7" != "mount /data" ]]; then
    print_error "Incorrect. Use: sudo mount /data"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  "

  # STEP 8
  echo
  echo "  Step 8: Verify /data is now mounted read-write."
  read -p "  $PROMPT" cmd8
  if [[ "$cmd8" != "findmnt /data" && "$cmd8" != "mount | grep ' on /data '" ]]; then
    print_error "Incorrect. Use: findmnt /data  (or: mount | grep ' on /data ')"
    read -p "Press Enter to continue..." _
    continue
  fi
  if [[ "$cmd8" == "findmnt /data" ]]; then
    echo "  TARGET SOURCE    FSTYPE OPTIONS"
    echo "  /data  /dev/sdb1 xfs    rw,relatime,seclabel,attr2,inode64,logbufs=8,logbsize=32k,noquota"
  else
    echo "  /dev/sdb1 on /data type xfs (rw,relatime,seclabel,attr2,inode64,logbufs=8,logbsize=32k,noquota)"
  fi

  # STEP 9
  echo
  echo "  Step 9: Prove write access by creating a file on /data."
  read -p "  $PROMPT" cmd9
  if [[ "$cmd9" != "touch /data/healthcheck.txt" && "$cmd9" != "sudo touch /data/healthcheck.txt" ]]; then
    print_error "Incorrect. Use: touch /data/healthcheck.txt"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  "

  # STEP 10
  echo
  echo "  Step 10: Verify the file exists."
  read -p "  $PROMPT" cmd10
  if [[ "$cmd10" != "ls -l /data/healthcheck.txt" && "$cmd10" != "stat /data/healthcheck.txt" ]]; then
    print_error "Incorrect. Use: ls -l /data/healthcheck.txt  (or: stat /data/healthcheck.txt)"
    read -p "Press Enter to continue..." _
    continue
  fi
  if [[ "$cmd10" == "ls -l /data/healthcheck.txt" ]]; then
    echo "  -rw-r--r--. 1 root root 0 Dec 21 11:06 /data/healthcheck.txt"
  else
    echo "    File: /data/healthcheck.txt"
    echo "    Size: 0          Blocks: 0          IO Block: 4096   regular empty file"
    echo "Device: 08h/8d Inode: 131131      Links: 1"
    echo "Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)"
  fi

  print_success "Excellent work!"
  print_info "You earned $LAB_XP XP for completing this lab!"
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

  if [[ "$choice" == "2" ]]; then
    exit 0
  fi
done
