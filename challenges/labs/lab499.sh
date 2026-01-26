#!/bin/bash

# Lab 499: LVM — Assign Physical Volumes to Volume Groups (vgcreate/vgextend/vgs/vgdisplay/vgreduce)
# Focus: Create a VG from PVs, extend a VG with an additional PV, verify VG state,
#        and (optionally) remove a PV from a VG.
#
# RHCSA Objective:
# - Assign physical volumes to volume groups
#
# Key skills validated:
# - Create PVs (pvcreate) as prerequisites
# - Create a VG with vgcreate
# - Add PVs to an existing VG with vgextend
# - Verify VG/PV membership with vgs, pvs, vgdisplay
# - Remove a PV from a VG with vgreduce (exam-relevant)
#
# Difficulty: Intermediate
# XP: 49900

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 499: Assign PVs to Volume Groups"
LAB_ID="lab499"
LAB_XP=49900
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab499:~$ "

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
  center_text "Two new disks were attached to this system for a storage expansion."
  center_text "You must initialize them as LVM PVs and combine them into a new VG."
  center_text "Then, add a third PV to extend the VG, verify capacity, and finally"
  center_text "remove that third PV to return the system to its original storage plan."
  echo
  center_text "Lab devices (simulated):"
  center_text "- /dev/sdb  (5G disk)"
  center_text "- /dev/sdc  (5G disk)"
  center_text "- /dev/sdd  (2G disk)  (temporary add/remove)"
  echo
  center_text "Target VG name: vg_data"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  # STEP 1: Identify devices
  echo "  Step 1: List block devices to confirm /dev/sdb, /dev/sdc, and /dev/sdd exist."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "lsblk" ]]; then
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
  echo "  sdd           8:48   0    2G  0 disk"
  echo

  # STEP 2: Create PVs on sdb and sdc
  echo "  Step 2: Initialize /dev/sdb and /dev/sdc as physical volumes in one command."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo pvcreate /dev/sdb /dev/sdc" ]]; then
    print_error "Incorrect. Use: sudo pvcreate /dev/sdb /dev/sdc"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Physical volume \"/dev/sdb\" successfully created."
  echo "  Physical volume \"/dev/sdc\" successfully created."
  echo

  # STEP 3: Create VG with vgcreate
  echo "  Step 3: Create volume group vg_data using /dev/sdb and /dev/sdc."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo vgcreate vg_data /dev/sdb /dev/sdc" ]]; then
    print_error "Incorrect. Use: sudo vgcreate vg_data /dev/sdb /dev/sdc"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Volume group \"vg_data\" successfully created"
  echo

  # STEP 4: Verify VG summary (vgs)
  echo "  Step 4: Verify the VG exists and check total/free space."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo vgs" && "$cmd4" != "vgs" ]]; then
    print_error "Incorrect. Use: sudo vgs"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  VG      #PV #LV #SN Attr   VSize   VFree"
  echo "  rhel      1   2   0 wz--n- <39.4g     0"
  echo "  vg_data   2   0   0 wz--n-  9.99g  9.99g"
  echo

  # STEP 5: Verify PV membership (pvs)
  echo "  Step 5: Verify which PVs belong to vg_data using pvs."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo pvs" && "$cmd5" != "pvs" ]]; then
    print_error "Incorrect. Use: sudo pvs"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  PV         VG      Fmt  Attr PSize   PFree"
  echo "  /dev/sda2  rhel     lvm2 a--  <39.4g     0"
  echo "  /dev/sdb   vg_data  lvm2 a--   5.00g  5.00g"
  echo "  /dev/sdc   vg_data  lvm2 a--   5.00g  5.00g"
  echo

  # STEP 6: Create PV on sdd (temporary disk)
  echo "  Step 6: Initialize /dev/sdd as a physical volume (temporary capacity add)."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo pvcreate /dev/sdd" ]]; then
    print_error "Incorrect. Use: sudo pvcreate /dev/sdd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Physical volume \"/dev/sdd\" successfully created."
  echo

  # STEP 7: Extend VG with sdd
  echo "  Step 7: Add /dev/sdd to vg_data (extend the volume group)."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo vgextend vg_data /dev/sdd" ]]; then
    print_error "Incorrect. Use: sudo vgextend vg_data /dev/sdd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Volume group \"vg_data\" successfully extended"
  echo

  # STEP 8: Verify new capacity (vgs vg_data)
  echo "  Step 8: Verify vg_data now includes 3 PVs and increased size."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo vgs vg_data" && "$cmd8" != "vgs vg_data" ]]; then
    print_error "Incorrect. Use: sudo vgs vg_data"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  VG      #PV #LV #SN Attr   VSize   VFree"
  echo "  vg_data   3   0   0 wz--n- 11.99g 11.99g"
  echo

  # STEP 9: Detailed VG info (vgdisplay vg_data)
  echo "  Step 9: Display detailed information about vg_data."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo vgdisplay vg_data" ]]; then
    print_error "Incorrect. Use: sudo vgdisplay vg_data"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  --- Volume group ---"
  echo "  VG Name               vg_data"
  echo "  System ID"
  echo "  Format                lvm2"
  echo "  Metadata Areas        3"
  echo "  Metadata Sequence No  2"
  echo "  VG Access             read/write"
  echo "  VG Status             resizable"
  echo "  MAX LV                0"
  echo "  Cur LV                0"
  echo "  Open LV               0"
  echo "  Max PV                0"
  echo "  Cur PV                3"
  echo "  Act PV                3"
  echo "  VG Size               11.99 GiB"
  echo "  PE Size               4.00 MiB"
  echo "  Total PE              3070"
  echo "  Alloc PE / Size       0 / 0"
  echo "  Free  PE / Size       3070 / 11.99 GiB"
  echo "  VG UUID               7QmJc2-yL3p-Bb9d-1k2m-3n4p-5q6r-7s8t9u"
  echo

  # STEP 10: Remove /dev/sdd from vg_data (vgreduce)
  echo "  Step 10: Remove /dev/sdd from vg_data (vgreduce)."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "sudo vgreduce vg_data /dev/sdd" ]]; then
    print_error "Incorrect. Use: sudo vgreduce vg_data /dev/sdd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Removed \"/dev/sdd\" from volume group \"vg_data\""
  echo

  # STEP 11: Verify /dev/sdd no longer belongs to the VG (pvs)
  echo "  Step 11: Verify /dev/sdd is no longer assigned to vg_data."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "sudo pvs" && "$cmd11" != "pvs" ]]; then
    print_error "Incorrect. Use: sudo pvs"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  PV         VG      Fmt  Attr PSize   PFree"
  echo "  /dev/sda2  rhel     lvm2 a--  <39.4g     0"
  echo "  /dev/sdb   vg_data  lvm2 a--   5.00g  5.00g"
  echo "  /dev/sdc   vg_data  lvm2 a--   5.00g  5.00g"
  echo "  /dev/sdd           lvm2 ---    2.00g  2.00g"
  echo

  # STEP 12: (Cleanup) wipe PV label from /dev/sdd
  echo "  Step 12: Cleanup: wipe the PV metadata from /dev/sdd (pvremove)."
  read -p "$PROMPT" cmd12
  echo
  if [[ "$cmd12" != "sudo pvremove /dev/sdd" ]]; then
    print_error "Incorrect. Use: sudo pvremove /dev/sdd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Labels on physical volume \"/dev/sdd\" successfully wiped."
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- created PVs and assigned them to a new VG with vgcreate"
  print_info "- extended the VG with vgextend"
  print_info "- verified VG size/free space with vgs and vgdisplay"
  print_info "- removed a PV from the VG with vgreduce"
  print_info "- cleaned up PV metadata with pvremove"
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
