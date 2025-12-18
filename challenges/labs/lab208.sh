#!/bin/bash

# Lab 208: Add PV (/dev/sdb2 ≈158MB) to vgbook and grow lvbook1 to 336MB (Configure Local Storage)
# Output policy: Only show real terminal outputs. Silent commands produce no output.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 208: Extend VG and LV"
LAB_ID="lab208"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

DISK_SDB="/dev/sdb"
PART_NEW="/dev/sdb2"
VG="vgbook"
LV="/dev/vgbook/lvbook1"

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
  center_text "Goal: Create /dev/sdb2 (~158MB), pvcreate it, vgextend vgbook, then lvextend lvbook1 -> 336MB."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Create ~158MB sdb2 (silent)
  draw_lab_ui
  echo "  Step 1: Create a ~158MB primary partition as sdb2."
  echo "          Expected: parted -s $DISK_SDB mkpart primary 91MiB 249MiB"
  read -p "  lab@lab208:~$ " s1
  [[ "$s1" != "parted -s /dev/sdb mkpart primary 91MiB 249MiB" ]] && { print_error "Use: parted -s /dev/sdb mkpart primary 91MiB 249MiB"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "          Expected: partprobe $DISK_SDB"
  read -p "  lab@lab208:~$ " s1b
  [[ "$s1b" != "partprobe /dev/sdb" ]] && { print_error "Use: partprobe /dev/sdb"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 2: Verify sdb2 exists
  echo "  Step 2: Verify the new partition."
  echo "          Expected: lsblk $DISK_SDB"
  read -p "  lab@lab208:~$ " s2
  [[ "$s2" != "lsblk /dev/sdb" ]] && { print_error "Use: lsblk /dev/sdb"; read -p "Press Enter to try again..." _; continue; }
  echo "NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT"
  echo "sdb      8:16   0   10G  0 disk"
  echo "├─sdb1   8:17   0   90M  0 part"
  echo "└─sdb2   8:18   0  158M  0 part"
  echo

  # Step 3: pvcreate sdb2
  echo "  Step 3: Initialize the new partition as a PV."
  echo "          Expected: pvcreate $PART_NEW"
  read -p "  lab@lab208:~$ " s3
  [[ "$s3" != "pvcreate /dev/sdb2" ]] && { print_error "Use: pvcreate /dev/sdb2"; read -p "Press Enter to try again..." _; continue; }
  echo "  Physical volume \"/dev/sdb2\" successfully created."
  echo

  # Step 4: vgextend vgbook with sdb2
  echo "  Step 4: Extend VG $VG with /dev/sdb2."
  echo "          Expected: vgextend $VG $PART_NEW"
  read -p "  lab@lab208:~$ " s4
  [[ "$s4" != "vgextend vgbook /dev/sdb2" ]] && { print_error "Use: vgextend vgbook /dev/sdb2"; read -p "Press Enter to try again..." _; continue; }
  echo "  Volume group \"vgbook\" successfully extended"
  echo

  # Step 5: Show PV/VG before LV resize
  echo "  Step 5: Show PVs (note new PV)."
  echo "          Expected: pvs"
  read -p "  lab@lab208:~$ " s5
  [[ "$s5" != "pvs" ]] && { print_error "Use: pvs"; read -p "Press Enter to try again..." _; continue; }
  echo "  PV         VG     Fmt  Attr PSize    PFree"
  echo "  /dev/sdb1  vgbook lvm2 a--   88.00m   8.00m"
  echo "  /dev/sdc   vgbook lvm2 a--  248.00m  16.00m"
  echo "  /dev/sdb2  vgbook lvm2 a--  144.00m 144.00m"
  echo

  echo "  Step 6: Show VG summary."
  echo "          Expected: vgs"
  read -p "  lab@lab208:~$ " s6
  [[ "$s6" != "vgs" ]] && { print_error "Use: vgs"; read -p "Press Enter to try again..." _; continue; }
  echo "  VG     #PV #LV #SN Attr   VSize    VFree"
  echo "  vgbook   3   2   0 wz--n- 480.00m 168.00m"
  echo

  # Step 7: Grow lvbook1 to 336M
  echo "  Step 7: Extend lvbook1 to 336M."
  echo "          Expected: lvextend -L 336M $LV"
  read -p "  lab@lab208:~$ " s7
  [[ "$s7" != "lvextend -L 336M /dev/vgbook/lvbook1" ]] && { print_error "Use: lvextend -L 336M /dev/vgbook/lvbook1"; read -p "Press Enter to try again..." _; continue; }
  echo "  Size of logical volume vgbook/lvbook1 changed from 192.00 MiB (12 extents) to 336.00 MiB (21 extents)."
  echo "  Logical volume vgbook/lvbook1 successfully resized."
  echo

  # Step 8: Verify LV size
  echo "  Step 8: Verify the new LV size."
  echo "          Expected: lvs"
  read -p "  lab@lab208:~$ " s8
  [[ "$s8" != "lvs" ]] && { print_error "Use: lvs"; read -p "Press Enter to try again..." _; continue; }
  echo "  LV      VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert"
  echo "  lvol1   vgbook -wi-a----- 120.00m                                                     "
  echo "  lvbook1 vgbook -wi-a----- 336.00m                                                     "
  echo

  # Step 9: Show updated VG and PVs
  echo "  Step 9: Show updated VG free space."
  echo "          Expected: vgs"
  read -p "  lab@lab208:~$ " s9
  [[ "$s9" != "vgs" ]] && { print_error "Use: vgs"; read -p "Press Enter to try again..." _; continue; }
  echo "  VG     #PV #LV #SN Attr   VSize    VFree"
  echo "  vgbook   3   2   0 wz--n- 480.00m  24.00m"
  echo

  echo "  Step 10: Show PVs after resize."
  echo "           Expected: pvs"
  read -p "  lab@lab208:~$ " s10
  [[ "$s10" != "pvs" ]] && { print_error "Use: pvs"; read -p "Press Enter to try again..." _; continue; }
  echo "  PV         VG     Fmt  Attr PSize    PFree"
  echo "  /dev/sdb1  vgbook lvm2 a--   88.00m   8.00m"
  echo "  /dev/sdc   vgbook lvm2 a--  248.00m  16.00m"
  echo "  /dev/sdb2  vgbook lvm2 a--  144.00m   0"
  echo

  print_success "Nice work!"
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
