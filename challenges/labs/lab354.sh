#!/bin/bash

# Lab 354: RHEL Troubleshooting — system boots into emergency mode due to a bad /etc/fstab entry
# RHCSA focus: identifying why emergency mode happened with systemd, reading boot logs (journalctl),
# inspecting block devices (lsblk/blkid), validating fstab entries, fixing safely,
# reloading mounts (mount -a), clearing failed units, and verifying normal system state.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 354"
LAB_ID="lab354"
LAB_XP=35400
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

PROMPT="student@lab354:~$ > "

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "RHEL Troubleshooting — the system booted into emergency mode after a reboot."
  center_text "Interactive: find the cause, fix it, mount cleanly, and verify normal system state."
  echo
  center_text "Press Enter to begin."
  read _
  draw_lab_ui

  # STEP 1
  echo "  Step 1: Identify failed systemd units (look for a failed mount or local-fs failure)."
  read -p "  $PROMPT" cmd1
  if [[ "$cmd1" != "systemctl --failed" && "$cmd1" != "sudo systemctl --failed" ]]; then
    print_error "Incorrect. Use: systemctl --failed"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  UNIT                 LOAD   ACTIVE SUB    DESCRIPTION"
  echo "  var-log.mount        loaded failed failed /var/log"
  echo "  local-fs.target      loaded failed failed Local File Systems"
  echo "  "
  echo "  2 loaded units listed."
  echo "  2 failed units listed."

  # STEP 2
  echo
  echo "  Step 2: View the status of local-fs.target to confirm why the boot dropped into emergency mode."
  read -p "  $PROMPT" cmd2
  if [[ "$cmd2" != "systemctl status local-fs.target" && "$cmd2" != "sudo systemctl status local-fs.target" ]]; then
    print_error "Incorrect. Use: systemctl status local-fs.target"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  ● local-fs.target - Local File Systems"
  echo "     Loaded: loaded (/usr/lib/systemd/system/local-fs.target; static)"
  echo "     Active: failed (Result: dependency) since Fri 2025-12-21 09:14:28 EST; 2min 03s ago"
  echo "       Docs: man:systemd.special(7)"
  echo "  "
  echo "  Dec 21 09:14:28 rhel-lab systemd[1]: local-fs.target: Dependency failed for /var/log."
  echo "  Dec 21 09:14:28 rhel-lab systemd[1]: local-fs.target: Job var-log.mount/start failed with result 'dependency'."
  echo "  Dec 21 09:14:28 rhel-lab systemd[1]: local-fs.target: Failed with result 'dependency'."
  echo "  Dec 21 09:14:28 rhel-lab systemd[1]: Failed to start Local File Systems."
  echo "  Dec 21 09:14:28 rhel-lab systemd[1]: You are in emergency mode. After logging in, type \"journalctl -xb\" to view system logs."

  # STEP 3
  echo
  echo "  Step 3: View the detailed status for the failed mount unit."
  read -p "  $PROMPT" cmd3
  if [[ "$cmd3" != "systemctl status var-log.mount" && "$cmd3" != "sudo systemctl status var-log.mount" ]]; then
    print_error "Incorrect. Use: systemctl status var-log.mount"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  ● var-log.mount - /var/log"
  echo "     Loaded: loaded (/etc/fstab; generated)"
  echo "     Active: failed (Result: exit-code) since Fri 2025-12-21 09:14:28 EST; 2min 14s ago"
  echo "      Where: /var/log"
  echo "       What: /dev/disk/by-uuid/dead-beef-cafe-babe"
  echo "  "
  echo "  Dec 21 09:14:28 rhel-lab systemd[1]: Mounting /var/log..."
  echo "  Dec 21 09:14:28 rhel-lab mount[612]: mount: /var/log: special device /dev/disk/by-uuid/dead-beef-cafe-babe does not exist."
  echo "  Dec 21 09:14:28 rhel-lab systemd[1]: var-log.mount: Mount process exited, code=exited, status=32/n/a"
  echo "  Dec 21 09:14:28 rhel-lab systemd[1]: var-log.mount: Failed with result 'exit-code'."
  echo "  Dec 21 09:14:28 rhel-lab systemd[1]: Failed to mount /var/log."

  # STEP 4
  echo
  echo "  Step 4: Review the boot log around the failure to confirm the root cause."
  read -p "  $PROMPT" cmd4
  if [[ "$cmd4" != "journalctl -xb" && "$cmd4" != "sudo journalctl -xb" ]]; then
    print_error "Incorrect. Use: journalctl -xb"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  -- Boot 7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f --"
  echo "  Dec 21 09:14:27 rhel-lab systemd[1]: Starting Local File Systems..."
  echo "  Dec 21 09:14:28 rhel-lab systemd[1]: Mounting /var/log..."
  echo "  Dec 21 09:14:28 rhel-lab mount[612]: mount: /var/log: special device /dev/disk/by-uuid/dead-beef-cafe-babe does not exist."
  echo "  Dec 21 09:14:28 rhel-lab systemd[1]: var-log.mount: Mount process exited, code=exited, status=32/n/a"
  echo "  Dec 21 09:14:28 rhel-lab systemd[1]: var-log.mount: Failed with result 'exit-code'."
  echo "  Dec 21 09:14:28 rhel-lab systemd[1]: Failed to mount /var/log."
  echo "  Dec 21 09:14:28 rhel-lab systemd[1]: local-fs.target: Failed with result 'dependency'."
  echo "  Dec 21 09:14:28 rhel-lab systemd[1]: You are in emergency mode. After logging in, type \"journalctl -xb\" to view system logs."

  # STEP 5
  echo
  echo "  Step 5: Inspect block devices and filesystems to locate the intended /var/log partition."
  read -p "  $PROMPT" cmd5
  if [[ "$cmd5" != "lsblk -f" && "$cmd5" != "sudo lsblk -f" ]]; then
    print_error "Incorrect. Use: lsblk -f"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  NAME   FSTYPE FSVER LABEL   UUID                                 FSAVAIL FSUSE% MOUNTPOINTS"
  echo "  sda"
  echo "  ├─sda1 xfs          boot    6b9d3b8a-7d4a-4c6a-8f4c-3e8b6f2d2a11  380M    23%   /boot"
  echo "  ├─sda2 xfs          root    4f1c2d8e-9c0a-4a9a-a3d1-7f3c2b1a0e55  28G     22%   /"
  echo "  ├─sda3 xfs          varlog  beef-cafe-babe-dead                    9.3G    2%    "
  echo "  └─sda4 swap         swap    8a8a8a8a-1111-2222-3333-444444444444                [SWAP]"
  echo "  sr0"

  # STEP 6
  echo
  echo "  Step 6: Confirm the exact UUID of the filesystem that should mount at /var/log."
  read -p "  $PROMPT" cmd6
  if [[ "$cmd6" != "blkid /dev/sda3" && "$cmd6" != "sudo blkid /dev/sda3" ]]; then
    print_error "Incorrect. Use: blkid /dev/sda3"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  /dev/sda3: LABEL=\"varlog\" UUID=\"beef-cafe-babe-dead\" TYPE=\"xfs\""

  # STEP 7
  echo
  echo "  Step 7: Show the /var/log entry in /etc/fstab (it references a missing UUID)."
  read -p "  $PROMPT" cmd7
  if [[ "$cmd7" != "grep -n ' /var/log ' /etc/fstab" && "$cmd7" != "sudo grep -n ' /var/log ' /etc/fstab" ]]; then
    print_error "Incorrect. Use: grep -n ' /var/log ' /etc/fstab"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  16:UUID=dead-beef-cafe-babe  /var/log  xfs  defaults  0 0"

  # STEP 8
  echo
  echo "  Step 8: Fix the UUID in /etc/fstab (use a safe, single-line replace)."
  read -p "  $PROMPT" cmd8
  if [[ "$cmd8" != "sudo sed -i 's/UUID=dead-beef-cafe-babe/UUID=beef-cafe-babe-dead/' /etc/fstab" ]]; then
    print_error "Incorrect. Use: sudo sed -i 's/UUID=dead-beef-cafe-babe/UUID=beef-cafe-babe-dead/' /etc/fstab"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  "

  # STEP 9
  echo
  echo "  Step 9: Validate /etc/fstab and mount everything that is not mounted."
  read -p "  $PROMPT" cmd9
  if [[ "$cmd9" != "sudo mount -a" && "$cmd9" != "mount -a" ]]; then
    print_error "Incorrect. Use: sudo mount -a"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  "

  # STEP 10
  echo
  echo "  Step 10: Clear the failed unit state now that the mount is fixed."
  read -p "  $PROMPT" cmd10
  if [[ "$cmd10" != "sudo systemctl reset-failed" && "$cmd10" != "systemctl reset-failed" ]]; then
    print_error "Incorrect. Use: sudo systemctl reset-failed"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  "

  # STEP 11
  echo
  echo "  Step 11: Verify the system is healthy and /var/log is mounted."
  read -p "  $PROMPT" cmd11
  if [[ "$cmd11" != "findmnt /var/log" && "$cmd11" != "df -h /var/log" && "$cmd11" != "systemctl is-system-running" ]]; then
    print_error "Incorrect. Use: findmnt /var/log  (or: df -h /var/log  or: systemctl is-system-running)"
    read -p "Press Enter to continue..." _
    continue
  fi

  if [[ "$cmd11" == "findmnt /var/log" ]]; then
    echo "  TARGET   SOURCE    FSTYPE OPTIONS"
    echo "  /var/log /dev/sda3 xfs    rw,relatime,seclabel,attr2,inode64,logbufs=8,logbsize=32k,noquota"
  elif [[ "$cmd11" == "df -h /var/log" ]]; then
    echo "  Filesystem      Size  Used Avail Use% Mounted on"
    echo "  /dev/sda3       10G   180M  9.9G   2% /var/log"
  else
    echo "  running"
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
