#!/bin/bash

# Lab 113: Explore sysfs (/sys, /sys/class, /sys/block)

# Dynamically locate root directory and source core scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 113: sysfs Exploration (/sys, /sys/class, /sys/block)"
LAB_ID="lab113"
LAB_XP=8080
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"

[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

draw_lab_ui() {
  clear
  center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
  center_draw_progress_bar "$XP" "$(calculate_xP_to_next_level)" 2>/dev/null || center_draw_progress_bar "$LEVEL" "$XP"
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
  center_text "Walk sysfs to relate devices ↔ drivers and read device attributes."
  center_text "You will explore /sys, /sys/class, /sys/block and cross-check with lsblk."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Survey /sys top-level
  echo "  Step 1: List the first 10 entries at the top of /sys."
  read -p "  lab@lpic-lab113:~$ " cmd1
  echo
  if [[ "$cmd1" != "ls -l /sys | head -n 10" && "$cmd1" != "ls -l /sys | head" && "$cmd1" != "head -n 10 <(ls -l /sys)" ]]; then
    print_error "Incorrect. Try: ls -l /sys | head -n 10"
    read -p "Press Enter to try again..." _
    continue
  fi
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
  echo

  # STEP 2: Survey /sys/class and list network class entries
  echo "  Step 2: List entries in the 'net' class."
  read -p "  lab@lpic-lab113:~$ " cmd2
  echo
  if [[ "$cmd2" != "ls -1 /sys/class/net" && "$cmd2" != "ls /sys/class/net" ]]; then
    print_error "Incorrect. Use: ls -1 /sys/class/net"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  lo"
  echo "  eth0"
  echo

  # STEP 3: Survey block devices via sysfs
  echo "  Step 3: Show the block devices directory listing."
  read -p "  lab@lpic-lab113:~$ " cmd3
  echo
  if [[ "$cmd3" != "ls -l /sys/block" ]]; then
    print_error "Incorrect. Use: ls -l /sys/block"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  total 0"
  echo "  lrwxrwxrwx 1 root root 0 Aug 19 12:00 sda -> ../devices/pci0000:00/.../block/sda"
  echo "  lrwxrwxrwx 1 root root 0 Aug 19 12:00 sr0 -> ../devices/pci0000:00/.../block/sr0"
  echo

  # STEP 4: Read block device size (sectors) from sysfs
  echo "  Step 4: Print the size (in 512-byte sectors) of /sys/block/sda."
  read -p "  lab@lpic-lab113:~$ " cmd4
  echo
  if [[ "$cmd4" != "cat /sys/block/sda/size" ]]; then
    print_error "Incorrect. Use: cat /sys/block/sda/size"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  83886080"
  echo

  # STEP 5: Convert sectors to GiB using awk
  echo "  Step 5: Convert the sector count to GiB (512 bytes per sector)."
  read -p "  lab@lpic-lab113:~$ " cmd5
  echo
  if [[ "$cmd5" != "awk 'BEGIN{b=512} {printf \"%.1f GiB\\n\", ($1*b)/1024/1024/1024}' /sys/block/sda/size" ]]; then
    print_error "Incorrect. Example: awk 'BEGIN{b=512} {printf \"%.1f GiB\\n\", ($1*b)/1024/1024/1024}' /sys/block/sda/size"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  40.0 GiB"
  echo

  # STEP 6: Read vendor/model via the device subdir
  echo "  Step 6: Show the storage device vendor and model for sda."
  read -p "  lab@lpic-lab113:~$ " cmd6a
  echo
  if [[ "$cmd6a" != "cat /sys/block/sda/device/vendor" ]]; then
    print_error "Incorrect. Example: cat /sys/block/sda/device/vendor"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  ATA"
  echo
  read -p "  lab@lpic-lab113:~$ " cmd6b
  echo
  if [[ "$cmd6b" != "cat /sys/block/sda/device/model" ]]; then
    print_error "Incorrect. Example: cat /sys/block/sda/device/model"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Generic_Disk"
  echo

  # STEP 7: Identify the driver bound to sda via sysfs
  echo "  Step 7: Resolve the absolute path of the driver bound to sda's device."
  read -p "  lab@lpic-lab113:~$ " cmd7
  echo
  if [[ "$cmd7" != "readlink -f /sys/block/sda/device/driver" ]]; then
    print_error "Incorrect. Use: readlink -f /sys/block/sda/device/driver"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  /sys/bus/scsi/drivers/sd"
  echo

  # STEP 8: Inspect the uevent file for sda (modalias & properties)
  echo "  Step 8: Print the uevent data for sda."
  read -p "  lab@lpic-lab113:~$ " cmd8
  echo
  if [[ "$cmd8" != "cat /sys/block/sda/uevent" ]]; then
    print_error "Incorrect. Use: cat /sys/block/sda/uevent"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  MAJOR=8"
  echo "  MINOR=0"
  echo "  DEVNAME=sda"
  echo "  DEVTYPE=disk"
  echo

  # STEP 9: Cross-check major:minor with lsblk
  echo "  Step 9: Cross-check sda's major:minor via lsblk."
  read -p "  lab@lpic-lab113:~$ " cmd9
  echo
  if [[ "$cmd9" != "lsblk -o NAME,MAJ:MIN | grep '^sda'" && "$cmd9" != "lsblk -o NAME,MAJ:MIN | grep ^sda" ]]; then
    print_error "Incorrect. Example: lsblk -o NAME,MAJ:MIN | grep '^sda'"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  sda            8:0"
  echo

  # STEP 10: Follow a network iface to its driver via /sys/class/net
  echo "  Step 10: Resolve the driver for eth0 through /sys/class/net."
  read -p "  lab@lpic-lab113:~$ " cmd10
  echo
  if [[ "$cmd10" != "readlink -f /sys/class/net/eth0/device/driver" ]]; then
    print_error "Incorrect. Use: readlink -f /sys/class/net/eth0/device/driver"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  /sys/bus/pci/drivers/e1000"
  echo

  print_success "Excellent!"
  print_info "You explored sysfs top-level, enumerated classes and block devices, read size/vendor/model,"
  print_info "resolved driver bindings via symlinks, inspected uevent attributes, and verified major:minor."
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

  [[ "$choice" == "2" ]] && exit 0
done
