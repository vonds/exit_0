#!/bin/bash

# Lab 206: LVM — PVs on sdb1 (≈90MB) and sdc (≈250MB), VG vgbook with 16M PE (Configure Local Storage)
# Output policy: Only show real command output. Silent commands produce no output.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 206: LVM PVs + VG (16M PE)"
LAB_ID="lab206"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

DISK_SDB="/dev/sdb"
PART_SDB="/dev/sdb1"
DISK_SDC="/dev/sdc"
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
  center_text "Goal: Create PVs on $PART_SDB (~90MB) and $DISK_SDC (~250MB), then create VG $VG with 16M PE and list PVs/VG."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Create a ~90MB partition on /dev/sdb (silent)
  draw_lab_ui
  echo "  Step 1: Create a ~90MB partition sdb1."
  echo "          Expected: parted -s $DISK_SDB mklabel gpt"
  read -p "  lab@lab206:~$ " s1a
  [[ "$s1a" != "parted -s /dev/sdb mklabel gpt" ]] && { print_error "Use: parted -s /dev/sdb mklabel gpt"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "          Expected: parted -s $DISK_SDB mkpart primary 1MiB 91MiB"
  read -p "  lab@lab206:~$ " s1b
  [[ "$s1b" != "parted -s /dev/sdb mkpart primary 1MiB 91MiB" ]] && { print_error "Use: parted -s /dev/sdb mkpart primary 1MiB 91MiB"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "          Expected: partprobe $DISK_SDB"
  read -p "  lab@lab206:~$ " s1c
  [[ "$s1c" != "partprobe /dev/sdb" ]] && { print_error "Use: partprobe /dev/sdb"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 2: Verify partition exists (shows lsblk output)
  echo "  Step 2: Verify sdb1 exists."
  echo "          Expected: lsblk $DISK_SDB"
  read -p "  lab@lab206:~$ " s2
  [[ "$s2" != "lsblk /dev/sdb" ]] && { print_error "Use: lsblk /dev/sdb"; read -p "Press Enter to try again..." _; continue; }
  echo "NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT"
  echo "sdb      8:16   0   10G  0 disk"
  echo "└─sdb1   8:17   0   90M  0 part"
  echo

  # Step 3: Initialize PVs (pvcreate prints created messages)
  echo "  Step 3: Initialize $PART_SDB as a PV."
  echo "          Expected: pvcreate $PART_SDB"
  read -p "  lab@lab206:~$ " s3a
  [[ "$s3a" != "pvcreate /dev/sdb1" ]] && { print_error "Use: pvcreate /dev/sdb1"; read -p "Press Enter to try again..." _; continue; }
  echo "  Physical volume \"/dev/sdb1\" successfully created."
  echo
  echo "          Initialize whole disk $DISK_SDC as a PV."
  echo "          Expected: pvcreate $DISK_SDC"
  read -p "  lab@lab206:~$ " s3b
  [[ "$s3b" != "pvcreate /dev/sdc" ]] && { print_error "Use: pvcreate /dev/sdc"; read -p "Press Enter to try again..." _; continue; }
  echo "  Physical volume \"/dev/sdc\" successfully created."
  echo

  # Step 4: Create VG with 16M PE size (vgcreate prints success line)
  echo "  Step 4: Create VG $VG with 16M PE from both PVs."
  echo "          Expected: vgcreate -s 16M $VG $PART_SDB $DISK_SDC"
  read -p "  lab@lab206:~$ " s4
  [[ "$s4" != "vgcreate -s 16M vgbook /dev/sdb1 /dev/sdc" ]] && { print_error "Use: vgcreate -s 16M vgbook /dev/sdb1 /dev/sdc"; read -p "Press Enter to try again..." _; continue; }
  echo "  Volume group \"vgbook\" successfully created"
  echo

  # Step 5: Show PVs (pvs output)
  echo "  Step 5: List PVs."
  echo "          Expected: pvs"
  read -p "  lab@lab206:~$ " s5
  [[ "$s5" != "pvs" ]] && { print_error "Use: pvs"; read -p "Press Enter to try again..." _; continue; }
  echo "  PV         VG     Fmt  Attr PSize    PFree"
  echo "  /dev/sdb1  vgbook lvm2 a--   88.00m  88.00m"
  echo "  /dev/sdc   vgbook lvm2 a--  248.00m 248.00m"
  echo

  # Step 6: Show VG summary (vgs output)
  echo "  Step 6: Show VG summary."
  echo "          Expected: vgs"
  read -p "  lab@lab206:~$ " s6
  [[ "$s6" != "vgs" ]] && { print_error "Use: vgs"; read -p "Press Enter to try again..." _; continue; }
  echo "  VG     #PV #LV #SN Attr   VSize    VFree"
  echo "  vgbook   2   0   0 wz--n- 336.00m 336.00m"
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
