#!/bin/bash

# Lab 383: Verify Ownership and Permissions After a Mount Change

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 383: Verify Ownership/Permissions After Mount Change"
LAB_ID="lab383"
LAB_XP=38300
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab383:~$ "

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
  center_text "A mount change was made on /mnt/share and users report files look 'wrong'."
  center_text "You must verify what is mounted, and confirm ownership/permissions are as expected."
  echo
  center_text "Lab assumptions (simulated):"
  center_text "- Underlying directory: /mnt/share (on root filesystem)"
  center_text "- New mount device: /dev/sdd1 (vfat) mounted on /mnt/share"
  center_text "- After mount, ownership/permissions appear changed"
  echo
  center_text "Goal:"
  center_text "- Prove what is mounted and why permissions differ"
  center_text "- Remount with correct options so examuser can write safely"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  # STEP 1: Check underlying mount point permissions (directory itself)
  echo "  Step 1: Check the current permissions on the mount point path (/mnt/share)."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "ls -ld /mnt/share" ]]; then
    print_error "Incorrect. Use: ls -ld /mnt/share"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  drwxrwx--- 2 root projectgroup 4096 /mnt/share"
  echo

  # STEP 2: Verify what is actually mounted there (source + fstype + options)
  echo "  Step 2: Verify what is mounted on /mnt/share and with which options."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "findmnt /mnt/share" && "$cmd2" != "sudo findmnt /mnt/share" ]]; then
    print_error "Incorrect. Use: findmnt /mnt/share"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  TARGET    SOURCE    FSTYPE OPTIONS"
  echo "  /mnt/share /dev/sdd1 vfat   rw,relatime,seclabel,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,errors=remount-ro"
  echo

  # STEP 3: Demonstrate overlay behavior (contents belong to mounted fs, not underlying dir)
  echo "  Step 3: List contents and inspect ownership/permissions after the mount change."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "ls -l /mnt/share" ]]; then
    print_error "Incorrect. Use: ls -l /mnt/share"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  total 12"
  echo "  -rwxr-xr-x 1 root root  2048 notes.txt"
  echo "  -rwxr-xr-x 1 root root  4096 report.csv"
  echo "  drwxr-xr-x 1 root root  4096 uploads"
  echo

  # STEP 4: Confirm filesystem type for the mounted device (helps explain permission behavior)
  echo "  Step 4: Confirm filesystem type (helps explain why chmod/chown may not behave normally)."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo blkid /dev/sdd1" && "$cmd4" != "blkid /dev/sdd1" ]]; then
    print_error "Incorrect. Use: sudo blkid /dev/sdd1"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  /dev/sdd1: LABEL=\"SHARE\" UUID=\"1A2B-3C4D\" TYPE=\"vfat\""
  echo

  # STEP 5: Validate the problem: attempt to create a file as examuser
  echo "  Step 5: Try to create a file on /mnt/share to confirm the access problem."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "touch /mnt/share/testfile" ]]; then
    print_error "Incorrect. Use: touch /mnt/share/testfile"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  touch: cannot touch '/mnt/share/testfile': Permission denied"
  echo

  # STEP 6: Unmount to prepare for a corrected remount
  echo "  Step 6: Unmount /mnt/share so you can remount with corrected vfat ownership/permission options."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo umount /mnt/share" ]]; then
    print_error "Incorrect. Use: sudo umount /mnt/share"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # STEP 7: Remount with options that give examuser ownership and group write access
  echo "  Step 7: Remount /dev/sdd1 on /mnt/share with vfat options so examuser can write."
  center_text "Requirement: set uid=1000, gid=1000, and umask=0002 (group-writable)."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo mount -t vfat -o uid=1000,gid=1000,umask=0002 /dev/sdd1 /mnt/share" ]]; then
    print_error "Incorrect. Use: sudo mount -t vfat -o uid=1000,gid=1000,umask=0002 /dev/sdd1 /mnt/share"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # STEP 8: Verify mount options took effect
  echo "  Step 8: Verify the updated mount options are active."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "findmnt /mnt/share" && "$cmd8" != "sudo findmnt /mnt/share" ]]; then
    print_error "Incorrect. Use: findmnt /mnt/share"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  TARGET    SOURCE    FSTYPE OPTIONS"
  echo "  /mnt/share /dev/sdd1 vfat   rw,relatime,seclabel,uid=1000,gid=1000,umask=0002,codepage=437,iocharset=ascii,shortname=mixed,errors=remount-ro"
  echo

  # STEP 9: Verify ownership/permissions view after corrected mount
  echo "  Step 9: Re-check file listings to verify ownership/permissions now reflect the new options."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "ls -l /mnt/share" ]]; then
    print_error "Incorrect. Use: ls -l /mnt/share"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  total 12"
  echo "  -rwxrwxr-x 1 examuser examuser  2048 notes.txt"
  echo "  -rwxrwxr-x 1 examuser examuser  4096 report.csv"
  echo "  drwxrwxr-x 1 examuser examuser  4096 uploads"
  echo

  # STEP 10: Confirm write access now works
  echo "  Step 10: Create a file to confirm write access is restored."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "touch /mnt/share/testfile" ]]; then
    print_error "Incorrect. Use: touch /mnt/share/testfile"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # STEP 11: Verify the new file ownership/permissions
  echo "  Step 11: Verify the new file's ownership and permissions."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "ls -l /mnt/share/testfile" ]]; then
    print_error "Incorrect. Use: ls -l /mnt/share/testfile"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  -rwxrwxr-x 1 examuser examuser 0 /mnt/share/testfile"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- verified the active mount and mount options"
  print_info "- diagnosed permission changes caused by a mount overlay"
  print_info "- remounted vfat with correct uid/gid/umask options"
  print_info "- confirmed ownership/permissions and write access after the mount change"
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
