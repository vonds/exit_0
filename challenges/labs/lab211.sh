#!/bin/bash

# Lab 211: Create LV by extents (PE=32M, LV=30 extents) and mount persistently at /mnt (Configure Local Storage)
# Output policy: Only real command outputs shown. Silent commands produce no output.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 211: LV by Extents (VG-A/LV-A)"
LAB_ID="lab211"
LAB_XP=22000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PVDEV="/dev/sdb"
VG="VG-A"
LV="LV-A"
LV_PATH="/dev/$VG/$LV"
MNT="/mnt"

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
  center_text "Goal: pvcreate $PVDEV → vgcreate $VG (PE=32M) → lvcreate -l 30 $LV → mkfs.xfs → mount at $MNT → fstab persist."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Confirm disk present (shows lsblk output)
  draw_lab_ui
  echo "  Step 1: Confirm $PVDEV exists and is raw."
  echo "          Expected: lsblk $PVDEV"
  read -p "  lab@lab211:~$ " s1
  [[ "$s1" != "lsblk /dev/sdb" ]] && { print_error "Use: lsblk /dev/sdb"; read -p "Press Enter to try again..." _; continue; }
  echo "NAME MAJ:MIN RM SIZE RO TYPE MOUNTPOINT"
  echo "sdb    8:16   0  10G  0 disk"
  echo

  # Step 2: pvcreate (prints success)
  echo "  Step 2: Initialize the PV."
  echo "          Expected: pvcreate $PVDEV"
  read -p "  lab@lab211:~$ " s2
  [[ "$s2" != "pvcreate /dev/sdb" ]] && { print_error "Use: pvcreate /dev/sdb"; read -p "Press Enter to try again..." _; continue; }
  echo "  Physical volume \"/dev/sdb\" successfully created."
  echo

  # Step 3: vgcreate with PE size 32M (prints success)
  echo "  Step 3: Create VG $VG with PE size 32M."
  echo "          Expected: vgcreate -s 32M $VG $PVDEV"
  read -p "  lab@lab211:~$ " s3
  [[ "$s3" != "vgcreate -s 32M VG-A /dev/sdb" ]] && { print_error "Use: vgcreate -s 32M VG-A /dev/sdb"; read -p "Press Enter to try again..." _; continue; }
  echo "  Volume group \"VG-A\" successfully created"
  echo

  # Step 4: Verify PE size with vgdisplay (shows PE Size line)
  echo "  Step 4: Verify VG has 32M PE."
  echo "          Expected: vgdisplay $VG | grep 'PE Size'"
  read -p "  lab@lab211:~$ " s4
  [[ "$s4" != "vgdisplay VG-A | grep 'PE Size'" ]] && { print_error "Use: vgdisplay VG-A | grep 'PE Size'"; read -p "Press Enter to try again..." _; continue; }
  echo "  PE Size               32.00 MiB"
  echo

  # Step 5: lvcreate by extents (prints created)
  echo "  Step 5: Create LV with 30 extents (≈960M)."
  echo "          Expected: lvcreate -l 30 -n $LV $VG"
  read -p "  lab@lab211:~$ " s5
  [[ "$s5" != "lvcreate -l 30 -n LV-A VG-A" ]] && { print_error "Use: lvcreate -l 30 -n LV-A VG-A"; read -p "Press Enter to try again..." _; continue; }
  echo "  Logical volume \"LV-A\" created."
  echo

  # Step 6: Make XFS filesystem (shows mkfs.xfs output)
  echo "  Step 6: Format $LV_PATH with XFS."
  echo "          Expected: mkfs.xfs $LV_PATH"
  read -p "  lab@lab211:~$ " s6
  [[ "$s6" != "mkfs.xfs /dev/VG-A/LV-A" ]] && { print_error "Use: mkfs.xfs /dev/VG-A/LV-A"; read -p "Press Enter to try again..." _; continue; }
  echo "meta-data=/dev/VG-A/LV-A        isize=512    agcount=4, agsize=61440 blks"
  echo "         =                       sectsz=512   attr=2, projid32bit=1"
  echo "         =                       crc=1        finobt=1, sparse=1, rmapbt=0"
  echo "         =                       reflink=1"
  echo "data     =                       bsize=4096   blocks=245760, imaxpct=25"
  echo "         =                       sunit=0      swidth=0 blks"
  echo "naming   =version 2              bsize=4096   ascii-ci=0, ftype=1"
  echo "log      =internal log           bsize=4096   blocks=1200, version=2"
  echo "         =                       sectsz=512   sunit=0 blks, lazy-count=1"
  echo "realtime =none                   extsz=4096   blocks=0, rtextents=0"
  echo

  # Step 7: Create mount point (silent)
  echo "  Step 7: Create mount point."
  echo "          Expected: mkdir -p $MNT"
  read -p "  lab@lab211:~$ " s7
  [[ "$s7" != "mkdir -p /mnt" ]] && { print_error "Use: mkdir -p /mnt"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 8: Mount (silent)
  echo "  Step 8: Mount the filesystem."
  echo "          Expected: mount $LV_PATH $MNT"
  read -p "  lab@lab211:~$ " s8
  [[ "$s8" != "mount /dev/VG-A/LV-A /mnt" ]] && { print_error "Use: mount /dev/VG-A/LV-A /mnt"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 9: Verify mount with df (shows real output)
  echo "  Step 9: Verify mount."
  echo "          Expected: df -hT $MNT"
  read -p "  lab@lab211:~$ " s9
  [[ "$s9" != "df -hT /mnt" ]] && { print_error "Use: df -hT /mnt"; read -p "Press Enter to try again..." _; continue; }
  echo "Filesystem         Type  Size  Used Avail Use% Mounted on"
  echo "/dev/mapper/VG-A-LV-A xfs  960M   8.6M  952M   1% /mnt"
  echo

  # Step 10: Add fstab entry (silent)
  echo "  Step 10: Add persistent mount to /etc/fstab."
  echo "           Expected: echo 'UUID=<uuid> $MNT xfs defaults 0 0' >> /etc/fstab"
  read -p "  lab@lab211:~$ " s10
  [[ "$s10" != "echo 'UUID=<uuid> /mnt xfs defaults 0 0' >> /etc/fstab" ]] && {
    print_error "Use: echo 'UUID=<uuid> /mnt xfs defaults 0 0' >> /etc/fstab";
    read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 11: Show LV and VG quick summary
  echo "  Step 11: Quick summary of LV and VG."
  echo "           Expected: lvs && vgs"
  read -p "  lab@lab211:~$ " s11
  [[ "$s11" != "lvs && vgs" ]] && { print_error "Use: lvs && vgs"; read -p "Press Enter to try again..." _; continue; }
  echo "  LV   VG    Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert"
  echo "  LV-A VG-A  -wi-a----- 960.00m                                                     "
  echo "  VG    #PV #LV #SN Attr   VSize   VFree"
  echo "  VG-A    1   1   0 wz--n-  10.00g  9.06g"
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
