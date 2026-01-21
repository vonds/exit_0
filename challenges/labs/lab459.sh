#!/bin/bash

# Lab 459: RHEL Storage Security — Encrypt a Disk with LUKS and Persist It
# Focus: encrypting a block device using LUKS, unlocking it, creating a filesystem,
# mounting it, and ensuring persistence across reboots.
# Key skills: lsblk, cryptsetup luksFormat/open, mkfs.xfs, mount,
# /etc/crypttab, /etc/fstab, systemctl daemon-reload, verification workflow.
# Disk used in this lab: /dev/nvme1 (5GiB, unused)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 459: Encrypt a Disk with LUKS"
LAB_ID="lab459"
LAB_XP=45900
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
  center_text "A new disk must be protected using full-disk encryption."
  center_text "Policy:"
  center_text "- Disk: /dev/nvme1"
  center_text "- Encryption: LUKS"
  center_text "- Mapper name: crypt459"
  center_text "- Filesystem: XFS"
  center_text "- Mount point: /secure459"
  echo
  center_text "Goal: encrypt the disk, unlock it, format it, mount it,"
  center_text "and configure it to unlock and mount automatically at boot."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Verify disk is unused
  echo "  Step 1: Verify /dev/nvme1 exists and is not mounted."
  read -p "  lab@rhel-lab459:~$ " cmd1
  echo
  if [[ "$cmd1" != "lsblk" && "$cmd1" != "sudo lsblk" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS"
  echo "  nvme0n1     259:0    0   30G  0 disk"
  echo "  ├─nvme0n1p1 259:1    0  600M  0 part /boot/efi"
  echo "  ├─nvme0n1p2 259:2    0    1G  0 part /boot"
  echo "  └─nvme0n1p3 259:3    0 28.4G  0 part"
  echo "    ├─rhel-root 253:0  0   12G  0 lvm  /"
  echo "    ├─rhel-swap 253:1  0    2G  0 lvm  [SWAP]"
  echo "    └─rhel-home 253:2  0 14.4G  0 lvm  /home"
  echo "  nvme1n1     259:4    0    5G  0 disk"
  echo

  # STEP 2: Initialize LUKS encryption
  echo "  Step 2: Encrypt /dev/nvme1n1 using LUKS."
  read -p "  lab@rhel-lab459:~$ " cmd2
  echo
  if [[ "$cmd2" != "sudo cryptsetup luksFormat /dev/nvme1n1" && \
        "$cmd2" != "cryptsetup luksFormat /dev/nvme1n1" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  WARNING!"
  echo "  ========"
  echo "  This will overwrite data on /dev/nvme1n1 irrevocably."
  echo
  echo -n "  Are you sure? (Type 'yes' in uppercase): "
  echo "YES"
  echo -n "  Enter passphrase for /dev/nvme1n1: "
  echo
  echo -n "  Verify passphrase: "
  echo
  echo

  # STEP 3: Open encrypted device
  echo "  Step 3: Open the encrypted device as crypt459."
  read -p "  lab@rhel-lab459:~$ " cmd3
  echo
  if [[ "$cmd3" != "sudo cryptsetup open /dev/nvme1n1 crypt459" && \
        "$cmd3" != "cryptsetup open /dev/nvme1n1 crypt459" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo -n "  Enter passphrase for /dev/nvme1n1: "
  echo
  echo

  # STEP 4: Verify mapper device exists
  echo "  Step 4: Verify the mapped device exists."
  read -p "  lab@rhel-lab459:~$ " cmd4
  echo
  if [[ "$cmd4" != "lsblk" && "$cmd4" != "sudo lsblk" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  NAME        MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINTS"
  echo "  nvme1n1     259:4    0    5G  0 disk"
  echo "  └─crypt459  253:3    0    5G  0 crypt"
  echo

  # STEP 5: Create filesystem on encrypted device
  echo "  Step 5: Create an XFS filesystem on /dev/mapper/crypt459."
  read -p "  lab@rhel-lab459:~$ " cmd5
  echo
  if [[ "$cmd5" != "sudo mkfs.xfs /dev/mapper/crypt459" && \
        "$cmd5" != "mkfs.xfs /dev/mapper/crypt459" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  meta-data=/dev/mapper/crypt459 isize=512    agcount=4, agsize=327616 blks"
  echo "           =                       sectsz=512   attr=2, projid32bit=1"
  echo "           =                       crc=1        finobt=1, sparse=1, rmapbt=0"
  echo "           =                       reflink=1    bigtime=1 inobtcount=1"
  echo "  data     =                       bsize=4096   blocks=1310720, imaxpct=25"
  echo "           =                       sunit=0      swidth=0 blks"
  echo "  naming   =version 2              bsize=4096   ascii-ci=0, ftype=1"
  echo "  log      =internal log           bsize=4096   blocks=6400, version=2"
  echo "           =                       sectsz=512   sunit=0 blks, lazy-count=1"
  echo "  realtime =none                   extsz=4096   blocks=0, rtextents=0"
  echo

  # STEP 6: Create mount point
  echo "  Step 6: Create mount point /secure459."
  read -p "  lab@rhel-lab459:~$ " cmd6
  echo
  if [[ "$cmd6" != "sudo mkdir -p /secure459" && \
        "$cmd6" != "mkdir -p /secure459" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  # mkdir is silent on success.

  # STEP 7: Mount encrypted filesystem
  echo "  Step 7: Mount the encrypted filesystem."
  read -p "  lab@rhel-lab459:~$ " cmd7
  echo
  if [[ "$cmd7" != "sudo mount /dev/mapper/crypt459 /secure459" && \
        "$cmd7" != "mount /dev/mapper/crypt459 /secure459" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  # mount is silent on success.

  # STEP 8: Verify mount
  echo "  Step 8: Verify the filesystem is mounted."
  read -p "  lab@rhel-lab459:~$ " cmd8
  echo
  if [[ "$cmd8" != "df -h | grep secure459" && \
        "$cmd8" != "mount | grep secure459" && \
        "$cmd8" != "findmnt /secure459" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  if [[ "$cmd8" == "findmnt /secure459" ]]; then
    echo "  TARGET     SOURCE              FSTYPE OPTIONS"
    echo "  /secure459 /dev/mapper/crypt459 xfs    rw,relatime,seclabel,attr2,inode64,logbufs=8,logbsize=32k,noquota"
  elif [[ "$cmd8" == "mount | grep secure459" ]]; then
    echo "  /dev/mapper/crypt459 on /secure459 type xfs (rw,relatime,seclabel,attr2,inode64,logbufs=8,logbsize=32k,noquota)"
  else
    echo "  /dev/mapper/crypt459  5.0G   47M  5.0G   1% /secure459"
  fi
  echo

  # STEP 9: Configure /etc/crypttab
  echo "  Step 9: Configure /etc/crypttab for persistent unlock (use the LUKS UUID)."
  read -p "  lab@rhel-lab459:~$ " cmd9
  echo
  if [[ "$cmd9" != "sudo vim /etc/crypttab" && \
        "$cmd9" != "sudo nano /etc/crypttab" && \
        "$cmd9" != "sudoedit /etc/crypttab" && \
        "$cmd9" != "sudo vi /etc/crypttab" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (added line)"
  echo "  crypt459  UUID=3b0f1d2a-9d8a-4d5a-9e3f-3d2e8a7c1b55  none  luks"
  echo

  # STEP 10: Configure /etc/fstab
  echo "  Step 10: Configure /etc/fstab to mount the decrypted mapper device."
  read -p "  lab@rhel-lab459:~$ " cmd10
  echo
  if [[ "$cmd10" != "sudo vim /etc/fstab" && \
        "$cmd10" != "sudo nano /etc/fstab" && \
        "$cmd10" != "sudoedit /etc/fstab" && \
        "$cmd10" != "sudo vi /etc/fstab" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (added line)"
  echo "  /dev/mapper/crypt459  /secure459  xfs  defaults  0  0"
  echo

  # STEP 11: Reload systemd + test mounts
  echo "  Step 11: Reload systemd units and test mounting without rebooting."
  read -p "  lab@rhel-lab459:~$ " cmd11
  echo
  if [[ "$cmd11" != "sudo systemctl daemon-reload" && \
        "$cmd11" != "systemctl daemon-reload" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  # daemon-reload is silent on success.

  echo "  Step 12: Test the fstab entry now."
  read -p "  lab@rhel-lab459:~$ " cmd12
  echo
  if [[ "$cmd12" != "sudo mount -a" && \
        "$cmd12" != "mount -a" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  # mount -a is silent on success when no errors.

  echo "  Step 13: Verify the mount is still present."
  read -p "  lab@rhel-lab459:~$ " cmd13
  echo
  if [[ "$cmd13" != "findmnt /secure459" && \
        "$cmd13" != "df -h /secure459" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  if [[ "$cmd13" == "findmnt /secure459" ]]; then
    echo "  TARGET     SOURCE              FSTYPE OPTIONS"
    echo "  /secure459 /dev/mapper/crypt459 xfs    rw,relatime,seclabel,attr2,inode64,logbufs=8,logbsize=32k,noquota"
  else
    echo "  Filesystem              Size  Used Avail Use% Mounted on"
    echo "  /dev/mapper/crypt459    5.0G   47M  5.0G   1% /secure459"
  fi
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- encrypted a disk using LUKS"
  print_info "- unlocked it with cryptsetup"
  print_info "- created and mounted an XFS filesystem on the encrypted device"
  print_info "- configured /etc/crypttab (UUID-based) and /etc/fstab for persistence"
  print_info "- reloaded systemd and validated mounts without reboot"
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
