#!/bin/bash

# Lab 353: RHEL Troubleshooting — /data won't mount at boot due to bad /etc/fstab UUID
# RHCSA focus: identifying failed mounts with systemd, reading boot logs (journalctl),
# inspecting block devices (lsblk/blkid), validating fstab entries, fixing UUID safely,
# reloading mounts (mount -a), and verifying with df/findmnt.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 353"
LAB_ID="lab353"
LAB_XP=35300
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

PROMPT="student@lab353:~$ > "

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "RHEL Troubleshooting — after reboot, /data is missing and apps cannot write logs."
  center_text "Interactive: find the failed mount, inspect disks/UUIDs, fix /etc/fstab, and mount cleanly."
  echo
  center_text "Press Enter to begin."
  read _
  draw_lab_ui

  # STEP 1
  echo "  Step 1: Identify failed systemd units (look for a failed mount)."
  read -p "  $PROMPT" cmd1
  if [[ "$cmd1" != "systemctl --failed" && "$cmd1" != "sudo systemctl --failed" ]]; then
    print_error "Incorrect. Use: systemctl --failed"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  UNIT            LOAD   ACTIVE SUB    DESCRIPTION"
  echo "  data.mount      loaded failed failed /data"
  echo "  "
  echo "  LOAD   = Reflects whether the unit definition was properly loaded."
  echo "  ACTIVE = The high-level unit activation state, i.e. generalization of SUB."
  echo "  SUB    = The low-level unit activation state, values depend on unit type."
  echo "  "
  echo "  1 loaded units listed."
  echo "  1 failed units listed."

  # STEP 2
  echo
  echo "  Step 2: View the detailed status for the failed mount unit."
  read -p "  $PROMPT" cmd2
  if [[ "$cmd2" != "systemctl status data.mount" && "$cmd2" != "sudo systemctl status data.mount" ]]; then
    print_error "Incorrect. Use: systemctl status data.mount"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  ● data.mount - /data"
  echo "     Loaded: loaded (/etc/fstab; generated)"
  echo "     Active: failed (Result: exit-code) since Fri 2025-12-19 18:12:05 EST; 1min 7s ago"
  echo "      Where: /data"
  echo "       What: /dev/disk/by-uuid/1111-2222-3333-4444"
  echo "  "
  echo "  Dec 19 18:12:05 rhel-lab systemd[1]: Mounting /data..."
  echo "  Dec 19 18:12:05 rhel-lab mount[742]: mount: /data: special device /dev/disk/by-uuid/1111-2222-3333-4444 does not exist."
  echo "  Dec 19 18:12:05 rhel-lab systemd[1]: data.mount: Mount process exited, code=exited, status=32/n/a"
  echo "  Dec 19 18:12:05 rhel-lab systemd[1]: data.mount: Failed with result 'exit-code'."
  echo "  Dec 19 18:12:05 rhel-lab systemd[1]: Failed to mount /data."

  # STEP 3
  echo
  echo "  Step 3: Inspect block devices and filesystems to locate the intended /data partition."
  read -p "  $PROMPT" cmd3
  if [[ "$cmd3" != "lsblk -f" && "$cmd3" != "sudo lsblk -f" ]]; then
    print_error "Incorrect. Use: lsblk -f"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  NAME   FSTYPE FSVER LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINTS"
  echo "  sda"
  echo "  ├─sda1 xfs          boot  6b9d3b8a-7d4a-4c6a-8f4c-3e8b6f2d2a11  380M    23%   /boot"
  echo "  ├─sda2 xfs          root  4f1c2d8e-9c0a-4a9a-a3d1-7f3c2b1a0e55  28G     22%   /"
  echo "  └─sda3 xfs          data  aaaa-bbbb-cccc-dddd                    31G     1%    "
  echo "  sr0"

  # STEP 4
  echo
  echo "  Step 4: Confirm the exact UUID of the data filesystem."
  read -p "  $PROMPT" cmd4
  if [[ "$cmd4" != "blkid /dev/sda3" && "$cmd4" != "sudo blkid /dev/sda3" ]]; then
    print_error "Incorrect. Use: blkid /dev/sda3"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  /dev/sda3: LABEL=\"data\" UUID=\"aaaa-bbbb-cccc-dddd\" TYPE=\"xfs\""

  # STEP 5
  echo
  echo "  Step 5: Show the /data entry in /etc/fstab (the UUID is wrong)."
  read -p "  $PROMPT" cmd5
  if [[ "$cmd5" != "grep -n ' /data ' /etc/fstab" && "$cmd5" != "sudo grep -n ' /data ' /etc/fstab" ]]; then
    print_error "Incorrect. Use: grep -n ' /data ' /etc/fstab"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  12:UUID=1111-2222-3333-4444  /data  xfs  defaults  0 0"

  # STEP 6
  echo
  echo "  Step 6: Fix the UUID in /etc/fstab (use a safe, single-line replace)."
  read -p "  $PROMPT" cmd6
  if [[ "$cmd6" != "sudo sed -i 's/UUID=1111-2222-3333-4444/UUID=aaaa-bbbb-cccc-dddd/' /etc/fstab" ]]; then
    print_error "Incorrect. Use: sudo sed -i 's/UUID=1111-2222-3333-4444/UUID=aaaa-bbbb-cccc-dddd/' /etc/fstab"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  "

  # STEP 7
  echo
  echo "  Step 7: Validate /etc/fstab and mount everything that is not mounted."
  read -p "  $PROMPT" cmd7
  if [[ "$cmd7" != "sudo mount -a" && "$cmd7" != "mount -a" ]]; then
    print_error "Incorrect. Use: sudo mount -a"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  "

  # STEP 8
  echo
  echo "  Step 8: Verify /data is now mounted and available."
  read -p "  $PROMPT" cmd8
  if [[ "$cmd8" != "df -h /data" && "$cmd8" != "findmnt /data" ]]; then
    print_error "Incorrect. Use: df -h /data  (or: findmnt /data)"
    read -p "Press Enter to continue..." _
    continue
  fi
  if [[ "$cmd8" == "df -h /data" ]]; then
    echo "  Filesystem      Size  Used Avail Use% Mounted on"
    echo "  /dev/sda3        40G  416M   40G   2% /data"
  else
    echo "  TARGET SOURCE    FSTYPE OPTIONS"
    echo "  /data  /dev/sda3 xfs    rw,relatime,seclabel,attr2,inode64,logbufs=8,logbsize=32k,noquota"
  fi

  print_success "Excellent work!"
  print_info "You earned $LAB_XP XP for completing this lab!"
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

  if [[ "$choice" == "2" ]]; then
    exit 0
  fi
done
