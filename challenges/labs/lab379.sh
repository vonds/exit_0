#!/bin/bash

# Lab 379: RHEL Troubleshooting — Recover From Accidental 'mkfs' on Wrong Partition (Partial Recovery)
# Focus: responding to an accidental filesystem format on the wrong partition, minimizing further damage,
# creating a forensic image, and attempting partial file recovery via file carving.
# Key skills: lsblk -f, mount, umount, dmesg (optional), dd (image backup), dnf, testdisk/photorec,
# triage workflow, and safe verification.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 379: Recover From Accidental mkfs (Partial Recovery)"
LAB_ID="lab379"
LAB_XP=37900
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
  center_text "A teammate ran 'mkfs' on the wrong partition: /dev/vdb1."
  center_text "That partition used to be mounted at /data and contained files."
  center_text "You must respond safely: stop writes, image the device, and attempt partial recovery."
  echo
  center_text "Goal: minimize damage, create an image, and carve recoverable files into /root/recover379."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Identify the affected partition and filesystem state
  echo "  Step 1: Identify the affected partition and confirm its current filesystem type."
  read -p "  lab@rhel-lab379:~$ " cmd1
  echo
  if [[ "$cmd1" != "lsblk -f" && \
        "$cmd1" != "sudo lsblk -f" && \
        "$cmd1" != "lsblk --fs" && \
        "$cmd1" != "sudo lsblk --fs" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  NAME   FSTYPE FSVER LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINTS"
  echo "  vda"
  echo "  ├─vda1 xfs          root  11111111-2222-3333-4444-aaaaaaaaaaaa    18G    35% /"
  echo "  └─vda2 swap         swap  bbbbbbbb-cccc-dddd-eeee-ffffffffffff                [SWAP]"
  echo "  vdb"
  echo "  └─vdb1 ext4   1.0         99999999-8888-7777-6666-555555555555"
  echo

  # STEP 2: Ensure the device is not mounted (stop writes)
  echo "  Step 2: Ensure /dev/vdb1 is not mounted (stop further writes)."
  read -p "  lab@rhel-lab379:~$ " cmd2
  echo
  if [[ "$cmd2" != "mount | grep vdb1" && \
        "$cmd2" != "sudo mount | grep vdb1" && \
        "$cmd2" != "findmnt /dev/vdb1" && \
        "$cmd2" != "sudo findmnt /dev/vdb1" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd2" == *"grep vdb1"* ]]; then
    echo "  /dev/vdb1 on /data type ext4 (rw,relatime,seclabel)"
  else
    echo "  TARGET SOURCE    FSTYPE OPTIONS"
    echo "  /data  /dev/vdb1 ext4   rw,relatime,seclabel"
  fi
  echo

  # STEP 3: Unmount immediately
  echo "  Step 3: Unmount /data immediately."
  read -p "  lab@rhel-lab379:~$ " cmd3
  echo
  if [[ "$cmd3" != "sudo umount /data" && \
        "$cmd3" != "umount /data" && \
        "$cmd3" != "sudo umount /dev/vdb1" && \
        "$cmd3" != "umount /dev/vdb1" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 4: Verify it is unmounted
  echo "  Step 4: Verify /dev/vdb1 is no longer mounted."
  read -p "  lab@rhel-lab379:~$ " cmd4
  echo
  if [[ "$cmd4" != "mount | grep vdb1" && \
        "$cmd4" != "sudo mount | grep vdb1" && \
        "$cmd4" != "findmnt /dev/vdb1" && \
        "$cmd4" != "sudo findmnt /dev/vdb1" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd4" == *"grep vdb1"* ]]; then
    echo "  (no output)"
  else
    echo "  (no output)"
  fi
  echo

  # STEP 5: Create a forensic image backup before attempting recovery
  echo "  Step 5: Create a forensic image of /dev/vdb1 at /root/vdb1_lab379.img."
  read -p "  lab@rhel-lab379:~$ " cmd5
  echo
  if [[ "$cmd5" != "sudo dd if=/dev/vdb1 of=/root/vdb1_lab379.img bs=64K status=progress" && \
        "$cmd5" != "dd if=/dev/vdb1 of=/root/vdb1_lab379.img bs=64K status=progress" && \
        "$cmd5" != "sudo dd if=/dev/vdb1 of=/root/vdb1_lab379.img bs=1M status=progress" && \
        "$cmd5" != "dd if=/dev/vdb1 of=/root/vdb1_lab379.img bs=1M status=progress" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  67108864 bytes (67 MB, 64 MiB) copied, 0.14 s, 479 MB/s"
  echo "  1073741824 bytes (1.1 GB, 1.0 GiB) copied, 2.21 s, 486 MB/s"
  echo "  2147483648 bytes (2.1 GB, 2.0 GiB) copied, 4.43 s, 485 MB/s"
  echo "  4294967296 bytes (4.3 GB, 4.0 GiB) copied, 8.88 s, 484 MB/s"
  echo "  4294967296 bytes (4.3 GB, 4.0 GiB) copied, 8.89 s, 483 MB/s"
  echo

  # STEP 6: Install recovery tooling (photorec is in the testdisk package)
  echo "  Step 6: Install recovery tooling (testdisk/photorec)."
  read -p "  lab@rhel-lab379:~$ " cmd6
  echo
  if [[ "$cmd6" != "sudo dnf -y install testdisk" && \
        "$cmd6" != "dnf -y install testdisk" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Last metadata expiration check: 0:03:12 ago on Mon Jan 12 2026."
  echo "  Dependencies resolved."
  echo "  Installing:"
  echo "   testdisk               x86_64        7.1-XX.el9         appstream        600 k"
  echo "  Installing dependencies:"
  echo "   (photorec provided by testdisk)"
  echo "  Complete!"
  echo

  # STEP 7: Prepare an output directory for recovered files
  echo "  Step 7: Create the recovery output directory at /root/recover379."
  read -p "  lab@rhel-lab379:~$ " cmd7
  echo
  if [[ "$cmd7" != "sudo mkdir -p /root/recover379" && \
        "$cmd7" != "mkdir -p /root/recover379" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 8: Run photorec against the IMAGE (not the live device)
  echo "  Step 8: Run photorec against /root/vdb1_lab379.img to attempt partial recovery."
  read -p "  lab@rhel-lab379:~$ " cmd8
  echo
  if [[ "$cmd8" != "sudo photorec /root/vdb1_lab379.img" && \
        "$cmd8" != "photorec /root/vdb1_lab379.img" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  PhotoRec 7.1, Data Recovery Utility, January 2026"
  echo "  (interactive UI opened)"
  echo "  (selected destination directory: /root/recover379)"
  echo "  (carving started...)"
  echo "  (carving finished: some files recovered, names may be generic)"
  echo

  # STEP 9: Verify recovered output exists
  echo "  Step 9: Verify recovered files exist under /root/recover379."
  read -p "  lab@rhel-lab379:~$ " cmd9
  echo
  if [[ "$cmd9" != "ls -l /root/recover379" && \
        "$cmd9" != "sudo ls -l /root/recover379" && \
        "$cmd9" != "find /root/recover379 -maxdepth 2 -type f | head" && \
        "$cmd9" != "sudo find /root/recover379 -maxdepth 2 -type f | head" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd9" == "ls -l /root/recover379" || "$cmd9" == "sudo ls -l /root/recover379" ]]; then
    echo "  total 0"
    echo "  drwxr-xr-x. 2 root root 4096 Jan 12 18:42 recup_dir.1"
    echo "  drwxr-xr-x. 2 root root 4096 Jan 12 18:42 recup_dir.2"
  else
    echo "  /root/recover379/recup_dir.1/f0000123.pdf"
    echo "  /root/recover379/recup_dir.1/f0000199.jpg"
    echo "  /root/recover379/recup_dir.1/f0000201.txt"
    echo "  /root/recover379/recup_dir.2/f0000007.zip"
    echo "  /root/recover379/recup_dir.2/f0000042.png"
  fi
  echo

  print_success "Great job."
  print_info "You handled an accidental mkfs incident safely and attempted partial recovery:"
  print_info "- confirmed the impacted device and stopped further writes (unmounted)"
  print_info "- created a forensic image before doing anything destructive"
  print_info "- used photorec against the IMAGE (not the live partition) to carve recoverable files"
  print_info "- verified recovered output in /root/recover379"
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
