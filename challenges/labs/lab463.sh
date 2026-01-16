#!/bin/bash

# Lab 463: RHEL Storage Polish — UUID-based Mounts + Recovery (Broken fstab + Failed Encrypted Mount)
# Focus: replacing device-path mounts with UUID= in /etc/fstab, safely validating mounts, and
# recovering from two common storage failures: a broken /etc/fstab entry and a failed LUKS mount.
# Key skills: lsblk -f, blkid, findmnt, df -h, /etc/fstab, mount -a, journalctl (optional),
# cryptsetup luksOpen, /etc/crypttab, systemctl daemon-reload, safe troubleshooting workflow.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 463: UUID Mounts + Recovery (fstab + LUKS)"
LAB_ID="lab463"
LAB_XP=46300
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
  center_text "You inherited a system with risky device-path mounts in /etc/fstab."
  center_text "You must convert mounts to UUID= form, then recover from two real failures:"
  center_text "1) /etc/fstab has a broken entry that causes mount -a to fail."
  center_text "2) An encrypted volume fails to mount because the mapper device isn't open."
  echo
  center_text "Policy:"
  center_text "- Data mount: /data463 (XFS) currently uses /dev/nvme1p1"
  center_text "- Encrypted mount: /secure463 uses /dev/mapper/crypt463 (LUKS on /dev/nvme2)"
  echo
  center_text "Goal: use UUID= in /etc/fstab, fix broken fstab safely, and recover failed LUKS mount."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Identify mounts and filesystems
  echo "  Step 1: Inspect filesystems and UUIDs (you'll need UUID= values)."
  read -p "  lab@rhel-lab463:~$ " cmd1
  echo
  if [[ "$cmd1" != "lsblk -f" && \
        "$cmd1" != "sudo lsblk -f" && \
        "$cmd1" != "blkid" && \
        "$cmd1" != "sudo blkid" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  echo "  NAME        FSTYPE      UUID                                 MOUNTPOINT"
  echo "  nvme1p1     xfs         11111111-2222-3333-4444-aaaaaaaaaaaa  /data463"
  echo "  nvme2       crypto_LUKS 55555555-6666-7777-8888-bbbbbbbbbbbb"
  echo "  └─crypt463  xfs         99999999-aaaa-bbbb-cccc-cccccccccccc  /secure463"
  echo

  # STEP 2: Show current /etc/fstab state (simulate risky device paths)
  echo "  Step 2: View /etc/fstab (confirm device-path entries exist)."
  read -p "  lab@rhel-lab463:~$ " cmd2
  echo
  if [[ "$cmd2" != "sudo cat /etc/fstab" && \
        "$cmd2" != "cat /etc/fstab" && \
        "$cmd2" != "sudo less /etc/fstab" && \
        "$cmd2" != "less /etc/fstab" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  # /etc/fstab"
  echo "  /dev/nvme1p1              /data463     xfs   defaults        0 0"
  echo "  /dev/mapper/crypt463      /secure463   xfs   defaults        0 0"
  echo

  # STEP 3: Convert /data463 mount to UUID= in /etc/fstab
  echo "  Step 3: Edit /etc/fstab and replace /dev/nvme1p1 with UUID= for /data463."
  read -p "  lab@rhel-lab463:~$ " cmd3
  echo
  if [[ "$cmd3" != "sudo vim /etc/fstab" && \
        "$cmd3" != "sudo nano /etc/fstab" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (editor opened)"
  echo "  (updated line to UUID=...)"
  echo "  UUID=11111111-2222-3333-4444-aaaaaaaaaaaa  /data463  xfs  defaults  0 0"
  echo "  (saved and exited)"
  echo

  # STEP 4: Validate fstab safely with mount -a (no reboot)
  echo "  Step 4: Validate /etc/fstab safely."
  read -p "  lab@rhel-lab463:~$ " cmd4
  echo
  if [[ "$cmd4" != "sudo mount -a" && \
        "$cmd4" != "mount -a" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  # STEP 5: Verify /data463 still mounted correctly
  echo "  Step 5: Verify /data463 is mounted correctly."
  read -p "  lab@rhel-lab463:~$ " cmd5
  echo
  if [[ "$cmd5" != "findmnt /data463" && \
        "$cmd5" != "df -h | grep data463" && \
        "$cmd5" != "mount | grep data463" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  TARGET   SOURCE                                      FSTYPE OPTIONS"
  echo "  /data463 UUID=11111111-2222-3333-4444-aaaaaaaaaaaa  xfs    rw,relatime,seclabel"
  echo

  # --- Recovery Scenario 1: Broken fstab ---
  # STEP 6: Simulate a broken fstab entry detection via mount -a failure
  echo "  Step 6: Recovery: mount -a fails due to a broken /etc/fstab entry."
  read -p "  lab@rhel-lab463:~$ " cmd6
  echo
  if [[ "$cmd6" != "sudo mount -a" && "$cmd6" != "mount -a" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  mount: /broken463: special device /dev/nvme9p9 does not exist."
  echo "  mount: (hint) you may have a bad /etc/fstab entry."
  echo

  # STEP 7: Locate the bad line by inspecting /etc/fstab
  echo "  Step 7: Open /etc/fstab and locate the broken entry."
  read -p "  lab@rhel-lab463:~$ " cmd7
  echo
  if [[ "$cmd7" != "sudo vim /etc/fstab" && \
        "$cmd7" != "sudo nano /etc/fstab" && \
        "$cmd7" != "sudo cat /etc/fstab" && \
        "$cmd7" != "cat /etc/fstab" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (found bad line)"
  echo "  /dev/nvme9p9   /broken463   xfs   defaults   0 0"
  echo

  # STEP 8: Fix the broken fstab entry by commenting it out
  echo "  Step 8: Fix it safely by commenting out the bad line (prefix with #)."
  read -p "  lab@rhel-lab463:~$ " cmd8
  echo
  if [[ "$cmd8" != "sudo vim /etc/fstab" && \
        "$cmd8" != "sudo nano /etc/fstab" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (commented out bad line)"
  echo "  #/dev/nvme9p9  /broken463   xfs   defaults   0 0"
  echo "  (saved and exited)"
  echo

  # STEP 9: Re-run mount -a to confirm fstab is now clean
  echo "  Step 9: Confirm the issue is resolved."
  read -p "  lab@rhel-lab463:~$ " cmd9
  echo
  if [[ "$cmd9" != "sudo mount -a" && "$cmd9" != "mount -a" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  # --- Recovery Scenario 2: Failed encrypted mount ---
  # STEP 10: Simulate encrypted mount failing because mapper is not open
  echo "  Step 10: Recovery: Encrypted mount fails because /dev/mapper/crypt463 is not open."
  echo "  Attempt to mount /secure463 to see the failure."
  read -p "  lab@rhel-lab463:~$ " cmd10
  echo
  if [[ "$cmd10" != "sudo mount /secure463" && \
        "$cmd10" != "mount /secure463" && \
        "$cmd10" != "sudo mount -a" && \
        "$cmd10" != "mount -a" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  mount: /secure463: special device /dev/mapper/crypt463 does not exist."
  echo

  # STEP 11: Confirm mapper device is missing
  echo "  Step 11: Confirm /dev/mapper/crypt463 is missing."
  read -p "  lab@rhel-lab463:~$ " cmd11
  echo
  if [[ "$cmd11" != "lsblk" && \
        "$cmd11" != "sudo lsblk" && \
        "$cmd11" != "ls /dev/mapper" && \
        "$cmd11" != "sudo ls /dev/mapper" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (crypt463 not present)"
  echo

  # STEP 12: Open the LUKS device (recover by unlocking it)
  echo "  Step 12: Unlock the encrypted device (open /dev/nvme2 as crypt463)."
  read -p "  lab@rhel-lab463:~$ " cmd12
  echo
  if [[ "$cmd12" != "sudo cryptsetup open /dev/nvme2 crypt463" && \
        "$cmd12" != "cryptsetup open /dev/nvme2 crypt463" && \
        "$cmd12" != "sudo cryptsetup luksOpen /dev/nvme2 crypt463" && \
        "$cmd12" != "cryptsetup luksOpen /dev/nvme2 crypt463" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Enter passphrase for /dev/nvme2:"
  echo

  # STEP 13: Mount again (or mount -a)
  echo "  Step 13: Mount the encrypted filesystem now that the mapper exists."
  read -p "  lab@rhel-lab463:~$ " cmd13
  echo
  if [[ "$cmd13" != "sudo mount /secure463" && \
        "$cmd13" != "mount /secure463" && \
        "$cmd13" != "sudo mount -a" && \
        "$cmd13" != "mount -a" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  # STEP 14: Verify encrypted mount is present
  echo "  Step 14: Verify /secure463 is mounted."
  read -p "  lab@rhel-lab463:~$ " cmd14
  echo
  if [[ "$cmd14" != "findmnt /secure463" && \
        "$cmd14" != "df -h | grep secure463" && \
        "$cmd14" != "mount | grep secure463" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  /dev/mapper/crypt463   5.0G   33M  5.0G   1% /secure463"
  echo

  # STEP 15: Optional polish—ensure crypttab exists for boot-time unlock
  echo "  Step 15: Ensure /etc/crypttab contains an entry for crypt463 (boot-time unlock)."
  read -p "  lab@rhel-lab463:~$ " cmd15
  echo
  if [[ "$cmd15" != "sudo cat /etc/crypttab" && \
        "$cmd15" != "cat /etc/crypttab" && \
        "$cmd15" != "sudo vim /etc/crypttab" && \
        "$cmd15" != "sudo nano /etc/crypttab" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  crypt463  UUID=55555555-6666-7777-8888-bbbbbbbbbbbb  none  luks"
  echo

  print_success "Excellent work."
  print_info "You completed RHCSA-level storage polish and recovery:"
  print_info "- migrated a mount to UUID= form in /etc/fstab and validated with mount -a"
  print_info "- recovered from a broken /etc/fstab entry safely (no reboot required)"
  print_info "- recovered from a failed encrypted mount by opening the LUKS device and remounting"
  print_info "- confirmed crypttab entry format (UUID= for LUKS device is exam-relevant)"
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
