#!/bin/bash

# Lab 371: RHEL Storage — Resize a Logical Volume Without Data Loss
# Focus: safely extending a logical volume and filesystem while preserving existing data
# Key skills: lsblk/lvs/vgs, df -h, lvextend, resize2fs or xfs_growfs,
# understanding filesystem constraints, and verification.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 371: Resize a Logical Volume Without Data Loss"
LAB_ID="lab371"
LAB_XP=37100
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
  center_text "A mounted logical volume is running out of space."
  center_text "The filesystem contains data and must not be corrupted or lost."
  echo
  center_text "Goal: extend the logical volume and filesystem safely while preserving data."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Inspect current disk, VG, and LV layout
  echo "  Step 1: Inspect the current block devices, volume groups, and logical volumes."
  read -p "  lab@rhel-lab371:~$ " cmd1
  echo
  if [[ "$cmd1" != "lsblk" && \
        "$cmd1" != "lsblk -f" && \
        "$cmd1" != "lvs" && \
        "$cmd1" != "vgs" && \
        "$cmd1" != "sudo lvs" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  LV        VG       Attr       LSize"
  echo "  lvdata    vgdata   -wi-ao----  5.00g"
  echo
  echo "  VG       #PV #LV #SN Attr   VSize   VFree"
  echo "  vgdata     1   1   0 wz--n- 10.00g  5.00g"
  echo

  # STEP 2: Confirm filesystem type and mount point
  echo "  Step 2: Identify the filesystem type and mount point of the logical volume."
  read -p "  lab@rhel-lab371:~$ " cmd2
  echo
  if [[ "$cmd2" != "df -Th" && \
        "$cmd2" != "findmnt" && \
        "$cmd2" != "lsblk -f" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Filesystem               Type  Size Used Avail Use% Mounted on"
  echo "  /dev/mapper/vgdata-lvdata xfs   5.0G 4.2G  0.8G  85% /mnt/data"
  echo

  # STEP 3: Verify free space exists in the VG
  echo "  Step 3: Verify that the volume group has free space available."
  read -p "  lab@rhel-lab371:~$ " cmd3
  echo
  if [[ "$cmd3" != "vgs" && "$cmd3" != "sudo vgs" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  VG       #PV #LV #SN Attr   VSize   VFree"
  echo "  vgdata     1   1   0 wz--n- 10.00g  5.00g"
  echo

  # STEP 4: Extend the logical volume
  echo "  Step 4: Extend the logical volume by 3G."
  read -p "  lab@rhel-lab371:~$ " cmd4
  echo
  if [[ "$cmd4" != "sudo lvextend -L +3G /dev/vgdata/lvdata" && \
        "$cmd4" != "sudo lvextend -L+3G /dev/vgdata/lvdata" && \
        "$cmd4" != "sudo lvextend -r -L +3G /dev/vgdata/lvdata" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd4" == *"-r"* ]]; then
    echo "  Size of logical volume vgdata/lvdata changed from 5.00 GiB to 8.00 GiB."
    echo "  Logical volume vgdata/lvdata successfully resized."
    echo "  Filesystem resized automatically."
  else
    echo "  Size of logical volume vgdata/lvdata changed from 5.00 GiB to 8.00 GiB."
    echo "  Logical volume vgdata/lvdata successfully resized."
  fi
  echo

  # STEP 5: Grow the filesystem (if not already resized)
  echo "  Step 5: Grow the filesystem to use the new space."
  read -p "  lab@rhel-lab371:~$ " cmd5
  echo
  if [[ "$cmd5" != "sudo xfs_growfs /mnt/data" && \
        "$cmd5" != "sudo resize2fs /dev/vgdata/lvdata" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  data blocks changed from 1310720 to 2097152"
  echo

  # STEP 6: Verify the new size and data integrity
  echo "  Step 6: Verify the logical volume and filesystem size."
  read -p "  lab@rhel-lab371:~$ " cmd6
  echo
  if [[ "$cmd6" != "df -h /mnt/data" && \
        "$cmd6" != "lsblk" && \
        "$cmd6" != "lvs" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Filesystem               Size Used Avail Use% Mounted on"
  echo "  /dev/mapper/vgdata-lvdata 8.0G 4.2G  3.8G  53% /mnt/data"
  echo

  print_success "Great job."
  print_info "You safely resized a logical volume and filesystem without data loss by:"
  print_info "- verifying free space in the volume group"
  print_info "- extending the logical volume"
  print_info "- growing the filesystem while mounted"
  print_info "- validating the final size and data integrity"
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
