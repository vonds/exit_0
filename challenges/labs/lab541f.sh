#!/bin/bash

# Lab 541F: Configure Local Storage with LVM and Persistent Mounting (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 541F: Configure Local Storage with LVM and Persistent Mounting"
LAB_ID="lab541f"
LAB_XP=54100
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@servera:~$ "

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
  center_text "ServerA needs additional local storage configured with LVM."
  center_text "Use /dev/sdb to create a new logical volume, format it with"
  center_text "ext4, mount it persistently at /mylv, then extend it."
  echo

  center_text "Requirements:"
  center_text "- Disk: /dev/sdb"
  center_text "- Volume group: myvg"
  center_text "- Logical volume: mylv"
  center_text "- Initial size: 500MiB"
  center_text "- Filesystem: ext4"
  center_text "- Mount point: /mylv"
  center_text "- Extend by: 500MiB"
  echo

  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Inspect the available block devices so you can identify /dev/sdb."
  read -p "$PROMPT" cmd1
  echo

  if [[ "$cmd1" != "lsblk" ]]; then
    print_error "Incorrect. Use: lsblk"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS"
  echo "  sda           8:0    0   40G  0 disk"
  echo "  ├─sda1        8:1    0    1G  0 part /boot"
  echo "  └─sda2        8:2    0   39G  0 part"
  echo "    ├─rhel-root 253:0  0   35G  0 lvm  /"
  echo "    └─rhel-swap 253:1  0    4G  0 lvm  [SWAP]"
  echo "  sdb           8:16   0    2G  0 disk"
  echo

  echo "  Step 2: Create a GPT partition table and a single partition on /dev/sdb."
  read -p "$PROMPT" cmd2
  echo

  if [[ "$cmd2" != "sudo parted -s /dev/sdb mklabel gpt mkpart primary 1MiB 100%" ]]; then
    print_error "Incorrect. Use: sudo parted -s /dev/sdb mklabel gpt mkpart primary 1MiB 100%"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 3: Verify that the new partition was created."
  read -p "$PROMPT" cmd3
  echo

  if [[ "$cmd3" != "lsblk" ]]; then
    print_error "Incorrect. Use: lsblk"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS"
  echo "  sda           8:0    0   40G  0 disk"
  echo "  ├─sda1        8:1    0    1G  0 part /boot"
  echo "  └─sda2        8:2    0   39G  0 part"
  echo "    ├─rhel-root 253:0  0   35G  0 lvm  /"
  echo "    └─rhel-swap 253:1  0    4G  0 lvm  [SWAP]"
  echo "  sdb           8:16   0    2G  0 disk"
  echo "  └─sdb1        8:17   0    2G  0 part"
  echo

  echo "  Step 4: Create a physical volume on /dev/sdb1."
  read -p "$PROMPT" cmd4
  echo

  if [[ "$cmd4" != "sudo pvcreate /dev/sdb1" ]]; then
    print_error "Incorrect. Use: sudo pvcreate /dev/sdb1"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  Physical volume \"/dev/sdb1\" successfully created."
  echo

  echo "  Step 5: Create a volume group named myvg."
  read -p "$PROMPT" cmd5
  echo

  if [[ "$cmd5" != "sudo vgcreate myvg /dev/sdb1" ]]; then
    print_error "Incorrect. Use: sudo vgcreate myvg /dev/sdb1"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  Volume group \"myvg\" successfully created"
  echo

  echo "  Step 6: Verify the new volume group."
  read -p "$PROMPT" cmd6
  echo

  if [[ "$cmd6" != "vgs" ]]; then
    print_error "Incorrect. Use: vgs"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  VG   #PV #LV #SN Attr   VSize  VFree"
  echo "  myvg   1   0   0 wz--n- 1.99g 1.99g"
  echo "  rhel   1   2   0 wz--n- 38.99g    0"
  echo

  echo "  Step 7: Create a logical volume named mylv with a size of 500MiB."
  read -p "$PROMPT" cmd7
  echo

  if [[ "$cmd7" != "sudo lvcreate -L 500M -n mylv myvg" ]]; then
    print_error "Incorrect. Use: sudo lvcreate -L 500M -n mylv myvg"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  Logical volume \"mylv\" created."
  echo

  echo "  Step 8: Verify the new logical volume."
  read -p "$PROMPT" cmd8
  echo

  if [[ "$cmd8" != "lvs" ]]; then
    print_error "Incorrect. Use: lvs"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  LV   VG   Attr       LSize"
  echo "  mylv myvg -wi-a----- 500.00m"
  echo "  root rhel -wi-ao----  35.00g"
  echo "  swap rhel -wi-ao----   4.00g"
  echo

  echo "  Step 9: Format /dev/myvg/mylv with the ext4 filesystem."
  read -p "$PROMPT" cmd9
  echo

  if [[ "$cmd9" != "sudo mkfs.ext4 /dev/myvg/mylv" ]]; then
    print_error "Incorrect. Use: sudo mkfs.ext4 /dev/myvg/mylv"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  Creating filesystem with 128000 4k blocks and 128016 inodes"
  echo

  echo "  Step 10: Create the mount point /mylv."
  read -p "$PROMPT" cmd10
  echo

  if [[ "$cmd10" != "sudo mkdir -p /mylv" ]]; then
    print_error "Incorrect. Use: sudo mkdir -p /mylv"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 11: Add a persistent mount entry for /dev/myvg/mylv at /mylv."
  read -p "$PROMPT" cmd11
  echo

  if [[ "$cmd11" != "echo '/dev/myvg/mylv /mylv ext4 defaults 0 0' | sudo tee -a /etc/fstab > /dev/null" ]]; then
    print_error "Incorrect. Use: echo '/dev/myvg/mylv /mylv ext4 defaults 0 0' | sudo tee -a /etc/fstab > /dev/null"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 12: Mount all filesystems from /etc/fstab."
  read -p "$PROMPT" cmd12
  echo

  if [[ "$cmd12" != "sudo mount -a" ]]; then
    print_error "Incorrect. Use: sudo mount -a"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 13: Verify that /mylv is mounted."
  read -p "$PROMPT" cmd13
  echo

  if [[ "$cmd13" != "df -h /mylv" ]]; then
    print_error "Incorrect. Use: df -h /mylv"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  Filesystem            Size  Used Avail Use% Mounted on"
  echo "  /dev/mapper/myvg-mylv 477M   24K  440M   1% /mylv"
  echo

  echo "  Step 14: Extend the logical volume by an additional 500MiB."
  read -p "$PROMPT" cmd14
  echo

  if [[ "$cmd14" != "sudo lvextend -L +500M /dev/myvg/mylv" ]]; then
    print_error "Incorrect. Use: sudo lvextend -L +500M /dev/myvg/mylv"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  Size of logical volume myvg/mylv changed from 500.00 MiB to 1000.00 MiB."
  echo

  echo "  Step 15: Grow the ext4 filesystem to use the new space."
  read -p "$PROMPT" cmd15
  echo

  if [[ "$cmd15" != "sudo resize2fs /dev/myvg/mylv" ]]; then
    print_error "Incorrect. Use: sudo resize2fs /dev/myvg/mylv"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  resize2fs 1.47.0 (5-Feb-2023)"
  echo "  Filesystem at /dev/myvg/mylv is mounted on /mylv; on-line resizing required"
  echo "  The filesystem on /dev/myvg/mylv is now 256000 (4k) blocks long."
  echo

  echo "  Step 16: Verify the logical volume now has approximately 1GiB total space."
  read -p "$PROMPT" cmd16
  echo

  if [[ "$cmd16" != "df -h /mylv" ]]; then
    print_error "Incorrect. Use: df -h /mylv"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  Filesystem            Size  Used Avail Use% Mounted on"
  echo "  /dev/mapper/myvg-mylv 954M   28K  888M   1% /mylv"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- inspected the available block devices"
  print_info "- created a new partition on /dev/sdb"
  print_info "- configured /dev/sdb1 as a physical volume"
  print_info "- created the myvg volume group"
  print_info "- created the mylv logical volume"
  print_info "- formatted the logical volume with ext4"
  print_info "- mounted it persistently at /mylv"
  print_info "- extended the logical volume and resized the filesystem"
  print_info "- verified the final mounted size"
  print_info "You earned $LAB_XP XP."

  award_xp $LAB_XP
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
