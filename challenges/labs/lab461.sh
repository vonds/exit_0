#!/bin/bash

# Lab 461: RHEL Storage Management — LVM Creation and Extension Using fdisk
# Focus: creating LVM-backed storage from raw disks, then extending it with an additional disk.
# Key skills: fdisk (interactive), partition type 8e (Linux LVM), lvm2, pvcreate, pvdisplay,
# vgcreate, vgdisplay, lvcreate, lvdisplay, mkfs.xfs, mount, df -h, vgextend, lvextend, xfs_growfs.
# Disks used in this lab: /dev/nvme1 (initial), /dev/nvme2 (extension)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 461: Create and Extend LVM Storage"
LAB_ID="lab461"
LAB_XP=46100
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
  center_text "Two new 5 GiB NVMe disks have been attached to the system: nvme1 and nvme2."
  center_text "You must create an LVM setup on nvme1, then extend it using nvme2."
  echo
  center_text "Goal: create PV → VG → LV, format, mount, then extend VG, LV, and filesystem."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: List disks with fdisk -l | less
  echo "  Step 1: List all disks using fdisk and paginate the output."
  read -p "  lab@rhel-lab461:~$ " cmd1
  echo
  if [[ "$cmd1" != "sudo fdisk -l | less" && "$cmd1" != "fdisk -l | less" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Disk /dev/nvme0n1: 40 GiB, 42949672960 bytes, 83886080 sectors"
  echo "  Disk model: QEMU NVMe Ctrl"
  echo "  Units: sectors of 1 * 512 = 512 bytes"
  echo "  Sector size (logical/physical): 512 bytes / 512 bytes"
  echo "  I/O size (minimum/optimal): 512 bytes / 512 bytes"
  echo "  Disklabel type: gpt"
  echo
  echo "  Disk /dev/nvme1: 5 GiB, 5368709120 bytes, 10485760 sectors"
  echo "  Disk model: QEMU NVMe Ctrl"
  echo "  Units: sectors of 1 * 512 = 512 bytes"
  echo "  Sector size (logical/physical): 512 bytes / 512 bytes"
  echo "  I/O size (minimum/optimal): 512 bytes / 512 bytes"
  echo
  echo "  Disk /dev/nvme2: 5 GiB, 5368709120 bytes, 10485760 sectors"
  echo "  Disk model: QEMU NVMe Ctrl"
  echo "  Units: sectors of 1 * 512 = 512 bytes"
  echo "  Sector size (logical/physical): 512 bytes / 512 bytes"
  echo "  I/O size (minimum/optimal): 512 bytes / 512 bytes"
  echo

  # STEP 2: Open /dev/nvme1 in fdisk
  echo "  Step 2: Open /dev/nvme1 with fdisk."
  read -p "  lab@rhel-lab461:~$ " cmd2
  echo
  if [[ "$cmd2" != "sudo fdisk /dev/nvme1" && "$cmd2" != "fdisk /dev/nvme1" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Welcome to fdisk (util-linux 2.39.3)."
  echo "  Changes will remain in memory only, until you decide to write them."
  echo "  Be careful before using the write command."
  echo
  echo "  Device does not contain a recognized partition table."
  echo "  Created a new DOS disklabel with disk identifier 0x6e5b1c2a."
  echo "  Command (m for help):"

  # fdisk interactive (nvme1)
  echo "  fdisk: Create a new partition."
  read -p "  Command (m for help): " fd1
  [[ "$fd1" != "n" ]] && { print_error "Expected 'n'."; read -p "Press Enter..." _; continue; }

  echo "  Partition type"
  echo "     p   primary (0 primary, 0 extended, 4 free)"
  echo "     e   extended (container for logical partitions)"
  echo "  Select (default p):"
  read -p "  " fd2
  [[ -n "$fd2" ]] && { print_error "Press Enter for default."; read -p "Press Enter..." _; continue; }

  echo "  Partition number (1-4, default 1):"
  read -p "  " fd3
  [[ -n "$fd3" ]] && { print_error "Press Enter for default."; read -p "Press Enter..." _; continue; }

  echo "  First sector (2048-10485759, default 2048):"
  read -p "  " fd4
  [[ -n "$fd4" ]] && { print_error "Press Enter for default."; read -p "Press Enter..." _; continue; }

  echo "  Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-10485759, default 10485759):"
  read -p "  " fd5
  [[ -n "$fd5" ]] && { print_error "Press Enter for default."; read -p "Press Enter..." _; continue; }

  echo "  Created a new partition 1 of type 'Linux' and of size 5 GiB."
  echo

  echo "  fdisk: Print partition table."
  read -p "  Command (m for help): " fd6
  [[ "$fd6" != "p" ]] && { print_error "Expected 'p'."; read -p "Press Enter..." _; continue; }
  echo
  echo "  Disk /dev/nvme1: 5 GiB, 5368709120 bytes, 10485760 sectors"
  echo "  Units: sectors of 1 * 512 = 512 bytes"
  echo "  Sector size (logical/physical): 512 bytes / 512 bytes"
  echo "  I/O size (minimum/optimal): 512 bytes / 512 bytes"
  echo "  Disklabel type: dos"
  echo "  Disk identifier: 0x6e5b1c2a"
  echo
  echo "  Device         Boot Start      End  Sectors Size Id Type"
  echo "  /dev/nvme1p1         2048 10485759 10483712   5G 83 Linux"
  echo

  echo "  fdisk: List partition types."
  read -p "  Command (m for help): " fd7
  [[ "$fd7" != "l" ]] && { print_error "Expected 'l'."; read -p "Press Enter..." _; continue; }
  echo
  echo "  8e  Linux LVM"
  echo

  echo "  fdisk: Change partition type."
  read -p "  Command (m for help): " fd8
  [[ "$fd8" != "t" ]] && { print_error "Expected 't'."; read -p "Press Enter..." _; continue; }

  echo "  Selected partition 1"
  echo "  Hex code or alias (type L to list all):"
  read -p "  " fd9
  [[ "$fd9" != "8e" ]] && { print_error "Expected '8e'."; read -p "Press Enter..." _; continue; }

  echo "  Changed type of partition 'Linux' to 'Linux LVM'."
  echo
  echo "  fdisk: Confirm change."
  read -p "  Command (m for help): " fd10
  [[ "$fd10" != "p" ]] && { print_error "Expected 'p'."; read -p "Press Enter..." _; continue; }
  echo
  echo "  Device         Boot Start      End  Sectors Size Id Type"
  echo "  /dev/nvme1p1         2048 10485759 10483712   5G 8e Linux LVM"
  echo

  echo "  fdisk: Write changes."
  read -p "  Command (m for help): " fd11
  [[ "$fd11" != "w" ]] && { print_error "Expected 'w'."; read -p "Press Enter..." _; continue; }
  echo
  echo "  The partition table has been altered."
  echo "  Calling ioctl() to re-read partition table."
  echo "  Syncing disks."
  echo

  # STEP 3: Install LVM tools
  echo "  Step 3: Install lvm2 package."
  read -p "  lab@rhel-lab461:~$ " cmd3
  echo
  if [[ "$cmd3" != "sudo dnf -y install lvm2" && "$cmd3" != "dnf -y install lvm2" ]]; then
    print_error "Incorrect."
    read -p "Press Enter..." _
    continue
  fi
  echo "  Last metadata expiration check: 0:00:31 ago on Thu 15 Jan 2026 10:12:07 PM UTC."
  echo "  Dependencies resolved."
  echo "  Nothing to do."
  echo "  Complete!"
  echo

  # STEP 4: Create Physical Volume (must use the partition)
  echo "  Step 4: Create a physical volume on /dev/nvme1p1."
  read -p "  lab@rhel-lab461:~$ " cmd4
  echo
  if [[ "$cmd4" != "sudo pvcreate /dev/nvme1p1" && "$cmd4" != "pvcreate /dev/nvme1p1" ]]; then
    print_error "Incorrect. Use the partition (/dev/nvme1p1)."
    read -p "Press Enter..." _
    continue
  fi
  echo "  Physical volume \"/dev/nvme1p1\" successfully created."
  echo

  echo "  Step 5: Verify physical volume."
  read -p "  lab@rhel-lab461:~$ " cmd5
  [[ "$cmd5" != "pvdisplay" && "$cmd5" != "sudo pvdisplay" ]] && { print_error "Incorrect."; read -p "Press Enter..." _; continue; }
  echo
  echo "  --- Physical volume ---"
  echo "  PV Name               /dev/nvme1p1"
  echo "  VG Name"
  echo "  PV Size               5.00 GiB / not usable 3.00 MiB"
  echo "  Allocatable           yes"
  echo "  PE Size               4.00 MiB"
  echo "  Total PE              1279"
  echo "  Free PE               1279"
  echo "  Allocated PE          0"
  echo "  PV UUID               0l0p8H-tVY1-2b0Z-7Y9w-nD5Z-u7QG-2m8XkZ"
  echo

  # STEP 6: Create Volume Group (use partition)
  echo "  Step 6: Create volume group vgdata."
  read -p "  lab@rhel-lab461:~$ " cmd6
  [[ "$cmd6" != "sudo vgcreate vgdata /dev/nvme1p1" && "$cmd6" != "vgcreate vgdata /dev/nvme1p1" ]] && { print_error "Incorrect."; read -p "Press Enter..." _; continue; }
  echo
  echo "  Volume group \"vgdata\" successfully created"
  echo

  echo "  Step 7: Verify volume group."
  read -p "  lab@rhel-lab461:~$ " cmd7
  [[ "$cmd7" != "vgdisplay" && "$cmd7" != "sudo vgdisplay" ]] && { print_error "Incorrect."; read -p "Press Enter..." _; continue; }
  echo
  echo "  --- Volume group ---"
  echo "  VG Name               vgdata"
  echo "  System ID"
  echo "  Format                lvm2"
  echo "  Metadata Areas        1"
  echo "  Metadata Sequence No  1"
  echo "  VG Access             read/write"
  echo "  VG Status             resizable"
  echo "  MAX LV                0"
  echo "  Cur LV                0"
  echo "  Open LV               0"
  echo "  Max PV                0"
  echo "  Cur PV                1"
  echo "  Act PV                1"
  echo "  VG Size               5.00 GiB"
  echo "  PE Size               4.00 MiB"
  echo "  Total PE              1279"
  echo "  Alloc PE / Size       0 / 0"
  echo "  Free  PE / Size       1279 / 5.00 GiB"
  echo "  VG UUID               rK3oQd-4cHf-Xv0m-Cb2e-wK8x-7mJp-kQ1nZ9"
  echo

  # STEP 8: Create Logical Volume (4G fits in VG)
  echo "  Step 8: Create a 4G logical volume named lvdata."
  read -p "  lab@rhel-lab461:~$ " cmd8
  [[ "$cmd8" != "sudo lvcreate -L 4G -n lvdata vgdata" && "$cmd8" != "lvcreate -L 4G -n lvdata vgdata" ]] && { print_error "Incorrect. Use -L 4G."; read -p "Press Enter..." _; continue; }
  echo
  echo "  Logical volume \"lvdata\" created."
  echo

  echo "  Step 9: Verify logical volume."
  read -p "  lab@rhel-lab461:~$ " cmd9
  [[ "$cmd9" != "lvdisplay" && "$cmd9" != "sudo lvdisplay" ]] && { print_error "Incorrect."; read -p "Press Enter..." _; continue; }
  echo
  echo "  --- Logical volume ---"
  echo "  LV Path                /dev/vgdata/lvdata"
  echo "  LV Name                lvdata"
  echo "  VG Name                vgdata"
  echo "  LV UUID                9NwqQe-2f1Y-Ak9p-3dQe-0c9V-Rb4k-2c6bHn"
  echo "  LV Write Access        read/write"
  echo "  LV Creation host, time rhel-lab461, 2026-01-15 22:14:52 +0000"
  echo "  LV Status              available"
  echo "  # open                 0"
  echo "  LV Size                4.00 GiB"
  echo "  Current LE             1024"
  echo "  Segments               1"
  echo "  Allocation             inherit"
  echo "  Read ahead sectors     auto"
  echo "  - currently set to     256"
  echo "  Block device           253:0"
  echo

  # STEP 10: Format and mount
  echo "  Step 10: Format the LV with XFS."
  read -p "  lab@rhel-lab461:~$ " cmd10
  [[ "$cmd10" != "sudo mkfs.xfs /dev/vgdata/lvdata" && "$cmd10" != "mkfs.xfs /dev/vgdata/lvdata" ]] && { print_error "Incorrect."; read -p "Press Enter..." _; continue; }
  echo
  echo "  meta-data=/dev/vgdata/lvdata   isize=512    agcount=4, agsize=262144 blks"
  echo "           =                       sectsz=512   attr=2, projid32bit=1"
  echo "           =                       crc=1        finobt=1, sparse=1, rmapbt=0"
  echo "           =                       reflink=1    bigtime=1 inobtcount=1"
  echo "  data     =                       bsize=4096   blocks=1048576, imaxpct=25"
  echo "           =                       sunit=0      swidth=0 blks"
  echo "  naming   =version 2              bsize=4096   ascii-ci=0, ftype=1"
  echo "  log      =internal log           bsize=4096   blocks=16384, version=2"
  echo "           =                       sectsz=512   sunit=0 blks, lazy-count=1"
  echo "  realtime =none                   extsz=4096   blocks=0, rtextents=0"
  echo

  echo "  Step 11: Create mount directory /lvdata."
  read -p "  lab@rhel-lab461:~$ " cmd11
  [[ "$cmd11" != "sudo mkdir /lvdata" && "$cmd11" != "mkdir /lvdata" ]] && { print_error "Incorrect."; read -p "Press Enter..." _; continue; }
  echo

  echo "  Step 12: Mount the logical volume."
  read -p "  lab@rhel-lab461:~$ " cmd12
  [[ "$cmd12" != "sudo mount /dev/vgdata/lvdata /lvdata" && "$cmd12" != "mount /dev/vgdata/lvdata /lvdata" ]] && { print_error "Incorrect."; read -p "Press Enter..." _; continue; }
  echo

  echo "  Step 13: Verify mount."
  read -p "  lab@rhel-lab461:~$ " cmd13
  [[ "$cmd13" != "df -h" && "$cmd13" != "sudo df -h" ]] && { print_error "Incorrect."; read -p "Press Enter..." _; continue; }
  echo
  echo "  Filesystem                 Size  Used Avail Use% Mounted on"
  echo "  /dev/nvme0n1p2              38G  6.2G   32G  17% /"
  echo "  /dev/nvme0n1p1             960M  228M  733M  24% /boot"
  echo "  /dev/mapper/vgdata-lvdata  4.0G   33M  4.0G   1% /lvdata"
  echo

  # STEP 14: Repeat fdisk on nvme2 (summarized but enforced)
  echo "  Step 14: Create an LVM partition on /dev/nvme2 (same fdisk steps as before)."
  read -p "  lab@rhel-lab461:~$ " cmd14
  [[ "$cmd14" != "sudo fdisk /dev/nvme2" && "$cmd14" != "fdisk /dev/nvme2" ]] && { print_error "Incorrect."; read -p "Press Enter..." _; continue; }
  echo
  echo "  Welcome to fdisk (util-linux 2.39.3)."
  echo "  Device does not contain a recognized partition table."
  echo "  Created a new DOS disklabel with disk identifier 0x41f2a9c0."
  echo "  (Partition created: /dev/nvme2p1 type 8e Linux LVM, written to disk)"
  echo

  echo "  Step 15: Create a physical volume on /dev/nvme2p1."
  read -p "  lab@rhel-lab461:~$ " cmd15a
  echo
  if [[ "$cmd15a" != "sudo pvcreate /dev/nvme2p1" && "$cmd15a" != "pvcreate /dev/nvme2p1" ]]; then
    print_error "Incorrect. You must pvcreate /dev/nvme2p1 before vgextend."
    read -p "Press Enter..." _
    continue
  fi
  echo "  Physical volume \"/dev/nvme2p1\" successfully created."
  echo

  # STEP 16: Extend VG (use partition)
  echo "  Step 16: Extend volume group with /dev/nvme2p1."
  read -p "  lab@rhel-lab461:~$ " cmd16
  echo
  [[ "$cmd16" != "sudo vgextend vgdata /dev/nvme2p1" && "$cmd16" != "vgextend vgdata /dev/nvme2p1" ]] && { print_error "Incorrect."; read -p "Press Enter..." _; continue; }
  echo "  Volume group \"vgdata\" successfully extended"
  echo

  # STEP 17: Extend LV (4G more -> total 8G)
  echo "  Step 17: Extend logical volume by 4G."
  read -p "  lab@rhel-lab461:~$ " cmd17
  echo
  [[ "$cmd17" != "sudo lvextend -L +4G /dev/vgdata/lvdata" && "$cmd17" != "lvextend -L +4G /dev/vgdata/lvdata" ]] && { print_error "Incorrect. Use -L +4G."; read -p "Press Enter..." _; continue; }
  echo "  Size of logical volume vgdata/lvdata changed from 4.00 GiB (1024 extents) to 8.00 GiB (2048 extents)."
  echo "  Logical volume vgdata/lvdata successfully resized."
  echo

  # STEP 18: Grow filesystem
  echo "  Step 18: Extend the XFS filesystem mounted at /lvdata."
  read -p "  lab@rhel-lab461:~$ " cmd18
  echo
  [[ "$cmd18" != "sudo xfs_growfs /lvdata" && "$cmd18" != "xfs_growfs /lvdata" ]] && { print_error "Incorrect."; read -p "Press Enter..." _; continue; }
  echo "  meta-data=/dev/mapper/vgdata-lvdata isize=512    agcount=4, agsize=262144 blks"
  echo "  data     =                       bsize=4096   blocks=2097152, imaxpct=25"
  echo "  naming   =version 2              bsize=4096   ascii-ci=0, ftype=1"
  echo "  log      =internal log           bsize=4096   blocks=16384, version=2"
  echo "  realtime =none                   extsz=4096   blocks=0, rtextents=0"
  echo

  # STEP 19: Final verification
  echo "  Step 19: Final verification."
  read -p "  lab@rhel-lab461:~$ " cmd19
  echo
  [[ "$cmd19" != "df -h" && "$cmd19" != "sudo df -h" ]] && { print_error "Incorrect."; read -p "Press Enter..." _; continue; }
  echo
  echo "  Filesystem                 Size  Used Avail Use% Mounted on"
  echo "  /dev/nvme0n1p2              38G  6.2G   32G  17% /"
  echo "  /dev/nvme0n1p1             960M  228M  733M  24% /boot"
  echo "  /dev/mapper/vgdata-lvdata  8.0G   40M  8.0G   1% /lvdata"
  echo

  print_success "Outstanding work."
  print_info "You successfully:"
  print_info "- created LVM partitions using fdisk with type 8e"
  print_info "- built PV → VG → LV"
  print_info "- formatted and mounted the logical volume"
  print_info "- extended the VG, LV, and filesystem using a second disk"
  print_info "You earned $LAB_XP XP."
  award_xp $LAB_XP

  XP=$(jq '.XP' "$SAVE_JSON")
  LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
  export XP
  export LEVEL
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
