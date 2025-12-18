#!/bin/bash

# Lab 107: Hardware Inventory Basics (PCI, USB, Block Devices)

# Dynamically locate root directory and source core scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 107: Hardware Inventory Basics"
LAB_ID="lab107"
LAB_XP=17850
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
  center_text "Inventory your system's PCI, USB, and block devices, then map a PCI device"
  center_text "to its kernel driver and verify whether that driver module is loaded."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Enumerate PCI devices (IDs included)
  echo "  Step 1: List PCI devices including vendor:device numeric IDs."
  read -p "  lab@lpic-lab107:~$ " cmd1
  echo
  if [[ "$cmd1" != "lspci -nn" && "$cmd1" != "sudo lspci -nn" ]]; then
    print_error "Incorrect. Try: lspci -nn"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  00:00.0 Host bridge [0600]: Intel Corporation 440FX - 82441FX PMC [8086:1237]"
  echo "  00:01.0 ISA bridge [0601]: Intel Corporation 82371AB/EB/MB PIIX4 ISA [8086:7110]"
  echo "  00:01.1 IDE interface [0101]: Intel Corporation 82371AB/EB/MB PIIX4 IDE [8086:7111]"
  echo "  00:02.0 VGA compatible controller [0300]: Cirrus Logic GD 5446 [1013:00b8]"
  echo "  00:03.0 Ethernet controller [0200]: Intel Corporation 82540EM Gigabit Ethernet [8086:100e]"
  echo

  # STEP 2: Map PCI devices to kernel drivers
  echo "  Step 2: Show which kernel driver is in use for PCI devices."
  read -p "  lab@lpic-lab107:~$ " cmd2
  echo
  if [[ "$cmd2" != "lspci -nnk" && "$cmd2" != "sudo lspci -nnk" ]]; then
    print_error "Incorrect. Use: lspci -nnk"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  00:03.0 Ethernet controller [0200]: Intel Corporation 82540EM Gigabit Ethernet [8086:100e]"
  echo "          Subsystem: Intel Corporation PRO/1000 MT Desktop Adapter"
  echo "          Kernel driver in use: e1000"
  echo "          Kernel modules: e1000"
  echo
  echo "  00:02.0 VGA compatible controller [0300]: Cirrus Logic GD 5446 [1013:00b8]"
  echo "          Kernel driver in use: cirrus"
  echo "          Kernel modules: cirrus"
  echo

  # STEP 3: Enumerate USB devices
  echo "  Step 3: List attached USB devices on the system."
  read -p "  lab@lpic-lab107:~$ " cmd3
  echo
  if [[ "$cmd3" != "lsusb" && "$cmd3" != "sudo lsusb" ]]; then
    print_error "Incorrect. Try: lsusb"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Bus 001 Device 002: ID 8087:0024 Intel Corp. Integrated Rate Matching Hub"
  echo "  Bus 001 Device 003: ID 046d:c534 Logitech, Inc. Unifying Receiver"
  echo "  Bus 002 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub"
  echo

  # STEP 4: Inspect block devices and mount points
  echo "  Step 4: Show block devices with size and mountpoints columns."
  read -p "  lab@lpic-lab107:~$ " cmd4
  echo
  if [[ "$cmd4" != "lsblk -o NAME,MAJ:MIN,RM,SIZE,RO,TYPE,MOUNTPOINTS" && "$cmd4" != "lsblk -o NAME,MAJ:MIN,RM,SIZE,RO,TYPE,MOUNTPOINT" ]]; then
    print_error "Incorrect. Example: lsblk -o NAME,MAJ:MIN,RM,SIZE,RO,TYPE,MOUNTPOINTS"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS"
  echo "  sda      8:0    0    40G  0 disk "
  echo "  ├─sda1   8:1    0   512M  0 part /boot"
  echo "  └─sda2   8:2    0  39.5G  0 part /"
  echo "  sr0     11:0    1  1024M  0 rom  "
  echo

  # STEP 5: Verify a PCI driver's module is loaded
  echo "  Step 5: Verify that the Ethernet driver's kernel module is currently loaded."
  read -p "  lab@lpic-lab107:~$ " cmd5
  echo
  if [[ "$cmd5" != "lsmod | grep -E '^e1000(\\s|$)'" && "$cmd5" != "lsmod | grep e1000" && "$cmd5" != "grep e1000 /proc/modules" ]]; then
    print_error "Incorrect. Example: lsmod | grep e1000"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  e1000               155648  0"
  echo

  print_success "Nice work!"
  print_info "You listed PCI devices with numeric IDs, mapped devices to drivers, enumerated USB,"
  print_info "inspected block devices and mounts, and confirmed a kernel module is loaded."
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
