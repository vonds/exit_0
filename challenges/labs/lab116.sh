#!/bin/bash

# Lab 116: Identify Mass Storage Types (SATA/SCSI/NVMe/USB)

# Dynamically locate root directory and source core scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 116: Identify Mass Storage Types (SATA/SCSI/NVMe/USB)"
LAB_ID="lab116"
LAB_XP=8180
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
  center_text "Identify disks by type (SATA/SCSI/NVMe/USB), determine rotational vs SSD,"
  center_text "inspect schedulers, and correlate devices with sysfs and udev properties."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: List block devices with transport hints
  echo "  Step 1: Show block devices with transport and model hints."
  echo "          (Hint: lsblk -o NAME,TYPE,ROTA,TRAN,SIZE,MODEL | grep -E '^sd|^nvme|^vd|^sr')"
  read -p "  lab@lpic-lab116:~$ " cmd1
  echo
  if [[ "$cmd1" != "lsblk -o NAME,TYPE,ROTA,TRAN,SIZE,MODEL | grep -E '^sd|^nvme|^vd|^sr'" && \
        "$cmd1" != "lsblk -o NAME,TYPE,ROTA,TRAN,SIZE,MODEL | grep -E \"^sd|^nvme|^vd|^sr\"" ]]; then
    print_error "Incorrect. Example: lsblk -o NAME,TYPE,ROTA,TRAN,SIZE,MODEL | grep -E '^sd|^nvme|^vd|^sr'"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  NAME   TYPE ROTA TRAN   SIZE MODEL"
  echo "  sda    disk    1 sata    40G Generic_Disk"
  echo "  ├─sda1 part    1 sata   512M "
  echo "  └─sda2 part    1 sata  39.5G "
  echo "  nvme0n1 disk   0 nvme   512G NVMe_SSD_512"
  echo "  sr0    rom     1 sata     1G QEMU_DVD-ROM"
  echo

  # STEP 2: Determine if sda is rotational from sysfs
  echo "  Step 2: Check whether sda is rotational via sysfs."
  echo "          (Hint: cat /sys/block/sda/queue/rotational)"
  read -p "  lab@lpic-lab116:~$ " cmd2
  echo
  if [[ "$cmd2" != "cat /sys/block/sda/queue/rotational" ]]; then
    print_error "Incorrect. Use: cat /sys/block/sda/queue/rotational"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  1"
  echo

  # STEP 3: Determine if nvme0n1 is rotational
  echo "  Step 3: Check whether nvme0n1 is rotational."
  echo "          (Hint: cat /sys/block/nvme0n1/queue/rotational)"
  read -p "  lab@lpic-lab116:~$ " cmd3
  echo
  if [[ "$cmd3" != "cat /sys/block/nvme0n1/queue/rotational" ]]; then
    print_error "Incorrect. Use: cat /sys/block/nvme0n1/queue/rotational"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  0"
  echo

  # STEP 4: Identify transport for sda from udev properties
  echo "  Step 4: Verify the transport (ID_BUS/ID_ATA/SCSI) for sda via udev."
  echo "          (Hint: udevadm info --query=property --name=/dev/sda | egrep '^(ID_BUS|ID_ATA|ID_SCSI)')"
  read -p "  lab@lpic-lab116:~$ " cmd4
  echo
  if [[ "$cmd4" != "udevadm info --query=property --name=/dev/sda | egrep '^(ID_BUS|ID_ATA|ID_SCSI)'" && \
        "$cmd4" != "udevadm info --query=property --name=/dev/sda | grep -E '^(ID_BUS|ID_ATA|ID_SCSI)'" ]]; then
    print_error "Incorrect. Example: udevadm info --query=property --name=/dev/sda | egrep '^(ID_BUS|ID_ATA|ID_SCSI)'"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  ID_BUS=ata"
  echo "  ID_ATA=1"
  echo "  ID_SCSI=1"
  echo

  # STEP 5: Read vendor/model for sda from sysfs
  echo "  Step 5: Show vendor and model for sda via sysfs."
  echo "          (Hints: cat /sys/block/sda/device/vendor  &&  cat /sys/block/sda/device/model)"
  read -p "  lab@lpic-lab116:~$ " cmd5a
  echo
  if [[ "$cmd5a" != "cat /sys/block/sda/device/vendor" ]]; then
    print_error "Incorrect. Example: cat /sys/block/sda/device/vendor"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  ATA"
  echo
  read -p "  lab@lpic-lab116:~$ " cmd5b
  echo
  if [[ "$cmd5b" != "cat /sys/block/sda/device/model" ]]; then
    print_error "Incorrect. Example: cat /sys/block/sda/device/model"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Generic_Disk"
  echo

  # STEP 6: Inspect I/O scheduler for sda
  echo "  Step 6: Show the active I/O scheduler for sda."
  echo "          (Hint: cat /sys/block/sda/queue/scheduler)"
  read -p "  lab@lpic-lab116:~$ " cmd6
  echo
  if [[ "$cmd6" != "cat /sys/block/sda/queue/scheduler" ]]; then
    print_error "Incorrect. Use: cat /sys/block/sda/queue/scheduler"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  mq-deadline kyber [bfq] none"
  echo "  (Selected scheduler appears in brackets; your system may differ.)"
  echo

  # STEP 7: Map a partition back to its parent disk via sysfs
  echo "  Step 7: Resolve sda2's parent disk using sysfs."
  echo "          (Hint: readlink -f /sys/class/block/sda2/.. | xargs basename)"
  read -p "  lab@lpic-lab116:~$ " cmd7
  echo
  if [[ "$cmd7" != "readlink -f /sys/class/block/sda2/.. | xargs basename" && \
        "$cmd7" != "basename $(readlink -f /sys/class/block/sda2/..)" ]]; then
    print_error "Incorrect. Example: readlink -f /sys/class/block/sda2/.. | xargs basename"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  sda"
  echo

  # STEP 8: Identify a USB storage device path in sysfs (example 1-1)
  echo "  Step 8: Print a USB device's vendor/product IDs from sysfs."
  echo "          (Hint: cat /sys/bus/usb/devices/1-1/idVendor && cat /sys/bus/usb/devices/1-1/idProduct)"
  read -p "  lab@lpic-lab116:~$ " cmd8a
  echo
  if [[ "$cmd8a" != "cat /sys/bus/usb/devices/1-1/idVendor" ]]; then
    print_error "Incorrect. Example: cat /sys/bus/usb/devices/1-1/idVendor"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  058f"
  echo
  read -p "  lab@lpic-lab116:~$ " cmd8b
  echo
  if [[ "$cmd8b" != "cat /sys/bus/usb/devices/1-1/idProduct" ]]; then
    print_error "Incorrect. Example: cat /sys/bus/usb/devices/1-1/idProduct"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  6387"
  echo

  # STEP 9: Correlate a disk to its PCI/NVMe path
  echo "  Step 9: Resolve the physical device path for nvme0n1 (PCI address)."
  echo "          (Hint: readlink -f /sys/block/nvme0n1/device)"
  read -p "  lab@lpic-lab116:~$ " cmd9
  echo
  if [[ "$cmd9" != "readlink -f /sys/block/nvme0n1/device" ]]; then
    print_error "Incorrect. Use: readlink -f /sys/block/nvme0n1/device"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  /sys/devices/pci0000:00/0000:00:04.0/0000:01:00.0/nvme/nvme0"
  echo

  # STEP 10: Cross-check using lsblk with transport & filesystem
  echo "  Step 10: Show disk/partition, transport, FSTYPE, and mountpoints."
  echo "           (Hint: lsblk -o NAME,TYPE,TRAN,FSTYPE,MOUNTPOINTS)"
  read -p "  lab@lpic-lab116:~$ " cmd10
  echo
  if [[ "$cmd10" != "lsblk -o NAME,TYPE,TRAN,FSTYPE,MOUNTPOINTS" ]]; then
    print_error "Incorrect. Use: lsblk -o NAME,TYPE,TRAN,FSTYPE,MOUNTPOINTS"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  NAME      TYPE TRAN FSTYPE MOUNTPOINTS"
  echo "  sda       disk sata              "
  echo "  ├─sda1    part sata ext4   /boot"
  echo "  └─sda2    part sata ext4   /"
  echo "  nvme0n1   disk nvme              "
  echo "  └─nvme0n1p1 part nvme ext4   /data"
  echo

  print_success "Excellent!"
  print_info "You identified disks by bus/transport, determined rotational vs SSD, inspected I/O schedulers,"
  print_info "mapped partitions to parent disks, read USB vendor/product IDs, and correlated NVMe to PCI path."
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
