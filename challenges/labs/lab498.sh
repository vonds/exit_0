#!/bin/bash

# Lab 498: LVM — Create and Remove Physical Volumes (pvcreate/pvs/pvdisplay/pvremove)
# Focus: Initialize block devices as LVM PVs, inspect PVs, and safely wipe PV metadata.
#
# RHCSA Objective:
# - Create and remove physical volumes
#
# Key skills validated:
# - Identify candidate block devices for PV use
# - Create PVs on whole disks and partitions (pvcreate)
# - Verify PVs (pvs, pvdisplay)
# - Confirm PV is not in a VG (vgs)
# - Remove PV metadata safely (pvremove)
#
# Difficulty: Intermediate
# XP: 49800

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 498: Create and Remove Physical Volumes"
LAB_ID="lab498"
LAB_XP=49800
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab498:~$ "

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
  center_text "A storage admin left two unused devices attached to this VM."
  center_text "You must initialize them as LVM physical volumes (PVs), verify them,"
  center_text "and then safely remove (wipe) the PV metadata so the devices can be reused."
  echo
  center_text "Lab devices (simulated):"
  center_text "- /dev/sdb  (empty disk)"
  center_text "- /dev/sdc1 (empty partition)"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  # STEP 1: Identify candidate devices
  echo "  Step 1: List block devices and identify the two empty targets."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "lsblk" && "$cmd1" != "lsblk -f" ]]; then
    print_error "Incorrect. Use: lsblk"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS"
  echo "  sda           8:0    0   40G  0 disk"
  echo "  ├─sda1        8:1    0  600M  0 part /boot"
  echo "  └─sda2        8:2    0 39.4G  0 part"
  echo "    ├─rhel-root 253:0  0   35G  0 lvm  /"
  echo "    └─rhel-swap 253:1  0  4.4G  0 lvm  [SWAP]"
  echo "  sdb           8:16   0    5G  0 disk"
  echo "  sdc           8:32   0    5G  0 disk"
  echo "  └─sdc1        8:33   0    1G  0 part"
  echo

  # STEP 2: Create PV on /dev/sdb
  echo "  Step 2: Initialize /dev/sdb as a physical volume."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo pvcreate /dev/sdb" ]]; then
    print_error "Incorrect. Use: sudo pvcreate /dev/sdb"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Physical volume \"/dev/sdb\" successfully created."
  echo

  # STEP 3: Create PV on /dev/sdc1
  echo "  Step 3: Initialize /dev/sdc1 as a physical volume."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo pvcreate /dev/sdc1" ]]; then
    print_error "Incorrect. Use: sudo pvcreate /dev/sdc1"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Physical volume \"/dev/sdc1\" successfully created."
  echo

  # STEP 4: Verify PVs with pvs
  echo "  Step 4: Verify both PVs exist using pvs."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo pvs" && "$cmd4" != "pvs" ]]; then
    print_error "Incorrect. Use: sudo pvs"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  PV         VG  Fmt  Attr PSize  PFree"
  echo "  /dev/sdb       lvm2 ---   5.00g 5.00g"
  echo "  /dev/sdc1      lvm2 ---   1.00g 1.00g"
  echo

  # STEP 5: View detailed PV info (pvdisplay /dev/sdb)
  echo "  Step 5: Display detailed information for /dev/sdb."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo pvdisplay /dev/sdb" ]]; then
    print_error "Incorrect. Use: sudo pvdisplay /dev/sdb"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  --- Physical volume ---"
  echo "  PV Name               /dev/sdb"
  echo "  VG Name"
  echo "  PV Size               5.00 GiB / not usable 4.00 MiB"
  echo "  Allocatable           yes"
  echo "  PE Size               4.00 MiB"
  echo "  Total PE              1279"
  echo "  Free PE               1279"
  echo "  Allocated PE          0"
  echo "  PV UUID               Xh9pQe-4Qm2-Xt7y-9p0a-1m2n-3b4c-5d6e7f"
  echo

  # STEP 6: Confirm PVs are not in any VG (vgs)
  echo "  Step 6: Confirm no new volume group was created (vgs)."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo vgs" && "$cmd6" != "vgs" ]]; then
    print_error "Incorrect. Use: sudo vgs"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  VG   #PV #LV #SN Attr   VSize   VFree"
  echo "  rhel    1   2   0 wz--n-  <39.4g     0"
  echo

  # STEP 7: Remove PV metadata from /dev/sdc1
  echo "  Step 7: Remove (wipe) LVM metadata from /dev/sdc1 using pvremove."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo pvremove /dev/sdc1" ]]; then
    print_error "Incorrect. Use: sudo pvremove /dev/sdc1"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Labels on physical volume \"/dev/sdc1\" successfully wiped."
  echo

  # STEP 8: Remove PV metadata from /dev/sdb
  echo "  Step 8: Remove (wipe) LVM metadata from /dev/sdb using pvremove."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo pvremove /dev/sdb" ]]; then
    print_error "Incorrect. Use: sudo pvremove /dev/sdb"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Labels on physical volume \"/dev/sdb\" successfully wiped."
  echo

  # STEP 9: Verify PVs are gone
  echo "  Step 9: Verify the PVs were removed (pvs)."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo pvs" && "$cmd9" != "pvs" ]]; then
    print_error "Incorrect. Use: sudo pvs"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  PV         VG   Fmt  Attr PSize  PFree"
  echo "  /dev/sda2  rhel lvm2 a--  <39.4g     0"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- identified unused devices with lsblk"
  print_info "- created PVs with pvcreate"
  print_info "- verified PVs using pvs and pvdisplay"
  print_info "- confirmed VG membership with vgs"
  print_info "- removed PV metadata using pvremove"
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
