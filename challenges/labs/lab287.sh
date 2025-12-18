#!/bin/bash

# Lab 287: Prepare /dev/sdb for a Web Server (MBR with fdisk: adapt to single partition)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 287: MBR Partitioning with fdisk (Adapt to Single Partition)"
LAB_ID="lab287"
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
  center_text "Scenario (continued):"
  center_text "After creating two partitions on /dev/sdb, requirements changed."
  center_text "The application team wants a single large partition on the MBR disk."
  center_text "You must remove /dev/sdb2 and recreate /dev/sdb1 to span the entire disk."
  echo
  center_text "Press Enter to begin the lab..."
  read _

  # Assumption: Starting state from Lab 286 (sdb1 ~20G, sdb2 ~20G)

  # Step 1: Reopen fdisk for modification
  draw_lab_ui
  echo "  Step 1: Open the partitioning tool on /dev/sdb to modify the layout."
  read -p "  webadmin@host:~$ " cmd1
  echo
  if [[ "$cmd1" != "fdisk /dev/sdb" && "$cmd1" != "sudo fdisk /dev/sdb" ]]; then
    print_error "Open fdisk on /dev/sdb."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Command (m for help):"
  echo

  # Step 2: Delete partition 2
  echo "  Step 2: Remove the second partition."
  read -p "  fdisk(/dev/sdb)> " cmd2a
  echo
  if [[ "$cmd2a" != "d" ]]; then
    print_error "Enter the delete command."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Partition number (1,2, default 2):"
  read -p "  fdisk(/dev/sdb)> " cmd2b
  echo
  if [[ "$cmd2b" != "2" && "$cmd2b" != "" ]]; then
    print_error "Delete partition 2 (Enter selects default 2)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Partition 2 has been deleted."
  echo "  Command (m for help):"
  echo

  # Step 3: Write changes
  echo "  Step 3: Save changes."
  read -p "  fdisk(/dev/sdb)> " cmd3
  echo
  if [[ "$cmd3" != "w" ]]; then
    print_error "Write the partition table to disk."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  The partition table has been altered!"
  echo

  # Step 4: Re-read and verify only sdb1 remains
  echo "  Step 4: Re-read the table and verify only the first partition exists."
  read -p "  webadmin@host:~$ " cmd4a
  echo
  if [[ "$cmd4a" != "partprobe /dev/sdb" && "$cmd4a" != "sudo partprobe /dev/sdb" ]]; then
    print_error "Use partprobe /dev/sdb."
    read -p "Press Enter to try again..." _
    continue
  fi
  read -p "  webadmin@host:~$ " cmd4b
  echo
  if [[ "$cmd4b" != "lsblk /dev/sdb" && "$cmd4b" != "fdisk -l /dev/sdb" ]]; then
    print_error "Verify with lsblk /dev/sdb or fdisk -l /dev/sdb."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT"
  echo "  sdb      8:16   0  40G  0 disk"
  echo "  └─sdb1   8:17   0  20G  0 part"
  echo

  # Step 5: Inspect start sector of sdb1
  echo "  Step 5: Inspect the start sector of /dev/sdb1 (you'll reuse it)."
  read -p "  webadmin@host:~$ " cmd5
  echo
  if [[ "$cmd5" != "fdisk -l /dev/sdb" ]]; then
    print_error "List details with fdisk -l /dev/sdb."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Device     Start     End         Sectors  Size Type"
  echo "  /dev/sdb1  2048      41945087    41943040  20G Linux"
  echo

  # Step 6: Reopen fdisk for delete+recreate
  echo "  Step 6: Reopen the partitioning tool to resize by delete+recreate."
  read -p "  webadmin@host:~$ " cmd6
  echo
  if [[ "$cmd6" != "fdisk /dev/sdb" && "$cmd6" != "sudo fdisk /dev/sdb" ]]; then
    print_error "Open fdisk on /dev/sdb."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Command (m for help):"
  echo

  # Step 7: Delete sdb1
  echo "  Step 7: Remove the current first partition so you can recreate it larger."
  read -p "  fdisk(/dev/sdb)> " cmd7
  echo
  if [[ "$cmd7" != "d" ]]; then
    print_error "Use the delete command."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Selected partition 1"
  echo "  Partition 1 has been deleted."
  echo "  Command (m for help):"
  echo

  # Step 8: Create new sdb1 starting at sector 2048 to the end
  echo "  Step 8: Create a new primary partition 1 starting at sector 2048 and extending to the end."
  read -p "  fdisk(/dev/sdb)> " cmd8a
  echo
  if [[ "$cmd8a" != "n" ]]; then
    print_error "Start new partition creation."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Partition type"
  echo "     p   primary (0 primary, 0 extended, 4 free)"
  echo "     e   extended"
  echo "  Select (default p):"
  read -p "  fdisk(/dev/sdb)> " cmd8b
  echo
  if [[ "$cmd8b" != "p" && "$cmd8b" != "" ]]; then
    print_error "Choose primary (Enter accepts default)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Partition number (1-4, default 1):"
  read -p "  fdisk(/dev/sdb)> " cmd8c
  echo
  if [[ "$cmd8c" != "1" && "$cmd8c" != "" ]]; then
    print_error "Use partition number 1 (Enter for default)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  First sector (2048-83886079, default 2048):"
  read -p "  fdisk(/dev/sdb)> " cmd8d
  echo
  if [[ "$cmd8d" != "2048" && "$cmd8d" != "" ]]; then
    print_error "Set first sector to 2048 (or press Enter if default is 2048)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-83886079, default 83886079):"
  read -p "  fdisk(/dev/sdb)> " cmd8e
  echo
  if [[ "$cmd8e" != "" && "$cmd8e" != "+100%" && "$cmd8e" != "+100" ]]; then
    print_error "Let it extend to the end (press Enter for default end)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Created a new partition 1 of type 'Linux'."
  echo "  Command (m for help):"
  echo

  # Step 9: Write changes
  echo "  Step 9: Persist the new single-partition layout."
  read -p "  fdisk(/dev/sdb)> " cmd9
  echo
  if [[ "$cmd9" != "w" ]]; then
    print_error "Write changes to disk."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  The partition table has been altered!"
  echo

  # Step 10: Re-read and final verification
  echo "  Step 10: Notify the kernel and verify the final single-partition layout."
  read -p "  webadmin@host:~$ " cmd10a
  echo
  if [[ "$cmd10a" != "partprobe /dev/sdb" && "$cmd10a" != "sudo partprobe /dev/sdb" ]]; then
    print_error "Use partprobe /dev/sdb."
    read -p "Press Enter to try again..." _
    continue
  fi
  read -p "  webadmin@host:~$ " cmd10b
  echo
  if [[ "$cmd10b" != "fdisk -l /dev/sdb" && "$cmd10b" != "lsblk /dev/sdb" && "$cmd10b" != "lsblk -o NAME,SIZE,TYPE /dev/sdb" ]]; then
    print_error "Verify with fdisk -l /dev/sdb or lsblk variants."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Disk /dev/sdb: 40 GiB, 42949672960 bytes, 83886080 sectors"
  echo "  Disklabel type: dos"
  echo "  Device     Boot  Start      End        Sectors  Size Id Type"
  echo "  /dev/sdb1         2048   83886079     83884032   40G 83 Linux"
  echo
  echo "  (Next step outside this lab would be to create a filesystem and mount it for the web app.)"
  echo

  print_success "Nice work! Layout adapted to a single large MBR partition."
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
