#!/bin/bash

# Lab 125: RHEL Storage Ops — LVM Basics (PV -> VG -> LV), Make XFS, Mount, Extend, Clean Up
# Focus: building an LVM stack from scratch, formatting with XFS, mounting persistently,
# extending an LV, growing XFS online, then safely cleaning up.
# Key skills: dnf, lsblk, pvcreate/pvs/pvremove, vgcreate/vgs/vgremove, lvcreate/lvs/lvextend/lvremove,
# mkfs.xfs, blkid, mkdir, mount/umount, /etc/fstab, mount -a, df, xfs_growfs.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 125: LVM Basics — Build, Mount, Extend, Clean Up"
LAB_ID="lab125"
LAB_XP=12500
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
  center_text "A VM gets a new blank disk for application logs. You want flexibility to resize later,"
  center_text "so you choose LVM. You will create PV->VG->LV, format XFS, mount at /mnt/logs,"
  center_text "make it persistent via /etc/fstab, extend it, grow XFS online, then clean up."
  echo
  center_text "Notes:"
  center_text "- Assume this blank disk exists: /dev/vdb (1G)"
  center_text "- Use sudo where required."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Verify the disk exists and is unused
  echo "  Step 1: Verify /dev/vdb exists and is not mounted."
  read -p "  lab@rhel-lab125:~$ " cmd1
  echo
  if [[ "$cmd1" != "lsblk" && \
        "$cmd1" != "lsblk -f" && \
        "$cmd1" != "lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  NAME   MAJ:MIN RM SIZE RO TYPE FSTYPE MOUNTPOINTS"
  echo "  vda    253:0    0  11G  0 disk"
  echo "  └─vda1 253:1    0  10G  0 part xfs    /"
  echo "  vdb    253:16   0   1G  0 disk"
  echo

  # STEP 2: Ensure LVM tooling is installed
  echo "  Step 2: Install LVM tooling."
  read -p "  lab@rhel-lab125:~$ " cmd2
  echo
  if [[ "$cmd2" != "sudo dnf install lvm2" && \
        "$cmd2" != "sudo dnf -y install lvm2" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Last metadata expiration check: 0:18:41 ago on Sun 11 Jan 2026 09:12:03 AM UTC."
  echo "  Dependencies resolved."
  echo "  Nothing to do."
  echo "  Complete!"
  echo

  # STEP 3: Create a PV
  echo "  Step 3: Initialize /dev/vdb as an LVM physical volume."
  read -p "  lab@rhel-lab125:~$ " cmd3
  echo
  if [[ "$cmd3" != "sudo pvcreate /dev/vdb" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Physical volume \"/dev/vdb\" successfully created."
  echo "  Creating devices file /etc/lvm/devices/system.devices"
  echo

  # STEP 4: Verify PV exists
  echo "  Step 4: Verify the PV."
  read -p "  lab@rhel-lab125:~$ " cmd4
  echo
  if [[ "$cmd4" != "sudo pvs" && \
        "$cmd4" != "sudo pvs -o pv_name,vg_name,pv_size,pv_free" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  PV         VG Fmt  Attr PSize PFree"
  echo "  /dev/vdb      lvm2 ---  1.00g 1.00g"
  echo

  # STEP 5: Create a VG
  echo "  Step 5: Create a volume group named 'logs_vg' using /dev/vdb."
  read -p "  lab@rhel-lab125:~$ " cmd5
  echo
  if [[ "$cmd5" != "sudo vgcreate logs_vg /dev/vdb" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Volume group \"logs_vg\" successfully created"
  echo

  # STEP 6: Create an LV
  echo "  Step 6: Create a 500M logical volume named 'logs_lv' in logs_vg."
  read -p "  lab@rhel-lab125:~$ " cmd6
  echo
  if [[ "$cmd6" != "sudo lvcreate -L 500M -n logs_lv logs_vg" && \
        "$cmd6" != "sudo lvcreate --size 500M --name logs_lv logs_vg" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Logical volume \"logs_lv\" created."
  echo

  # STEP 7: Verify LV path
  echo "  Step 7: Verify the LV exists."
  read -p "  lab@rhel-lab125:~$ " cmd7
  echo
  if [[ "$cmd7" != "sudo lvs" && \
        "$cmd7" != "sudo lvs -o lv_name,vg_name,lv_size,lv_path" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  LV      VG      Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert"
  echo "  logs_lv logs_vg -wi-a----- 500.00m"
  echo

  # STEP 8: Make XFS on the LV
  echo "  Step 8: Create an XFS filesystem on /dev/logs_vg/logs_lv."
  read -p "  lab@rhel-lab125:~$ " cmd8
  echo
  if [[ "$cmd8" != "sudo mkfs.xfs /dev/logs_vg/logs_lv" && \
        "$cmd8" != "sudo mkfs.xfs -f /dev/logs_vg/logs_lv" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  meta-data=/dev/logs_vg/logs_lv isize=512    agcount=4, agsize=32000 blks"
  echo "           =                       sectsz=512   attr=2, projid32bit=1"
  echo "           =                       crc=1        finobt=1, sparse=1, rmapbt=0"
  echo "           =                       reflink=1    bigtime=1 inobtcount=1 nrext64=0"
  echo "  data     =                       bsize=4096   blocks=128000, imaxpct=25"
  echo "           =                       sunit=0      swidth=0 blks"
  echo "  naming   =version 2              bsize=4096   ascii-ci=0, ftype=1"
  echo "  log      =internal log           bsize=4096   blocks=16384, version=2"
  echo "           =                       sectsz=512   sunit=0 blks, lazy-count=1"
  echo "  realtime =none                   extsz=4096   blocks=0, rtextents=0"
  echo

  # STEP 9: Create mountpoint directory
  echo "  Step 9: Create the mountpoint directory /mnt/logs."
  read -p "  lab@rhel-lab125:~$ " cmd9
  echo
  if [[ "$cmd9" != "sudo mkdir -p /mnt/logs" && \
        "$cmd9" != "mkdir -p /mnt/logs" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 10: Mount the filesystem
  echo "  Step 10: Mount /dev/logs_vg/logs_lv at /mnt/logs."
  read -p "  lab@rhel-lab125:~$ " cmd10
  echo
  if [[ "$cmd10" != "sudo mount /dev/logs_vg/logs_lv /mnt/logs" && \
        "$cmd10" != "mount /dev/logs_vg/logs_lv /mnt/logs" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 11: Verify mount with df
  echo "  Step 11: Verify the mount with df."
  read -p "  lab@rhel-lab125:~$ " cmd11
  echo
  if [[ "$cmd11" != "df -h /mnt/logs" && \
        "$cmd11" != "sudo df -h /mnt/logs" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Filesystem                  Size  Used Avail Use% Mounted on"
  echo "  /dev/mapper/logs_vg-logs_lv  488M   34M  454M   7% /mnt/logs"
  echo

  # STEP 12: Get UUID (for fstab)
  echo "  Step 12: Get the UUID for /dev/logs_vg/logs_lv."
  read -p "  lab@rhel-lab125:~$ " cmd12
  echo
  if [[ "$cmd12" != "sudo blkid /dev/logs_vg/logs_lv" && \
        "$cmd12" != "blkid /dev/logs_vg/logs_lv" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  /dev/mapper/logs_vg-logs_lv: UUID=\"b3a9e2c7-9a3b-4b48-a7df-8b4d2f7b6c21\" TYPE=\"xfs\""
  echo

  # STEP 13: Add persistent mount to /etc/fstab using UUID
  echo "  Step 13: Add an /etc/fstab entry using that UUID for /mnt/logs."
  read -p "  lab@rhel-lab125:~$ " cmd13
  echo
  if [[ "$cmd13" != "echo 'UUID=b3a9e2c7-9a3b-4b48-a7df-8b4d2f7b6c21 /mnt/logs xfs defaults 0 0' | sudo tee -a /etc/fstab" && \
        "$cmd13" != "sudo sh -c \"echo 'UUID=b3a9e2c7-9a3b-4b48-a7df-8b4d2f7b6c21 /mnt/logs xfs defaults 0 0' >> /etc/fstab\"" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  UUID=b3a9e2c7-9a3b-4b48-a7df-8b4d2f7b6c21 /mnt/logs xfs defaults 0 0"
  echo

  # STEP 14: Test fstab entry with mount -a (ops safe)
  echo "  Step 14: Test /etc/fstab entries."
  read -p "  lab@rhel-lab125:~$ " cmd14
  echo
  if [[ "$cmd14" != "sudo mount -a" && \
        "$cmd14" != "mount -a" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 15: Extend the LV and grow XFS online
  echo "  Step 15: Extend the LV by 200M."
  read -p "  lab@rhel-lab125:~$ " cmd15
  echo
  if [[ "$cmd15" != "sudo lvextend -L +200M /dev/logs_vg/logs_lv" && \
        "$cmd15" != "sudo lvextend -L+200M /dev/logs_vg/logs_lv" && \
        "$cmd15" != "sudo lvextend -r -L +200M /dev/logs_vg/logs_lv" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Size of logical volume logs_vg/logs_lv changed from 500.00 MiB (125 extents) to 700.00 MiB (175 extents)."
  echo "  Logical volume logs_vg/logs_lv successfully resized."
  echo

  echo "  Step 16: Grow the XFS filesystem on /mnt/logs to use the new space."
  read -p "  lab@rhel-lab125:~$ " cmd16
  echo
  if [[ "$cmd16" != "sudo xfs_growfs /mnt/logs" && \
        "$cmd16" != "xfs_growfs /mnt/logs" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  meta-data=/dev/mapper/logs_vg-logs_lv isize=512    agcount=4, agsize=32000 blks"
  echo "  data     =                       bsize=4096   blocks=179200, imaxpct=25"
  echo "  data blocks changed from 128000 to 179200"
  echo

  echo "  Step 17: Verify the new size with df."
  read -p "  lab@rhel-lab125:~$ " cmd17
  echo
  if [[ "$cmd17" != "df -h /mnt/logs" && \
        "$cmd17" != "sudo df -h /mnt/logs" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Filesystem                  Size  Used Avail Use% Mounted on"
  echo "  /dev/mapper/logs_vg-logs_lv  688M   35M  653M   6% /mnt/logs"
  echo

  # STEP 18: Clean up (remove fstab line, unmount, remove LV/VG/PV)
  echo "  Step 18: Remove the /mnt/logs entry from /etc/fstab."
  read -p "  lab@rhel-lab125:~$ " cmd18
  echo
  if [[ "$cmd18" != "sudo sed -i '/mnt/logs/d' /etc/fstab" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  echo "  Step 19: Unmount /mnt/logs."
  read -p "  lab@rhel-lab125:~$ " cmd19
  echo
  if [[ "$cmd19" != "sudo umount /mnt/logs" && \
        "$cmd19" != "umount /mnt/logs" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  echo "  Step 20: Remove the LV."
  read -p "  lab@rhel-lab125:~$ " cmd20
  echo
  if [[ "$cmd20" != "sudo lvremove -y /dev/logs_vg/logs_lv" && \
        "$cmd20" != "sudo lvremove -y logs_vg/logs_lv" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Logical volume \"logs_lv\" successfully removed."
  echo

  echo "  Step 21: Remove the VG."
  read -p "  lab@rhel-lab125:~$ " cmd21
  echo
  if [[ "$cmd21" != "sudo vgremove -y logs_vg" && \
        "$cmd21" != "sudo vgremove logs_vg" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Volume group \"logs_vg\" successfully removed"
  echo

  echo "  Step 22: Remove the PV label from /dev/vdb."
  read -p "  lab@rhel-lab125:~$ " cmd22
  echo
  if [[ "$cmd22" != "sudo pvremove -y /dev/vdb" && \
        "$cmd22" != "sudo pvremove /dev/vdb" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Labels on physical volume \"/dev/vdb\" successfully wiped."
  echo

  print_success "Great job."
  print_info "You completed a full, ops-realistic LVM workflow:"
  print_info "- built PV -> VG -> LV and verified each layer"
  print_info "- formatted XFS, mounted it, and made it persistent with a UUID-based fstab entry"
  print_info "- extended the LV and grew XFS online safely"
  print_info "- cleaned up the stack and reverted the system state"
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
