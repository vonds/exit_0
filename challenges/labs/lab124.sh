#!/bin/bash

# Lab 124: RHEL Storage Ops — Create a GPT Partition Table, Create a Partition, Verify, Delete the Partition
# Focus: initializing a disk with a GPT label, creating a partition, verifying via multiple sources,
# then removing the partition and re-verifying.
# Key skills: lsblk, parted (print/mklabel/mkpart/rm), /proc/partitions verification, and safe workflow.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 124: Create and Delete GPT Partitions with parted"
LAB_ID="lab124"
LAB_XP=31500
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
  center_text "A new 2G disk was attached to a RHEL VM for a temporary data staging task."
  center_text "Before handing the VM to an automation pipeline, you need to initialize the disk with GPT,"
  center_text "create a small partition to validate the workflow, verify the kernel sees it,"
  center_text "then remove the partition to return the disk to a clean state."
  echo
  center_text "Notes:"
  center_text "- Assume this disk exists and is unused: /dev/sdb"
  center_text "- Use sudo where required."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Confirm the disk exists and has no mountpoints
  echo "  Step 1: Confirm /dev/sdb is present and not mounted."
  read -p "  lab@rhel-lab124:~$ " cmd1
  echo
  if [[ "$cmd1" != "lsblk" && \
        "$cmd1" != "lsblk -f" && \
        "$cmd1" != "lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  NAME   MAJ:MIN RM SIZE RO TYPE FSTYPE MOUNTPOINTS"
  echo "  sda      8:0    0  20G  0 disk"
  echo "  └─sda1   8:1    0  20G  0 part xfs    /"
  echo "  sdb      8:16   0   2G  0 disk"
  echo

  # STEP 2: View current partition info (expect an error / unknown label)
  echo "  Step 2: View current partition table on /dev/sdb."
  read -p "  lab@rhel-lab124:~$ " cmd2
  echo
  if [[ "$cmd2" != "sudo parted /dev/sdb print" && \
        "$cmd2" != "parted /dev/sdb print" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Error: /dev/sdb: unrecognised disk label"
  echo "  Model: Virtio Block Device (virtblk)"
  echo "  Disk /dev/sdb: 2147MB"
  echo "  Sector size (logical/physical): 512B/512B"
  echo "  Partition Table: unknown"
  echo "  Disk Flags:"
  echo

  # STEP 3: Apply GPT disk label
  echo "  Step 3: Create a GPT partition table on /dev/sdb."
  read -p "  lab@rhel-lab124:~$ " cmd3
  echo
  if [[ "$cmd3" != "sudo parted /dev/sdb mklabel gpt" && \
        "$cmd3" != "parted /dev/sdb mklabel gpt" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Information: You may need to update /etc/fstab."
  echo

  # STEP 4: Confirm the GPT label with print
  echo "  Step 4: Confirm GPT is applied."
  read -p "  lab@rhel-lab124:~$ " cmd4
  echo
  if [[ "$cmd4" != "sudo parted /dev/sdb print" && \
        "$cmd4" != "parted /dev/sdb print" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Model: Virtio Block Device (virtblk)"
  echo "  Disk /dev/sdb: 2147MB"
  echo "  Sector size (logical/physical): 512B/512B"
  echo "  Partition Table: gpt"
  echo "  Disk Flags:"
  echo
  echo "  Number  Start  End  Size  File system  Name  Flags"
  echo

  # STEP 5: Create a 100MB primary partition starting at 1MiB
  echo "  Step 5: Create a 100MiB partition starting at 1MiB."
  read -p "  lab@rhel-lab124:~$ " cmd5
  echo
  if [[ "$cmd5" != "sudo parted /dev/sdb mkpart primary 1MiB 101MiB" && \
        "$cmd5" != "parted /dev/sdb mkpart primary 1MiB 101MiB" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Information: You may need to update /etc/fstab."
  echo

  # STEP 6: Verify the new partition in parted
  echo "  Step 6: Verify the new partition exists."
  read -p "  lab@rhel-lab124:~$ " cmd6
  echo
  if [[ "$cmd6" != "sudo parted /dev/sdb print" && \
        "$cmd6" != "parted /dev/sdb print" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Model: Virtio Block Device (virtblk)"
  echo "  Disk /dev/sdb: 2147MB"
  echo "  Sector size (logical/physical): 512B/512B"
  echo "  Partition Table: gpt"
  echo "  Disk Flags:"
  echo
  echo "  Number  Start   End     Size    File system  Name     Flags"
  echo "   1      1049kB  106MB   105MB                primary"
  echo

  # STEP 7: Confirm kernel device node exists with lsblk
  echo "  Step 7: Confirm /dev/sdb1 exists."
  read -p "  lab@rhel-lab124:~$ " cmd7
  echo
  if [[ "$cmd7" != "lsblk" && \
        "$cmd7" != "lsblk -o NAME,SIZE,TYPE,MOUNTPOINTS" && \
        "$cmd7" != "lsblk -f" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINTS"
  echo "  sda      8:0    0  20G  0 disk"
  echo "  └─sda1   8:1    0  20G  0 part /"
  echo "  sdb      8:16   0   2G  0 disk"
  echo "  └─sdb1   8:17   0 100M  0 part"
  echo

  # STEP 8: Confirm /proc/partitions reflects the new partition
  echo "  Step 8: Confirm /proc/partitions shows sdb and sdb1."
  read -p "  lab@rhel-lab124:~$ " cmd8
  echo
  if [[ "$cmd8" != "cat /proc/partitions | tail" && \
        "$cmd8" != "tail /proc/partitions" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  major minor  #blocks  name"
  echo "    8       0   20971520 sda"
  echo "    8       1   20970496 sda1"
  echo "    8      16    2097152 sdb"
  echo "    8      17     102400 sdb1"
  echo

  # STEP 9: Remove partition 1
  echo "  Step 9: Remove partition 1 from /dev/sdb."
  read -p "  lab@rhel-lab124:~$ " cmd9
  echo
  if [[ "$cmd9" != "sudo parted /dev/sdb rm 1" && \
        "$cmd9" != "parted /dev/sdb rm 1" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Information: You may need to update /etc/fstab."
  echo

  # STEP 10: Verify deletion via parted, /proc/partitions, and lsblk
  echo "  Step 10: Confirm partition 1 is gone."
  read -p "  lab@rhel-lab124:~$ " cmd10
  echo
  if [[ "$cmd10" != "sudo parted /dev/sdb print" && \
        "$cmd10" != "parted /dev/sdb print" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Model: Virtio Block Device (virtblk)"
  echo "  Disk /dev/sdb: 2147MB"
  echo "  Sector size (logical/physical): 512B/512B"
  echo "  Partition Table: gpt"
  echo "  Disk Flags:"
  echo
  echo "  Number  Start  End  Size  File system  Name  Flags"
  echo

  echo "  Step 11: Confirm /proc/partitions no longer lists sdb1."
  read -p "  lab@rhel-lab124:~$ " cmd11
  echo
  if [[ "$cmd11" != "cat /proc/partitions | tail" && \
        "$cmd11" != "tail /proc/partitions" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  major minor  #blocks  name"
  echo "    8       0   20971520 sda"
  echo "    8       1   20970496 sda1"
  echo "    8      16    2097152 sdb"
  echo

  echo "  Step 12: Verify that sdb1 is gone."
  read -p "  lab@rhel-lab124:~$ " cmd12
  echo
  if [[ "$cmd12" != "lsblk" && \
        "$cmd12" != "lsblk -o NAME,SIZE,TYPE,MOUNTPOINTS" && \
        "$cmd12" != "lsblk -f" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINTS"
  echo "  sda      8:0    0  20G  0 disk"
  echo "  └─sda1   8:1    0  20G  0 part /"
  echo "  sdb      8:16   0   2G  0 disk"
  echo

  print_success "Great job."
  print_info "You followed a real ops workflow for GPT partitioning:"
  print_info "- confirmed the disk state and detected an unknown/unlabeled disk"
  print_info "- applied a GPT label once (mklabel gpt) and verified it"
  print_info "- created a partition with explicit MiB boundaries, then verified with parted/lsblk/proc"
  print_info "- removed the partition and verified the system state is clean again"
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
