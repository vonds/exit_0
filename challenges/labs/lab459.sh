#!/bin/bash

# Lab 459: RHEL Storage Security — Encrypt a Disk with LUKS and Persist It
# Focus: encrypting a block device using LUKS, unlocking it, creating a filesystem,
# mounting it, and ensuring persistence across reboots.
# Key skills: lsblk, cryptsetup luksFormat/open, mkfs.xfs, mount,
# /etc/crypttab, /etc/fstab, systemctl daemon-reload, verification workflow.
# Disk used in this lab: /dev/nvme1 (5GiB, unused)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 459: Encrypt a Disk with LUKS"
LAB_ID="lab459"
LAB_XP=45900
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
  center_text "A new disk must be protected using full-disk encryption."
  center_text "Policy:"
  center_text "- Disk: /dev/nvme1"
  center_text "- Encryption: LUKS"
  center_text "- Mapper name: crypt459"
  center_text "- Filesystem: XFS"
  center_text "- Mount point: /secure459"
  echo
  center_text "Goal: encrypt the disk, unlock it, format it, mount it,"
  center_text "and configure it to unlock and mount automatically at boot."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Verify disk is unused
  echo "  Step 1: Verify /dev/nvme1 exists and is not mounted."
  read -p "  lab@rhel-lab459:~$ " cmd1
  echo
  if [[ "$cmd1" != "lsblk" && "$cmd1" != "sudo lsblk" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  NAME     SIZE TYPE MOUNTPOINT"
  echo "  nvme1     5G  disk"
  echo

  # STEP 2: Initialize LUKS encryption
  echo "  Step 2: Encrypt /dev/nvme1 using LUKS."
  read -p "  lab@rhel-lab459:~$ " cmd2
  echo
  if [[ "$cmd2" != "sudo cryptsetup luksFormat /dev/nvme1" && \
        "$cmd2" != "cryptsetup luksFormat /dev/nvme1" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  WARNING!"
  echo "  This will overwrite data on /dev/nvme1."
  echo "  Are you sure? (Type YES in uppercase): YES"
  echo "  Enter passphrase:"
  echo "  Verify passphrase:"
  echo

  # STEP 3: Open encrypted device
  echo "  Step 3: Open the encrypted device as crypt459."
  read -p "  lab@rhel-lab459:~$ " cmd3
  echo
  if [[ "$cmd3" != "sudo cryptsetup open /dev/nvme1 crypt459" && \
        "$cmd3" != "cryptsetup open /dev/nvme1 crypt459" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Enter passphrase for /dev/nvme1:"
  echo

  # STEP 4: Verify mapper device exists
  echo "  Step 4: Verify the mapped device exists."
  read -p "  lab@rhel-lab459:~$ " cmd4
  echo
  if [[ "$cmd4" != "lsblk" && "$cmd4" != "sudo lsblk" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  crypt459  5G  crypt"
  echo

  # STEP 5: Create filesystem on encrypted device
  echo "  Step 5: Create an XFS filesystem on /dev/mapper/crypt459."
  read -p "  lab@rhel-lab459:~$ " cmd5
  echo
  if [[ "$cmd5" != "sudo mkfs.xfs /dev/mapper/crypt459" && \
        "$cmd5" != "mkfs.xfs /dev/mapper/crypt459" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  # STEP 6: Create mount point
  echo "  Step 6: Create mount point /secure459."
  read -p "  lab@rhel-lab459:~$ " cmd6
  echo
  if [[ "$cmd6" != "sudo mkdir -p /secure459" && \
        "$cmd6" != "mkdir -p /secure459" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  # STEP 7: Mount encrypted filesystem
  echo "  Step 7: Mount the encrypted filesystem."
  read -p "  lab@rhel-lab459:~$ " cmd7
  echo
  if [[ "$cmd7" != "sudo mount /dev/mapper/crypt459 /secure459" && \
        "$cmd7" != "mount /dev/mapper/crypt459 /secure459" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  # STEP 8: Verify mount
  echo "  Step 8: Verify the filesystem is mounted."
  read -p "  lab@rhel-lab459:~$ " cmd8
  echo
  if [[ "$cmd8" != "df -h | grep secure459" && \
        "$cmd8" != "mount | grep secure459" && \
        "$cmd8" != "findmnt /secure459" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  /dev/mapper/crypt459   5.0G   33M  5.0G   1% /secure459"
  echo

  # STEP 9: Configure /etc/crypttab
  echo "  Step 9: Configure /etc/crypttab for persistent unlock."
  read -p "  lab@rhel-lab459:~$ " cmd9
  echo
  if [[ "$cmd9" != "sudo vim /etc/crypttab" && \
        "$cmd9" != "sudo nano /etc/crypttab" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (added line)"
  echo "  crypt459  /dev/nvme1  none  luks"
  echo

  # STEP 10: Configure /etc/fstab
  echo "  Step 10: Configure /etc/fstab to mount encrypted filesystem."
  read -p "  lab@rhel-lab459:~$ " cmd10
  echo
  if [[ "$cmd10" != "sudo vim /etc/fstab" && \
        "$cmd10" != "sudo nano /etc/fstab" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (added line)"
  echo "  /dev/mapper/crypt459  /secure459  xfs  defaults  0  0"
  echo

  # STEP 11: Reload systemd and test mount
  echo "  Step 11: Test configuration without reloading."
  read -p "  lab@rhel-lab459:~$ " cmd11
  echo
  if [[ "$cmd11" != "sudo mount -a" && \
        "$cmd11" != "mount -a" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
 

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- encrypted a disk using LUKS"
  print_info "- unlocked it using cryptsetup"
  print_info "- created and mounted a filesystem on the encrypted device"
  print_info "- configured /etc/crypttab and /etc/fstab for persistence"
  print_info "This is exactly the disk encryption knowledge RHCSA expects."
  print_info "You earned $LAB_XP XP."
  award_xp $LAB_XP

  XP=$(jq '.XP' "$SAVE_JSON")
  LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
  export XP
  export LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've completed this lab $completion_count time(s)."
  echo
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " choice

  [[ "$choice" == "2" ]] && exit 0
done
