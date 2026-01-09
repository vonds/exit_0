#!/bin/bash

# Lab 377: RHEL Troubleshooting — Identify Why Swap Is Not Activating
# Focus: diagnosing swap activation failures (fstab issues, wrong UUID, missing device, permissions, SELinux contexts)
# Key skills: swapon --show, free -h, lsblk -f, blkid, /etc/fstab, mount -a, systemctl status, journalctl -b,
# mkswap, swapon, swapoff, and safe verification.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 377: Identify Why Swap Is Not Activating"
LAB_ID="lab377"
LAB_XP=37700
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
  center_text "After a reboot, the system is slow under memory pressure."
  center_text "The admin claims swap is configured, but it shows 0B active."
  center_text "You need to identify why swap isn't activating and fix it safely."
  echo
  center_text "Goal: find the swap activation failure, correct it, and verify swap is active."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Confirm swap is not active
  echo "  Step 1: Confirm swap is not active right now."
  read -p "  lab@rhel-lab377:~$ " cmd1
  echo
  if [[ "$cmd1" != "swapon --show" && \
        "$cmd1" != "sudo swapon --show" && \
        "$cmd1" != "free -h" && \
        "$cmd1" != "sudo free -h" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd1" == *"swapon --show"* ]]; then
    echo "  (no output)"
    echo "  No active swap devices/files."
  else
    echo "               total        used        free      shared  buff/cache   available"
    echo "  Mem:           3.7G        2.9G        220M        120M        620M        420M"
    echo "  Swap:            0B          0B          0B"
  fi
  echo

  # STEP 2: Identify configured swap in /etc/fstab
  echo "  Step 2: Check /etc/fstab for any swap entry."
  read -p "  lab@rhel-lab377:~$ " cmd2
  echo
  if [[ "$cmd2" != "sudo grep -n -E '\\sswap\\s' /etc/fstab" && \
        "$cmd2" != "grep -n -E '\\sswap\\s' /etc/fstab" && \
        "$cmd2" != "sudo grep -n swap /etc/fstab" && \
        "$cmd2" != "grep -n swap /etc/fstab" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  12: UUID=deadbeef-dead-beef-dead-beefdeadbeef  none  swap  defaults  0 0"
  echo

  # STEP 3: Check boot logs / systemd for swap activation failure
  echo "  Step 3: Check boot logs or systemd status for swap activation errors."
  read -p "  lab@rhel-lab377:~$ " cmd3
  echo
  if [[ "$cmd3" != "sudo journalctl -b --no-pager | grep -i swap" && \
        "$cmd3" != "sudo systemctl status dev-disk-by\\x2duuid-deadbeef\\x2ddead\\x2dbeef\\x2ddead\\x2dbeefdeadbeef.swap --no-pager" && \
        "$cmd3" != "sudo systemctl --failed --no-pager" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  systemd[1]: dev-disk-by\\x2duuid-deadbeef\\x2ddead\\x2dbeef\\x2ddead\\x2dbeefdeadbeef.swap: Job failed."
  echo "  systemd[1]: Failed to activate swap dev-disk-by\\x2duuid-deadbeef\\x2ddead\\x2dbeef\\x2ddead\\x2dbeefdeadbeef.swap."
  echo "  systemd[1]: Dependency failed for Local Encrypted Volumes / Swap / etc."
  echo

  # STEP 4: Find what swap device/file actually exists
  echo "  Step 4: Identify the intended swap device/file on disk."
  read -p "  lab@rhel-lab377:~$ " cmd4
  echo
  if [[ "$cmd4" != "lsblk -f" && \
        "$cmd4" != "sudo lsblk -f" && \
        "$cmd4" != "sudo blkid" && \
        "$cmd4" != "blkid" && \
        "$cmd4" != "lsblk" && \
        "$cmd4" != "sudo lsblk" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  NAME            FSTYPE  LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINTS"
  echo "  vda"
  echo "  ├─vda1          xfs           8f8f8f8f-1111-2222-3333-aaaaaaaaaaaa      1G    12% /boot"
  echo "  └─vda2          LVM2_member   99999999-aaaa-bbbb-cccc-123456789abc"
  echo "    ├─rl-root     xfs           12121212-3434-5656-7878-bbbbbbbbbbbb     23G    43% /"
  echo "    └─rl-swap     swap          abababab-cdef-1234-5678-cccccccccccc"
  echo

  # STEP 5: Confirm swap signature exists (or not) on the device
  echo "  Step 5: Confirm the swap signature on the expected swap LV."
  read -p "  lab@rhel-lab377:~$ " cmd5
  echo
  if [[ "$cmd5" != "sudo blkid /dev/mapper/rl-swap" && \
        "$cmd5" != "blkid /dev/mapper/rl-swap" && \
        "$cmd5" != "sudo file -s /dev/mapper/rl-swap" && \
        "$cmd5" != "file -s /dev/mapper/rl-swap" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd5" == *"file -s"* ]]; then
    echo "  /dev/mapper/rl-swap: Linux swap file, 4k page size, little endian, version 1"
  else
    echo "  /dev/mapper/rl-swap: UUID=\"abababab-cdef-1234-5678-cccccccccccc\" TYPE=\"swap\""
  fi
  echo

  # STEP 6: Fix /etc/fstab UUID to match the real swap UUID (line change is user input)
  echo "  Step 6: Edit /etc/fstab and correct the swap UUID to the one shown for rl-swap."
  read -p "  lab@rhel-lab377:~$ " cmd6
  echo
  if [[ "$cmd6" != "sudo vim /etc/fstab" && \
        "$cmd6" != "sudo nano /etc/fstab" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (editor opened)"
  echo "  (swap UUID corrected and saved)"
  echo

  # STEP 7: Try activating swap now (without reboot)
  echo "  Step 7: Activate swap now (without reboot) to validate the fix."
  read -p "  lab@rhel-lab377:~$ " cmd7
  echo
  if [[ "$cmd7" != "sudo swapon -a" && \
        "$cmd7" != "swapon -a" && \
        "$cmd7" != "sudo swapon /dev/mapper/rl-swap" && \
        "$cmd7" != "swapon /dev/mapper/rl-swap" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (no output)"
  echo

  # STEP 8: Verify swap is active
  echo "  Step 8: Verify swap is active and shows up in swapon output."
  read -p "  lab@rhel-lab377:~$ " cmd8
  echo
  if [[ "$cmd8" != "swapon --show" && \
        "$cmd8" != "sudo swapon --show" && \
        "$cmd8" != "free -h" && \
        "$cmd8" != "sudo free -h" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd8" == *"swapon --show"* ]]; then
    echo "  NAME                 TYPE  SIZE USED PRIO"
    echo "  /dev/dm-1            part  2.0G   0B   -2"
  else
    echo "               total        used        free      shared  buff/cache   available"
    echo "  Mem:           3.7G        2.9G        220M        120M        620M        420M"
    echo "  Swap:          2.0G          0B        2.0G"
  fi
  echo

  # STEP 9: Confirm /etc/fstab entry is correct now
  echo "  Step 9: Confirm /etc/fstab now references the correct swap UUID."
  read -p "  lab@rhel-lab377:~$ " cmd9
  echo
  if [[ "$cmd9" != "sudo grep -n -E '\\sswap\\s' /etc/fstab" && \
        "$cmd9" != "grep -n -E '\\sswap\\s' /etc/fstab" && \
        "$cmd9" != "sudo grep -n swap /etc/fstab" && \
        "$cmd9" != "grep -n swap /etc/fstab" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  12: UUID=abababab-cdef-1234-5678-cccccccccccc  none  swap  defaults  0 0"
  echo

  # STEP 10: Optional hardening: validate swap priority and overall health
  echo "  Step 10: Show systemd status for the swap unit to confirm it is active."
  read -p "  lab@rhel-lab377:~$ " cmd10
  echo
  if [[ "$cmd10" != "sudo systemctl status dev-mapper-rl\\x2dswap.swap --no-pager" && \
        "$cmd10" != "sudo systemctl status dev-dm\\x2d1.swap --no-pager" && \
        "$cmd10" != "sudo systemctl --type=swap --no-pager" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  ● dev-mapper-rl\\x2dswap.swap - /dev/mapper/rl-swap"
  echo "     Loaded: loaded (/etc/fstab; generated)"
  echo "     Active: active (active) since Fri 2026-01-09 13:02:11 EST; 1min ago"
  echo

  print_success "Great job."
  print_info "You diagnosed why swap wasn't activating:"
  print_info "- confirmed swap was inactive (swapon/free)"
  print_info "- found a bad UUID in /etc/fstab and confirmed systemd swap unit failure"
  print_info "- identified the correct swap device and UUID via lsblk/blkid"
  print_info "- corrected /etc/fstab and validated immediately with swapon -a"
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
