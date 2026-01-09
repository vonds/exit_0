#!/bin/bash

# Lab 376: RHEL Troubleshooting — Fix an Incorrect UUID-Based Mount
# Focus: correcting a bad UUID in /etc/fstab, validating with mount -a, and confirming systemd mount behavior
# Key skills: findmnt, mount -a, /etc/fstab, systemctl status, journalctl -b, blkid, lsblk -f,
# UUID/LABEL usage, and safe verification.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 376: Fix Incorrect UUID-Based Mount"
LAB_ID="lab376"
LAB_XP=37600
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
  center_text "After a storage change, /mnt/archive no longer mounts at boot."
  center_text "The entry in /etc/fstab uses UUID=..., but the mount fails."
  center_text "Manually mounting by device path works."
  echo
  center_text "Goal: identify the incorrect UUID, fix /etc/fstab safely, validate with mount -a,"
  center_text "and confirm the mount is healthy and persistent-ready."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Confirm the mount is missing
  echo "  Step 1: Confirm whether /mnt/archive is mounted right now."
  read -p "  lab@rhel-lab376:~$ " cmd1
  echo
  if [[ "$cmd1" != "findmnt /mnt/archive" && \
        "$cmd1" != "mount | grep /mnt/archive" && \
        "$cmd1" != "df -h /mnt/archive" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (no output)"
  echo "  /mnt/archive is not mounted."
  echo

  # STEP 2: Inspect the fstab entry
  echo "  Step 2: Inspect the /etc/fstab entry for /mnt/archive."
  read -p "  lab@rhel-lab376:~$ " cmd2
  echo
  if [[ "$cmd2" != "sudo grep -n '/mnt/archive' /etc/fstab" && \
        "$cmd2" != "grep -n '/mnt/archive' /etc/fstab" && \
        "$cmd2" != "sudo cat /etc/fstab" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  16: UUID=11111111-2222-3333-4444-deaddeaddead  /mnt/archive  xfs  defaults  0 0"
  echo

  # STEP 3: Prove the filesystem is real by mounting with a device path
  echo "  Step 3: Mount /mnt/archive manually using a device path to confirm the disk and mountpoint are valid."
  read -p "  lab@rhel-lab376:~$ " cmd3
  echo
  if [[ "$cmd3" != "sudo mount /dev/vgdata/lvarchive /mnt/archive" && \
        "$cmd3" != "sudo mount /mnt/archive" && \
        "$cmd3" != "sudo mount -t xfs /dev/vgdata/lvarchive /mnt/archive" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (no output)"
  echo

  # STEP 4: Verify it is mounted now
  echo "  Step 4: Verify /mnt/archive is mounted and identify its SOURCE."
  read -p "  lab@rhel-lab376:~$ " cmd4
  echo
  if [[ "$cmd4" != "findmnt /mnt/archive" && \
        "$cmd4" != "df -Th /mnt/archive" && \
        "$cmd4" != "mount | grep /mnt/archive" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  TARGET        SOURCE                     FSTYPE OPTIONS"
  echo "  /mnt/archive  /dev/mapper/vgdata-lvarchive xfs   rw,relatime,seclabel,attr2,inode64,noquota"
  echo

  # STEP 5: Identify the correct UUID for the mounted source
  echo "  Step 5: Identify the correct UUID for the source device backing /mnt/archive."
  read -p "  lab@rhel-lab376:~$ " cmd5
  echo
  if [[ "$cmd5" != "sudo blkid /dev/vgdata/lvarchive" && \
        "$cmd5" != "blkid /dev/vgdata/lvarchive" && \
        "$cmd5" != "lsblk -f | grep -E 'lvarchive|archive'" && \
        "$cmd5" != "sudo lsblk -f | grep -E 'lvarchive|archive'" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  /dev/mapper/vgdata-lvarchive: UUID=\"abababab-9999-8888-7777-acdeffedc0de\" TYPE=\"xfs\""
  echo

  # STEP 6: Check boot-time failure evidence (fstab -> systemd mount)
  echo "  Step 6: Check boot logs or mount unit status for the failure message."
  read -p "  lab@rhel-lab376:~$ " cmd6
  echo
  if [[ "$cmd6" != "sudo journalctl -b --no-pager | grep -i archive" && \
        "$cmd6" != "sudo journalctl -b --no-pager | grep -i 'mnt-archive'" && \
        "$cmd6" != "sudo systemctl status mnt-archive.mount --no-pager" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  systemd[1]: mnt-archive.mount: Mount process exited, code=exited, status=32/n/a"
  echo "  mount[612]: wrong fs type, bad option, bad superblock on UUID=11111111-2222-3333-4444-deaddeaddead,"
  echo "             missing codepage or helper program, or other error."
  echo

  # STEP 7: Edit /etc/fstab to correct the UUID (the actual line change is part of the lab)
  echo "  Step 7: Edit /etc/fstab and replace the incorrect UUID with the correct UUID you found."
  read -p "  lab@rhel-lab376:~$ " cmd7
  echo
  if [[ "$cmd7" != "sudo vim /etc/fstab" && \
        "$cmd7" != "sudo nano /etc/fstab" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (editor opened)"
  echo "  (fstab updated and saved)"
  echo

  # STEP 8: Validate safely with mount -a (after unmount)
  echo "  Step 8: Validate the corrected /etc/fstab safely (no reboot): unmount then run mount -a."
  read -p "  lab@rhel-lab376:~$ " cmd8
  echo
  if [[ "$cmd8" != "sudo umount /mnt/archive" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (no output)"
  echo
  echo "  Step 9: Now run mount -a to confirm /etc/fstab mounts it cleanly."
  read -p "  lab@rhel-lab376:~$ " cmd9
  echo
  if [[ "$cmd9" != "sudo mount -a" && "$cmd9" != "mount -a" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (no output)"
  echo

  # STEP 9: Verify mount and prove fstab-style identity is correct
  echo "  Step 10: Verify /mnt/archive is mounted and confirm the UUID matches what you set in /etc/fstab."
  read -p "  lab@rhel-lab376:~$ " cmd10
  echo
  if [[ "$cmd10" != "findmnt /mnt/archive" && \
        "$cmd10" != "df -Th /mnt/archive" && \
        "$cmd10" != "sudo blkid /dev/vgdata/lvarchive" && \
        "$cmd10" != "blkid /dev/vgdata/lvarchive" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd10" == "findmnt /mnt/archive" ]]; then
    echo "  TARGET        SOURCE                        FSTYPE OPTIONS"
    echo "  /mnt/archive  /dev/mapper/vgdata-lvarchive  xfs   rw,relatime,seclabel,attr2,inode64,noquota"
    echo "  (fstab now uses UUID=abababab-9999-8888-7777-acdeffedc0de)"
  elif [[ "$cmd10" == "df -Th /mnt/archive" ]]; then
    echo "  Filesystem                    Type  Size  Used Avail Use% Mounted on"
    echo "  /dev/mapper/vgdata-lvarchive  xfs   480M   33M  447M   7% /mnt/archive"
    echo "  (fstab now uses UUID=abababab-9999-8888-7777-acdeffedc0de)"
  else
    echo "  /dev/mapper/vgdata-lvarchive: UUID=\"abababab-9999-8888-7777-acdeffedc0de\" TYPE=\"xfs\""
    echo "  (fstab now uses UUID=abababab-9999-8888-7777-acdeffedc0de)"
  fi
  echo

  print_success "Great job."
  print_info "You fixed an incorrect UUID-based mount safely:"
  print_info "- confirmed the mount was missing and found the bad UUID in /etc/fstab"
  print_info "- proved the storage was healthy by mounting via device path"
  print_info "- discovered the correct UUID with blkid/lsblk"
  print_info "- updated /etc/fstab and validated with umount + mount -a (no reboot required)"
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
