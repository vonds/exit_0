#!/bin/bash

# Lab 372: RHEL Storage — Identify Unused Block Devices and Prepare Them for Use
# Focus: finding unpartitioned/unmounted disks and safely preparing them for use
# Key skills: lsblk, blkid, wipefs, parted, mkfs, mkdir, mount, /etc/fstab, and verification.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 372: Identify Unused Block Devices and Prepare Them for Use"
LAB_ID="lab372"
LAB_XP=37200
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
  center_text "A server has additional disks attached but they are not in use."
  center_text "You must identify unused block devices and prepare one for mounting."
  echo
  center_text "Goal: locate an unused disk, partition it, create a filesystem, mount it,"
  center_text "and verify it is ready for use."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Identify unused disks (no partitions, no filesystem, no mountpoint)
  echo "  Step 1: List block devices and identify disks that appear unused."
  read -p "  lab@rhel-lab372:~$ " cmd1
  echo
  if [[ "$cmd1" != "lsblk" && \
        "$cmd1" != "lsblk -f" && \
        "$cmd1" != "sudo lsblk" && \
        "$cmd1" != "sudo lsblk -f" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  NAME   FSTYPE      LABEL UUID                                 MOUNTPOINT"
  echo "  sda"
  echo "  ├─sda1 xfs               aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee  /boot"
  echo "  └─sda2 xfs               ffffffff-1111-2222-3333-444444444444  /"
  echo "  sdb"
  echo "  sdc"
  echo

  # STEP 2: Confirm there are no existing signatures (avoid clobbering used disks)
  echo "  Step 2: Check for existing filesystem/RAID/LVM signatures on /dev/sdb."
  read -p "  lab@rhel-lab372:~$ " cmd2
  echo
  if [[ "$cmd2" != "sudo wipefs /dev/sdb" && \
        "$cmd2" != "sudo blkid /dev/sdb" && \
        "$cmd2" != "sudo fdisk -l /dev/sdb" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd2" == *"wipefs"* ]]; then
    echo "  (no output)"
  else
    echo "  (no signatures found)"
  fi
  echo

  # STEP 3: Create a partition table and a single primary partition (1GiB)
  echo "  Step 3: Create a GPT label and a single partition using most of the disk on /dev/sdb."
  read -p "  lab@rhel-lab372:~$ " cmd3
  echo
  if [[ "$cmd3" != "sudo parted -s /dev/sdb mklabel gpt" && \
        "$cmd3" != "sudo parted -s /dev/sdb mkpart primary 1MiB 100%" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  # Require both operations to be performed (mklabel then mkpart) in two consecutive inputs.
  if [[ "$cmd3" == "sudo parted -s /dev/sdb mklabel gpt" ]]; then
    echo "  (no output)"
    echo
    echo "  Step 4: Create the partition (use most of the disk)."
    read -p "  lab@rhel-lab372:~$ " cmd4
    echo
    if [[ "$cmd4" != "sudo parted -s /dev/sdb mkpart primary 1MiB 100%" ]]; then
      print_error "Incorrect."
      read -p "Press Enter to try again..." _
      continue
    fi
    echo "  (no output)"
    echo
  else
    # They tried mkpart first; require mklabel next
    echo "  (no output)"
    echo
    echo "  Step 4: Ensure the disk has a GPT label."
    read -p "  lab@rhel-lab372:~$ " cmd4
    echo
    if [[ "$cmd4" != "sudo parted -s /dev/sdb mklabel gpt" ]]; then
      print_error "Incorrect."
      read -p "Press Enter to try again..." _
      continue
    fi
    echo "  (no output)"
    echo
  fi

  # STEP 5: Inform kernel of partition changes
  echo "  Step 5: Inform the kernel of the partition changes and confirm /dev/sdb1 exists."
  read -p "  lab@rhel-lab372:~$ " cmd5
  echo
  if [[ "$cmd5" != "sudo partprobe /dev/sdb" && \
        "$cmd5" != "sudo udevadm settle" && \
        "$cmd5" != "lsblk /dev/sdb" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  NAME MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT"
  echo "  sdb    8:16   0  1.0G  0 disk"
  echo "  └─sdb1 8:17   0 1023M  0 part"
  echo

  # STEP 6: Create a filesystem on the new partition
  echo "  Step 6: Create an XFS filesystem on /dev/sdb1."
  read -p "  lab@rhel-lab372:~$ " cmd6
  echo
  if [[ "$cmd6" != "sudo mkfs.xfs -f /dev/sdb1" && \
        "$cmd6" != "sudo mkfs.xfs /dev/sdb1" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  meta-data=/dev/sdb1              isize=512    agcount=4, agsize=65536 blks"
  echo "  data     =                       bsize=4096   blocks=261888, imaxpct=25"
  echo "  naming   =version 2              bsize=4096   ascii-ci=0, ftype=1"
  echo "  log      =internal log           bsize=4096   blocks=16384, version=2"
  echo "  realtime =none                   extsz=4096   blocks=0, rtextents=0"
  echo

  # STEP 7: Create mount point and mount it
  echo "  Step 7: Create a mount point at /mnt/unused and mount /dev/sdb1."
  read -p "  lab@rhel-lab372:~$ " cmd7
  echo
  if [[ "$cmd7" != "sudo mkdir -p /mnt/unused" && \
        "$cmd7" != "sudo mount /dev/sdb1 /mnt/unused" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  # Require both operations (mkdir then mount) in two inputs
  if [[ "$cmd7" == "sudo mkdir -p /mnt/unused" ]]; then
    echo "  (no output)"
    echo
    echo "  Step 8: Mount the filesystem."
    read -p "  lab@rhel-lab372:~$ " cmd8
    echo
    if [[ "$cmd8" != "sudo mount /dev/sdb1 /mnt/unused" ]]; then
      print_error "Incorrect."
      read -p "Press Enter to try again..." _
      continue
    fi
    echo "  (no output)"
    echo
  else
    echo "  (no output)"
    echo
    echo "  Step 8: Create the mount point."
    read -p "  lab@rhel-lab372:~$ " cmd8
    echo
    if [[ "$cmd8" != "sudo mkdir -p /mnt/unused" ]]; then
      print_error "Incorrect."
      read -p "Press Enter to try again..." _
      continue
    fi
    echo "  (no output)"
    echo
  fi

  # STEP 9: Persist mount using UUID in /etc/fstab
  echo "  Step 9: Get the UUID for /dev/sdb1 so you can create a persistent mount."
  read -p "  lab@rhel-lab372:~$ " cmd9
  echo
  if [[ "$cmd9" != "sudo blkid /dev/sdb1" && \
        "$cmd9" != "blkid /dev/sdb1" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  /dev/sdb1: UUID=\"12121212-3434-5656-7878-909090909090\" TYPE=\"xfs\" PARTUUID=\"abcd1234-01\""
  echo

  echo "  Step 10: Add a persistent /etc/fstab entry for /mnt/unused using the UUID."
  read -p "  lab@rhel-lab372:~$ " cmd10
  echo
  if [[ "$cmd10" != "sudo bash -lc 'echo \"UUID=12121212-3434-5656-7878-909090909090 /mnt/unused xfs defaults 0 0\" >> /etc/fstab'" && \
        "$cmd10" != "sudo sh -c 'echo \"UUID=12121212-3434-5656-7878-909090909090 /mnt/unused xfs defaults 0 0\" >> /etc/fstab'" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (entry appended)"
  echo

  # STEP 11: Validate fstab and mount state
  echo "  Step 11: Validate mounts from /etc/fstab and confirm /mnt/unused is mounted."
  read -p "  lab@rhel-lab372:~$ " cmd11
  echo
  if [[ "$cmd11" != "sudo mount -a" && \
        "$cmd11" != "findmnt /mnt/unused" && \
        "$cmd11" != "df -h /mnt/unused" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd11" == "sudo mount -a" ]]; then
    echo "  (no output)"
  else
    echo "  TARGET       SOURCE    FSTYPE OPTIONS"
    echo "  /mnt/unused  /dev/sdb1 xfs    rw,relatime,seclabel,attr2,inode64,noquota"
  fi
  echo

  print_success "Great job."
  print_info "You identified unused block devices and safely prepared /dev/sdb for use by:"
  print_info "- verifying it had no signatures"
  print_info "- partitioning it and creating a filesystem"
  print_info "- mounting it and persisting the mount using UUID in /etc/fstab"
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
