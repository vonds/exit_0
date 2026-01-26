#!/bin/bash

# Lab 382: Diagnose Slow I/O on One Filesystem (/var)
# Focus: Prove a slow-write symptom, identify the specific filesystem affected,
#        inspect mount options, trace the root cause to /etc/fstab,
#        fix the misconfiguration safely, remount, and validate improvement.
#
# RHCSA Objective (related):
# - Locate and interpret system log files and journals (for troubleshooting)
# - Manage storage and mounts (fstab, mount options)
#
# Key skills validated:
# - Measure write performance with a simple dd test
# - Identify the backing device and mount options for a filesystem (findmnt)
# - Inspect /etc/fstab entries for a specific mount
# - Correct an fstab entry and safely remount without rebooting
# - Validate improvement with a repeatable test
#
# Difficulty: Intermediate
# XP: 38200

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 382: Diagnose Slow I/O on /var"
LAB_ID="lab382"
LAB_XP=38200
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab382:~$ "

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
  center_text "Users report that package installs and log writes are painfully slow."
  center_text "The problem appears isolated to ONE filesystem: /var."
  center_text "You must diagnose the cause, fix it safely, and verify improvement."
  echo
  center_text "Constraints:"
  center_text "- No reboot"
  center_text "- Non-destructive changes only"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  # STEP 1: Prove slow writes on /var with a simple dd test
  echo "  Step 1: Run a quick write test to /var/tmp to confirm the slow I/O symptom."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "dd if=/dev/zero of=/var/tmp/io.test bs=1M count=256 conv=fdatasync" && \
        "$cmd1" != "sudo dd if=/dev/zero of=/var/tmp/io.test bs=1M count=256 conv=fdatasync" ]]; then
    print_error "Incorrect. Use: dd if=/dev/zero of=/var/tmp/io.test bs=1M count=256 conv=fdatasync"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  256+0 records in"
  echo "  256+0 records out"
  echo "  268435456 bytes (268 MB, 256 MiB) copied, 21.4823 s, 12.5 MB/s"
  echo

  # STEP 2: Identify what device backs /var and inspect mount options
  echo "  Step 2: Inspect the mount source and options for /var."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "findmnt /var" && "$cmd2" != "sudo findmnt /var" ]]; then
    print_error "Incorrect. Use: findmnt /var"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  TARGET SOURCE              FSTYPE OPTIONS"
  echo "  /var   /dev/vg0/var        xfs    rw,relatime,seclabel,attr2,inode64,logbufs=8,logbsize=32k,sync"
  echo

  # STEP 3: Confirm that /var is uniquely affected (compare with /)
  echo "  Step 3: Compare mount options on / (root) to confirm /var is the outlier."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "findmnt /" && "$cmd3" != "sudo findmnt /" ]]; then
    print_error "Incorrect. Use: findmnt /"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  TARGET SOURCE              FSTYPE OPTIONS"
  echo "  /      /dev/vg0/root       xfs    rw,relatime,seclabel,attr2,inode64,logbufs=8,logbsize=32k"
  echo

  # STEP 4: Locate the /var entry in /etc/fstab
  echo "  Step 4: Locate the /var mount entry in /etc/fstab."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "grep -w /var /etc/fstab" && "$cmd4" != "sudo grep -w /var /etc/fstab" ]]; then
    print_error "Incorrect. Use: grep -w /var /etc/fstab"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  UUID=7b7b7b7b-1111-2222-3333-444444444444  /var  xfs  defaults,sync  0  0"
  echo

  # STEP 5: Edit /etc/fstab
  echo "  Step 5: Open /etc/fstab for editing."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo vim /etc/fstab" && "$cmd5" != "vim /etc/fstab" ]]; then
    print_error "Incorrect. Use: sudo vim /etc/fstab"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (editor opened)"
  echo

  # STEP 6: User must type the corrected fstab line (remove sync)
  echo "  Step 6: Type the corrected /var line (remove the sync option)."
  read -p "  fstab> " fstab_line
  echo
  if [[ "$fstab_line" != "UUID=7b7b7b7b-1111-2222-3333-444444444444  /var  xfs  defaults  0  0" ]]; then
    print_error "Incorrect fstab line."
    print_info "Expected:"
    echo "  UUID=7b7b7b7b-1111-2222-3333-444444444444  /var  xfs  defaults  0  0"
    echo
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (line entered into /etc/fstab)"
  echo "  (file saved and closed)"
  echo

  # STEP 7: Remount /var safely without reboot
  echo "  Step 7: Remount /var so the corrected options take effect (no reboot)."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo mount -o remount /var" && "$cmd7" != "mount -o remount /var" ]]; then
    print_error "Incorrect. Use: sudo mount -o remount /var"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (remounted /var)"
  echo

  # STEP 8: Verify sync is gone
  echo "  Step 8: Verify /var mount options no longer include sync."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "findmnt /var" && "$cmd8" != "sudo findmnt /var" ]]; then
    print_error "Incorrect. Use: findmnt /var"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  TARGET SOURCE              FSTYPE OPTIONS"
  echo "  /var   /dev/vg0/var        xfs    rw,relatime,seclabel,attr2,inode64,logbufs=8,logbsize=32k"
  echo

  # STEP 9: Re-run the same dd test to validate improvement
  echo "  Step 9: Re-run the same write test to validate performance improved."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "dd if=/dev/zero of=/var/tmp/io.test bs=1M count=256 conv=fdatasync" && \
        "$cmd9" != "sudo dd if=/dev/zero of=/var/tmp/io.test bs=1M count=256 conv=fdatasync" ]]; then
    print_error "Incorrect. Use: dd if=/dev/zero of=/var/tmp/io.test bs=1M count=256 conv=fdatasync"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  256+0 records in"
  echo "  256+0 records out"
  echo "  268435456 bytes (268 MB, 256 MiB) copied, 2.1031 s, 128 MB/s"
  echo

  # STEP 10: Cleanup test file
  echo "  Step 10: Remove the test file you created."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "rm -f /var/tmp/io.test" && "$cmd10" != "sudo rm -f /var/tmp/io.test" ]]; then
    print_error "Incorrect. Use: rm -f /var/tmp/io.test"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (file removed)"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- proved the slow I/O symptom with a repeatable test"
  print_info "- isolated the issue to /var"
  print_info "- identified a bad mount option (sync) as the root cause"
  print_info "- corrected /etc/fstab and remounted safely (no reboot)"
  print_info "- validated the performance improvement"
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
