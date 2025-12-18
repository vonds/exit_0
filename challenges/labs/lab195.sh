#!/bin/bash

# Lab 195: Adjust GRUB Timeout to 1 Second (Operate Running Systems)
# Output policy: Only show real command output. If a command is silent, show nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 195: Adjust GRUB Timeout"
LAB_ID="lab195"
LAB_XP=22000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

GRUB_FILE="/etc/default/grub"

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
  center_text "Goal: Set GRUB_TIMEOUT to 1 second and rebuild GRUB config."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Show current timeout (realistic grep output)
  draw_lab_ui
  echo "  Step 1: Check current GRUB_TIMEOUT value."
  echo "          Expected: grep GRUB_TIMEOUT= $GRUB_FILE"
  read -p "  lab@lab195:~$ " s1
  [[ "$s1" != "grep GRUB_TIMEOUT= /etc/default/grub" ]] && { print_error "Use: grep GRUB_TIMEOUT= /etc/default/grub"; read -p "Press Enter to try again..." _; continue; }
  echo "GRUB_TIMEOUT=5"
  echo

  # Step 2: Edit grub file (silent, no output)
  echo "  Step 2: Change GRUB_TIMEOUT=5 → GRUB_TIMEOUT=1."
  echo "          Expected: vi $GRUB_FILE (or other editor)"
  read -p "  lab@lab195:~$ " s2
  [[ "$s2" != "vi /etc/default/grub" ]] && { print_error "Use: vi /etc/default/grub"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 3: Verify change (grep shows new value)
  echo "  Step 3: Confirm new value."
  echo "          Expected: grep GRUB_TIMEOUT= $GRUB_FILE"
  read -p "  lab@lab195:~$ " s3
  [[ "$s3" != "grep GRUB_TIMEOUT= /etc/default/grub" ]] && { print_error "Use: grep GRUB_TIMEOUT= /etc/default/grub"; read -p "Press Enter to try again..." _; continue; }
  echo "GRUB_TIMEOUT=1"
  echo

  # Step 4: Rebuild grub config (realistic output)
  echo "  Step 4: Rebuild GRUB configuration."
  echo "          Expected: grub2-mkconfig -o /boot/grub2/grub.cfg"
  read -p "  lab@lab195:~$ " s4
  [[ "$s4" != "grub2-mkconfig -o /boot/grub2/grub.cfg" ]] && { print_error "Use: grub2-mkconfig -o /boot/grub2/grub.cfg"; read -p "Press Enter to try again..." _; continue; }
  echo "Generating grub configuration file ..."
  echo "Found linux image: /boot/vmlinuz-5.14.0-362.el9.x86_64"
  echo "Found initrd image: /boot/initramfs-5.14.0-362.el9.x86_64.img"
  echo "done"
  echo

  # Step 5: Verify grub.cfg has new timeout
  echo "  Step 5: Verify grub.cfg reflects new timeout."
  echo "          Expected: grep timeout /boot/grub2/grub.cfg | head -1"
  read -p "  lab@lab195:~$ " s5
  [[ "$s5" != "grep timeout /boot/grub2/grub.cfg | head -1" ]] && { print_error "Use: grep timeout /boot/grub2/grub.cfg | head -1"; read -p "Press Enter to try again..." _; continue; }
  echo "set timeout=1"
  echo

  print_success "Nice work!"
  print_info "You earned $LAB_XP XP for completing this lab."
  award_xp $LAB_XP
  XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON"); export XP; export LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've successfully completed this lab $completion_count time(s)."
  echo
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " post_choice
  [[ "$post_choice" == "2" ]] && exit 0
done
