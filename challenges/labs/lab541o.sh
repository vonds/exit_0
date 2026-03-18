#!/bin/bash

# Lab 541O: Add Swap Space Non-Destructively (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 541O: Add Swap Space Non-Destructively"
LAB_ID="lab541o"
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
  center_text "ServerA requires additional swap space without disrupting"
  center_text "existing storage. Create a new 512MiB partition on /dev/sdb,"
  center_text "format it as swap, activate it, and ensure it persists at boot."
  echo

  center_text "Requirements:"
  center_text "- Disk: /dev/sdb"
  center_text "- Partition size: 512MiB"
  center_text "- Format as swap"
  center_text "- Activate immediately"
  center_text "- Enable automatically at boot"
  echo

  center_text "Press Enter to begin..."
  read _
  draw_lab_ui


  echo "  Step 1: Inspect available block devices."
  read -p "$PROMPT" cmd1
  echo

  if [[ "$cmd1" != "lsblk" ]]; then
    print_error "Incorrect. Use: lsblk"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS"
  echo "  sda      8:0    0   40G  0 disk"
  echo "  ├─sda1   8:1    0    1G  0 part /boot"
  echo "  └─sda2   8:2    0   39G  0 part"
  echo "    ├─rhel-root 253:0 0   35G  0 lvm  /"
  echo "    └─rhel-swap 253:1 0    4G  0 lvm  [SWAP]"
  echo "  sdb      8:16   0    2G  0 disk"
  echo

  echo "  Step 2: Create a new 512MiB partition on /dev/sdb."
  read -p "$PROMPT" cmd2
  echo

  if [[ "$cmd2" != "sudo parted -s /dev/sdb mkpart primary linux-swap 1MiB 513MiB" ]]; then
    print_error "Incorrect."
    print_info "Use: sudo parted -s /dev/sdb mkpart primary linux-swap 1MiB 513MiB"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 3: Verify the new partition exists."
  read -p "$PROMPT" cmd3
  echo

  if [[ "$cmd3" != "lsblk" ]]; then
    print_error "Incorrect. Use: lsblk"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  sdb      8:16   0    2G  0 disk"
  echo "  └─sdb1   8:17   0  512M  0 part"
  echo

  echo "  Step 4: Format the new partition as swap."
  read -p "$PROMPT" cmd4
  echo

  if [[ "$cmd4" != "sudo mkswap /dev/sdb1" ]]; then
    print_error "Incorrect. Use: sudo mkswap /dev/sdb1"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  Setting up swapspace version 1, size = 512 MiB"
  echo

  echo "  Step 5: Activate the new swap space."
  read -p "$PROMPT" cmd5
  echo

  if [[ "$cmd5" != "sudo swapon /dev/sdb1" ]]; then
    print_error "Incorrect. Use: sudo swapon /dev/sdb1"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 6: Verify the swap space is active."
  read -p "$PROMPT" cmd6
  echo

  if [[ "$cmd6" != "swapon --show" ]]; then
    print_error "Incorrect. Use: swapon --show"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  NAME       TYPE SIZE USED PRIO"
  echo "  /dev/dm-1  partition 4G   0B   -2"
  echo "  /dev/sdb1  partition 512M 0B   -3"
  echo

  echo "  Step 7: Add the swap partition to /etc/fstab for automatic activation at boot."
  read -p "$PROMPT" cmd7
  echo

  if [[ "$cmd7" != "echo '/dev/sdb1 swap swap defaults 0 0' | sudo tee -a /etc/fstab > /dev/null" ]]; then
    print_error "Incorrect."
    print_info "Use: echo '/dev/sdb1 swap swap defaults 0 0' | sudo tee -a /etc/fstab > /dev/null"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 8: Verify the fstab entry."
  read -p "$PROMPT" cmd8
  echo

  if [[ "$cmd8" != "grep sdb1 /etc/fstab" ]]; then
    print_error "Incorrect. Use: grep sdb1 /etc/fstab"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  /dev/sdb1 swap swap defaults 0 0"
  echo


  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- inspected block devices"
  print_info "- created a 512MiB partition"
  print_info "- formatted it as swap"
  print_info "- activated swap space immediately"
  print_info "- configured swap to activate automatically at boot"
  print_info "- verified the swap configuration"
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