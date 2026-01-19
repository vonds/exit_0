#!/bin/bash

# Lab 458: RHEL Storage Ops — Mount, Persist, Grow XFS Safely
# Focus: mounting LVs, making mounts persistent, extending an LV with an existing XFS filesystem,
# and verifying requirements exactly as RHCSA expects.
# Key skills: mkdir, mount, findmnt, df -h, blkid, /etc/fstab, lvextend, xfs_growfs, vgs/lvs

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 458: Mount, Persist, and Grow XFS on LVM"
LAB_ID="lab458"
LAB_XP=75800
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
  center_text "A volume group and logical volume already exist."
  center_text "You must mount the filesystem, make it persistent,"
  center_text "then extend the logical volume and grow the XFS filesystem safely."
  echo
  center_text "Existing resources:"
  center_text "- VG: volume1"
  center_text "- LV: volume1/data"
  center_text "- LV size: 1G"
  center_text "- Filesystem: XFS"
  center_text "- Additional free space exists in the VG"
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Create mount point
  echo "  Step 1: Create the mount point /mnt/data."
  read -p "  lab@rhel-lab458:~$ " cmd1
  echo
  if [[ "$cmd1" != "sudo mkdir /mnt/data" && \
        "$cmd1" != "sudo mkdir -p /mnt/data" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  # Realistic: mkdir is silent on success.

  # STEP 2: Mount LV
  echo "  Step 2: Mount /dev/volume1/data at /mnt/data."
  read -p "  lab@rhel-lab458:~$ " cmd2
  echo
  if [[ "$cmd2" != "sudo mount /dev/volume1/data /mnt/data" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  # Realistic: mount is silent on success.

  # STEP 3: Verify mount
  echo "  Step 3: Verify the filesystem is mounted."
  read -p "  lab@rhel-lab458:~$ " cmd3
  echo
  if [[ "$cmd3" != "findmnt /mnt/data" && \
        "$cmd3" != "df -h /mnt/data" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  if [[ "$cmd3" == "findmnt /mnt/data" ]]; then
    echo "  TARGET   SOURCE              FSTYPE OPTIONS"
    echo "  /mnt/data /dev/mapper/volume1-data xfs    rw,relatime,seclabel,attr2,inode64,logbufs=8,logbsize=32k,noquota"
  else
    echo "  Filesystem                 Size  Used Avail Use% Mounted on"
    echo "  /dev/mapper/volume1-data  1014M   33M  982M   4% /mnt/data"
  fi
  echo

  # STEP 4: Get UUID
  echo "  Step 4: Identify the filesystem UUID."
  read -p "  lab@rhel-lab458:~$ " cmd4
  echo
  if [[ "$cmd4" != "blkid /dev/volume1/data" && \
        "$cmd4" != "sudo blkid /dev/volume1/data" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  # Realistic blkid output for an XFS LV mapper path
  echo "  /dev/mapper/volume1-data: UUID=\"2e7d6a4f-0b8b-4a1d-9b2d-2f8f6e1c3c9a\" BLOCK_SIZE=\"512\" TYPE=\"xfs\""
  echo

  # STEP 5: Persist mount
  echo "  Step 5: Add a persistent mount entry to /etc/fstab using the UUID."
  read -p "  lab@rhel-lab458:~$ " cmd5
  echo
  if [[ "$cmd5" != "sudo vim /etc/fstab" && \
        "$cmd5" != "sudo nano /etc/fstab" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  # Don't "print the answer line" as if the script did it; just simulate editor actions.
  echo "  (opened /etc/fstab)"
  echo "  (added an entry using the UUID for /mnt/data)"
  echo "  (saved and exited)"
  echo

  # STEP 6: Test fstab
  echo "  Step 6: Test the fstab entry without rebooting."
  read -p "  lab@rhel-lab458:~$ " cmd6
  echo
  if [[ "$cmd6" != "sudo mount -a" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  # Realistic: mount -a is silent if everything is OK.

  # STEP 7: Extend LV
  echo "  Step 7: Extend the logical volume by 500M."
  read -p "  lab@rhel-lab458:~$ " cmd7
  echo
  if [[ "$cmd7" != "sudo lvextend -L +500M /dev/volume1/data" && \
        "$cmd7" != "sudo lvextend -r -L +500M /dev/volume1/data" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  if [[ "$cmd7" == "sudo lvextend -r -L +500M /dev/volume1/data" ]]; then
    echo "  Size of logical volume volume1/data changed from 1.00 GiB (256 extents) to 1.49 GiB (382 extents)."
    echo "  Logical volume volume1/data successfully resized."
    echo "  meta-data=/dev/mapper/volume1-data isize=512    agcount=4, agsize=65536 blks"
    echo "           =                       sectsz=512   attr=2, projid32bit=1"
    echo "           =                       crc=1        finobt=1, sparse=1, rmapbt=0"
    echo "           =                       reflink=1    bigtime=1 inobtcount=1"
    echo "  data     =                       bsize=4096   blocks=262144, imaxpct=25"
    echo "           =                       sunit=0      swidth=0 blks"
    echo "  naming   =version 2              bsize=4096   ascii-ci=0, ftype=1"
    echo "  log      =internal               bsize=4096   blocks=16384, version=2"
    echo "           =                       sectsz=512   sunit=0 blks, lazy-count=1"
    echo "  realtime =none                   extsz=4096   blocks=0, rtextents=0"
    echo "  data blocks changed from 262144 to 390144"
  else
    echo "  Size of logical volume volume1/data changed from 1.00 GiB (256 extents) to 1.49 GiB (382 extents)."
    echo "  Logical volume volume1/data successfully resized."
  fi
  echo

  # STEP 8: Grow XFS filesystem (only needed if -r was NOT used)
  echo "  Step 8: Grow the XFS filesystem to use the new space."
  read -p "  lab@rhel-lab458:~$ " cmd8
  echo
  if [[ "$cmd8" != "sudo xfs_growfs /mnt/data" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  meta-data=/dev/mapper/volume1-data isize=512    agcount=4, agsize=65536 blks"
  echo "           =                       sectsz=512   attr=2, projid32bit=1"
  echo "           =                       crc=1        finobt=1, sparse=1, rmapbt=0"
  echo "           =                       reflink=1    bigtime=1 inobtcount=1"
  echo "  data     =                       bsize=4096   blocks=390144, imaxpct=25"
  echo "           =                       sunit=0      swidth=0 blks"
  echo "  naming   =version 2              bsize=4096   ascii-ci=0, ftype=1"
  echo "  log      =internal               bsize=4096   blocks=16384, version=2"
  echo "           =                       sectsz=512   sunit=0 blks, lazy-count=1"
  echo "  realtime =none                   extsz=4096   blocks=0, rtextents=0"
  echo "  data blocks changed from 262144 to 390144"
  echo

  # STEP 9: Verify final size
  echo "  Step 9: Verify the new filesystem size."
  read -p "  lab@rhel-lab458:~$ " cmd9
  echo
  if [[ "$cmd9" != "df -h /mnt/data" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Filesystem                 Size  Used Avail Use% Mounted on"
  echo "  /dev/mapper/volume1-data   1.5G   33M  1.5G   3% /mnt/data"
  echo

  print_success "Excellent work."
  print_info "You demonstrated RHCSA-critical storage skills:"
  print_info "- mounting and verifying filesystems"
  print_info "- making mounts persistent with UUIDs"
  print_info "- extending LVs with an existing XFS filesystem"
  print_info "- growing XFS safely without data loss"
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
