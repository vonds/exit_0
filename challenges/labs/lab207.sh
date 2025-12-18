#!/bin/bash

# Lab 207: Create LVs in vgbook (Configure Local Storage)
# - lvol1 = 120M
# - lvbook1 = 192M
# Output policy: Only real terminal outputs shown. Silent commands produce no output.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 207: Create LVs (lvol1=120M, lvbook1=192M)"
LAB_ID="lab207"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

VG="vgbook"

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
  center_text "Goal: Create lvol1=120M and lvbook1=192M in VG $VG, then verify with lvs/vgs."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Create lvol1 (lvcreate output)
  draw_lab_ui
  echo "  Step 1: Create logical volume lvol1 with 120M."
  echo "          Expected: lvcreate -L 120M -n lvol1 $VG"
  read -p "  lab@lab207:~$ " s1
  [[ "$s1" != "lvcreate -L 120M -n lvol1 vgbook" ]] && { print_error "Use: lvcreate -L 120M -n lvol1 vgbook"; read -p "Press Enter to try again..." _; continue; }
  echo "  Logical volume \"lvol1\" created."
  echo

  # Step 2: Create lvbook1 (lvcreate output)
  echo "  Step 2: Create logical volume lvbook1 with 192M."
  echo "          Expected: lvcreate -L 192M -n lvbook1 $VG"
  read -p "  lab@lab207:~$ " s2
  [[ "$s2" != "lvcreate -L 192M -n lvbook1 vgbook" ]] && { print_error "Use: lvcreate -L 192M -n lvbook1 vgbook"; read -p "Press Enter to try again..." _; continue; }
  echo "  Logical volume \"lvbook1\" created."
  echo

  # Step 3: Verify with lvs
  echo "  Step 3: Verify logical volumes."
  echo "          Expected: lvs"
  read -p "  lab@lab207:~$ " s3
  [[ "$s3" != "lvs" ]] && { print_error "Use: lvs"; read -p "Press Enter to try again..." _; continue; }
  echo "  LV      VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert"
  echo "  lvol1   vgbook -wi-a----- 120.00m                                                     "
  echo "  lvbook1 vgbook -wi-a----- 192.00m                                                     "
  echo

  # Step 4: Show VG summary
  echo "  Step 4: Show VG summary."
  echo "          Expected: vgs"
  read -p "  lab@lab207:~$ " s4
  [[ "$s4" != "vgs" ]] && { print_error "Use: vgs"; read -p "Press Enter to try again..." _; continue; }
  echo "  VG     #PV #LV #SN Attr   VSize    VFree"
  echo "  vgbook   2   2   0 wz--n- 336.00m  24.00m"
  echo

  # Step 5: Show detailed LV info
  echo "  Step 5: Show detailed LV info."
  echo "          Expected: lvdisplay $VG"
  read -p "  lab@lab207:~$ " s5
  [[ "$s5" != "lvdisplay vgbook" ]] && { print_error "Use: lvdisplay vgbook"; read -p "Press Enter to try again..." _; continue; }
  echo "  --- Logical volume ---"
  echo "  LV Path                /dev/vgbook/lvol1"
  echo "  LV Name                lvol1"
  echo "  VG Name                vgbook"
  echo "  LV Size                120.00 MiB"
  echo "  LV Status              available"
  echo "  # open                 0"
  echo
  echo "  --- Logical volume ---"
  echo "  LV Path                /dev/vgbook/lvbook1"
  echo "  LV Name                lvbook1"
  echo "  VG Name                vgbook"
  echo "  LV Size                192.00 MiB"
  echo "  LV Status              available"
  echo "  # open                 0"
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
