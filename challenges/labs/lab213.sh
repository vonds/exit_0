#!/bin/bash

# Lab 213: Create ext4 + XFS partitions, mount via UUID (SIMULATED & SAFE)
# SAFETY: This lab does NOT touch your system. It only checks typed commands and prints canned outputs.
#         No real disks, mounts, or fstab writes occur. fstab lines go to /tmp/fstab.lab213 (simulated).
# Output policy: Show only realistic, canned command output. Silent steps print nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 213: ext4 + XFS via UUID (SIMULATED)"
LAB_ID="lab213"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Mock devices/paths (placeholders only)
DISK="/dev/sdd"
P1="/dev/sdd1"                  # ~200MiB (ext4)
P2="/dev/sdd2"                  # ~300MiB (xfs)
MNT1="/mnt/ext4data"
MNT2="/mnt/xfsdata"

# Mock UUIDs (fixed, deterministic)
UUID_EXT4="11111111-2222-3333-4444-555555555555"
UUID_XFS="aaaaaaa1-bbbb-cccc-dddd-eeeeeeeeeeee"

# Simulated fstab file
FSTAB_SIM="/tmp/fstab.lab213"

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
  center_text "Goal: On $DISK, create $P1 (ext4 ~200MiB) and $P2 (xfs ~300MiB). Format, mount by UUID to"
  center_text "$MNT1 and $MNT2, then add persistent entries to $FSTAB_SIM (simulated) and verify."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Partition the disk (SIMULATED)
  draw_lab_ui
  echo "  Step 1: Create two partitions on $DISK (ext4 ~200MiB, xfs ~300MiB)."
  echo "          Expected: parted -s $DISK mklabel gpt"
  read -p "  lab@lab213:~$ " cmd1a
  [[ "$cmd1a" != "parted -s /dev/sdd mklabel gpt" ]] && { print_error "Use: parted -s /dev/sdd mklabel gpt"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "          Expected: parted -s $DISK mkpart primary ext4 1MiB 201MiB"
  read -p "  lab@lab213:~$ " cmd1b
  [[ "$cmd1b" != "parted -s /dev/sdd mkpart primary ext4 1MiB 201MiB" ]] && { print_error "Use: parted -s /dev/sdd mkpart primary ext4 1MiB 201MiB"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "          Expected: parted -s $DISK mkpart primary xfs 201MiB 501MiB"
  read -p "  lab@lab213:~$ " cmd1c
  [[ "$cmd1c" != "parted -s /dev/sdd mkpart primary xfs 201MiB 501MiB" ]] && { print_error "Use: parted -s /dev/sdd mkpart primary xfs 201MiB 501MiB"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "          Expected: partprobe $DISK"
  read -p "  lab@lab213:~$ " cmd1d
  [[ "$cmd1d" != "partprobe /dev/sdd" ]] && { print_error "Use: partprobe /dev/sdd"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 2: Verify partitions (SIMULATED)
  echo "  Step 2: Verify partitions exist."
  echo "          Expected: lsblk $DISK"
  read -p "  lab@lab213:~$ " cmd2
  [[ "$cmd2" != "lsblk /dev/sdd" ]] && { print_error "Use: lsblk /dev/sdd"; read -p "Press Enter to try again..." _; continue; }
  echo "NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS"
  echo "sdd      8:48   0   10G  0 disk"
  echo "├─sdd1   8:49   0  200M  0 part"
  echo "└─sdd2   8:50   0  300M  0 part"
  echo

  # Step 3: Make filesystems (SIMULATED)
  echo "  Step 3: Create ext4 on $P1 and xfs on $P2."
  echo "          Expected: mkfs.ext4 -L ext4data $P1"
  read -p "  lab@lab213:~$ " cmd3a
  [[ "$cmd3a" != "mkfs.ext4 -L ext4data /dev/sdd1" ]] && { print_error "Use: mkfs.ext4 -L ext4data /dev/sdd1"; read -p "Press Enter to try again..." _; continue; }
  echo "mke2fs 1.46.5 (30-Dec-2021)"
  echo "Creating filesystem with 51200 4k blocks and 12800 inodes"
  echo "Filesystem UUID: $UUID_EXT4"
  echo "Writing superblocks and filesystem accounting information: done"
  echo
  echo "          Expected: mkfs.xfs -f -L xfsdata $P2"
  read -p "  lab@lab213:~$ " cmd3b
  [[ "$cmd3b" != "mkfs.xfs -f -L xfsdata /dev/sdd2" ]] && { print_error "Use: mkfs.xfs -f -L xfsdata /dev/sdd2"; read -p "Press Enter to try again..." _; continue; }
  echo "meta-data=/dev/sdd2              isize=512    agcount=4, agsize=19200 blks"
  echo "data     =                        bsize=4096   blocks=76800, imaxpct=25"
  echo "naming   =version 2               bsize=4096   ascii-ci=0, ftype=1"
  echo "log      =internal log            bsize=4096   blocks=2560, version=2"
  echo "realtime =none                    extsz=4096   blocks=0, rtextents=0"
  echo

  # Step 4: Retrieve UUIDs (SIMULATED)
  echo "  Step 4: Get UUIDs for both filesystems."
  echo "          Expected: blkid -s UUID -o value $P1"
  read -p "  lab@lab213:~$ " cmd4a
  [[ "$cmd4a" != "blkid -s UUID -o value /dev/sdd1" ]] && { print_error "Use: blkid -s UUID -o value /dev/sdd1"; read -p "Press Enter to try again..." _; continue; }
  echo "$UUID_EXT4"
  echo
  echo "          Expected: blkid -s UUID -o value $P2"
  read -p "  lab@lab213:~$ " cmd4b
  [[ "$cmd4b" != "blkid -s UUID -o value /dev/sdd2" ]] && { print_error "Use: blkid -s UUID -o value /dev/sdd2"; read -p "Press Enter to try again..." _; continue; }
  echo "$UUID_XFS"
  echo

  # Step 5: Prepare mount points (SIMULATED – silent)
  echo "  Step 5: Create mount points (no output on success)."
  echo "          Expected: mkdir -p $MNT1"
  read -p "  lab@lab213:~$ " cmd5a
  [[ "$cmd5a" != "mkdir -p /mnt/ext4data" ]] && { print_error "Use: mkdir -p /mnt/ext4data"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "          Expected: mkdir -p $MNT2"
  read -p "  lab@lab213:~$ " cmd5b
  [[ "$cmd5b" != "mkdir -p /mnt/xfsdata" ]] && { print_error "Use: mkdir -p /mnt/xfsdata"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 6: Mount by UUID (SIMULATED – mount prints nothing on success)
  echo "  Step 6: Mount both filesystems by UUID."
  echo "          Expected: mount -t ext4 UUID=$UUID_EXT4 $MNT1"
  read -p "  lab@lab213:~$ " cmd6a
  [[ "$cmd6a" != "mount -t ext4 UUID=$UUID_EXT4 /mnt/ext4data" ]] && { print_error "Use: mount -t ext4 UUID=$UUID_EXT4 /mnt/ext4data"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "          Expected: mount -t xfs UUID=$UUID_XFS $MNT2"
  read -p "  lab@lab213:~$ " cmd6b
  [[ "$cmd6b" != "mount -t xfs UUID=$UUID_XFS /mnt/xfsdata" ]] && { print_error "Use: mount -t xfs UUID=$UUID_XFS /mnt/xfsdata"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 7: Verify mounts (SIMULATED df -T)
  echo "  Step 7: Verify with df -T."
  echo "          Expected: df -T | egrep '$MNT1|$MNT2'"
  read -p "  lab@lab213:~$ " cmd7
  [[ "$cmd7" != "df -T | egrep '/mnt/ext4data|/mnt/xfsdata'" ]] && { print_error "Use: df -T | egrep '/mnt/ext4data|/mnt/xfsdata'"; read -p "Press Enter to try again..." _; continue; }
  echo "Filesystem     Type  1K-blocks  Used Available Use% Mounted on"
  echo "/dev/sdd1      ext4     196608  6144    190464   4% /mnt/ext4data"
  echo "/dev/sdd2      xfs      307200  2048    305152   1% /mnt/xfsdata"
  echo

  # Step 8: Persist with simulated fstab
  echo "  Step 8: Add persistent entries to $FSTAB_SIM (simulated)."
  echo "          Expected: echo 'UUID=$UUID_EXT4 $MNT1 ext4 defaults 0 0' | tee -a $FSTAB_SIM"
  read -p "  lab@lab213:~$ " cmd8a
  [[ "$cmd8a" != "echo 'UUID=$UUID_EXT4 /mnt/ext4data ext4 defaults 0 0' | tee -a /tmp/fstab.lab213" ]] && { print_error "Use the exact echo | tee -a form for ext4"; read -p "Press Enter to try again..." _; continue; }
  echo "UUID=$UUID_EXT4 /mnt/ext4data ext4 defaults 0 0"
  echo
  echo "          Expected: echo 'UUID=$UUID_XFS $MNT2 xfs defaults 0 0' | tee -a $FSTAB_SIM"
  read -p "  lab@lab213:~$ " cmd8b
  [[ "$cmd8b" != "echo 'UUID=$UUID_XFS /mnt/xfsdata xfs defaults 0 0' | tee -a /tmp/fstab.lab213" ]] && { print_error "Use the exact echo | tee -a form for xfs"; read -p "Press Enter to try again..." _; continue; }
  echo "UUID=$UUID_XFS /mnt/xfsdata xfs defaults 0 0"
  echo

  # Step 9: Show simulated fstab contents
  echo "  Step 9: Display $FSTAB_SIM."
  echo "          Expected: cat $FSTAB_SIM"
  read -p "  lab@lab213:~$ " cmd9
  [[ "$cmd9" != "cat /tmp/fstab.lab213" ]] && { print_error "Use: cat /tmp/fstab.lab213"; read -p "Press Enter to try again..." _; continue; }
  echo "UUID=$UUID_EXT4 /mnt/ext4data ext4 defaults 0 0"
  echo "UUID=$UUID_XFS /mnt/xfsdata xfs defaults 0 0"
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
