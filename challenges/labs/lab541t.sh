#!/bin/bash

# Lab 541T: Create and Mount an LVM-VDO Volume (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 541T: Create and Mount an LVM-VDO Volume"
LAB_ID="lab541t"
LAB_XP=54100
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@servera:~$ "

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
  center_text "ServerA needs a space-efficient logical volume using VDO."
  center_text "Use the existing volume group myvg to create a VDO LV"
  center_text "named vdo_lv with a 5GiB physical size and a 20GiB"
  center_text "virtual size, then format and mount it persistently."
  echo
  center_text "Requirements:"
  center_text "- Volume Group: myvg"
  center_text "- VDO LV Name: vdo_lv"
  center_text "- Physical Size: 5GiB"
  center_text "- Virtual Size: 20GiB"
  center_text "- Filesystem: xfs"
  center_text "- Mount Point: /vdo_data"
  echo

  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Install the packages required for LVM-VDO management."
  read -p "$PROMPT" cmd1
  echo

  if [[ "$cmd1" != "sudo dnf install -y lvm2 kmod-kvdo vdo" ]]; then
    print_error "Incorrect. Use: sudo dnf install -y lvm2 kmod-kvdo vdo"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Installed:"
  echo "    lvm2"
  echo "    kmod-kvdo"
  echo "    vdo"
  echo

  echo "  Step 2: Confirm the target volume group exists before creating the VDO LV."
  read -p "$PROMPT" cmd2
  echo

  if [[ "$cmd2" != "vgs myvg" ]]; then
    print_error "Incorrect. Use: vgs myvg"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  VG   #PV #LV #SN Attr   VSize   VFree"
  echo "  myvg   1   0   0 wz--n- 10.00g 10.00g"
  echo

  echo "  Step 3: Create the VDO logical volume with a 5GiB physical size and 20GiB virtual size."
  read -p "$PROMPT" cmd3
  echo

  if [[ "$cmd3" != "sudo lvcreate --type vdo --name vdo_lv --size 5G --virtualsize 20G myvg" ]]; then
    print_error "Incorrect."
    print_info "Use: sudo lvcreate --type vdo --name vdo_lv --size 5G --virtualsize 20G myvg"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Logical volume \"vdo_lv\" created."
  echo

  echo "  Step 4: Verify the new logical volume exists."
  read -p "$PROMPT" cmd4
  echo

  if [[ "$cmd4" != "sudo lvs myvg" && "$cmd4" != "lvs myvg" ]]; then
    print_error "Incorrect. Use: lvs myvg"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  LV      VG   Attr       LSize  Pool    Origin Data%  Meta%  Move Log Cpy%Sync Convert"
  echo "  vdo_lv  myvg vwi-a-v--- 20.00g vdo_lv  0.00"
  echo "  [vdo_lv_vpool] myvg dwi------- 5.00g"
  echo

  echo "  Step 5: Create an XFS filesystem on the VDO logical volume."
  read -p "$PROMPT" cmd5
  echo

  if [[ "$cmd5" != "sudo mkfs.xfs -K /dev/myvg/vdo_lv" ]]; then
    print_error "Incorrect. Use: sudo mkfs.xfs -K /dev/myvg/vdo_lv"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  meta-data=/dev/myvg/vdo_lv        isize=512    agcount=4, agsize=1310720 blks"
  echo "           =                       sectsz=4096   attr=2, projid32bit=1"
  echo "           =                       crc=1         finobt=1, sparse=1, rmapbt=0"
  echo "           =                       reflink=1     bigtime=1 inobtcount=1"
  echo "  data     =                       bsize=4096    blocks=5242880, imaxpct=25"
  echo "           =                       sunit=0       swidth=0 blks"
  echo "  naming   =version 2              bsize=4096    ascii-ci=0, ftype=1"
  echo "  log      =internal log           bsize=4096    blocks=2560, version=2"
  echo "           =                       sectsz=4096   sunit=1 blks, lazy-count=1"
  echo "  realtime =none                   extsz=4096    blocks=0, rtextents=0"
  echo

  echo "  Step 6: Create the persistent mount point."
  read -p "$PROMPT" cmd6
  echo

  if [[ "$cmd6" != "sudo mkdir -p /vdo_data" ]]; then
    print_error "Incorrect. Use: sudo mkdir -p /vdo_data"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 7: Add a persistent fstab entry for the VDO volume."
  read -p "$PROMPT" cmd7
  echo

  if [[ "$cmd7" != "echo '/dev/myvg/vdo_lv /vdo_data xfs defaults 0 0' | sudo tee -a /etc/fstab > /dev/null" ]]; then
    print_error "Incorrect."
    print_info "Use: echo '/dev/myvg/vdo_lv /vdo_data xfs defaults 0 0' | sudo tee -a /etc/fstab > /dev/null"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 8: Mount all filesystems from /etc/fstab."
  read -p "$PROMPT" cmd8
  echo

  if [[ "$cmd8" != "sudo mount -a" ]]; then
    print_error "Incorrect. Use: sudo mount -a"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  [no output]"
  echo

  echo "  Step 9: Verify the VDO filesystem is mounted."
  read -p "$PROMPT" cmd9
  echo

  if [[ "$cmd9" != "mount | grep vdo_data" ]]; then
    print_error "Incorrect. Use: mount | grep vdo_data"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  /dev/mapper/myvg-vdo_lv on /vdo_data type xfs (rw,relatime,seclabel,attr2,inode64,logbufs=8,logbsize=32k,noquota)"
  echo

  echo "  Step 10: Confirm the mounted capacity reflects the virtual size."
  read -p "$PROMPT" cmd10
  echo

  if [[ "$cmd10" != "df -h /vdo_data" ]]; then
    print_error "Incorrect. Use: df -h /vdo_data"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Filesystem                Size  Used Avail Use% Mounted on"
  echo "  /dev/mapper/myvg-vdo_lv    20G  175M   20G   1% /vdo_data"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- installed the required VDO packages"
  print_info "- verified the myvg volume group"
  print_info "- created a VDO logical volume named vdo_lv"
  print_info "- set the physical size to 5GiB"
  print_info "- set the virtual size to 20GiB"
  print_info "- formatted the volume with XFS"
  print_info "- mounted it persistently at /vdo_data"
  print_info "- verified the mount and available capacity"
  print_info "You earned $LAB_XP XP."

  award_xp $LAB_XP
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