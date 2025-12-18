#!/bin/bash

# Lab 110: Monitor Hardware Events with dmesg and udevadm

# Dynamically locate root directory and source core scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 110: Monitor Hardware Events with dmesg and udevadm"
LAB_ID="lab110"
LAB_XP=18060
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
  center_text "Use dmesg to inspect the kernel ring buffer and udevadm to monitor and query"
  center_text "device events and attributes. You'll practice readable timestamps, filtering,"
  center_text "live monitoring, and triggering/settling udev rules."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Show recent kernel messages
  echo "  Step 1: Show the last 20 kernel messages."
  read -p "  lab@lpic-lab110:~$ " cmd1
  echo
  if [[ "$cmd1" != "dmesg | tail -n 20" && "$cmd1" != "dmesg | tail -20" && "$cmd1" != "dmesg | tail" ]]; then
    print_error "Incorrect. Try: dmesg | tail -n 20"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  [  +0.000000] Linux version 6.6.0 (gcc-13) ..."
  echo "  [  +0.012345] Command line: BOOT_IMAGE=/vmlinuz ..."
  echo "  [  +1.234567] ACPI: Added _OSI(Linux-Lenovo-NV-HDMI-Audio)"
  echo "  [  +2.001122] ata1: SATA link up 6.0 Gbps (SStatus 133 SControl 300)"
  echo "  [  +2.112233] usb 1-1: new full-speed USB device number 2 using xhci_hcd"
  echo "  [  +2.334455] e1000 0000:00:03.0 eth0: Intel(R) PRO/1000 Network Connection"
  echo

  # STEP 2: Human-readable timestamps
  echo "  Step 2: Re-run with human-readable timestamps and show only the last 5 lines."
  read -p "  lab@lpic-lab110:~$ " cmd2
  echo
  if [[ "$cmd2" != "dmesg -T | tail -n 5" && "$cmd2" != "dmesg --ctime | tail -n 5" ]]; then
    print_error "Incorrect. Examples: dmesg -T | tail -n 5   OR   dmesg --ctime | tail -n 5"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  [Tue Aug 19 12:08:02 2025] usb 1-1: new full-speed USB device number 2 using xhci_hcd"
  echo "  [Tue Aug 19 12:08:02 2025] usb 1-1: New USB device found, idVendor=046d, idProduct=c534, bcdDevice=29.01"
  echo "  [Tue Aug 19 12:08:02 2025] usb 1-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0"
  echo "  [Tue Aug 19 12:08:02 2025] input: Logitech USB Receiver as /devices/pci0000:00/.../input/input4"
  echo "  [Tue Aug 19 12:08:03 2025] hid-generic 0003:046D:C534.0003: input,hidraw1: USB HID v1.11 Keyboard"
  echo

  # STEP 3: Filter for USB-related messages
  echo "  Step 3: Filter dmesg for case-insensitive 'usb' and show the last 10 matches."
  read -p "  lab@lpic-lab110:~$ " cmd3
  echo
  if [[ "$cmd3" != "dmesg | grep -i usb | tail -n 10" && "$cmd3" != "dmesg -T | grep -i usb | tail -n 10" ]]; then
    print_error "Incorrect. Example: dmesg -T | grep -i usb | tail -n 10"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  usb 1-1: new full-speed USB device number 2 using xhci_hcd"
  echo "  usb 1-1: New USB device found, idVendor=046d, idProduct=c534, bcdDevice=29.01"
  echo "  usb 1-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0"
  echo "  usb 1-1: Product: USB Receiver"
  echo "  usb 1-1: Manufacturer: Logitech"
  echo

  # STEP 4: Live udev monitoring (kernel + udev)
  echo "  Step 4: Start a live device event monitor for kernel and udev events."
  read -p "  lab@lpic-lab110:~$ " cmd4
  echo
  if [[ "$cmd4" != "udevadm monitor --kernel --udev" && "$cmd4" != "udevadm monitor --udev --kernel" ]]; then
    print_error "Incorrect. Use: udevadm monitor --kernel --udev"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  monitoring kernel uevents"
  echo "  monitoring udev events"
  echo "  (press Ctrl+C to stop monitoring)"
  echo
  echo "  KERNEL[1234.567890] add      /devices/pci0000:00/0000:00:14.0/usb1/1-1 (usb)"
  echo "  UDEV  [1234.568321] add      /devices/pci0000:00/0000:00:14.0/usb1/1-1 (usb)"
  echo "  KERNEL[1234.570001] add      /devices/.../1-1/1-1:1.0/usbhid/usb/hiddev0 (hiddev)"
  echo "  UDEV  [1234.571111] add      /devices/.../1-1/1-1:1.0/usbhid/usb/hiddev0 (hiddev)"
  echo

  # STEP 5: Query device attributes with udevadm info
  echo "  Step 5: Query udev properties for a block device using its node name."
  read -p "  lab@lpic-lab110:~$ " cmd5
  echo
  if [[ "$cmd5" != "udevadm info --query=all --name=/dev/sda" && "$cmd5" != "sudo udevadm info --query=all --name=/dev/sda" ]]; then
    print_error "Incorrect. Use: udevadm info --query=all --name=/dev/sda"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  P: /devices/pci0000:00/.../host0/target0:0:0/0:0:0:0/block/sda"
  echo "  N: sda"
  echo "  S: disk/by-id/ata-Generic_Disk_123456"
  echo "  E: DEVNAME=/dev/sda"
  echo "  E: DEVTYPE=disk"
  echo "  E: ID_BUS=ata"
  echo "  E: ID_MODEL=Generic_Disk"
  echo "  E: ID_SERIAL=Generic_Disk_123456"
  echo

  # STEP 6: Trigger udev for block subsystem, then settle
  echo "  Step 6: Trigger udev events for the 'block' subsystem, then wait for rules to finish."
  read -p "  lab@lpic-lab110:~$ " cmd6
  echo
  if [[ "$cmd6" != "udevadm trigger --subsystem-match=block; udevadm settle" && \
        "$cmd6" != "udevadm trigger --subsystem-match=block ; udevadm settle" && \
        "$cmd6" != "udevadm trigger --type=subsystems --subsystem-match=block; udevadm settle" ]]; then
    print_error "Incorrect. Example: udevadm trigger --subsystem-match=block; udevadm settle"
    read -p "Press Enter to try again..." _
    continue
  fi


  # STEP 7: Inspect sysfs for a USB device's vendor/product IDs
  echo "  Step 7: From sysfs, print a USB device's idVendor and idProduct."
  read -p "  lab@lpic-lab110:~$ " cmd7a
  echo
  if [[ "$cmd7a" != "cat /sys/bus/usb/devices/1-1/idVendor" ]]; then
    print_error "Incorrect. Example: cat /sys/bus/usb/devices/1-1/idVendor"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  046d"
  echo
  read -p "  lab@lpic-lab110:~$ " cmd7b
  echo
  if [[ "$cmd7b" != "cat /sys/bus/usb/devices/1-1/idProduct" ]]; then
    print_error "Incorrect. Example: cat /sys/bus/usb/devices/1-1/idProduct"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  c534"
  echo

  print_success "Well done!"
  print_info "You inspected the kernel ring buffer with readable timestamps, filtered for USB,"
  print_info "monitored live uevents, queried udev attributes, triggered/settled rules, and"
  print_info "looked up vendor/product IDs directly in sysfs."
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
