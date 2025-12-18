#!/bin/bash

# Lab 286: Prepare /dev/sdb for a Web Server (MBR with fdisk: create initial partitions)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 286: MBR Partitioning with fdisk (Create Initial Partitions)"
LAB_ID="lab286"
LAB_XP=30000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

draw_lab_ui() {
  clear
  center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
  center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
  echo; echo; echo
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
  center_text "You are the system administrator for a mid-sized company."
  center_text "Your team is deploying a new web server to host internal applications."
  center_text "The server has a new secondary disk (/dev/sdb) installed, but before you"
  center_text "can use it for application data, you must set up partitions."
  center_text "The system requires you to use an MBR partition table for compatibility reasons."
  echo
  center_text "Press Enter to begin the lab..."
  read _

  # Step 1: Identify /dev/sdb
  draw_lab_ui
  echo "  Step 1: Identify block devices and verify the presence of the new disk."
  read -p "  lab286@root:~# " cmd1
  echo
  if [[ "$cmd1" != "lsblk -o NAME,SIZE,TYPE,MOUNTPOINT" && "$cmd1" != "lsblk" && "$cmd1" != "lsblk /dev/sdb" ]]; then
    print_error "Try listing block devices (e.g., lsblk). You may include useful columns."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  NAME   SIZE TYPE MOUNTPOINT"
  echo "  sda     80G disk "
  echo "  ├─sda1  512M part /boot"
  echo "  └─sda2 79.5G part /"
  echo "  sdb     40G disk"
  echo

  # Step 2: Confirm /dev/sdb is not mounted
  echo "  Step 2: Confirm the new disk is not mounted anywhere."
  read -p "  lab286@root:~# " cmd2
  echo
  if [[ "$cmd2" != "findmnt /dev/sdb" && "$cmd2" != "lsblk -o NAME,MOUNTPOINT /dev/sdb" && "$cmd2" != "findmnt -rn -S /dev/sdb" ]]; then
    print_error "Use a mount inspection tool (e.g., findmnt /dev/sdb or lsblk -o NAME,MOUNTPOINT /dev/sdb)."
    read -p "Press Enter to try again..." _
    continue
  fi


  # Step 3: Backup current (empty or existing) partition table
  echo "  Step 3: Safeguard by dumping the current partition table layout to your home directory."
  read -p "  lab286@root:~# " cmd3
  echo
  if [[ "$cmd3" != "sfdisk -d /dev/sdb > ~/sdb-backup.sfdisk" && "$cmd3" != "sudo sfdisk -d /dev/sdb > ~/sdb-backup.sfdisk" ]]; then
    print_error "Use sfdisk to dump the table: sfdisk -d /dev/sdb > ~/sdb-backup.sfdisk"
    read -p "Press Enter to try again..." _
    continue
  fi

  # Step 4: Open fdisk
  echo "  Step 4: Open the disk in the appropriate partitioning tool."
  read -p "  lab286@root:~# " cmd4
  echo
  if [[ "$cmd4" != "fdisk /dev/sdb" && "$cmd4" != "sudo fdisk /dev/sdb" ]]; then
    print_error "Open fdisk on /dev/sdb."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Welcome to fdisk (util-linux)."
  echo "  Changes remain in memory until you write them."
  echo "  Command (m for help):"
  echo

  # Step 5: Create a DOS/MBR label
  echo "  Step 5: Inside the tool, initialize an MBR partition table for /dev/sdb."
  read -p "  fdisk(/dev/sdb)> " cmd5
  echo
  if [[ "$cmd5" != "o" ]]; then
    print_error "Initialize a DOS/MBR disklabel (single-letter command)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Created a new DOS disklabel with disk identifier 0x3a7b1cde"
  echo "  Command (m for help):"
  echo

  # Step 6: Create first partition
  echo "  Step 6: Create a new partition."
  read -p "  fdisk(/dev/sdb)> " cmd6
  echo
  if [[ "$cmd6" != "n" ]]; then
    print_error "Start the new-partition flow (single-letter command)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Partition type"
  echo "     p   primary (0 primary, 0 extended, 4 free)"
  echo "     e   extended"
  echo "  Select (default p):"
  echo

  # Step 7: Choose primary
  echo "  Step 7: Choose the partition type."
  read -p "  fdisk(/dev/sdb)> " cmd7
  echo
  if [[ "$cmd7" != "p" && "$cmd7" != "" ]]; then
    print_error "Pick primary (Enter accepts the default)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Partition number (1-4, default 1):"
  echo

  # Step 8: Partition number
  echo "  Step 8: Select the first partition number."
  read -p "  fdisk(/dev/sdb)> " cmd8
  echo
  if [[ "$cmd8" != "1" && "$cmd8" != "" ]]; then
    print_error "Use partition number 1 (Enter for default also works)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  First sector (2048-83886079, default 2048):"
  echo

  # Step 9: Accept default first sector
  echo "  Step 9: Accept the suggested first sector."
  read -p "  fdisk(/dev/sdb)> " cmd9
  echo
  if [[ "$cmd9" != "" ]]; then
    print_error "Press Enter to accept the default first sector."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-83886079, default 83886079):"
  echo

  # Step 10: Size the partition to 20G
  echo "  Step 10: Set the partition size to 20G."
  read -p "  fdisk(/dev/sdb)> " cmd10
  echo
  if [[ "$cmd10" != "+20G" && "$cmd10" != "+20g" ]]; then
    print_error "Specify the size using +20G."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Created a new partition 1 of type 'Linux' and of size 20 GiB."
  echo "  Command (m for help):"
  echo

  # Step 11: Create a second primary using remaining space
  echo "  Step 11: Create a second primary partition using the remaining space."
  read -p "  fdisk(/dev/sdb)> " cmd11a
  echo
  if [[ "$cmd11a" != "n" ]]; then
    print_error "Start a new partition."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Partition type"
  echo "     p   primary (1 primary, 0 extended, 3 free)"
  echo "     e   extended"
  echo "  Select (default p):"
  read -p "  fdisk(/dev/sdb)> " cmd11b
  echo
  if [[ "$cmd11b" != "p" && "$cmd11b" != "" ]]; then
    print_error "Choose primary (Enter accepts default)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Partition number (2-4, default 2):"
  read -p "  fdisk(/dev/sdb)> " cmd11c
  echo
  if [[ "$cmd11c" != "2" && "$cmd11c" != "" ]]; then
    print_error "Use partition number 2 (Enter accepts default)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  First sector (41945088-83886079, default 41945088):"
  read -p "  fdisk(/dev/sdb)> " cmd11d
  echo
  if [[ "$cmd11d" != "" ]]; then
    print_error "Press Enter to accept the suggested first sector."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Last sector, +/-sectors or +/-size{K,M,G,T,P} (41945088-83886079, default 83886079):"
  read -p "  fdisk(/dev/sdb)> " cmd11e
  echo
  if [[ "$cmd11e" != "" && "$cmd11e" != "+100%" && "$cmd11e" != "+100" ]]; then
    print_error "Use remaining space (Enter accepts default to end)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Created a new partition 2 of type 'Linux'."
  echo "  Command (m for help):"
  echo

  # Step 12: Write changes
  echo "  Step 12: Persist the changes to disk."
  read -p "  fdisk(/dev/sdb)> " cmd12
  echo
  if [[ "$cmd12" != "w" ]]; then
    print_error "Write the partition table to disk."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  The partition table has been altered!"
  echo

  # Step 13: Re-read partition table
  echo "  Step 13: Inform the kernel of the updated partition table."
  read -p "  lab286@root:~# " cmd13
  echo
  if [[ "$cmd13" != "partprobe /dev/sdb" && "$cmd13" != "sudo partprobe /dev/sdb" ]]; then
    print_error "Use partprobe on /dev/sdb."
    read -p "Press Enter to try again..." _
    continue
  fi

  # Step 14: Verify layout
  echo "  Step 14: Verify the current partition layout on /dev/sdb."
  read -p "  lab286@root:~# " cmd14
  echo
  if [[ "$cmd14" != "fdisk -l /dev/sdb" && "$cmd14" != "lsblk /dev/sdb" && "$cmd14" != "lsblk -o NAME,SIZE,TYPE /dev/sdb" ]]; then
    print_error "List partitions (fdisk -l /dev/sdb or lsblk variants)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Disk /dev/sdb: 40 GiB, 42949672960 bytes, 83886080 sectors"
  echo "  Disklabel type: dos"
  echo "  Device     Boot  Start      End        Sectors  Size Id Type"
  echo "  /dev/sdb1         2048   41945087     41943040   20G 83 Linux"
  echo "  /dev/sdb2     41945088   83886079     41940992   20G 83 Linux"
  echo
  echo "  (You will adapt this layout in Lab 287 to meet a single-partition requirement.)"
  echo

  print_success "Great job! Initial MBR layout created and verified."
  print_info "You earned $LAB_XP XP for completing this lab."
  award_xp $LAB_XP
  XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON"); export XP; export LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've successfully completed this lab $completion_count time(s)."
  echo
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " post_choice
  [[ "$post_choice" == "2" ]] && exit 0
done
