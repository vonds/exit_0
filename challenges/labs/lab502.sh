#!/bin/bash

# Lab 502: Add Partitions, Logical Volumes, and Swap Non-Destructively

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 502: Non-Destructive Storage Expansion"
LAB_ID="lab502"
LAB_XP=50200
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab502:~$ "

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
  center_text "Your host needs additional storage and swap, but the system must stay online."
  center_text "You have a new disk at /dev/sdb and an existing VG named vg_data."
  center_text "You must:"
  center_text "  1) Create a NEW 2G partition on /dev/sdb and mount it at /mnt/newdata (persistent)."
  center_text "  2) Create a NEW LV (3G) in vg_data and mount it at /mnt/storage (persistent)."
  center_text "  3) Extend that LV by +2G and grow the filesystem ONLINE."
  center_text "  4) Create a NEW 1G swap LV in vg_data, enable it, and persist it."
  echo
  center_text "Assumptions in this lab:"
  center_text "- The new partition will be /dev/sdb1"
  center_text "- The partition will be formatted ext4"
  center_text "- vg_data already exists and has free space"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  # STEP 1: Confirm disk present
  echo "  Step 1: Confirm the target disk exists (/dev/sdb)."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "lsblk" && "$cmd1" != "lsblk -f" ]]; then
    print_error "Incorrect. Use: lsblk"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  NAME            FSTYPE      LABEL UUID                                 MOUNTPOINT"
  echo "  sda"
  echo "  ├─sda1          xfs               9c5a1a2b-3c4d-5e6f-7a8b-9c0d1e2f3a4b  /"
  echo "  └─sda2          swap              7d7d7d7d-7d7d-7d7d-7d7d-7d7d7d7d7d7d  [SWAP]"
  echo "  sdb"
  echo

  # STEP 2: Create a new 2G partition with fdisk
  echo "  Step 2: Start fdisk on /dev/sdb (you will create a new 2G partition)."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo fdisk /dev/sdb" ]]; then
    print_error "Incorrect. Use: sudo fdisk /dev/sdb"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (fdisk opened)"
  echo "  Inside fdisk, you will create a new partition."
  echo

  # STEP 3: Simulate the key fdisk inputs
  echo "  Step 3: In fdisk, create a new partition (n) of size +2G, then write (w)."
  echo "  Type the three tokens in order (space-separated): n +2G w"
  read -p "  fdisk> " fdisk_tokens
  echo
  if [[ "$fdisk_tokens" != "n +2G w" ]]; then
    print_error "Incorrect. Expected: n +2G w"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  The partition table has been altered."
  echo "  Calling ioctl() to re-read partition table."
  echo "  Syncing disks."
  echo

  # STEP 4: Reload partition table without reboot
  echo "  Step 4: Reload the partition table so the kernel sees /dev/sdb1 (no reboot)."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo partprobe /dev/sdb" ]]; then
    print_error "Incorrect. Use: sudo partprobe /dev/sdb"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (partition table re-read)"
  echo

  # STEP 5: Make an ext4 filesystem on the new partition
  echo "  Step 5: Create an ext4 filesystem on /dev/sdb1."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo mkfs.ext4 /dev/sdb1" ]]; then
    print_error "Incorrect. Use: sudo mkfs.ext4 /dev/sdb1"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  mke2fs 1.46.5 (30-Dec-2021)"
  echo "  Creating filesystem with 524288 4k blocks and 131072 inodes"
  echo "  Filesystem UUID: 11111111-2222-3333-4444-555555555555"
  echo "  Superblock backups stored on blocks: 32768, 98304, 163840, 229376, 294912"
  echo "  Allocating group tables: done"
  echo "  Writing inode tables: done"
  echo "  Creating journal (16384 blocks): done"
  echo "  Writing superblocks and filesystem accounting information: done"
  echo

  # STEP 6: Create mount point and mount
  echo "  Step 6: Create /mnt/newdata."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo mkdir /mnt/newdata" ]]; then
    print_error "Incorrect. Use: sudo mkdir /mnt/newdata"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (directory created)"
  echo

  echo "  Step 7: Mount /dev/sdb1 at /mnt/newdata."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo mount /dev/sdb1 /mnt/newdata" ]]; then
    print_error "Incorrect. Use: sudo mount /dev/sdb1 /mnt/newdata"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (mounted)"
  echo

  # STEP 8: Get UUID for partition
  echo "  Step 8: Get the UUID for /dev/sdb1 using blkid."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo blkid /dev/sdb1" && "$cmd8" != "blkid /dev/sdb1" ]]; then
    print_error "Incorrect. Use: sudo blkid /dev/sdb1"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  /dev/sdb1: UUID=\"11111111-2222-3333-4444-555555555555\" TYPE=\"ext4\""
  echo

  # STEP 9: Open /etc/fstab
  echo "  Step 9: Open /etc/fstab to add a persistent mount for /mnt/newdata."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo vim /etc/fstab" && "$cmd9" != "vim /etc/fstab" ]]; then
    print_error "Incorrect. Use: sudo vim /etc/fstab"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (editor opened)"
  echo

  # STEP 10: User must type exact fstab line for partition mount
  echo "  Step 10: Type the exact /etc/fstab line to mount /dev/sdb1 at /mnt/newdata by UUID."
  read -p "  fstab> " fstab_newdata
  echo
  if [[ "$fstab_newdata" != "UUID=11111111-2222-3333-4444-555555555555  /mnt/newdata  ext4  defaults  0  2" ]]; then
    print_error "Incorrect /etc/fstab line."
    print_info "Expected:"
    echo "  UUID=11111111-2222-3333-4444-555555555555  /mnt/newdata  ext4  defaults  0  2"
    echo
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (line entered into /etc/fstab)"
  echo "  (file saved and closed)"
  echo

  # STEP 11: Test fstab safely
  echo "  Step 11: Test /etc/fstab entries safely (no reboot)."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "sudo mount -a" && "$cmd11" != "mount -a" ]]; then
    print_error "Incorrect. Use: sudo mount -a"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (fstab entries mounted)"
  echo

  # STEP 12: Create LV (3G)
  echo "  Step 12: Create a new 3G logical volume named lv_storage in vg_data."
  read -p "$PROMPT" cmd12
  echo
  if [[ "$cmd12" != "sudo lvcreate -L 3G -n lv_storage vg_data" ]]; then
    print_error "Incorrect. Use: sudo lvcreate -L 3G -n lv_storage vg_data"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Logical volume \"lv_storage\" created."
  echo

  # STEP 13: Format LV
  echo "  Step 13: Format the LV with ext4."
  read -p "$PROMPT" cmd13
  echo
  if [[ "$cmd13" != "sudo mkfs.ext4 /dev/vg_data/lv_storage" ]]; then
    print_error "Incorrect. Use: sudo mkfs.ext4 /dev/vg_data/lv_storage"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  mke2fs 1.46.5 (30-Dec-2021)"
  echo "  Filesystem UUID: aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
  echo "  (filesystem created)"
  echo

  # STEP 14: Mount LV
  echo "  Step 14: Create /mnt/storage."
  read -p "$PROMPT" cmd14
  echo
  if [[ "$cmd14" != "sudo mkdir /mnt/storage" ]]; then
    print_error "Incorrect. Use: sudo mkdir /mnt/storage"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (directory created)"
  echo

  echo "  Step 15: Mount /dev/vg_data/lv_storage at /mnt/storage."
  read -p "$PROMPT" cmd15
  echo
  if [[ "$cmd15" != "sudo mount /dev/vg_data/lv_storage /mnt/storage" ]]; then
    print_error "Incorrect. Use: sudo mount /dev/vg_data/lv_storage /mnt/storage"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (mounted)"
  echo

  # STEP 16: Get UUID of LV
  echo "  Step 16: Get the UUID for /dev/vg_data/lv_storage."
  read -p "$PROMPT" cmd16
  echo
  if [[ "$cmd16" != "sudo blkid /dev/vg_data/lv_storage" && "$cmd16" != "blkid /dev/vg_data/lv_storage" ]]; then
    print_error "Incorrect. Use: sudo blkid /dev/vg_data/lv_storage"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  /dev/vg_data/lv_storage: UUID=\"aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee\" TYPE=\"ext4\""
  echo

  # STEP 17: User types LV mount line to fstab
  echo "  Step 17: Type the exact /etc/fstab line to mount lv_storage at /mnt/storage by UUID."
  read -p "  fstab> " fstab_storage
  echo
  if [[ "$fstab_storage" != "UUID=aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee  /mnt/storage  ext4  defaults  0  2" ]]; then
    print_error "Incorrect /etc/fstab line."
    print_info "Expected:"
    echo "  UUID=aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee  /mnt/storage  ext4  defaults  0  2"
    echo
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (line entered into /etc/fstab)"
  echo

  # STEP 18: Test fstab again
  echo "  Step 18: Test /etc/fstab mounts again."
  read -p "$PROMPT" cmd18
  echo
  if [[ "$cmd18" != "sudo mount -a" && "$cmd18" != "mount -a" ]]; then
    print_error "Incorrect. Use: sudo mount -a"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (fstab entries mounted)"
  echo

  # STEP 19: Extend LV by +2G (online)
  echo "  Step 19: Extend lv_storage by +2G (non-destructive)."
  read -p "$PROMPT" cmd19
  echo
  if [[ "$cmd19" != "sudo lvextend -L +2G /dev/vg_data/lv_storage" ]]; then
    print_error "Incorrect. Use: sudo lvextend -L +2G /dev/vg_data/lv_storage"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Size of logical volume vg_data/lv_storage changed from 3.00 GiB to 5.00 GiB."
  echo "  Logical volume vg_data/lv_storage successfully resized."
  echo

  # STEP 20: Grow ext4 filesystem online
  echo "  Step 20: Grow the ext4 filesystem to fill the extended LV (online)."
  read -p "$PROMPT" cmd20
  echo
  if [[ "$cmd20" != "sudo resize2fs /dev/vg_data/lv_storage" ]]; then
    print_error "Incorrect. Use: sudo resize2fs /dev/vg_data/lv_storage"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  resize2fs 1.46.5 (30-Dec-2021)"
  echo "  Filesystem at /dev/vg_data/lv_storage is mounted on /mnt/storage; on-line resizing required"
  echo "  old_desc_blocks = 1, new_desc_blocks = 1"
  echo "  The filesystem on /dev/vg_data/lv_storage is now 1310720 (4k) blocks long."
  echo

  # STEP 21: Verify new size
  echo "  Step 21: Verify the new size of /mnt/storage."
  read -p "$PROMPT" cmd21
  echo
  if [[ "$cmd21" != "df -h /mnt/storage" && "$cmd21" != "sudo df -h /mnt/storage" ]]; then
    print_error "Incorrect. Use: df -h /mnt/storage"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Filesystem                 Size  Used Avail Use% Mounted on"
  echo "  /dev/vg_data/lv_storage     4.9G   24K  4.6G   1% /mnt/storage"
  echo

  # STEP 22: Create swap LV
  echo "  Step 22: Create a new 1G logical volume named lv_swap in vg_data."
  read -p "$PROMPT" cmd22
  echo
  if [[ "$cmd22" != "sudo lvcreate -L 1G -n lv_swap vg_data" ]]; then
    print_error "Incorrect. Use: sudo lvcreate -L 1G -n lv_swap vg_data"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Logical volume \"lv_swap\" created."
  echo

  # STEP 23: mkswap
  echo "  Step 23: Format the new LV as swap."
  read -p "$PROMPT" cmd23
  echo
  if [[ "$cmd23" != "sudo mkswap /dev/vg_data/lv_swap" ]]; then
    print_error "Incorrect. Use: sudo mkswap /dev/vg_data/lv_swap"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Setting up swapspace version 1, size = 1024 MiB (1073737728 bytes)"
  echo "  no label, UUID=99999999-8888-7777-6666-555555555555"
  echo

  # STEP 24: swapon
  echo "  Step 24: Enable the new swap immediately."
  read -p "$PROMPT" cmd24
  echo
  if [[ "$cmd24" != "sudo swapon /dev/vg_data/lv_swap" ]]; then
    print_error "Incorrect. Use: sudo swapon /dev/vg_data/lv_swap"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (swap enabled)"
  echo

  # STEP 25: Verify swap
  echo "  Step 25: Verify swap is active."
  read -p "$PROMPT" cmd25
  echo
  if [[ "$cmd25" != "sudo swapon --show" && "$cmd25" != "swapon --show" ]]; then
    print_error "Incorrect. Use: sudo swapon --show"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  NAME                   TYPE      SIZE  USED PRIO"
  echo "  /dev/vg_data/lv_swap    partition 1024M   0B   -2"
  echo "  /dev/sda2              partition   2G  24M   -3"
  echo

  # STEP 26: Get UUID for swap LV
  echo "  Step 26: Get the UUID for the swap LV."
  read -p "$PROMPT" cmd26
  echo
  if [[ "$cmd26" != "sudo blkid /dev/vg_data/lv_swap" && "$cmd26" != "blkid /dev/vg_data/lv_swap" ]]; then
    print_error "Incorrect. Use: sudo blkid /dev/vg_data/lv_swap"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  /dev/vg_data/lv_swap: UUID=\"99999999-8888-7777-6666-555555555555\" TYPE=\"swap\""
  echo

  # STEP 27: User types swap fstab line
  echo "  Step 27: Type the exact /etc/fstab line to make this swap persistent by UUID."
  read -p "  fstab> " fstab_swap
  echo
  if [[ "$fstab_swap" != "UUID=99999999-8888-7777-6666-555555555555  none  swap  sw  0  0" ]]; then
    print_error "Incorrect /etc/fstab swap line."
    print_info "Expected:"
    echo "  UUID=99999999-8888-7777-6666-555555555555  none  swap  sw  0  0"
    echo
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (swap line entered into /etc/fstab)"
  echo

  # STEP 28: Test swap persistence logic safely
  echo "  Step 28: Test swap persistence logic (swapoff -a, then swapon -a)."
  read -p "$PROMPT" cmd28
  echo
  if [[ "$cmd28" != "sudo swapoff -a" ]]; then
    print_error "Incorrect. Use: sudo swapoff -a"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (all swap disabled)"
  echo

  echo "  Step 29: Re-enable swap from /etc/fstab."
  read -p "$PROMPT" cmd29
  echo
  if [[ "$cmd29" != "sudo swapon -a" ]]; then
    print_error "Incorrect. Use: sudo swapon -a"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (swap enabled from /etc/fstab)"
  echo

  echo "  Step 30: Verify swap is active again."
  read -p "$PROMPT" cmd30
  echo
  if [[ "$cmd30" != "sudo swapon --show" && "$cmd30" != "swapon --show" ]]; then
    print_error "Incorrect. Use: sudo swapon --show"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  NAME                   TYPE      SIZE  USED PRIO"
  echo "  /dev/vg_data/lv_swap    partition 1024M   0B   -2"
  echo "  /dev/sda2              partition   2G  24M   -3"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- created and mounted a new partition non-destructively"
  print_info "- persisted the mount by UUID in /etc/fstab (typed by you)"
  print_info "- created, mounted, and persisted a new LV filesystem"
  print_info "- extended the LV and resized ext4 online (no downtime)"
  print_info "- created swap on an LV, enabled it, and made it persistent"
  print_info "- tested mounts and swap safely without rebooting the system"
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
