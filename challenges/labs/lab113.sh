#!/bin/bash

# Lab 113: sysfs Exploration — relate devices ↔ drivers and read attributes from /sys
# RHCSA focus: reading hardware/device metadata from sysfs, resolving driver bindings via symlinks,
# verifying major:minor mappings, and cross-checking with standard tools (lsblk).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 113"
LAB_ID="lab113"
LAB_XP=11300
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

PROMPT="student@lab113:~$ > "

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "Explore sysfs (/sys) to relate devices ↔ drivers and read device attributes."
  center_text "Interactive: walk /sys, /sys/class, and /sys/block and cross-check with lsblk."
  echo
  center_text "Press Enter to begin."
  read _
  draw_lab_ui

  # STEP 1
  echo "  Step 1: List the first 10 entries at the top of /sys."
  read -p "  $PROMPT" cmd1
  if [[ "$cmd1" != "ls -l /sys | head -n 10" && "$cmd1" != "ls -l /sys | head" ]]; then
    print_error "Incorrect. Use: ls -l /sys | head -n 10"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo
  echo "  total 0"
  echo "  dr-xr-xr-x  10 root root 0 Aug 19 12:00 block"
  echo "  dr-xr-xr-x  59 root root 0 Aug 19 12:00 bus"
  echo "  dr-xr-xr-x  52 root root 0 Aug 19 12:00 class"
  echo "  dr-xr-xr-x   4 root root 0 Aug 19 12:00 dev"
  echo "  dr-xr-xr-x  10 root root 0 Aug 19 12:00 devices"
  echo "  dr-xr-xr-x   5 root root 0 Aug 19 12:00 firmware"
  echo "  dr-xr-xr-x   3 root root 0 Aug 19 12:00 fs"
  echo "  dr-xr-xr-x   2 root root 0 Aug 19 12:00 kernel"
  echo "  dr-xr-xr-x  17 root root 0 Aug 19 12:00 module"

  # STEP 2
  echo
  echo "  Step 2: List entries in the network class under /sys/class/net."
  read -p "  $PROMPT" cmd2
  if [[ "$cmd2" != "ls -1 /sys/class/net" && "$cmd2" != "ls /sys/class/net" ]]; then
    print_error "Incorrect. Use: ls -1 /sys/class/net"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo
  echo "  eth0"
  echo "  lo"

  # STEP 3
  echo
  echo "  Step 3: List block devices exposed by sysfs."
  read -p "  $PROMPT" cmd3
  if [[ "$cmd3" != "ls -l /sys/block" ]]; then
    print_error "Incorrect. Use: ls -l /sys/block"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo
  echo "  total 0"
  echo "  lrwxrwxrwx 1 root root 0 Aug 19 12:00 sda -> ../devices/pci0000:00/.../block/sda"
  echo "  lrwxrwxrwx 1 root root 0 Aug 19 12:00 sr0 -> ../devices/pci0000:00/.../block/sr0"

  # STEP 4
  echo
  echo "  Step 4: Print the size (in 512-byte sectors) of /sys/block/sda."
  read -p "  $PROMPT" cmd4
  if [[ "$cmd4" != "cat /sys/block/sda/size" ]]; then
    print_error "Incorrect. Use: cat /sys/block/sda/size"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo
  echo "  83886080"

  # STEP 5
  echo
  echo "  Step 5: Show the storage device vendor and model for sda."
  read -p "  $PROMPT" cmd5a
  if [[ "$cmd5a" != "cat /sys/block/sda/device/vendor" ]]; then
    print_error "Incorrect. Use: cat /sys/block/sda/device/vendor"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo
  echo "  ATA"
  echo
  read -p "  $PROMPT" cmd5b
  if [[ "$cmd5b" != "cat /sys/block/sda/device/model" ]]; then
    print_error "Incorrect. Use: cat /sys/block/sda/device/model"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo
  echo "  Generic_Disk"

  # STEP 6
  echo
  echo "  Step 6: Resolve the absolute path of the driver bound to sda's device."
  read -p "  $PROMPT" cmd6
  if [[ "$cmd6" != "readlink -f /sys/block/sda/device/driver" ]]; then
    print_error "Incorrect. Use: readlink -f /sys/block/sda/device/driver"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo
  echo "  /sys/bus/scsi/drivers/sd"

  # STEP 7
  echo
  echo "  Step 7: Print uevent properties for sda."
  read -p "  $PROMPT" cmd7
  if [[ "$cmd7" != "cat /sys/block/sda/uevent" ]]; then
    print_error "Incorrect. Use: cat /sys/block/sda/uevent"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo
  echo "  MAJOR=8"
  echo "  MINOR=0"
  echo "  DEVNAME=sda"
  echo "  DEVTYPE=disk"

  # STEP 8
  echo
  echo "  Step 8: Cross-check sda's major:minor using lsblk."
  read -p "  $PROMPT" cmd8
  if [[ "$cmd8" != "lsblk -o NAME,MAJ:MIN | grep '^sda'" && "$cmd8" != "lsblk -o NAME,MAJ:MIN | grep ^sda" ]]; then
    print_error "Incorrect. Use: lsblk -o NAME,MAJ:MIN | grep '^sda'"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo
  echo "  sda  8:0"

  # STEP 9
  echo
  echo "  Step 9: Resolve the driver bound to eth0 via sysfs."
  read -p "  $PROMPT" cmd9
  if [[ "$cmd9" != "readlink -f /sys/class/net/eth0/device/driver" ]]; then
    print_error "Incorrect. Use: readlink -f /sys/class/net/eth0/device/driver"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo
  echo "  /sys/bus/pci/drivers/e1000"

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
