#!/bin/bash

# Lab 203: Create GPT partition, format XFS, mount persistently (Configure Local Storage)
# Output policy: Only show real terminal outputs. Silent commands produce no output.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 203: GPT Partition + XFS Mount"
LAB_ID="lab203"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PART_DEV="/dev/sdb"
MOUNT_DIR="/mnt/xfsdata"

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
  center_text "Goal: Create a 2G GPT partition, format with XFS, and mount persistently at $MOUNT_DIR."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Create GPT label (silent)
  draw_lab_ui
  echo "  Step 1: Create GPT label on $PART_DEV."
  echo "          Expected: parted -s $PART_DEV mklabel gpt"
  read -p "  lab@lab203:~$ " s1
  [[ "$s1" != "parted -s /dev/sdb mklabel gpt" ]] && { print_error "Use: parted -s /dev/sdb mklabel gpt"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 2: Create 2G partition (silent)
  echo "  Step 2: Create a 2G primary partition."
  echo "          Expected: parted -s $PART_DEV mkpart primary xfs 1MiB 2049MiB"
  read -p "  lab@lab203:~$ " s2
  [[ "$s2" != "parted -s /dev/sdb mkpart primary xfs 1MiB 2049MiB" ]] && { print_error "Use: parted -s /dev/sdb mkpart primary xfs 1MiB 2049MiB"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 3: Show partition table
  echo "  Step 3: Verify partition table."
  echo "          Expected: lsblk $PART_DEV"
  read -p "  lab@lab203:~$ " s3
  [[ "$s3" != "lsblk /dev/sdb" ]] && { print_error "Use: lsblk /dev/sdb"; read -p "Press Enter to try again..." _; continue; }
  echo "NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT"
  echo "sdb      8:16   0   10G  0 disk"
  echo "└─sdb1   8:17   0    2G  0 part"
  echo

  # Step 4: Format with XFS
  echo "  Step 4: Format /dev/sdb1 with XFS."
  echo "          Expected: mkfs.xfs /dev/sdb1"
  read -p "  lab@lab203:~$ " s4
  [[ "$s4" != "mkfs.xfs /dev/sdb1" ]] && { print_error "Use: mkfs.xfs /dev/sdb1"; read -p "Press Enter to try again..." _; continue; }
  echo "meta-data=/dev/sdb1              isize=512    agcount=4, agsize=131072 blks"
  echo "         =                       sectsz=512   attr=2, projid32bit=1"
  echo "         =                       crc=1        finobt=1, sparse=1, rmapbt=0"
  echo "         =                       reflink=1"
  echo "data     =                       bsize=4096   blocks=524288, imaxpct=25"
  echo "         =                       sunit=0      swidth=0 blks"
  echo "naming   =version 2              bsize=4096   ascii-ci=0, ftype=1"
  echo "log      =internal log           bsize=4096   blocks=2560, version=2"
  echo "         =                       sectsz=512   sunit=0 blks, lazy-count=1"
  echo "realtime =none                   extsz=4096   blocks=0, rtextents=0"
  echo

  # Step 5: Create mount point (silent)
  echo "  Step 5: Create mount point $MOUNT_DIR."
  echo "          Expected: mkdir -p $MOUNT_DIR"
  read -p "  lab@lab203:~$ " s5
  [[ "$s5" != "mkdir -p /mnt/xfsdata" ]] && { print_error "Use: mkdir -p /mnt/xfsdata"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 6: Mount it
  echo "  Step 6: Mount the filesystem."
  echo "          Expected: mount /dev/sdb1 $MOUNT_DIR"
  read -p "  lab@lab203:~$ " s6
  [[ "$s6" != "mount /dev/sdb1 /mnt/xfsdata" ]] && { print_error "Use: mount /dev/sdb1 /mnt/xfsdata"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 7: Verify mounted FS
  echo "  Step 7: Verify mount with df."
  echo "          Expected: df -hT $MOUNT_DIR"
  read -p "  lab@lab203:~$ " s7
  [[ "$s7" != "df -hT /mnt/xfsdata" ]] && { print_error "Use: df -hT /mnt/xfsdata"; read -p "Press Enter to try again..." _; continue; }
  echo "Filesystem     Type  Size  Used Avail Use% Mounted on"
  echo "/dev/sdb1      xfs   2.0G   47M  1.9G   3% /mnt/xfsdata"
  echo

  # Step 8: Add fstab entry (silent, no output)
  echo "  Step 8: Add persistent mount to /etc/fstab (silent)."
  echo "          Expected: echo 'UUID=<uuid> $MOUNT_DIR xfs defaults 0 0' >> /etc/fstab"
  read -p "  lab@lab203:~$ " s8
  [[ "$s8" != "echo 'UUID=<uuid> /mnt/xfsdata xfs defaults 0 0' >> /etc/fstab" ]] && {
    print_error "Use: echo 'UUID=<uuid> /mnt/xfsdata xfs defaults 0 0' >> /etc/fstab";
    read -p "Press Enter to try again..." _; continue; }
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
