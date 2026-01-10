#!/bin/bash

# Lab 378: RHEL Troubleshooting — Add Swap Persistently and Verify Priority
# Focus: creating swap (LV or file), activating it now, making it persistent via /etc/fstab, and verifying priority
# Key skills: lsblk -f, blkid, fallocate/dd, chmod, mkswap, swapon/swapoff, swapon --show, free -h,
# /etc/fstab, mount -a (swap units), systemctl --type=swap, and safe verification.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 378: Add Swap Persistently and Verify Priority"
LAB_ID="lab378"
LAB_XP=37800
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
  center_text "A node was built without swap. Under memory pressure it becomes unstable."
  center_text "You're asked to add swap safely, make it persistent, and set a priority."
  center_text "Policy: create a swap file at /swapfile378 (1G) and set its priority to 10."
  echo
  center_text "Goal: create swap, activate it, persist it in /etc/fstab, and verify priority."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Confirm current swap state
  echo "  Step 1: Confirm there is currently no active swap."
  read -p "  lab@rhel-lab378:~$ " cmd1
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
    echo "  No active swap."
  else
    echo "               total        used        free      shared  buff/cache   available"
    echo "  Mem:           3.7G        1.1G        2.0G        120M        600M        2.3G"
    echo "  Swap:            0B          0B          0B"
  fi
  echo

  # STEP 2: Create the swap file
  echo "  Step 2: Create a 1G swap file at /swapfile378."
  read -p "  lab@rhel-lab378:~$ " cmd2
  echo
  if [[ "$cmd2" != "sudo fallocate -l 1G /swapfile378" && \
        "$cmd2" != "sudo dd if=/dev/zero of=/swapfile378 bs=1M count=1024 status=progress" && \
        "$cmd2" != "sudo dd if=/dev/zero of=/swapfile378 bs=1048576 count=1024 status=progress" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 3: Lock down permissions (required for swapfile on modern distros)
  echo "  Step 3: Restrict permissions on the swap file."
  read -p "  lab@rhel-lab378:~$ " cmd3
  echo
  if [[ "$cmd3" != "sudo chmod 600 /swapfile378" && \
        "$cmd3" != "chmod 600 /swapfile378" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 4: Initialize swap area
  echo "  Step 4: Initialize the file as swap."
  read -p "  lab@rhel-lab378:~$ " cmd4
  echo
  if [[ "$cmd4" != "sudo mkswap /swapfile378" && \
        "$cmd4" != "mkswap /swapfile378" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Setting up swapspace version 1, size = 1 GiB (1073737728 bytes)"
  echo "  no label, UUID=cdcdcdcd-1111-2222-3333-eeeeeeeeeeee"
  echo

  # STEP 5: Activate swap now
  echo "  Step 5: Activate the swap file now."
  read -p "  lab@rhel-lab378:~$ " cmd5
  echo
  if [[ "$cmd5" != "sudo swapon /swapfile378" && \
        "$cmd5" != "swapon /swapfile378" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 6: Verify active swap shows up
  echo "  Step 6: Verify the swap file is active."
  read -p "  lab@rhel-lab378:~$ " cmd6
  echo
  if [[ "$cmd6" != "swapon --show" && \
        "$cmd6" != "sudo swapon --show" && \
        "$cmd6" != "free -h" && \
        "$cmd6" != "sudo free -h" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd6" == *"swapon --show"* ]]; then
    echo "  NAME          TYPE  SIZE USED PRIO"
    echo "  /swapfile378  file 1024M   0B   -2"
  else
    echo "               total        used        free      shared  buff/cache   available"
    echo "  Mem:           3.7G        1.1G        2.0G        120M        600M        2.3G"
    echo "  Swap:          1.0G          0B        1.0G"
  fi
  echo

  # STEP 7: Add persistent entry with priority=10
  echo "  Step 7: Add /swapfile378 to /etc/fstab with a swap priority of 10 (pri=10)."
  read -p "  lab@rhel-lab378:~$ " cmd7
  echo
  if [[ "$cmd7" != "sudo vim /etc/fstab" && \
        "$cmd7" != "sudo nano /etc/fstab" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (editor opened)"
  echo "  (added line and saved)"
  echo

  # STEP 8: Validate fstab by cycling swap off/on safely
  echo "  Step 8: Validate persistence by cycling swap off and back on using fstab."
  read -p "  lab@rhel-lab378:~$ " cmd8
  echo
  if [[ "$cmd8" != "sudo swapoff /swapfile378" && \
        "$cmd8" != "swapoff /swapfile378" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo
  echo "  Step 9: Re-activate swap entries from /etc/fstab."
  read -p "  lab@rhel-lab378:~$ " cmd9
  echo
  if [[ "$cmd9" != "sudo swapon -a" && \
        "$cmd9" != "swapon -a" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 9: Verify priority is applied
  echo "  Step 10: Verify swap is active AND priority is set to 10."
  read -p "  lab@rhel-lab378:~$ " cmd10
  echo
  if [[ "$cmd10" != "swapon --show --output=NAME,TYPE,SIZE,USED,PRIO" && \
        "$cmd10" != "swapon --show" && \
        "$cmd10" != "sudo swapon --show" && \
        "$cmd10" != "cat /proc/swaps" && \
        "$cmd10" != "sudo cat /proc/swaps" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd10" == *"/proc/swaps"* ]]; then
    echo "  Filename        Type      Size   Used Priority"
    echo "  /swapfile378    file      1048572 0    10"
  else
    echo "  NAME          TYPE  SIZE USED PRIO"
    echo "  /swapfile378  file 1024M   0B   10"
  fi
  echo

  print_success "Great job."
  print_info "You added swap safely and made it persistent:"
  print_info "- created a 1G swap file with correct permissions"
  print_info "- initialized it with mkswap and activated it with swapon"
  print_info "- added an /etc/fstab entry with pri=10 and validated with swapon -a"
  print_info "- verified priority via swapon --show (or /proc/swaps)"
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
