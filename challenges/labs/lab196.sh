#!/bin/bash

# Lab 196: Reset Root Password via rd.break (Operate Running Systems)
# Output policy: Only show real command output. If a command is silent, show nothing.
# Note: GRUB edit (adding rd.break) happens outside the shell and produces no shell output.
# This lab starts from the emergency shell scenario: switch_root:/#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 196: Reset Root Password (rd.break)"
LAB_ID="lab196"
LAB_XP=26000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

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
  center_text "Goal: From the rd.break emergency shell, mount sysroot rw, chroot, reset root password, trigger SELinux relabel, reboot."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 0: Simulate reaching the emergency shell by rebooting first (optional realism)
  draw_lab_ui
  echo "  Step 0: Reboot to edit GRUB (append rd.break) — then arrive at emergency shell (simulated)."
  echo "          Expected: reboot"
  read -p "  lab@lab196:~$ " s0
  [[ "$s0" != "reboot" ]] && { print_error "Use: reboot"; read -p "Press Enter to try again..." _; continue; }
  echo "Rebooting."
  echo

  # Step 1: Remount sysroot read-write (no output)
  echo "  Step 1: In the emergency shell (switch_root:/#), remount /sysroot read-write."
  echo "          Expected: mount -o remount,rw /sysroot"
  read -p "  switch_root:/# " s1
  [[ "$s1" != "mount -o remount,rw /sysroot" ]] && { print_error "Use: mount -o remount,rw /sysroot"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 2: Chroot into sysroot (no output)
  echo "  Step 2: Chroot into /sysroot."
  echo "          Expected: chroot /sysroot"
  read -p "  switch_root:/# " s2
  [[ "$s2" != "chroot /sysroot" ]] && { print_error "Use: chroot /sysroot"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 3: Reset root password (shows passwd prompts and success)
  echo "  Step 3: Reset the root password."
  echo "          Expected: passwd root"
  read -p "  sh-5.1# " s3
  [[ "$s3" != "passwd root" ]] && { print_error "Use: passwd root"; read -p "Press Enter to try again..." _; continue; }
  echo "Changing password for user root."
  echo "New password:"
  echo "Retype new password:"
  echo "passwd: all authentication tokens updated successfully."
  echo

  # Step 4: Trigger SELinux relabel on next boot (no output)
  echo "  Step 4: Ensure SELinux relabel occurs on next boot."
  echo "          Expected: touch /.autorelabel"
  read -p "  sh-5.1# " s4
  [[ "$s4" != "touch /.autorelabel" ]] && { print_error "Use: touch /.autorelabel"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 5: Exit chroot (no output)
  echo "  Step 5: Exit chroot."
  echo "          Expected: exit"
  read -p "  sh-5.1# " s5
  [[ "$s5" != "exit" ]] && { print_error "Use: exit"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 6: Reboot system from emergency shell (shows a reboot message)
  echo "  Step 6: Reboot the system."
  echo "          Expected: reboot"
  read -p "  switch_root:/# " s6
  [[ "$s6" != "reboot" ]] && { print_error "Use: reboot"; read -p "Press Enter to try again..." _; continue; }
  echo "Rebooting."
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
