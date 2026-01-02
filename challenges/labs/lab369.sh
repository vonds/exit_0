#!/bin/bash

# Lab 369: RHEL Troubleshooting — recover a broken /etc/fstab entry
# Focus: diagnosing boot/mount failures caused by bad fstab lines and repairing safely
# Key skills: lsblk/blkid, findmnt, mount -a, journalctl -xb,
# editing /etc/fstab safely, using UUID/LABEL, and validating with a controlled mount test.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 369: Recover a Broken /etc/fstab Entry"
LAB_ID="lab369"
LAB_XP=36900
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
  center_text "After a storage change, server40 now fails to mount a filesystem at boot."
  center_text "The system drops into emergency mode because of a broken /etc/fstab entry."
  echo
  center_text "Goal: identify the broken fstab line, fix it safely, and validate mounts."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Identify symptom from boot logs (emergency mode / mount failure)
  echo "  Step 1: Inspect the current boot logs to identify the mount failure."
  read -p "  lab@rhel-lab369:~$ " cmd1
  echo
  if [[ "$cmd1" != "sudo journalctl -xb --no-pager" && \
        "$cmd1" != "sudo journalctl -xb --no-pager | tail -n 80" && \
        "$cmd1" != "journalctl -xb --no-pager" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  ...systemd[1]: Failed to mount /mnt/data."
  echo "  ...systemd[1]: Dependency failed for Local File Systems."
  echo "  ...systemd[1]: You are in emergency mode. After logging in, type \"journalctl -xb\" to view system logs..."
  echo

  # STEP 2: Locate the broken entry in fstab
  echo "  Step 2: Inspect /etc/fstab and locate the entry for /mnt/data."
  read -p "  lab@rhel-lab369:~$ " cmd2
  echo
  if [[ "$cmd2" != "sudo grep -n '/mnt/data' /etc/fstab" && \
        "$cmd2" != "grep -n '/mnt/data' /etc/fstab" && \
        "$cmd2" != "sudo cat /etc/fstab" && \
        "$cmd2" != "sudo sed -n '1,200p' /etc/fstab" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  12: UUID=11111111-2222-3333-4444-555555555555  /mnt/data  xfs  defaults  0 0"
  echo

  # STEP 3: Find the correct UUID
  echo "  Step 3: Find the correct UUID for the device that should mount at /mnt/data."
  read -p "  lab@rhel-lab369:~$ " cmd3
  echo
  if [[ "$cmd3" != "lsblk -f" && \
        "$cmd3" != "sudo lsblk -f" && \
        "$cmd3" != "blkid" && \
        "$cmd3" != "sudo blkid" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  NAME        FSTYPE LABEL UUID                                 MOUNTPOINT"
  echo "  sda"
  echo "  ├─sda1      xfs          aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee  /boot"
  echo "  └─sda2      xfs          ffffffff-1111-2222-3333-444444444444  /"
  echo "  sdb"
  echo "  └─sdb1      xfs   DATA   99999999-8888-7777-6666-555555555555"
  echo

  # STEP 4: Backup fstab before editing
  echo "  Step 4: Create a backup of /etc/fstab before making changes."
  read -p "  lab@rhel-lab369:~$ " cmd4
  echo
  if [[ "$cmd4" != "sudo cp -a /etc/fstab /etc/fstab.bak.lab369" && \
        "$cmd4" != "sudo cp /etc/fstab /etc/fstab.bak.lab369" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (backup created: /etc/fstab.bak.lab369)"
  echo

  # STEP 5: Confirm the exact line number you will change
  echo "  Step 5: Confirm the /mnt/data entry line number again (you will change line 12)."
  read -p "  lab@rhel-lab369:~$ " cmd5
  echo
  if [[ "$cmd5" != "sudo grep -n '/mnt/data' /etc/fstab" && \
        "$cmd5" != "grep -n '/mnt/data' /etc/fstab" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  12: UUID=11111111-2222-3333-4444-555555555555  /mnt/data  xfs  defaults  0 0"
  echo

  # STEP 6: Make the fix via a command (user must type the exact change)
  echo "  Step 6: Replace the bad UUID on line 12 with the correct UUID (command-based edit)."
  read -p "  lab@rhel-lab369:~$ " cmd6
  echo
  if [[ "$cmd6" != "sudo sed -i '12c UUID=99999999-8888-7777-6666-555555555555  /mnt/data  xfs  defaults  0 0' /etc/fstab" && \
        "$cmd6" != "sudo sed -i \"12c UUID=99999999-8888-7777-6666-555555555555  /mnt/data  xfs  defaults  0 0\" /etc/fstab" && \
        "$cmd6" != "sudo perl -0777 -i -pe 's/^UUID=11111111-2222-3333-4444-555555555555  \\/mnt\\/data  xfs  defaults  0 0$/UUID=99999999-8888-7777-6666-555555555555  \\/mnt\\/data  xfs  defaults  0 0/m' /etc/fstab" ]]; then
    print_error "Incorrect."
    echo
    print_info "Expected input (one valid option):"
    echo "  sudo sed -i '12c UUID=99999999-8888-7777-6666-555555555555  /mnt/data  xfs  defaults  0 0' /etc/fstab"
    echo
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (updated /etc/fstab line 12)"
  echo

  # STEP 7: Verify the corrected line
  echo "  Step 7: Verify the /mnt/data entry now contains the correct UUID."
  read -p "  lab@rhel-lab369:~$ " cmd7
  echo
  if [[ "$cmd7" != "sudo grep -n '/mnt/data' /etc/fstab" && \
        "$cmd7" != "grep -n '/mnt/data' /etc/fstab" && \
        "$cmd7" != "sudo sed -n '12p' /etc/fstab" && \
        "$cmd7" != "sed -n '12p' /etc/fstab" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd7" == *"12p"* ]]; then
    echo "  UUID=99999999-8888-7777-6666-555555555555  /mnt/data  xfs  defaults  0 0"
  else
    echo "  12: UUID=99999999-8888-7777-6666-555555555555  /mnt/data  xfs  defaults  0 0"
  fi
  echo

  # STEP 8: Validate safely without reboot (mount -a)
  echo "  Step 8: Validate the fix safely by running mount -a (should produce no errors)."
  read -p "  lab@rhel-lab369:~$ " cmd8
  echo
  if [[ "$cmd8" != "sudo mount -a" && "$cmd8" != "mount -a" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (no output)"
  echo

  # STEP 9: Verify mount is active
  echo "  Step 9: Verify /mnt/data is mounted."
  read -p "  lab@rhel-lab369:~$ " cmd9
  echo
  if [[ "$cmd9" != "findmnt /mnt/data" && \
        "$cmd9" != "mount | grep /mnt/data" && \
        "$cmd9" != "df -h | grep /mnt/data" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  TARGET    SOURCE     FSTYPE OPTIONS"
  echo "  /mnt/data /dev/sdb1  xfs    rw,relatime,seclabel,attr2,inode64,noquota"
  echo

  # STEP 10: Harden the entry to avoid emergency mode if disk is missing
  echo "  Step 10: Harden the entry to avoid emergency mode if the disk is missing (add 'nofail')."
  read -p "  lab@rhel-lab369:~$ " cmd10
  echo
  if [[ "$cmd10" != "sudo sed -i 's#defaults  0 0#defaults,nofail  0 0#' /etc/fstab" && \
        "$cmd10" != "sudo sed -i \"s#defaults  0 0#defaults,nofail  0 0#\" /etc/fstab" && \
        "$cmd10" != "sudo vim /etc/fstab" && \
        "$cmd10" != "sudo nano /etc/fstab" && \
        "$cmd10" != "sudo vi /etc/fstab" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (updated fstab options for /mnt/data to include nofail)"
  echo

  # STEP 11: Re-validate after hardening
  echo "  Step 11: Run mount -a again to confirm there are still no errors."
  read -p "  lab@rhel-lab369:~$ " cmd11
  echo
  if [[ "$cmd11" != "sudo mount -a" && "$cmd11" != "mount -a" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (no output)"
  echo

  print_success "Great job."
  print_info "You recovered from a broken /etc/fstab entry by:"
  print_info "- identifying the failing mount in journalctl"
  print_info "- backing up /etc/fstab"
  print_info "- replacing the bad UUID using a command-based edit"
  print_info "- validating safely with mount -a and verifying with findmnt"
  print_info "- hardening with nofail to avoid emergency mode"
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
