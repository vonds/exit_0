#!/bin/bash

# Lab 224: Remove VDO, recreate with XFS & persistent mount (SIMULATED & SAFE)
# SAFETY: This lab validates typed commands and prints canned outputs only.
#         No real disks, VDO volumes, filesystems, or /etc/fstab are modified.
#         A simulated fstab is written under /tmp for persistence steps.
# Output policy: Show only realistic, canned command output. Silent steps print nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 224: VDO → XFS + Persistent Mount"
LAB_ID="lab224"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated resources (placeholders)
DISK="/dev/sdd"
VDO_NAME="vdo1"
VDO_DEV="/dev/mapper/${VDO_NAME}"
MNT="/mnt/vdo1"
FS_LABEL="vdoXFS"
ALT_FSTAB_SIM="/tmp/fstab.lab224"
UUID_SIM="8f4c8b9a-6d2a-4a1f-9b5c-2b0c1d8e33aa"

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
  center_text "Goal: Remove an existing VDO, recreate it, make an XFS on it, mount at $MNT,"
  center_text "and add a (simulated) persistent entry to fstab. All actions are simulated."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Confirm existing VDO
  draw_lab_ui
  echo "  Step 1: List existing VDO volumes."
  echo "          Expected: sudo vdo list"
  read -p "  lab@lab224:~$ " cmd1
  [[ "$cmd1" != "sudo vdo list" ]] && { print_error "Use: sudo vdo list"; read -p "Press Enter to try again..." _; continue; }
  echo "vdo1"
  echo

  # Step 2: Stop the VDO before removal
  echo "  Step 2: Stop the VDO instance."
  echo "          Expected: sudo vdo stop --name=$VDO_NAME"
  read -p "  lab@lab224:~$ " cmd2
  [[ "$cmd2" != "sudo vdo stop --name=vdo1" ]] && { print_error "Use: sudo vdo stop --name=vdo1"; read -p "Press Enter to try again..." _; continue; }
  echo "Stopping VDO vdo1"
  echo "VDO vdo1 stopped"
  echo

  # Step 3: Remove the VDO
  echo "  Step 3: Remove the VDO instance."
  echo "          Expected: sudo vdo remove --name=$VDO_NAME"
  read -p "  lab@lab224:~$ " cmd3
  [[ "$cmd3" != "sudo vdo remove --name=vdo1" ]] && { print_error "Use: sudo vdo remove --name=vdo1"; read -p "Press Enter to try again..." _; continue; }
  echo "Removing VDO vdo1"
  echo "VDO vdo1 removed"
  echo

  # Step 4: Recreate the VDO on the same backing device
  echo "  Step 4: Recreate the VDO on $DISK (50G logical)."
  echo "          Expected: sudo vdo create --name=$VDO_NAME --device=$DISK --vdoLogicalSize=50G"
  read -p "  lab@lab224:~$ " cmd4
  [[ "$cmd4" != "sudo vdo create --name=vdo1 --device=/dev/sdd --vdoLogicalSize=50G" ]] && {
    print_error "Use: sudo vdo create --name=vdo1 --device=/dev/sdd --vdoLogicalSize=50G"
    read -p "Press Enter to try again..." _
    continue
  }
  echo "Creating VDO vdo1"
  echo "Starting VDO vdo1"
  echo "VDO instance vdo1 is ready at /dev/mapper/vdo1"
  echo

  # Step 5: Make an XFS filesystem on the VDO device
  echo "  Step 5: Create an XFS filesystem with label ${FS_LABEL}."
  echo "          Expected: sudo mkfs.xfs -L ${FS_LABEL} ${VDO_DEV}"
  read -p "  lab@lab224:~$ " cmd5
  [[ "$cmd5" != "sudo mkfs.xfs -L vdoXFS /dev/mapper/vdo1" ]] && { print_error "Use: sudo mkfs.xfs -L vdoXFS /dev/mapper/vdo1"; read -p "Press Enter to try again..." _; continue; }
  echo "meta-data=/dev/mapper/vdo1     isize=512    agcount=4, agsize=3276800 blks"
  echo "         =                       sectsz=512  attr=2, projid32bit=1, crc=1"
  echo "data     =                       bsize=4096  blocks=13107200, imaxpct=25"
  echo "         =                       sunit=0     swidth=0 blks"
  echo "naming   =version 2              bsize=4096  ascii-ci=0, ftype=1"
  echo "log      =internal log           bsize=4096  blocks=6400, version=2"
  echo "realtime =none                   extsz=4096  blocks=0, rtextents=0"
  echo

  # Step 6: Create the mount point (silent)
  echo "  Step 6: Create the mount point directory."
  echo "          Expected: sudo mkdir -p $MNT"
  read -p "  lab@lab224:~$ " cmd6
  [[ "$cmd6" != "sudo mkdir -p /mnt/vdo1" ]] && { print_error "Use: sudo mkdir -p /mnt/vdo1"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 7: Mount the filesystem
  echo "  Step 7: Mount the XFS filesystem."
  echo "          Expected: sudo mount ${VDO_DEV} ${MNT}"
  read -p "  lab@lab224:~$ " cmd7
  [[ "$cmd7" != "sudo mount /dev/mapper/vdo1 /mnt/vdo1" ]] && { print_error "Use: sudo mount /dev/mapper/vdo1 /mnt/vdo1"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 8: Verify the mount
  echo "  Step 8: Verify with findmnt and df."
  echo "          Expected: findmnt -T ${MNT}"
  read -p "  lab@lab224:~$ " cmd8a
  [[ "$cmd8a" != "findmnt -T /mnt/vdo1" ]] && { print_error "Use: findmnt -T /mnt/vdo1"; read -p "Press Enter to try again..." _; continue; }
  echo "TARGET    SOURCE               FSTYPE OPTIONS"
  echo "/mnt/vdo1 /dev/mapper/vdo1    xfs    rw,relatime,attr2,inode64,logbufs=8,quota"
  echo
  echo "          Expected: df -h | grep vdo1"
  read -p "  lab@lab224:~$ " cmd8b
  [[ "$cmd8b" != "df -h | grep vdo1" ]] && { print_error "Use: df -h | grep vdo1"; read -p "Press Enter to try again..." _; continue; }
  echo "/dev/mapper/vdo1   50G   33M   50G   1% /mnt/vdo1"
  echo

  # Step 9: Get the filesystem UUID for persistent mounts
  echo "  Step 9: Show the filesystem UUID."
  echo "          Expected: blkid -s UUID -o value ${VDO_DEV}"
  read -p "  lab@lab224:~$ " cmd9
  [[ "$cmd9" != "blkid -s UUID -o value /dev/mapper/vdo1" ]] && { print_error "Use: blkid -s UUID -o value /dev/mapper/vdo1"; read -p "Press Enter to try again..." _; continue; }
  echo "$UUID_SIM"
  echo

  # Step 10: Add a persistent entry to a SIMULATED fstab
  echo "  Step 10: Append persistent mount to a simulated fstab ($ALT_FSTAB_SIM)."
  echo "           Expected: echo 'UUID=$UUID_SIM  $MNT  xfs  defaults,_netdev  0 0' | sudo tee -a $ALT_FSTAB_SIM"
  read -p "  lab@lab224:~$ " cmd10
  [[ "$cmd10" != "echo 'UUID=8f4c8b9a-6d2a-4a1f-9b5c-2b0c1d8e33aa  /mnt/vdo1  xfs  defaults,_netdev  0 0' | sudo tee -a /tmp/fstab.lab224" ]] && {
    print_error "Use the exact echo | tee form with the UUID shown above"
    read -p "Press Enter to try again..." _
    continue
  }
  echo "UUID=8f4c8b9a-6d2a-4a1f-9b5c-2b0c1d8e33aa  /mnt/vdo1  xfs  defaults,_netdev  0 0"
  echo

  # Step 11: Test the simulated fstab by unmounting & re-mounting via -T (alt fstab)
  echo "  Step 11: Test the simulated fstab using mount -a with -T."
  echo "           Expected: sudo umount $MNT"
  read -p "  lab@lab224:~$ " cmd11a
  [[ "$cmd11a" != "sudo umount /mnt/vdo1" ]] && { print_error "Use: sudo umount /mnt/vdo1"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "           Expected: sudo mount -a -T $ALT_FSTAB_SIM"
  read -p "  lab@lab224:~$ " cmd11b
  [[ "$cmd11b" != "sudo mount -a -T /tmp/fstab.lab224" ]] && { print_error "Use: sudo mount -a -T /tmp/fstab.lab224"; read -p "Press Enter to try again..." _; continue; }
  # (mount -a success is silent)
  echo
  echo "           Expected: findmnt -T ${MNT}"
  read -p "  lab@lab224:~$ " cmd11c
  [[ "$cmd11c" != "findmnt -T /mnt/vdo1" ]] && { print_error "Use: findmnt -T /mnt/vdo1"; read -p "Press Enter to try again..." _; continue; }
  echo "TARGET    SOURCE               FSTYPE OPTIONS"
  echo "/mnt/vdo1 UUID=$UUID_SIM      xfs    rw,relatime,attr2,inode64,logbufs=8,_netdev"
  echo

  print_success "Nice work! VDO removed & recreated, XFS made and persistently mounted (simulated)."
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
