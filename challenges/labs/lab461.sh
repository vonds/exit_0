#!/bin/bash

# Lab 461: RHEL Storage Management — LVM Creation and Extension Using fdisk
# Focus: creating LVM-backed storage from raw disks, then extending it with an additional disk.
# Key skills: fdisk (interactive), partition type 8e (Linux LVM), lvm2, pvcreate, pvdisplay,
# vgcreate, vgdisplay, lvcreate, lvdisplay, mkfs.xfs, mount, df -h, vgextend, lvextend, xfs_growfs.
# Disks used in this lab: /dev/nvme1 (initial), /dev/nvme2 (extension)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 461: Create and Extend LVM Storage"
LAB_ID="lab461"
LAB_XP=46100
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
  center_text "Two new 5 GiB NVMe disks have been attached to the system: nvme1 and nvme2."
  center_text "You must create an LVM setup on nvme1, then extend it using nvme2."
  echo
  center_text "Goal: create PV → VG → LV, format, mount, then extend VG, LV, and filesystem."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: List disks with fdisk -l | less
  echo "  Step 1: List all disks using fdisk and paginate the output."
  read -p "  lab@rhel-lab461:~$ " cmd1
  echo
  if [[ "$cmd1" != "sudo fdisk -l | less" && "$cmd1" != "fdisk -l | less" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Disk /dev/nvme1: 5 GiB"
  echo "  Disk /dev/nvme2: 5 GiB"
  echo

  # STEP 2: Open /dev/nvme1 in fdisk
  echo "  Step 2: Open /dev/nvme1 with fdisk."
  read -p "  lab@rhel-lab461:~$ " cmd2
  echo
  if [[ "$cmd2" != "sudo fdisk /dev/nvme1" && "$cmd2" != "fdisk /dev/nvme1" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Command (m for help):"

  # fdisk interactive (nvme1)
  echo "  fdisk: Create a new partition (n)."
  read -p "  Command (m for help): " fd1
  [[ "$fd1" != "n" ]] && { print_error "Expected 'n'."; read -p "Press Enter..." _; continue; }

  echo "  Select (default p):"
  read -p "  " fd2
  [[ -n "$fd2" ]] && { print_error "Press Enter for default."; read -p "Press Enter..." _; continue; }

  echo "  Partition number (1-4, default 1):"
  read -p "  " fd3
  [[ -n "$fd3" ]] && { print_error "Press Enter for default."; read -p "Press Enter..." _; continue; }

  echo "  First sector (2048-..., default 2048):"
  read -p "  " fd4
  [[ -n "$fd4" ]] && { print_error "Press Enter for default."; read -p "Press Enter..." _; continue; }

  echo "  Last sector (..., default ...):"
  read -p "  " fd5
  [[ -n "$fd5" ]] && { print_error "Press Enter for default."; read -p "Press Enter..." _; continue; }

  echo "  Command (m for help):"

  echo "  fdisk: Print partition table (p)."
  read -p "  Command (m for help): " fd6
  [[ "$fd6" != "p" ]] && { print_error "Expected 'p'."; read -p "Press Enter..." _; continue; }

  echo "  Device       Type"
  echo "  /dev/nvme1p1 Linux"
  echo

  echo "  fdisk: List partition types (l)."
  read -p "  Command (m for help): " fd7
  [[ "$fd7" != "l" ]] && { print_error "Expected 'l'."; read -p "Press Enter..." _; continue; }
  echo "  Hex code 8e = Linux LVM"
  echo

  echo "  fdisk: Change partition type (t)."
  read -p "  Command (m for help): " fd8
  [[ "$fd8" != "t" ]] && { print_error "Expected 't'."; read -p "Press Enter..." _; continue; }

  echo "  Enter hex code (type L to list all codes):"
  read -p "  " fd9
  [[ "$fd9" != "8e" ]] && { print_error "Expected '8e'."; read -p "Press Enter..." _; continue; }

  echo "  fdisk: Confirm change (p)."
  read -p "  Command (m for help): " fd10
  [[ "$fd10" != "p" ]] && { print_error "Expected 'p'."; read -p "Press Enter..." _; continue; }

  echo "  /dev/nvme1p1 Linux LVM"
  echo

  echo "  fdisk: Write changes (w)."
  read -p "  Command (m for help): " fd11
  [[ "$fd11" != "w" ]] && { print_error "Expected 'w'."; read -p "Press Enter..." _; continue; }
  echo

  # STEP 3: Install LVM tools
  echo "  Step 3: Install lvm2 package."
  read -p "  lab@rhel-lab461:~$ " cmd3
  echo
  if [[ "$cmd3" != "sudo dnf -y install lvm2" && "$cmd3" != "dnf -y install lvm2" ]]; then
    print_error "Incorrect."
    read -p "Press Enter..." _
    continue
  fi
  echo

  # STEP 4: Create Physical Volume
  echo "  Step 4: Create a physical volume on /dev/nvme1p1."
  read -p "  lab@rhel-lab461:~$ " cmd4
  echo
  if [[ "$cmd4" != "sudo pvcreate /dev/nvme1p1" && "$cmd4" != "pvcreate /dev/nvme1p1" ]]; then
    print_error "Incorrect."
    read -p "Press Enter..." _
    continue
  fi
  echo

  echo "  Step 5: Verify physical volume."
  read -p "  lab@rhel-lab461:~$ " cmd5
  [[ "$cmd5" != "pvdisplay" && "$cmd5" != "sudo pvdisplay" ]] && { print_error "Incorrect."; read -p "Press Enter..." _; continue; }
  echo

  # STEP 6: Create Volume Group
  echo "  Step 6: Create volume group vgdata."
  read -p "  lab@rhel-lab461:~$ " cmd6
  [[ "$cmd6" != "sudo vgcreate vgdata /dev/nvme1p1" && "$cmd6" != "vgcreate vgdata /dev/nvme1p1" ]] && { print_error "Incorrect."; read -p "Press Enter..." _; continue; }
  echo

  echo "  Step 7: Verify volume group."
  read -p "  lab@rhel-lab461:~$ " cmd7
  [[ "$cmd7" != "vgdisplay" && "$cmd7" != "sudo vgdisplay" ]] && { print_error "Incorrect."; read -p "Press Enter..." _; continue; }
  echo

  # STEP 8: Create Logical Volume
  echo "  Step 8: Create a 5100 MB logical volume named lvdata."
  read -p "  lab@rhel-lab461:~$ " cmd8
  [[ "$cmd8" != "sudo lvcreate -L 5100M -n lvdata vgdata" && "$cmd8" != "lvcreate -L 5100M -n lvdata vgdata" ]] && { print_error "Incorrect."; read -p "Press Enter..." _; continue; }
  echo

  echo "  Step 9: Verify logical volume."
  read -p "  lab@rhel-lab461:~$ " cmd9
  [[ "$cmd9" != "lvdisplay" && "$cmd9" != "sudo lvdisplay" ]] && { print_error "Incorrect."; read -p "Press Enter..." _; continue; }
  echo

  # STEP 10: Format and mount
  echo "  Step 10: Format the LV with XFS."
  read -p "  lab@rhel-lab461:~$ " cmd10
  [[ "$cmd10" != "sudo mkfs.xfs /dev/vgdata/lvdata" && "$cmd10" != "mkfs.xfs /dev/vgdata/lvdata" ]] && { print_error "Incorrect."; read -p "Press Enter..." _; continue; }
  echo

  echo "  Step 11: Create mount directory /lvdata."
  read -p "  lab@rhel-lab461:~$ " cmd11
  [[ "$cmd11" != "sudo mkdir /lvdata" && "$cmd11" != "mkdir /lvdata" ]] && { print_error "Incorrect."; read -p "Press Enter..." _; continue; }
  echo

  echo "  Step 12: Mount the logical volume."
  read -p "  lab@rhel-lab461:~$ " cmd12
  [[ "$cmd12" != "sudo mount /dev/vgdata/lvdata /lvdata" && "$cmd12" != "mount /dev/vgdata/lvdata /lvdata" ]] && { print_error "Incorrect."; read -p "Press Enter..." _; continue; }
  echo

  echo "  Step 13: Verify mount."
  read -p "  lab@rhel-lab461:~$ " cmd13
  [[ "$cmd13" != "df -h" && "$cmd13" != "sudo df -h" ]] && { print_error "Incorrect."; read -p "Press Enter..." _; continue; }
  echo

  # STEP 14: Repeat fdisk on nvme2 (summarized but enforced)
  echo "  Step 14: Create LVM partition on /dev/nvme2 (same fdisk steps as before)."
  read -p "  lab@rhel-lab461:~$ " cmd14
  [[ "$cmd14" != "sudo fdisk /dev/nvme2" && "$cmd14" != "fdisk /dev/nvme2" ]] && { print_error "Incorrect."; read -p "Press Enter..." _; continue; }
  echo "  (Partition created, type set to Linux LVM, written to disk)"
  echo

  # STEP 15: Extend VG
  echo "  Step 15: Extend volume group with /dev/nvme2p1."
  read -p "  lab@rhel-lab461:~$ " cmd15
  [[ "$cmd15" != "sudo vgextend vgdata /dev/nvme2p1" && "$cmd15" != "vgextend vgdata /dev/nvme2p1" ]] && { print_error "Incorrect."; read -p "Press Enter..." _; continue; }
  echo

  # STEP 16: Extend LV
  echo "  Step 16: Extend logical volume by 5120 MB."
  read -p "  lab@rhel-lab461:~$ " cmd16
  [[ "$cmd16" != "sudo lvextend -L +5120M /dev/vgdata/lvdata" && "$cmd16" != "lvextend -L +5120M /dev/vgdata/lvdata" ]] && { print_error "Incorrect."; read -p "Press Enter..." _; continue; }
  echo

  # STEP 17: Grow filesystem
  echo "  Step 17: Extend the XFS filesystem."
  read -p "  lab@rhel-lab461:~$ " cmd17
  [[ "$cmd17" != "sudo xfs_growfs /lvdata" && "$cmd17" != "xfs_growfs /lvdata" ]] && { print_error "Incorrect."; read -p "Press Enter..." _; continue; }
  echo

  # STEP 18: Final verification
  echo "  Step 18: Final verification."
  read -p "  lab@rhel-lab461:~$ " cmd18
  [[ "$cmd18" != "df -h" && "$cmd18" != "sudo df -h" ]] && { print_error "Incorrect."; read -p "Press Enter..." _; continue; }
  echo

  print_success "Outstanding work."
  print_info "You successfully:"
  print_info "- created LVM partitions using fdisk with type 8e"
  print_info "- built PV → VG → LV"
  print_info "- formatted and mounted the logical volume"
  print_info "- extended the VG, LV, and filesystem using a second disk"
  print_info "You earned $LAB_XP XP."
  award_xp $LAB_XP

  XP=$(jq '.XP' "$SAVE_JSON")
  LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
  export XP
  export LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've completed this lab $completion_count time(s)."
  echo
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " choice

  [[ "$choice" == "2" ]] && exit 0
done
