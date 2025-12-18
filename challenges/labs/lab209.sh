#!/bin/bash

# Lab 209: Rename LV, resize, then remove LVs (Configure Local Storage)
# - Rename lvol1 -> lvbook2
# - Reduce lvbook2 to 50M, then grow by 32M
# - Remove lvbook2 and lvbook1
# Output policy: Only real command outputs. Silent commands produce no output.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 209: Rename, Resize, Remove LVs"
LAB_ID="lab209"
LAB_XP=25000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

VG="vgbook"
LV1="/dev/vgbook/lvol1"
LVNEW="/dev/vgbook/lvbook2"
LVBOOK1="/dev/vgbook/lvbook1"

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
  center_text "Goal: Rename lvol1 → lvbook2, shrink to 50M, grow by 32M, then remove lvbook2 and lvbook1."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Rename LV
  draw_lab_ui
  echo "  Step 1: Rename lvol1 to lvbook2."
  echo "          Expected: lvrename $VG lvol1 lvbook2"
  read -p "  lab@lab209:~$ " s1
  [[ "$s1" != "lvrename vgbook lvol1 lvbook2" ]] && { print_error "Use: lvrename vgbook lvol1 lvbook2"; read -p "Press Enter to try again..." _; continue; }
  echo "  Renamed \"lvol1\" to \"lvbook2\" in volume group \"vgbook\"."
  echo

  # Step 2: Reduce LV size
  echo "  Step 2: Reduce lvbook2 to 50M."
  echo "          Expected: lvreduce -L 50M $LVNEW"
  read -p "  lab@lab209:~$ " s2
  [[ "$s2" != "lvreduce -L 50M /dev/vgbook/lvbook2" ]] && { print_error "Use: lvreduce -L 50M /dev/vgbook/lvbook2"; read -p "Press Enter to try again..." _; continue; }
  echo "  WARNING: Reducing active logical volume to 50.00 MiB."
  echo "  THIS MAY DESTROY YOUR DATA (filesystem etc.)"
  echo "  Logical volume vgbook/lvbook2 successfully resized."
  echo

  # Step 3: Extend by 32M
  echo "  Step 3: Extend lvbook2 by 32M."
  echo "          Expected: lvresize -L +32M $LVNEW"
  read -p "  lab@lab209:~$ " s3
  [[ "$s3" != "lvresize -L +32M /dev/vgbook/lvbook2" ]] && { print_error "Use: lvresize -L +32M /dev/vgbook/lvbook2"; read -p "Press Enter to try again..." _; continue; }
  echo "  Size of logical volume vgbook/lvbook2 changed from 50.00 MiB to 82.00 MiB."
  echo "  Logical volume vgbook/lvbook2 successfully resized."
  echo

  # Step 4: Verify with lvs
  echo "  Step 4: Verify logical volumes."
  echo "          Expected: lvs"
  read -p "  lab@lab209:~$ " s4
  [[ "$s4" != "lvs" ]] && { print_error "Use: lvs"; read -p "Press Enter to try again..." _; continue; }
  echo "  LV      VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert"
  echo "  lvbook1 vgbook -wi-a----- 336.00m                                                     "
  echo "  lvbook2 vgbook -wi-a-----  82.00m                                                     "
  echo

  # Step 5: Remove lvbook2
  echo "  Step 5: Remove lvbook2."
  echo "          Expected: lvremove -y $LVNEW"
  read -p "  lab@lab209:~$ " s5
  [[ "$s5" != "lvremove -y /dev/vgbook/lvbook2" ]] && { print_error "Use: lvremove -y /dev/vgbook/lvbook2"; read -p "Press Enter to try again..." _; continue; }
  echo "  Logical volume \"lvbook2\" successfully removed"
  echo

  # Step 6: Remove lvbook1
  echo "  Step 6: Remove lvbook1."
  echo "          Expected: lvremove -y $LVBOOK1"
  read -p "  lab@lab209:~$ " s6
  [[ "$s6" != "lvremove -y /dev/vgbook/lvbook1" ]] && { print_error "Use: lvremove -y /dev/vgbook/lvbook1"; read -p "Press Enter to try again..." _; continue; }
  echo "  Logical volume \"lvbook1\" successfully removed"
  echo

  # Step 7: Verify VG and PVs are free
  echo "  Step 7: Show VG summary."
  echo "          Expected: vgs"
  read -p "  lab@lab209:~$ " s7
  [[ "$s7" != "vgs" ]] && { print_error "Use: vgs"; read -p "Press Enter to try again..." _; continue; }
  echo "  VG     #PV #LV #SN Attr   VSize    VFree"
  echo "  vgbook   3   0   0 wz--n- 480.00m 480.00m"
  echo

  echo "  Step 8: Show PVs."
  echo "          Expected: pvs"
  read -p "  lab@lab209:~$ " s8
  [[ "$s8" != "pvs" ]] && { print_error "Use: pvs"; read -p "Press Enter to try again..." _; continue; }
  echo "  PV         VG     Fmt  Attr PSize    PFree"
  echo "  /dev/sdb1  vgbook lvm2 a--   88.00m  88.00m"
  echo "  /dev/sdb2  vgbook lvm2 a--  144.00m 144.00m"
  echo "  /dev/sdc   vgbook lvm2 a--  248.00m 248.00m"
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
