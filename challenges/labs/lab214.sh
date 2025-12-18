#!/bin/bash

# Lab 214: Create VG/LVs with ext4 + XFS, persistent mounts (SIMULATED & SAFE)
# SAFETY: This lab does NOT touch your system. It only validates typed commands and prints canned outputs.
#         No real disks, LVM changes, or fstab writes occur. fstab lines go to /tmp/fstab.lab214 (simulated).
# Output policy: Show only realistic, canned command output. Silent steps print nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 214: VG + LVs (ext4 & XFS) with persistent mounts"
LAB_ID="lab214"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Mock devices/paths (placeholders only)
PV_DISK="/dev/sde"                 # single disk used as PV
VG="vgdata"
LV_EXT="lvext4"                    # ~300MiB
LV_XFS="lvxfs"                     # ~500MiB
LV_EXT_PATH="/dev/$VG/$LV_EXT"
LV_XFS_PATH="/dev/$VG/$LV_XFS"

# Mount points (simulated)
MNT_EXT="/mnt/data_ext4"
MNT_XFS="/mnt/data_xfs"

# Simulated UUIDs
UUID_EXT="22222222-3333-4444-5555-666666666666"
UUID_XFS="bbbbbbb2-cccc-dddd-eeee-ffffffffffff"

# Simulated fstab file
FSTAB_SIM="/tmp/fstab.lab214"

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
  center_text "Goal: Create VG $VG on $PV_DISK, then LVs $LV_EXT (~300MiB) and $LV_XFS (~500MiB)."
  center_text "Format as ext4/XFS, mount by UUID at $MNT_EXT and $MNT_XFS, persist to $FSTAB_SIM."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Initialize PV (SIMULATED)
  draw_lab_ui
  echo "  Step 1: Initialize $PV_DISK as an LVM PV."
  echo "          Expected: pvcreate $PV_DISK"
  read -p "  lab@lab214:~$ " cmd1
  [[ "$cmd1" != "pvcreate /dev/sde" ]] && { print_error "Use: pvcreate /dev/sde"; read -p "Press Enter to try again..." _; continue; }
  echo "  Physical volume \"/dev/sde\" successfully created."
  echo

  # Step 2: Create VG (SIMULATED)
  echo "  Step 2: Create VG $VG."
  echo "          Expected: vgcreate $VG $PV_DISK"
  read -p "  lab@lab214:~$ " cmd2
  [[ "$cmd2" != "vgcreate vgdata /dev/sde" ]] && { print_error "Use: vgcreate vgdata /dev/sde"; read -p "Press Enter to try again..." _; continue; }
  echo "  Volume group \"vgdata\" successfully created"
  echo

  # Step 3: Create LVs (SIMULATED)
  echo "  Step 3: Create LVs (~300MiB and ~500MiB)."
  echo "          Expected: lvcreate -L 300M -n $LV_EXT $VG"
  read -p "  lab@lab214:~$ " cmd3a
  [[ "$cmd3a" != "lvcreate -L 300M -n lvext4 vgdata" ]] && { print_error "Use: lvcreate -L 300M -n lvext4 vgdata"; read -p "Press Enter to try again..." _; continue; }
  echo "  Logical volume \"lvext4\" created."
  echo
  echo "          Expected: lvcreate -L 500M -n $LV_XFS $VG"
  read -p "  lab@lab214:~$ " cmd3b
  [[ "$cmd3b" != "lvcreate -L 500M -n lvxfs vgdata" ]] && { print_error "Use: lvcreate -L 500M -n lvxfs vgdata"; read -p "Press Enter to try again..." _; continue; }
  echo "  Logical volume \"lvxfs\" created."
  echo

  # Step 4: Show LVs (SIMULATED lvs)
  echo "  Step 4: List logical volumes."
  echo "          Expected: lvs"
  read -p "  lab@lab214:~$ " cmd4
  [[ "$cmd4" != "lvs" ]] && { print_error "Use: lvs"; read -p "Press Enter to try again..." _; continue; }
  echo "  LV     VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert"
  echo "  lvext4 vgdata -wi-a----- 300.00m                                                     "
  echo "  lvxfs  vgdata -wi-a----- 500.00m                                                     "
  echo

  # Step 5: Make filesystems (SIMULATED)
  echo "  Step 5: Create filesystems on the LVs."
  echo "          Expected: mkfs.ext4 -L data_ext4 $LV_EXT_PATH"
  read -p "  lab@lab214:~$ " cmd5a
  [[ "$cmd5a" != "mkfs.ext4 -L data_ext4 /dev/vgdata/lvext4" ]] && { print_error "Use: mkfs.ext4 -L data_ext4 /dev/vgdata/lvext4"; read -p "Press Enter to try again..." _; continue; }
  echo "mke2fs 1.46.5 (30-Dec-2021)"
  echo "Creating filesystem with 76800 4k blocks and 19200 inodes"
  echo "Filesystem UUID: $UUID_EXT"
  echo "Superblock backups stored on blocks: "
  echo "        32768, 98304"
  echo "Writing superblocks and filesystem accounting information: done"
  echo
  echo "          Expected: mkfs.xfs -f -L data_xfs $LV_XFS_PATH"
  read -p "  lab@lab214:~$ " cmd5b
  [[ "$cmd5b" != "mkfs.xfs -f -L data_xfs /dev/vgdata/lvxfs" ]] && { print_error "Use: mkfs.xfs -f -L data_xfs /dev/vgdata/lvxfs"; read -p "Press Enter to try again..." _; continue; }
  echo "meta-data=/dev/vgdata/lvxfs     isize=512    agcount=4, agsize=32000 blks"
  echo "data     =                       bsize=4096   blocks=128000, imaxpct=25"
  echo "naming   =version 2              bsize=4096   ascii-ci=0, ftype=1"
  echo "log      =internal log           bsize=4096   blocks=2560, version=2"
  echo "realtime =none                   extsz=4096   blocks=0, rtextents=0"
  echo

  # Step 6: Get UUIDs (SIMULATED)
  echo "  Step 6: Retrieve UUIDs for both filesystems."
  echo "          Expected: blkid -s UUID -o value $LV_EXT_PATH"
  read -p "  lab@lab214:~$ " cmd6a
  [[ "$cmd6a" != "blkid -s UUID -o value /dev/vgdata/lvext4" ]] && { print_error "Use: blkid -s UUID -o value /dev/vgdata/lvext4"; read -p "Press Enter to try again..." _; continue; }
  echo "$UUID_EXT"
  echo
  echo "          Expected: blkid -s UUID -o value $LV_XFS_PATH"
  read -p "  lab@lab214:~$ " cmd6b
  [[ "$cmd6b" != "blkid -s UUID -o value /dev/vgdata/lvxfs" ]] && { print_error "Use: blkid -s UUID -o value /dev/vgdata/lvxfs"; read -p "Press Enter to try again..." _; continue; }
  echo "$UUID_XFS"
  echo

  # Step 7: Create mount points (SIMULATED – silent)
  echo "  Step 7: Create mount points (no output on success)."
  echo "          Expected: mkdir -p $MNT_EXT"
  read -p "  lab@lab214:~$ " cmd7a
  [[ "$cmd7a" != "mkdir -p /mnt/data_ext4" ]] && { print_error "Use: mkdir -p /mnt/data_ext4"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "          Expected: mkdir -p $MNT_XFS"
  read -p "  lab@lab214:~$ " cmd7b
  [[ "$cmd7b" != "mkdir -p /mnt/data_xfs" ]] && { print_error "Use: mkdir -p /mnt/data_xfs"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 8: Mount by UUID (SIMULATED)
  echo "  Step 8: Mount both filesystems by UUID."
  echo "          Expected: mount -t ext4 UUID=$UUID_EXT $MNT_EXT"
  read -p "  lab@lab214:~$ " cmd8a
  [[ "$cmd8a" != "mount -t ext4 UUID=$UUID_EXT /mnt/data_ext4" ]] && { print_error "Use: mount -t ext4 UUID=$UUID_EXT /mnt/data_ext4"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "          Expected: mount -t xfs UUID=$UUID_XFS $MNT_XFS"
  read -p "  lab@lab214:~$ " cmd8b
  [[ "$cmd8b" != "mount -t xfs UUID=$UUID_XFS /mnt/data_xfs" ]] && { print_error "Use: mount -t xfs UUID=$UUID_XFS /mnt/data_xfs"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 9: Verify mounts (SIMULATED df -T)
  echo "  Step 9: Verify with df -T."
  echo "          Expected: df -T | egrep '$MNT_EXT|$MNT_XFS'"
  read -p "  lab@lab214:~$ " cmd9
  [[ "$cmd9" != "df -T | egrep '/mnt/data_ext4|/mnt/data_xfs'" ]] && { print_error "Use: df -T | egrep '/mnt/data_ext4|/mnt/data_xfs'"; read -p "Press Enter to try again..." _; continue; }
  echo "Filesystem               Type  1K-blocks  Used Available Use% Mounted on"
  echo "/dev/vgdata/lvext4       ext4     307200  6144    301056   2% /mnt/data_ext4"
  echo "/dev/vgdata/lvxfs        xfs      512000  2048    509952   1% /mnt/data_xfs"
  echo

  # Step 10: Persist to simulated fstab
  echo "  Step 10: Add persistent entries to $FSTAB_SIM (simulated)."
  echo "           Expected: echo 'UUID=$UUID_EXT $MNT_EXT ext4 defaults 0 0' | tee -a $FSTAB_SIM"
  read -p "  lab@lab214:~$ " cmd10a
  [[ "$cmd10a" != "echo 'UUID=$UUID_EXT /mnt/data_ext4 ext4 defaults 0 0' | tee -a /tmp/fstab.lab214" ]] && { print_error "Use the exact echo | tee -a form for ext4"; read -p "Press Enter to try again..." _; continue; }
  echo "UUID=$UUID_EXT /mnt/data_ext4 ext4 defaults 0 0"
  echo
  echo "           Expected: echo 'UUID=$UUID_XFS $MNT_XFS xfs defaults 0 0' | tee -a $FSTAB_SIM"
  read -p "  lab@lab214:~$ " cmd10b
  [[ "$cmd10b" != "echo 'UUID=$UUID_XFS /mnt/data_xfs xfs defaults 0 0' | tee -a /tmp/fstab.lab214" ]] && { print_error "Use the exact echo | tee -a form for xfs"; read -p "Press Enter to try again..." _; continue; }
  echo "UUID=$UUID_XFS /mnt/data_xfs xfs defaults 0 0"
  echo

  # Step 11: Show simulated fstab contents
  echo "  Step 11: Display $FSTAB_SIM."
  echo "           Expected: cat $FSTAB_SIM"
  read -p "  lab@lab214:~$ " cmd11
  [[ "$cmd11" != "cat /tmp/fstab.lab214" ]] && { print_error "Use: cat /tmp/fstab.lab214"; read -p "Press Enter to try again..." _; continue; }
  echo "UUID=$UUID_EXT /mnt/data_ext4 ext4 defaults 0 0"
  echo "UUID=$UUID_XFS /mnt/data_xfs xfs defaults 0 0"
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
