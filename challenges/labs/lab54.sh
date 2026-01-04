#!/bin/bash

# Lab 54: Recover Root Password (Simulation)
# Focus: GRUB edit workflow, init=/bin/sh rescue shell, SELinux policy load, rw remount,
# password reset, autorelabel, and safe reboot. Realistic prompts/output. No answers shown.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 54: Recover Root Password"
LAB_ID="lab54"
LAB_XP=11850
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
  center_text "The root password is forgotten."
  center_text "You have console access and must recover root by editing GRUB."
  echo
  center_text "Goal: boot into a rescue shell, enable policy to make changes, reset root password,"
  center_text "and reboot back into normal mode."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Interrupt GRUB
  echo "  Step 1: On reboot, interrupt GRUB and edit the selected boot entry."
  read -p "  > " cmd1
  echo
  if [[ "$cmd1" != "e" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (GRUB edit screen opens)"
  echo

  # STEP 2: Add init=/bin/sh
  echo "  Step 2: Modify the linux kernel line to boot into a minimal shell."
  echo "          Enter the exact kernel-arg you would append."
  read -p "  grub(edit)> " cmd2
  echo
  if [[ "$cmd2" != *"init=/bin/sh"* ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  # STEP 3: Boot modified entry
  echo "  Step 3: Boot the modified entry."
  read -p "  grub(edit)> " cmd3
  echo
  if [[ "$cmd3" != "Ctrl+x" && "$cmd3" != "F10" && "$cmd3" != "ctrl+x" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  [  OK  ] Started dracut pre-pivot and cleanup hook."
  echo "  [  OK  ] Reached target Switch Root."
  echo "  Switching root."
  echo "  /bin/sh: can't access tty; job control turned off"
  echo "  sh-5.1#"
  echo

  # STEP 4: Load SELinux policy
  echo "  Step 4: Ensure policy is loaded so permission checks behave correctly before changes."
  read -p "  sh-5.1# " cmd4
  echo
  if [[ "$cmd4" != "/usr/sbin/load_policy -i" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  /usr/sbin/load_policy:  done"
  echo

  # STEP 5: Remount /
  echo "  Step 5: Remount the root filesystem read-write."
  read -p "  sh-5.1# " cmd5
  echo
  if [[ "$cmd5" != "mount -o remount,rw /" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
 
  # STEP 6: Reset root password
  echo "  Step 6: Reset the root password."
  read -p "  sh-5.1# " cmd6
  echo
  if [[ "$cmd6" != "passwd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  New password:"
  echo "  Retype new password:"
  echo "  passwd: all authentication tokens updated successfully."
  echo

  # STEP 7: Trigger autorelabel
  echo "  Step 7: Ensure the system will relabel on next boot."
  read -p "  sh-5.1# " cmd7
  echo
  if [[ "$cmd7" != "touch /.autorelabel" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  # STEP 8: Reboot normally
  echo "  Step 8: Continue booting into normal mode."
  read -p "  sh-5.1# " cmd8
  echo
  if [[ "$cmd8" != "exec /sbin/init" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  system is rebooting..."
  echo "  SELinux relabel may take several minutes."
  echo

  print_success "Recovery simulation complete."
  print_info "You successfully used GRUB rescue boot to regain root access and restore normal boot."
  print_info "You earned $LAB_XP XP for completing this lab."
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
