#!/bin/bash

# Lab 375: RHEL Troubleshooting — Determine Why Disk Space Doesn't Match df Output
# Focus: finding "missing" disk usage, open-but-deleted files, mountpoint confusion, reserved blocks, and inode use
# Key skills: df, du, find, lsof, fuser, mount/findmnt, tune2fs, xfs_info, journalctl, systemctl restart, and safe verification.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 375: Disk Space Mismatch vs df"
LAB_ID="lab375"
LAB_XP=37500
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
  center_text "A teammate says: 'df shows / is almost full, but du doesn't add up.'"
  center_text "Package installs are failing with: 'No space left on device'."
  center_text "You need to explain the mismatch and fix it safely."
  echo
  center_text "Goal: identify what's consuming space that du isn't showing, remediate, and verify df is sane."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Confirm the reported symptom with df
  echo "  Step 1: Show filesystem usage and confirm a high-use mount (human-readable)."
  read -p "  lab@rhel-lab375:~$ " cmd1
  echo
  if [[ "$cmd1" != "df -h" && \
        "$cmd1" != "sudo df -h" && \
        "$cmd1" != "df -h /" && \
        "$cmd1" != "sudo df -h /" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Filesystem           Size  Used Avail Use% Mounted on"
  echo "  /dev/mapper/rl-root   40G   38G  2.0G  96% /"
  echo

  # STEP 2: Compare with du at the mountpoint
  echo "  Step 2: Summarize apparent directory usage on / to compare against df."
  read -p "  lab@rhel-lab375:~$ " cmd2
  echo
  if [[ "$cmd2" != "sudo du -xh / --max-depth=1 | sort -h" && \
        "$cmd2" != "du -xh / --max-depth=1 | sort -h" && \
        "$cmd2" != "sudo du -xh / -d 1 | sort -h" && \
        "$cmd2" != "du -xh / -d 1 | sort -h" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "   120M  /boot"
  echo "   900M  /etc"
  echo "   2.4G  /usr"
  echo "   3.1G  /var"
  echo "   6.8G  /home"
  echo "    15G  /"
  echo
  echo "  (du totals ~15G, but df reports ~38G used: mismatch confirmed)"
  echo

  # STEP 3: Ensure we are measuring the right filesystem (avoid crossing mounts)
  echo "  Step 3: Confirm what is mounted on / and whether /var or /home are separate filesystems."
  read -p "  lab@rhel-lab375:~$ " cmd3
  echo
  if [[ "$cmd3" != "findmnt -R /" && \
        "$cmd3" != "sudo findmnt -R /" && \
        "$cmd3" != "mount | head" && \
        "$cmd3" != "findmnt /" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  TARGET SOURCE              FSTYPE OPTIONS"
  echo "  /      /dev/mapper/rl-root xfs    rw,relatime,seclabel,attr2,inode64,noquota"
  echo "  /boot  /dev/nvme0n1p2      xfs    rw,relatime,seclabel,attr2,inode64,noquota"
  echo

  # STEP 4: Look for open-but-deleted files (classic df vs du mismatch)
  echo "  Step 4: Identify open deleted files still consuming space."
  read -p "  lab@rhel-lab375:~$ " cmd4
  echo
  if [[ "$cmd4" != "sudo lsof +L1" && \
        "$cmd4" != "lsof +L1" && \
        "$cmd4" != "sudo lsof | grep -i deleted" && \
        "$cmd4" != "lsof | grep -i deleted" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  COMMAND   PID USER  FD   TYPE DEVICE  SIZE/OFF NLINK  NODE NAME"
  echo "  java     1882 app  17w   REG  253,0  21474836480    0  1234 /var/log/app.log (deleted)"
  echo
  echo "  (A large deleted log is still open by a process.)"
  echo

  # STEP 5: Confirm which process/service owns the file
  echo "  Step 5: Confirm the owning process and service name for the PID."
  read -p "  lab@rhel-lab375:~$ " cmd5
  echo
  if [[ "$cmd5" != "ps -fp 1882" && \
        "$cmd5" != "sudo ps -fp 1882" && \
        "$cmd5" != "systemctl status app.service --no-pager" && \
        "$cmd5" != "sudo systemctl status app.service --no-pager" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  UID   PID  PPID  C STIME TTY          TIME CMD"
  echo "  app  1882     1  2 09:10 ?        00:00:22 /usr/bin/java -jar /opt/app/app.jar"
  echo

  # STEP 6: Safely release the space (restart the service or process)
  echo "  Step 6: Restart the service to close the deleted file handle and release space."
  read -p "  lab@rhel-lab375:~$ " cmd6
  echo
  if [[ "$cmd6" != "sudo systemctl restart app.service" && \
        "$cmd6" != "systemctl restart app.service" && \
        "$cmd6" != "sudo kill -HUP 1882" && \
        "$cmd6" != "kill -HUP 1882" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (no output)"
  echo

  # STEP 7: Verify deleted-open file is gone
  echo "  Step 7: Confirm there are no large open deleted files remaining."
  read -p "  lab@rhel-lab375:~$ " cmd7
  echo
  if [[ "$cmd7" != "sudo lsof +L1" && \
        "$cmd7" != "lsof +L1" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (no output)"
  echo

  # STEP 8: Re-check df to confirm space returns
  echo "  Step 8: Re-check filesystem usage."
  read -p "  lab@rhel-lab375:~$ " cmd8
  echo
  if [[ "$cmd8" != "df -h /" && \
        "$cmd8" != "sudo df -h /" && \
        "$cmd8" != "df -h" && \
        "$cmd8" != "sudo df -h" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Filesystem           Size  Used Avail Use% Mounted on"
  echo "  /dev/mapper/rl-root   40G   17G   23G  43% /"
  echo

  # STEP 9: Rule out inode exhaustion (df -i)
  echo "  Step 9: Check inode usage to confirm 'No space left' isn't inode exhaustion."
  read -p "  lab@rhel-lab375:~$ " cmd9
  echo
  if [[ "$cmd9" != "df -i /" && \
        "$cmd9" != "sudo df -i /" && \
        "$cmd9" != "df -i" && \
        "$cmd9" != "sudo df -i" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Filesystem          Inodes  IUsed   IFree IUse% Mounted on"
  echo "  /dev/mapper/rl-root  2.0M   120K    1.9M    6% /"
  echo

  # STEP 10: Confirm the root cause in logs (optional but good ops hygiene)
  echo "  Step 10: Check recent logs for disk-full messages around the time of failure."
  read -p "  lab@rhel-lab375:~$ " cmd10
  echo
  if [[ "$cmd10" != "sudo journalctl --since '1 hour ago' --no-pager | grep -i 'no space'" && \
        "$cmd10" != "journalctl --since '1 hour ago' --no-pager | grep -i 'no space'" && \
        "$cmd10" != "sudo journalctl -b --no-pager | grep -i 'no space'" && \
        "$cmd10" != "journalctl -b --no-pager | grep -i 'no space'" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Jan 07 05:22:41 rhel-lab375 app[1882]: ERROR: write failed: No space left on device"
  echo "  Jan 07 05:22:55 rhel-lab375 dnf[2401]: Error: Transaction test error: No space left on device"
  echo

  print_success "Great job."
  print_info "You diagnosed a df vs du mismatch with an ops-safe workflow:"
  print_info "- confirmed the mismatch (df vs du) and validated mounts"
  print_info "- used lsof to find a large open-but-deleted file consuming space"
  print_info "- restarted the owning service to release the file handle"
  print_info "- verified df recovered and ruled out inode exhaustion"
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
