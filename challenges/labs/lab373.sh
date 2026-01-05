#!/bin/bash

# Lab 373: RHEL Troubleshooting — Diagnose Why a Mount Works Manually but Not on Reboot
# Focus: persistent mounts, /etc/fstab correctness, systemd mount timing, UUID/LABEL usage
# Key skills: findmnt, mount -a, /etc/fstab, systemctl status, journalctl -b, blkid, lsblk -f,
# _netdev/nofail/x-systemd.* options, and safe verification.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 373: Mount Works Manually but Fails on Reboot"
LAB_ID="lab373"
LAB_XP=37300
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
  center_text "A filesystem mount works when you run it manually:"
  center_text "  sudo mount /mnt/projects"
  center_text "But after reboot, /mnt/projects is not mounted."
  center_text "The admin insists it is in /etc/fstab."
  echo
  center_text "Goal: identify why it fails at boot and fix /etc/fstab safely."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Confirm the mount is currently missing
  echo "  Step 1: Confirm whether /mnt/projects is mounted right now."
  read -p "  lab@rhel-lab373:~$ " cmd1
  echo
  if [[ "$cmd1" != "findmnt /mnt/projects" && \
        "$cmd1" != "mount | grep /mnt/projects" && \
        "$cmd1" != "df -h /mnt/projects" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (no output)"
  echo "  /mnt/projects is not mounted."
  echo

  # STEP 2: Mount manually to prove it works
  echo "  Step 2: Mount it manually to confirm the filesystem and mount point are valid."
  read -p "  lab@rhel-lab373:~$ " cmd2
  echo
  if [[ "$cmd2" != "sudo mount /mnt/projects" && \
        "$cmd2" != "sudo mount /dev/vgproj/lvproj /mnt/projects" && \
        "$cmd2" != "sudo mount -a" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (no output)"
  echo
  echo "  Step 3: Verify it is mounted now."
  read -p "  lab@rhel-lab373:~$ " cmd3
  echo
  if [[ "$cmd3" != "findmnt /mnt/projects" && \
        "$cmd3" != "df -Th /mnt/projects" && \
        "$cmd3" != "mount | grep /mnt/projects" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  TARGET         SOURCE                 FSTYPE OPTIONS"
  echo "  /mnt/projects  /dev/mapper/vgproj-lvproj xfs   rw,relatime,seclabel,attr2,inode64,noquota"
  echo

  # STEP 3: Inspect the fstab entry
  echo "  Step 4: Inspect the /etc/fstab entry for /mnt/projects."
  read -p "  lab@rhel-lab373:~$ " cmd4
  echo
  if [[ "$cmd4" != "sudo grep -n '/mnt/projects' /etc/fstab" && \
        "$cmd4" != "grep -n '/mnt/projects' /etc/fstab" && \
        "$cmd4" != "sudo cat /etc/fstab" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  14: /dev/vgproj/lvproj  /mnt/projects  xfs  defaults,nofail  0 0"
  echo

  # STEP 4: Diagnose likely boot-time issue: device path not stable at boot; prefer UUID
  echo "  Step 5: Identify a stable identifier for the source device (UUID)."
  read -p "  lab@rhel-lab373:~$ " cmd5
  echo
  if [[ "$cmd5" != "sudo blkid /dev/vgproj/lvproj" && \
        "$cmd5" != "blkid /dev/vgproj/lvproj" && \
        "$cmd5" != "lsblk -f" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  /dev/mapper/vgproj-lvproj: UUID=\"abababab-1111-2222-3333-cdcdcdcdcdcd\" TYPE=\"xfs\""
  echo

  # STEP 5: Check boot logs for mount failure
  echo "  Step 6: Check boot logs for the mount failure reason."
  read -p "  lab@rhel-lab373:~$ " cmd6
  echo
  if [[ "$cmd6" != "sudo journalctl -b --no-pager | grep -i projects" && \
        "$cmd6" != "sudo journalctl -b --no-pager | grep -i mount" && \
        "$cmd6" != "sudo systemctl status mnt-projects.mount --no-pager" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  systemd[1]: mnt-projects.mount: Mount process exited, code=exited, status=32/n/a"
  echo "  systemd[1]: Failed to mount /mnt/projects."
  echo "  mount[512]: special device /dev/vgproj/lvproj does not exist."
  echo

  # STEP 6: Fix fstab to use UUID + proper systemd ordering for LVM
  echo "  Step 7: Update the /etc/fstab entry to use UUID instead of the device path."
  read -p "  lab@rhel-lab373:~$ " cmd7
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

  # STEP 7: Validate fstab without reboot using mount -a
  echo "  Step 8: Validate /etc/fstab safely without reboot."
  read -p "  lab@rhel-lab373:~$ " cmd8
  echo
  if [[ "$cmd8" != "sudo umount /mnt/projects" && "$cmd8" != "sudo mount -a" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd8" == "sudo umount /mnt/projects" ]]; then
    echo "  (no output)"
    echo
    echo "  Step 9: Now run mount -a to confirm fstab mounts it successfully."
    read -p "  lab@rhel-lab373:~$ " cmd9
    echo
    if [[ "$cmd9" != "sudo mount -a" ]]; then
      print_error "Incorrect."
      read -p "Press Enter to try again..." _
      continue
    fi
    echo "  (no output)"
    echo
  else
    echo "  (no output)"
    echo
  fi

  # STEP 8: Verify mount is present and persistent-ready
  echo "  Step 10: Verify /mnt/projects is mounted and sourced by UUID."
  read -p "  lab@rhel-lab373:~$ " cmd10
  echo
  if [[ "$cmd10" != "findmnt /mnt/projects" && \
        "$cmd10" != "df -Th /mnt/projects" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  TARGET         SOURCE                                      FSTYPE OPTIONS"
  echo "  /mnt/projects  /dev/mapper/vgproj-lvproj                   xfs   rw,relatime,seclabel,attr2,inode64,noquota"
  echo "  (fstab now uses UUID=abababab-1111-2222-3333-cdcdcdcdcdcd)"
  echo

  print_success "Great job."
  print_info "You diagnosed why a mount worked manually but failed on reboot:"
  print_info "- boot logs showed the device path was not present at mount time"
  print_info "- you corrected /etc/fstab to use a stable identifier (UUID) and validated with mount -a"
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
