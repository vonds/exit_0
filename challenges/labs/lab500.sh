#!/bin/bash

# Lab 500: LVM — Create and Delete Logical Volumes (lvcreate/lvs/lvdisplay/mkfs/mount/lvremove)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 500: Create and Delete Logical Volumes"
LAB_ID="lab500"
LAB_XP=50000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab500:~$ "

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
  center_text "A new volume group already exists for application storage: vg_storage."
  center_text "You must create an LV for the app, format and mount it, verify it,"
  center_text "and then safely remove it as part of a rollback."
  echo
  center_text "Targets:"
  center_text "- VG:   vg_storage  (must exist)"
  center_text "- LV:   lv_data      (create/delete)"
  center_text "- Size: 5G"
  center_text "- Mount: /mnt/data"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  # STEP 1: Verify VG exists
  echo "  Step 1: Verify the volume group vg_storage exists and has free space."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "sudo vgs vg_storage" && "$cmd1" != "vgs vg_storage" ]]; then
    print_error "Incorrect. Use: sudo vgs vg_storage"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  VG         #PV #LV #SN Attr   VSize   VFree"
  echo "  vg_storage   2   0   0 wz--n- 10.00g 10.00g"
  echo

  # STEP 2: Create LV
  echo "  Step 2: Create a 5G logical volume named lv_data in vg_storage."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo lvcreate -L 5G -n lv_data vg_storage" ]]; then
    print_error "Incorrect. Use: sudo lvcreate -L 5G -n lv_data vg_storage"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Logical volume \"lv_data\" created."
  echo

  # STEP 3: Verify LV summary
  echo "  Step 3: Verify the LV exists using lvs."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo lvs" && "$cmd3" != "lvs" ]]; then
    print_error "Incorrect. Use: sudo lvs"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  LV      VG         Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert"
  echo "  lv_data vg_storage -wi-a-----  5.00g"
  echo

  # STEP 4: Detailed LV info
  echo "  Step 4: Display detailed information about the LV path."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo lvdisplay /dev/vg_storage/lv_data" ]]; then
    print_error "Incorrect. Use: sudo lvdisplay /dev/vg_storage/lv_data"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  --- Logical volume ---"
  echo "  LV Path                /dev/vg_storage/lv_data"
  echo "  LV Name                lv_data"
  echo "  VG Name                vg_storage"
  echo "  LV UUID                5sXL-KeWk-bjjQ-9xQp-Yz12-AbCd-EfGhIj"
  echo "  LV Write Access        read/write"
  echo "  LV Creation host, time rhel-lab500, 2026-01-25 22:04:11 -0500"
  echo "  LV Status              available"
  echo "  # open                 0"
  echo "  LV Size                5.00 GiB"
  echo "  Current LE             1280"
  echo "  Segments               1"
  echo "  Allocation             inherit"
  echo "  Read ahead sectors     auto"
  echo "  - currently set to     256"
  echo "  Block device           253:10"
  echo

  # STEP 5: Format the LV
  echo "  Step 5: Format the LV with ext4."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo mkfs.ext4 /dev/vg_storage/lv_data" ]]; then
    print_error "Incorrect. Use: sudo mkfs.ext4 /dev/vg_storage/lv_data"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  mke2fs 1.46.5 (30-Dec-2021)"
  echo "  Creating filesystem with 1310720 4k blocks and 327680 inodes"
  echo "  Filesystem UUID: 9a2b5c1d-2f6b-4e31-9c18-5d1a0b3e9f21"
  echo "  Superblock backups stored on blocks:"
  echo "  32768, 98304, 163840, 229376, 294912, 819200, 884736"
  echo
  echo "  Allocating group tables: done"
  echo "  Writing inode tables: done"
  echo "  Creating journal (16384 blocks): done"
  echo "  Writing superblocks and filesystem accounting information: done"
  echo

  # STEP 6: Create mountpoint
  echo "  Step 6: Create the mount point /mnt/data."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo mkdir /mnt/data" ]]; then
    print_error "Incorrect. Use: sudo mkdir /mnt/data"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (directory created)"
  echo

  # STEP 7: Mount the LV
  echo "  Step 7: Mount the LV at /mnt/data."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo mount /dev/vg_storage/lv_data /mnt/data" ]]; then
    print_error "Incorrect. Use: sudo mount /dev/vg_storage/lv_data /mnt/data"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (mounted)"
  echo

  # STEP 8: Verify mount
  echo "  Step 8: Verify the mount using df -h."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "df -h /mnt/data" && "$cmd8" != "sudo df -h /mnt/data" ]]; then
    print_error "Incorrect. Use: df -h /mnt/data"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Filesystem                         Size  Used Avail Use% Mounted on"
  echo "  /dev/mapper/vg_storage-lv_data     4.9G   24K  4.6G   1% /mnt/data"
  echo

  # STEP 9: Unmount before deletion
  echo "  Step 9: Unmount the LV to prepare for deletion."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo umount /mnt/data" ]]; then
    print_error "Incorrect. Use: sudo umount /mnt/data"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (unmounted)"
  echo

  # STEP 10: Delete LV
  echo "  Step 10: Delete the logical volume lv_data."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "sudo lvremove /dev/vg_storage/lv_data" ]]; then
    print_error "Incorrect. Use: sudo lvremove /dev/vg_storage/lv_data"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Do you really want to remove and DISCARD active logical volume vg_storage/lv_data? [y/n]: y"
  echo "  Logical volume \"lv_data\" successfully removed"
  echo

  # STEP 11: Verify LV removed
  echo "  Step 11: Verify lv_data no longer exists."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "sudo lvs" && "$cmd11" != "lvs" ]]; then
    print_error "Incorrect. Use: sudo lvs"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  LV   VG         Attr       LSize Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert"
  echo "  (no logical volumes found in volume group \"vg_storage\")"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- verified VG availability"
  print_info "- created an LV with lvcreate"
  print_info "- inspected LVs with lvs and lvdisplay"
  print_info "- formatted and mounted the LV"
  print_info "- unmounted and removed the LV safely"
  print_info "You earned $LAB_XP XP."

  award_xp $LAB_XP
  XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
  export XP LEVEL
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
