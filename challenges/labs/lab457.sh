#!/bin/bash

# Lab 457: RHEL Storage Ops — Build PVs, Create/Extend VG, Create/Resize LV, Make XFS, Remove LV
# Focus: installing LVM tooling, initializing physical volumes, creating/extending/reducing a VG,
# creating and resizing an LV, formatting with XFS, and safely removing an LV.
# Key skills: dnf, pvcreate/pvs/pvremove, vgcreate/vgs/vgextend/vgreduce/vgremove, lvcreate/lvs/lvresize/lvremove,
# lsblk, mkfs.xfs, and basic verification.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 457: LVM Build, Resize, Format, and Clean Up"
LAB_ID="lab457"
LAB_XP=75700
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
  center_text "You are on a fresh RHEL host with several 1G data disks attached."
  center_text "Your job is to install LVM tooling, build PVs, create a VG, manage membership,"
  center_text "create an LV, resize it, format it as XFS, then clean it up safely."
  echo
  center_text "Notes:"
  center_text "- Assume these disks exist: /dev/vdb /dev/vdc /dev/vdd /dev/vde"
  center_text "- Use sudo where required."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Install LVM tools
  echo "  Step 1: Install the LVM tools package."
  read -p "  lab@rhel-lab457:~$ " cmd1
  echo
  if [[ "$cmd1" != "sudo dnf install lvm2" && \
        "$cmd1" != "sudo dnf -y install lvm2" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Last metadata expiration check: 1:32:21 ago on Sat 10 Jan 2026 04:58:46 PM UTC."
  echo "  Dependencies resolved."
  echo "  Installed: lvm2"
  echo "  Complete!"
  echo

  # STEP 2: Create PVs on 4 disks
  echo "  Step 2: Initialize /dev/vdb /dev/vdc /dev/vdd /dev/vde as physical volumes."
  read -p "  lab@rhel-lab457:~$ " cmd2
  echo
  if [[ "$cmd2" != "sudo pvcreate /dev/vdb /dev/vdc /dev/vdd /dev/vde" && \
        "$cmd2" != "sudo pvcreate /dev/vd{b,c,d,e}" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Physical volume \"/dev/vdb\" successfully created."
  echo "  Physical volume \"/dev/vdc\" successfully created."
  echo "  Physical volume \"/dev/vdd\" successfully created."
  echo "  Physical volume \"/dev/vde\" successfully created."
  echo "  Creating devices file /etc/lvm/devices/system.devices"
  echo

  # STEP 3: Verify PVs
  echo "  Step 3: Verify the PVs exist."
  read -p "  lab@rhel-lab457:~$ " cmd3
  echo
  if [[ "$cmd3" != "sudo pvs" && \
        "$cmd3" != "sudo pvs -o pv_name,vg_name,pv_size,pv_free" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  PV         VG Fmt  Attr PSize PFree"
  echo "  /dev/vdb      lvm2 ---  1.00g 1.00g"
  echo "  /dev/vdc      lvm2 ---  1.00g 1.00g"
  echo "  /dev/vdd      lvm2 ---  1.00g 1.00g"
  echo "  /dev/vde      lvm2 ---  1.00g 1.00g"
  echo

  # STEP 4: Remove one PV label (wipe /dev/vde)
  echo "  Step 4: Remove (wipe) the PV label from /dev/vde so it is no longer a PV."
  read -p "  lab@rhel-lab457:~$ " cmd4
  echo
  if [[ "$cmd4" != "sudo pvremove /dev/vde" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Labels on physical volume \"/dev/vde\" successfully wiped."
  echo

  echo "  Step 5: Confirm /dev/vde is gone from pvs output."
  read -p "  lab@rhel-lab457:~$ " cmd5
  echo
  if [[ "$cmd5" != "sudo pvs" && \
        "$cmd5" != "sudo pvs -o pv_name,vg_name,pv_size,pv_free" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  PV         VG Fmt  Attr PSize PFree"
  echo "  /dev/vdb      lvm2 ---  1.00g 1.00g"
  echo "  /dev/vdc      lvm2 ---  1.00g 1.00g"
  echo "  /dev/vdd      lvm2 ---  1.00g 1.00g"
  echo

  # STEP 5: Create a VG with two PVs
  echo "  Step 6: Create volume group 'volume1' using /dev/vdb and /dev/vdc."
  read -p "  lab@rhel-lab457:~$ " cmd6
  echo
  if [[ "$cmd6" != "sudo vgcreate volume1 /dev/vdb /dev/vdc" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Volume group \"volume1\" successfully created"
  echo

  # STEP 6: Show block devices (sanity check)
  echo "  Step 7: List block devices so you can see the attached disks."
  read -p "  lab@rhel-lab457:~$ " cmd7
  echo
  if [[ "$cmd7" != "lsblk" && \
        "$cmd7" != "lsblk -f" && \
        "$cmd7" != "lsblk -o NAME,SIZE,TYPE,MOUNTPOINTS" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINTS"
  echo "  vda    253:0    0  11G  0 disk"
  echo "  └─vda1 253:1    0  10G  0 part /"
  echo "  vdb    253:16   0   1G  0 disk"
  echo "  vdc    253:32   0   1G  0 disk"
  echo "  vdd    253:48   0   1G  0 disk"
  echo "  vde    253:64   0   1G  0 disk"
  echo

  # STEP 7: Extend VG with /dev/vdd
  echo "  Step 8: Add /dev/vdd to volume group 'volume1'."
  read -p "  lab@rhel-lab457:~$ " cmd8
  echo
  if [[ "$cmd8" != "sudo vgextend volume1 /dev/vdd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Volume group \"volume1\" successfully extended"
  echo

  # STEP 8: Remove the VG (clean reset), then recreate it with 3 PVs
  echo "  Step 9: Remove the volume group volume1 (clean reset)."
  read -p "  lab@rhel-lab457:~$ " cmd9
  echo
  if [[ "$cmd9" != "sudo vgremove volume1" && \
        "$cmd9" != "sudo vgremove -y volume1" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Volume group \"volume1\" successfully removed"
  echo

  echo "  Step 10: Recreate volume group volume1 using /dev/vdb /dev/vdc /dev/vdd."
  read -p "  lab@rhel-lab457:~$ " cmd10
  echo
  if [[ "$cmd10" != "sudo vgcreate volume1 /dev/vdb /dev/vdc /dev/vdd" && \
        "$cmd10" != "sudo vgcreate volume1 /dev/vd{b,c,d}" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Volume group \"volume1\" successfully created"
  echo

  # STEP 9: Reduce VG by removing /dev/vdd
  echo "  Step 11: Remove /dev/vdd from volume1."
  read -p "  lab@rhel-lab457:~$ " cmd11
  echo
  if [[ "$cmd11" != "sudo vgreduce volume1 /dev/vdd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Removed \"/dev/vdd\" from volume group \"volume1\""
  echo

  # STEP 10: Verify VG state
  echo "  Step 12: Show VG summary."
  read -p "  lab@rhel-lab457:~$ " cmd12
  echo
  if [[ "$cmd12" != "sudo vgs" && \
        "$cmd12" != "sudo vgs volume1" && \
        "$cmd12" != "sudo vgs -o vg_name,pv_count,lv_count,vg_size,vg_free" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  VG      #PV #LV #SN Attr   VSize VFree"
  echo "  volume1   2   0   0 wz--n- 1.99g 1.99g"
  echo

  # STEP 11: Create LV 1.5G (allowed because VG ~1.99G)
  echo "  Step 13: Create a 1.5G logical volume named 'smalldata' in volume1."
  read -p "  lab@rhel-lab457:~$ " cmd13
  echo
  if [[ "$cmd13" != "sudo lvcreate --size=1.5G --name smalldata volume1" && \
        "$cmd13" != "sudo lvcreate -L 1.5G -n smalldata volume1" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Logical volume \"smalldata\" created."
  echo

  # STEP 12: Resize LV down to 1G (no filesystem yet)
  echo "  Step 14: Resize volume1/smalldata down to 1G."
  read -p "  lab@rhel-lab457:~$ " cmd14
  echo
  if [[ "$cmd14" != "sudo lvresize --size 1G volume1/smalldata" && \
        "$cmd14" != "sudo lvresize -L 1G volume1/smalldata" && \
        "$cmd14" != "sudo lvreduce -L 1G volume1/smalldata" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  No file system found on /dev/volume1/smalldata."
  echo "  Size of logical volume volume1/smalldata changed from 1.50 GiB (384 extents) to 1.00 GiB (256 extents)."
  echo "  Logical volume volume1/smalldata successfully resized."
  echo

  # STEP 13: Format as XFS
  echo "  Step 15: Create an XFS filesystem on /dev/volume1/smalldata."
  read -p "  lab@rhel-lab457:~$ " cmd15
  echo
  if [[ "$cmd15" != "sudo mkfs.xfs /dev/volume1/smalldata" && \
        "$cmd15" != "sudo mkfs.xfs -f /dev/volume1/smalldata" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  meta-data=/dev/volume1/smalldata isize=512    agcount=4, agsize=65536 blks"
  echo "           =                       sectsz=512   attr=2, projid32bit=1"
  echo "           =                       crc=1        finobt=1, sparse=1, rmapbt=0"
  echo "           =                       reflink=1    bigtime=1 inobtcount=1 nrext64=0"
  echo "  data     =                       bsize=4096   blocks=262144, imaxpct=25"
  echo "           =                       sunit=0      swidth=0 blks"
  echo "  naming   =version 2              bsize=4096   ascii-ci=0, ftype=1"
  echo "  log      =internal log           bsize=4096   blocks=16384, version=2"
  echo "           =                       sectsz=512   sunit=0 blks, lazy-count=1"
  echo "  realtime =none                   extsz=4096   blocks=0, rtextents=0"
  echo

  # STEP 14: Remove the LV
  echo "  Step 16: Remove the logical volume /dev/volume1/smalldata."
  read -p "  lab@rhel-lab457:~$ " cmd16
  echo
  if [[ "$cmd16" != "sudo lvremove /dev/volume1/smalldata" && \
        "$cmd16" != "sudo lvremove -y /dev/volume1/smalldata" && \
        "$cmd16" != "sudo lvremove volume1/smalldata" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Do you really want to remove active logical volume volume1/smalldata? [y/n]: y"
  echo "  Logical volume \"smalldata\" successfully removed."
  echo

  print_success "Great job."
  print_info "You completed a full LVM lifecycle with safe verification:"
  print_info "- installed lvm2 with dnf"
  print_info "- created PVs, removed an unwanted PV label, and verified with pvs"
  print_info "- created, extended, removed, and recreated a VG; then reduced PV membership"
  print_info "- created and resized an LV, formatted it as XFS, then removed it"
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
