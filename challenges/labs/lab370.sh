#!/bin/bash

# Lab 370: RHEL Troubleshooting — fix a filesystem that fails to mount at boot
# Focus: diagnosing mount failures at boot caused by filesystem errors, then repairing safely
# Key skills: journalctl -xb, systemctl status local-fs.target, lsblk/blkid/findmnt,
# mount -a, filesystem checks (xfs_repair or fsck), emergency-mode workflow, and verification.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 370: Fix Filesystem That Fails to Mount at Boot"
LAB_ID="lab370"
LAB_XP=37000
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
  center_text "After an unclean shutdown, a non-root filesystem fails to mount at boot."
  center_text "System drops into emergency mode and reports '/mnt/data' mount failure."
  echo
  center_text "Goal: identify the failing device, repair the filesystem, and restore a clean boot."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Identify failure from boot logs
  echo "  Step 1: Inspect the current boot logs to identify why /mnt/data failed to mount."
  read -p "  lab@rhel-lab370:~$ " cmd1
  echo
  if [[ "$cmd1" != "sudo journalctl -xb --no-pager" && \
        "$cmd1" != "sudo journalctl -xb --no-pager | tail -n 120" && \
        "$cmd1" != "journalctl -xb --no-pager" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  ...systemd[1]: Mounting /mnt/data..."
  echo "  ...kernel: XFS (sdb1): log mount/recovery failed: error -5"
  echo "  ...kernel: XFS (sdb1): corrupt log/inconsistent filesystem"
  echo "  ...systemd[1]: Failed to mount /mnt/data."
  echo "  ...systemd[1]: Dependency failed for Local File Systems."
  echo "  ...systemd[1]: You are in emergency mode."
  echo

  # STEP 2: Identify the device and filesystem type for /mnt/data
  echo "  Step 2: Determine which device and filesystem type correspond to /mnt/data."
  read -p "  lab@rhel-lab370:~$ " cmd2
  echo
  if [[ "$cmd2" != "findmnt /mnt/data" && \
        "$cmd2" != "sudo findmnt /mnt/data" && \
        "$cmd2" != "lsblk -f" && \
        "$cmd2" != "sudo lsblk -f" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd2" == *"findmnt"* ]]; then
    echo "  TARGET    SOURCE     FSTYPE OPTIONS"
    echo "  /mnt/data /dev/sdb1  xfs    rw,relatime"
  else
    echo "  NAME   FSTYPE LABEL UUID                                 MOUNTPOINT"
    echo "  sdb"
    echo "  └─sdb1 xfs    DATA  99999999-8888-7777-6666-555555555555  (not mounted)"
  fi
  echo

  # STEP 3: Ensure the filesystem is NOT mounted before repair
  echo "  Step 3: Confirm /dev/sdb1 is not mounted before performing repairs."
  read -p "  lab@rhel-lab370:~$ " cmd3
  echo
  if [[ "$cmd3" != "mount | grep sdb1" && \
        "$cmd3" != "findmnt -S /dev/sdb1" && \
        "$cmd3" != "lsblk -o NAME,MOUNTPOINT /dev/sdb" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (no mount found for /dev/sdb1)"
  echo

  # STEP 4: Run the correct repair tool for XFS
  echo "  Step 4: Repair the XFS filesystem on /dev/sdb1 (use the appropriate tool)."
  read -p "  lab@rhel-lab370:~$ " cmd4
  echo
  if [[ "$cmd4" != "sudo xfs_repair /dev/sdb1" && \
        "$cmd4" != "xfs_repair /dev/sdb1" && \
        "$cmd4" != "sudo xfs_repair -L /dev/sdb1" ]]; then
    print_error "Incorrect."
    echo
    print_info "Expected input (one valid option):"
    echo "  sudo xfs_repair /dev/sdb1"
    echo
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd4" == *" -L "* ]]; then
    echo "  Phase 1 - find and verify superblock..."
    echo "  Phase 2 - using internal log"
    echo "  -L option specified. Log zeroed."
    echo "  Phase 3 - for each AG..."
    echo "  Phase 7 - verify and correct link counts..."
    echo "  done"
  else
    echo "  Phase 1 - find and verify superblock..."
    echo "  Phase 2 - using internal log"
    echo "  Phase 3 - for each AG..."
    echo "  Phase 7 - verify and correct link counts..."
    echo "  done"
  fi
  echo

  # STEP 5: Validate mounts again with mount -a
  echo "  Step 5: Retry all mounts from /etc/fstab safely using mount -a."
  read -p "  lab@rhel-lab370:~$ " cmd5
  echo
  if [[ "$cmd5" != "sudo mount -a" && "$cmd5" != "mount -a" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (no output)"
  echo

  # STEP 6: Verify /mnt/data mounts successfully now
  echo "  Step 6: Verify /mnt/data is mounted successfully."
  read -p "  lab@rhel-lab370:~$ " cmd6
  echo
  if [[ "$cmd6" != "findmnt /mnt/data" && \
        "$cmd6" != "df -h | grep /mnt/data" && \
        "$cmd6" != "mount | grep /mnt/data" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  TARGET    SOURCE     FSTYPE OPTIONS"
  echo "  /mnt/data /dev/sdb1  xfs    rw,relatime,seclabel,attr2,inode64,noquota"
  echo

  # STEP 7: Confirm local-fs is healthy
  echo "  Step 7: Confirm systemd considers local filesystems healthy now."
  read -p "  lab@rhel-lab370:~$ " cmd7
  echo
  if [[ "$cmd7" != "systemctl status local-fs.target --no-pager" && \
        "$cmd7" != "sudo systemctl status local-fs.target --no-pager" && \
        "$cmd7" != "systemctl --failed" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd7" == "systemctl --failed" ]]; then
    echo "  0 loaded units listed."
  else
    echo "  ● local-fs.target - Local File Systems"
    echo "     Loaded: loaded"
    echo "     Active: active"
  fi
  echo

  # STEP 8: Validate persistence by reviewing fstab entry
  echo "  Step 8: Confirm /etc/fstab uses a stable identifier (UUID/LABEL) for /mnt/data."
  read -p "  lab@rhel-lab370:~$ " cmd8
  echo
  if [[ "$cmd8" != "sudo grep -n '/mnt/data' /etc/fstab" && \
        "$cmd8" != "grep -n '/mnt/data' /etc/fstab" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  12: UUID=99999999-8888-7777-6666-555555555555  /mnt/data  xfs  defaults  0 0"
  echo

  print_success "Great job."
  print_info "You fixed a filesystem that failed to mount at boot by:"
  print_info "- using journalctl to identify an XFS mount/recovery error"
  print_info "- confirming the failing device and that it was unmounted"
  print_info "- repairing it with xfs_repair"
  print_info "- validating with mount -a and verifying with findmnt/systemd status"
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
