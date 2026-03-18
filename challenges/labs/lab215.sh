#!/bin/bash

# Lab 215: Grow VG/LV and extend an ext4 filesystem online (SIMULATED & SAFE)
# SAFETY: This lab does NOT touch your system. It only validates typed commands and prints realistic canned outputs.
#         No real disks, LVM changes, or filesystems are modified.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 215: Online LV + ext4 Growth"
LAB_ID="lab215"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Scenario (mock):
# - Existing VG: vgdata
# - LVs: /dev/vgdata/lvext4 (ext4, ~300MiB, mounted at /mnt/data_ext4), /dev/vgdata/lvxfs (~500MiB)
# - Goal: Add /dev/sdf to VG, extend lvext4 by +400MiB to ~700MiB, grow ext4 online, verify.

VG="vgdata"
LV_EXT="lvext4"
LV_EXT_PATH="/dev/$VG/$LV_EXT"
MNT_EXT="/mnt/data_ext4"
NEW_PV="/dev/sdf"

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
  center_text "Goal: Extend $VG by adding $NEW_PV, grow $LV_EXT_PATH by +400M, and expand its ext4 filesystem online."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Baseline — show current LV size and filesystem usage (SIMULATED)
  draw_lab_ui
  echo "  Step 1: Check the current size of $LV_EXT_PATH."
  read -p "  lab@lab215:~$ " cmd1a
  [[ "$cmd1a" != "lvs /dev/vgdata/lvext4" ]] && { print_error "Use: lvs /dev/vgdata/lvext4"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "  LV     VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert"
  echo "  lvext4 vgdata -wi-ao---- 300.00m"
  echo
  echo "          Now confirm the mounted filesystem size."
  echo "          Expected: df -hT $MNT_EXT"
  read -p "  lab@lab215:~$ " cmd1b
  [[ "$cmd1b" != "df -hT /mnt/data_ext4" ]] && { print_error "Use: df -hT /mnt/data_ext4"; read -p "Press Enter to try again..." _; continue; }
  echo "Filesystem            Type  Size  Used Avail Use% Mounted on"
  echo "/dev/vgdata/lvext4    ext4  300M  6.0M  294M   2% /mnt/data_ext4"
  echo

  # Step 2: Prepare the new PV (SIMULATED)
  echo "  Step 2: Initialize $NEW_PV as a physical volume."
  read -p "  lab@lab215:~$ " cmd2
  [[ "$cmd2" != "pvcreate /dev/sdf" ]] && { print_error "Use: pvcreate /dev/sdf"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "  Physical volume \"/dev/sdf\" successfully created."
  echo

  # Step 3: Extend the VG (SIMULATED)
  echo "  Step 3: Add the new PV to $VG."
  read -p "  lab@lab215:~$ " cmd3
  [[ "$cmd3" != "vgextend vgdata /dev/sdf" ]] && { print_error "Use: vgextend vgdata /dev/sdf"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "  Volume group \"vgdata\" successfully extended"
  echo

  # Step 4: (Optional) Inspect VG free space (SIMULATED)
  echo "  Step 4: Show VG summary to confirm free space."
  read -p "  lab@lab215:~$ " cmd4
  [[ "$cmd4" != "vgs vgdata" ]] && { print_error "Use: vgs vgdata"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "  VG     #PV #LV #SN Attr   VSize   VFree"
  echo "  vgdata   2   2   0 wz--n-  2.00g  1.20g"
  echo

  # Step 5: Extend the logical volume by +400M (SIMULATED)
  echo "  Step 5: Grow $LV_EXT_PATH by +400M (to ~700M)."
  read -p "  lab@lab215:~$ " cmd5
  [[ "$cmd5" != "lvextend -L +400M /dev/vgdata/lvext4" ]] && { print_error "Use: lvextend -L +400M /dev/vgdata/lvext4"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "  Size of logical volume vgdata/lvext4 changed from 300.00 MiB (75 extents) to 700.00 MiB (175 extents)."
  echo "  Logical volume vgdata/lvext4 successfully resized."
  echo

  # Step 6: Grow the ext4 filesystem online (SIMULATED)
  echo "  Step 6: Resize the ext4 filesystem while mounted."
  read -p "  lab@lab215:~$ " cmd6
  [[ "$cmd6" != "resize2fs /dev/vgdata/lvext4" ]] && { print_error "Use: resize2fs /dev/vgdata/lvext4"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "resize2fs 1.46.5 (30-Dec-2021)"
  echo "Filesystem at /dev/vgdata/lvext4 is mounted on /mnt/data_ext4; on-line resizing required"
  echo "old_desc_blocks = 2, new_desc_blocks = 9"
  echo "The filesystem on /dev/vgdata/lvext4 is now 716800 (4k) blocks long."
  echo

  # Step 7: Verify LV size (SIMULATED)
  echo "  Step 7: Verify the new LV size."
  read -p "  lab@lab215:~$ " cmd7
  [[ "$cmd7" != "lvs /dev/vgdata/lvext4" ]] && { print_error "Use: lvs /dev/vgdata/lvext4"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "  LV     VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert"
  echo "  lvext4 vgdata -wi-ao---- 700.00m"
  echo

  # Step 8: Verify filesystem has grown (SIMULATED)
  echo "  Step 8: Confirm the mounted filesystem reflects the new size."
  read -p "  lab@lab215:~$ " cmd8
  [[ "$cmd8" != "df -hT /mnt/data_ext4" ]] && { print_error "Use: df -hT /mnt/data_ext4"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "Filesystem            Type  Size  Used Avail Use% Mounted on"
  echo "/dev/vgdata/lvext4    ext4  700M  6.5M  694M   1% /mnt/data_ext4"
  echo

  # Step 9: (Bonus) Visualize the block device layout (SIMULATED)
  echo "  Step 9: View device mapping."
  read -p "  lab@lab215:~$ " cmd9
  [[ "$cmd9" != "lsblk" ]] && { print_error "Use: lsblk"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "NAME                MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS"
  echo "sde                   8:64   0    10G  0 disk"
  echo "└─vgdata-lvext4     253:0    0   700M  0 lvm  /mnt/data_ext4"
  echo "  └─vgdata-lvxfs    253:1    0   500M  0 lvm"
  echo "sdf                   8:80   0    10G  0 disk"
  echo

  print_success "Nice work! You extended the LV and the ext4 filesystem online."
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
