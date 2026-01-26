#!/bin/bash

# Lab 501: Mount Filesystems at Boot by UUID or LABEL (/etc/fstab)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 501: Mount at Boot by UUID or LABEL"
LAB_ID="lab501"
LAB_XP=50100
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab501:~$ "

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
  center_text "A new data filesystem was added as /dev/sdb1."
  center_text "Device names can change across boots, so you must mount it persistently"
  center_text "using UUID or LABEL in /etc/fstab, then test safely without rebooting."
  echo
  center_text "Targets:"
  center_text "- Device: /dev/sdb1 (ext4)"
  center_text "- Mount:  /mnt/data"
  center_text "- Method: UUID= (primary) and LABEL= (secondary)"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  # STEP 1: Identify UUID/LABEL for /dev/sdb1
  echo "  Step 1: Identify the UUID (and LABEL if present) for /dev/sdb1."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "sudo blkid /dev/sdb1" && "$cmd1" != "blkid /dev/sdb1" ]]; then
    print_error "Incorrect. Use: sudo blkid /dev/sdb1"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  /dev/sdb1: LABEL=\"data\" UUID=\"f3b4c5d6-7890-1121-3141-f5e6d7a8b9c0\" TYPE=\"ext4\""
  echo

  # STEP 2: Create mount point
  echo "  Step 2: Create the mount point directory /mnt/data."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo mkdir /mnt/data" ]]; then
    print_error "Incorrect. Use: sudo mkdir /mnt/data"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (directory created)"
  echo

  # STEP 3: Open /etc/fstab for editing
  echo "  Step 3: Open /etc/fstab for editing."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo vim /etc/fstab" && "$cmd3" != "vim /etc/fstab" ]]; then
    print_error "Incorrect. Use: sudo vim /etc/fstab"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (editor opened)"
  echo
  echo "  Add a new line at the bottom (do NOT modify existing entries)."
  echo "  You will paste it in the next step."
  echo "  (editor ready)"
  echo

  # STEP 4: User must type the exact fstab line (UUID-based)
  echo "  Step 4: Type the exact /etc/fstab line to mount /dev/sdb1 at /mnt/data by UUID."
  read -p "  fstab> " fstab_line
  echo
  expected_uuid_line="UUID=f3b4c5d6-7890-1121-3141-f5e6d7a8b9c0  /mnt/data  ext4  defaults  0  2"
  if [[ "$fstab_line" != "$expected_uuid_line" ]]; then
    print_error "Incorrect /etc/fstab line."
    print_info  "Expected:"
    echo "  $expected_uuid_line"
    echo
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (line entered into /etc/fstab)"
  echo "  (file saved and closed)"
  echo

  # STEP 5: Test fstab safely
  echo "  Step 5: Test the /etc/fstab entry without rebooting."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo mount -a" && "$cmd5" != "mount -a" ]]; then
    print_error "Incorrect. Use: sudo mount -a"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (fstab entries mounted)"
  echo

  # STEP 6: Verify mount with df
  echo "  Step 6: Verify /mnt/data is mounted using df -h."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "df -h /mnt/data" && "$cmd6" != "sudo df -h /mnt/data" ]]; then
    print_error "Incorrect. Use: df -h /mnt/data"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Filesystem      Size  Used Avail Use% Mounted on"
  echo "  /dev/sdb1        20G   24K   19G   1% /mnt/data"
  echo

  # STEP 7: Verify mount source and options with findmnt
  echo "  Step 7: Confirm the mount source and options with findmnt."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "findmnt /mnt/data" && "$cmd7" != "sudo findmnt /mnt/data" ]]; then
    print_error "Incorrect. Use: findmnt /mnt/data"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  TARGET    SOURCE     FSTYPE OPTIONS"
  echo "  /mnt/data /dev/sdb1  ext4   rw,relatime,seclabel"
  echo

  # STEP 8: Show that UUID/LABEL are stable identifiers
  echo "  Step 8: Show UUID/LABEL view for all devices (useful verification step)."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo blkid" && "$cmd8" != "blkid" ]]; then
    print_error "Incorrect. Use: sudo blkid"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  /dev/sda1: UUID=\"9c5a1a2b-3c4d-5e6f-7a8b-9c0d1e2f3a4b\" TYPE=\"xfs\""
  echo "  /dev/sdb1: LABEL=\"data\" UUID=\"f3b4c5d6-7890-1121-3141-f5e6d7a8b9c0\" TYPE=\"ext4\""
  echo

  # STEP 9: Knowledge check — LABEL-based fstab line (typed by user)
  echo "  Step 9: Knowledge check — type the equivalent /etc/fstab line using LABEL=data."
  read -p "  fstab> " fstab_label_line
  echo
  expected_label_line="LABEL=data  /mnt/data  ext4  defaults  0  2"
  if [[ "$fstab_label_line" != "$expected_label_line" ]]; then
    print_error "Incorrect LABEL-based /etc/fstab line."
    print_info  "Expected:"
    echo "  $expected_label_line"
    echo
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  LABEL=data  /mnt/data  ext4  defaults  0  2"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- identified UUID and LABEL for the filesystem"
  print_info "- created a mount point"
  print_info "- typed a correct UUID-based /etc/fstab entry"
  print_info "- tested safely with mount -a"
  print_info "- verified the mount using df and findmnt"
  print_info "- demonstrated the correct LABEL-based entry"
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
