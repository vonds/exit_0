#!/bin/bash

# Lab 460: RHEL Storage Management — Create Partition, XFS Filesystem, Mount, and Persist via fstab

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 460: Create and Persist XFS Partition"
LAB_ID="lab460"
LAB_XP=46000
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
  center_text "A new 5GiB NVMe disk has been attached to a RHEL system."
  center_text "The disk (/dev/nvme) currently has no partitions."
  center_text "You must partition it, create an XFS filesystem, mount it at /data,"
  center_text "and ensure it mounts automatically after reboot."
  echo
  center_text "Goal: partition, format, mount, persist, reboot, and validate."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: List disks and confirm /dev/nvme has no partitions
  echo "  Step 1: List all disks and partitions (confirm /dev/nvme has no partitions)."
  read -p "  lab@rhel-lab460:~$ " cmd1
  echo
  if [[ "$cmd1" != "lsblk" && "$cmd1" != "lsblk -f" && "$cmd1" != "sudo lsblk" && "$cmd1" != "sudo lsblk -f" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  NAME        MAJ:MIN RM SIZE RO TYPE MOUNTPOINT"
  echo "  vda         252:0    0  20G  0 disk"
  echo "  ├─vda1      252:1    0  19G  0 part /"
  echo "  └─vda2      252:2    0   1G  0 part [SWAP]"
  echo "  nvme        259:0    0   5G  0 disk"
  echo

  # STEP 2: Open disk with fdisk
  echo "  Step 2: Open /dev/nvme using fdisk."
  read -p "  lab@rhel-lab460:~$ " cmd2
  echo
  if [[ "$cmd2" != "sudo fdisk /dev/nvme" && "$cmd2" != "fdisk /dev/nvme" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  # --- Simulated fdisk session (realistic Enter defaults) ---
  echo "  Welcome to fdisk (util-linux 2.37.4)."
  echo "  Changes will remain in memory only, until you decide to write them."
  echo "  Be careful before using the write command."
  echo

  echo "  fdisk Step 2a: Create a new partition."
  read -p "  Command (m for help): " fd1
  echo
  if [[ "$fd1" != "n" ]]; then
    print_error "Incorrect. In fdisk, start partition creation with: n"
    read -p "Press Enter to try again..." _
    continue
  fi

  echo "  Partition type"
  echo "     p   primary (0 primary, 0 extended, 4 free)"
  echo "     e   extended (container for logical partitions)"

  echo "  fdisk Step 2b: Press Enter to accept default partition type."
  read -p "  Select (default p): " fd2
  echo
  if [[ -n "$fd2" ]]; then
    print_error "Incorrect. Press Enter for the default (leave it blank)."
    read -p "Press Enter to try again..." _
    continue
  fi

  echo "  fdisk Step 2c: Press Enter to accept default partition number (1)."
  read -p "  Partition number (1-4, default 1): " fd3
  echo
  if [[ -n "$fd3" ]]; then
    print_error "Incorrect. Press Enter for the default partition number."
    read -p "Press Enter to try again..." _
    continue
  fi

  echo "  fdisk Step 2d: Press Enter to accept default first sector."
  read -p "  First sector (2048-10485759, default 2048): " fd4
  echo
  if [[ -n "$fd4" ]]; then
    print_error "Incorrect. Press Enter for the default first sector."
    read -p "Press Enter to try again..." _
    continue
  fi

  echo "  fdisk Step 2e: Press Enter to accept default last sector (use full disk)."
  read -p "  Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-10485759, default 10485759): " fd5
  echo
  if [[ -n "$fd5" ]]; then
    print_error "Incorrect. Press Enter for the default last sector (full disk)."
    read -p "Press Enter to try again..." _
    continue
  fi

  echo "  Created a new partition 1 of type 'Linux' and of size 5 GiB."
  echo

  echo "  fdisk Step 2f: Write the partition table to disk."
  read -p "  Command (m for help): " fd6
  echo
  if [[ "$fd6" != "w" ]]; then
    print_error "Incorrect. In fdisk, write changes with: w"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  The partition table has been altered."
  echo "  Calling ioctl() to re-read partition table."
  echo "  Syncing disks."
  echo

  # STEP 3: Verify partition table with fdisk -l
  echo "  Step 3: Verify the new partition exists."
  read -p "  lab@rhel-lab460:~$ " cmd3
  echo
  if [[ "$cmd3" != "sudo fdisk -l" && "$cmd3" != "fdisk -l" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Disk /dev/nvme: 5 GiB, 5368709120 bytes, 10485760 sectors"
  echo "  Device       Boot Start      End  Sectors Size Id Type"
  echo "  /dev/nvme1         2048 10485759 10483712   5G 83 Linux"
  echo

  # STEP 4: Create XFS filesystem
  echo "  Step 4: Create an XFS filesystem on /dev/nvme1."
  read -p "  lab@rhel-lab460:~$ " cmd4
  echo
  if [[ "$cmd4" != "sudo mkfs.xfs /dev/nvme1" && "$cmd4" != "mkfs.xfs /dev/nvme1" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  meta-data=/dev/nvme1              isize=512    agcount=4, agsize=327616 blks"
  echo "           =                       sectsz=512   attr=2, projid32bit=1"
  echo "           =                       crc=1        finobt=1, sparse=1, rmapbt=0"
  echo "  data     =                       bsize=4096   blocks=1310464, imaxpct=25"
  echo "           =                       sunit=0      swidth=0 blks"
  echo "  naming   =version 2              bsize=4096   ascii-ci=0, ftype=1"
  echo "  log      =internal log           bsize=4096   blocks=2560, version=2"
  echo "           =                       sectsz=512   sunit=0 blks, lazy-count=1"
  echo "  realtime =none                   extsz=4096   blocks=0, rtextents=0"
  echo

  # STEP 5: Confirm filesystem with blkid
  echo "  Step 5: Confirm the filesystem type with blkid."
  read -p "  lab@rhel-lab460:~$ " cmd5
  echo
  if [[ "$cmd5" != "sudo blkid /dev/nvme1" && "$cmd5" != "blkid /dev/nvme1" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  /dev/nvme1: UUID=\"7c7c7c7c-1111-2222-3333-444444444444\" TYPE=\"xfs\" PARTUUID=\"abababab-01\""
  echo

  # STEP 6: Create mount point
  echo "  Step 6: Create mount point /data."
  read -p "  lab@rhel-lab460:~$ " cmd6
  echo
  if [[ "$cmd6" != "sudo mkdir -p /data" && "$cmd6" != "mkdir -p /data" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  # STEP 7: Mount the filesystem
  echo "  Step 7: Mount /dev/nvme1 to /data."
  read -p "  lab@rhel-lab460:~$ " cmd7
  echo
  if [[ "$cmd7" != "sudo mount /dev/nvme1 /data" && "$cmd7" != "mount /dev/nvme1 /data" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  # STEP 8: Verify mount with df -h
  echo "  Step 8: Verify the mount."
  read -p "  lab@rhel-lab460:~$ " cmd8
  echo
  if [[ "$cmd8" != "df -h" && "$cmd8" != "sudo df -h" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Filesystem      Size  Used Avail Use% Mounted on"
  echo "  /dev/vda1        19G  6.7G   13G  35% /"
  echo "  /dev/nvme1      5.0G   33M  5.0G   1% /data"
  echo

  # STEP 9: Edit /etc/fstab
  echo "  Step 9: Open /etc/fstab for editing."
  read -p "  lab@rhel-lab460:~$ " cmd9
  echo
  if [[ "$cmd9" != "sudo vim /etc/fstab" && "$cmd9" != "sudo nano /etc/fstab" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (editor opened)"
  echo

  # STEP 10: Add the fstab line (NEW PROMPT)
  echo "  Step 10: In the editor, add an /etc/fstab entry that will mount /dev/nvme1 at /data as XFS on boot."
  read -p "  : " fstab_line
  echo
  if [[ "$fstab_line" != "/dev/nvme1 /data xfs defaults 0 0" ]]; then
    print_error "Incorrect. Type the line exactly (with single spaces as shown)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (line added)"
  echo "  (saved and exited)"
  echo

  # STEP 11: Reboot
  echo "  Step 11: Reboot the system."
  read -p "  lab@rhel-lab460:~$ " cmd11
  echo
  if [[ "$cmd11" != "sudo reboot" && "$cmd11" != "reboot" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Rebooting..."
  echo

  # STEP 12: Verify mount after reboot
  echo "  Step 12: After reboot, verify /data is mounted."
  read -p "  lab@rhel-lab460:~$ " cmd12
  echo
  if [[ "$cmd12" != "df -h | grep /data" && \
        "$cmd12" != "mount | grep /data" && \
        "$cmd12" != "findmnt /data" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd12" == *"findmnt"* ]]; then
    echo "  TARGET SOURCE     FSTYPE OPTIONS"
    echo "  /data  /dev/nvme1 xfs    rw,relatime,seclabel,attr2,inode64,logbufs=8,logbsize=32k"
    echo
  else
    echo "  /dev/nvme1      5.0G   33M  5.0G   1% /data"
    echo
  fi

  # STEP 13: Unmount the disk
  echo "  Step 13: Unmount /data."
  read -p "  lab@rhel-lab460:~$ " cmd13
  echo
  if [[ "$cmd13" != "sudo umount /data" && "$cmd13" != "umount /data" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  # STEP 14: Mount again using /etc/fstab (mount -a)
  echo "  Step 14: Mount using /etc/fstab."
  read -p "  lab@rhel-lab460:~$ " cmd14
  echo
  if [[ "$cmd14" != "sudo mount -a" && "$cmd14" != "mount -a" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  # STEP 15: Final verification
  echo "  Step 15: Verify /data is mounted again."
  read -p "  lab@rhel-lab460:~$ " cmd15
  echo
  if [[ "$cmd15" != "df -h | grep /data" && \
        "$cmd15" != "mount | grep /data" && \
        "$cmd15" != "findmnt /data" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  /dev/nvme1      5.0G   33M  5.0G   1% /data"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- partitioned a new disk interactively with fdisk using Enter-defaults"
  print_info "- created an XFS filesystem on /dev/nvme1"
  print_info "- mounted it at /data and verified with df/findmnt"
  print_info "- persisted the mount in /etc/fstab"
  print_info "- validated mounting after reboot and via mount -a"
  print_info "You earned $LAB_XP XP."
  award_xp $LAB_XP

  XP=$(jq '.XP' "$SAVE_JSON")
  LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
  export XP
  export LEVEL
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
