#!/bin/bash

# Lab 487: System Lifecycle Management — Boot, Reboot, and Shutdown
# Focus: safely rebooting, shutting down, changing boot targets, rescue mode,
# GRUB awareness, forced reboots, and boot log inspection.
#
# This lab is aligned directly with RHCSA Objective:
# 01- Boot, reboot, and shut down a system normally
#
# IMPORTANT:
# - Some steps simulate actions that would normally reboot the system.
# - You are validating correct commands and workflows, not actually rebooting
#   the lab environment unless explicitly instructed by an examiner.
#
# Key skills:
# systemctl reboot/poweroff/isolate/set-default
# shutdown scheduling and cancellation
# rescue/emergency targets
# GRUB interaction awareness
# journalctl boot logs
# forced reboot handling

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 487: Boot, Reboot, and Shutdown a System"
LAB_ID="lab487"
LAB_XP=48700
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab487:~$ "

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
  center_text "You are responsible for managing the system lifecycle on a RHEL server."
  center_text "You must demonstrate correct reboot, shutdown, target management,"
  center_text "and boot troubleshooting workflows expected on the RHCSA exam."
  echo
  center_text "Rules:"
  center_text "- Use systemctl and shutdown correctly."
  center_text "- Understand rescue mode, targets, and GRUB behavior."
  center_text "- No guessing: commands must be exact."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Immediate reboot
  echo "  Step 1: Reboot the system immediately using systemctl."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "sudo systemctl reboot" ]]; then
    print_error "Incorrect. Use systemctl reboot."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "Broadcast message from systemd:"
  echo "The system is going down for reboot NOW!"
  echo "  (reboot simulated)"
  echo

  # STEP 2: Immediate shutdown
  echo "  Step 2: Shut down the system immediately."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo systemctl poweroff" ]]; then
    print_error "Incorrect. Use systemctl poweroff."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "Broadcast message from systemd:"
  echo "The system is going down for poweroff NOW!"
  echo "  (shutdown simulated)"
  echo

  # STEP 3: Schedule shutdown
  echo "  Step 3: Schedule a shutdown 5 minutes from now."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo shutdown +5" ]]; then
    print_error "Incorrect. Use shutdown +5."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "Shutdown scheduled for 5 minutes from now."
  echo

  # STEP 4: Cancel scheduled shutdown
  echo "  Step 4: Cancel the scheduled shutdown."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo shutdown -c" ]]; then
    print_error "Incorrect. Use shutdown -c."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "Shutdown cancelled."
  echo

  # STEP 5: Switch to rescue mode
  echo "  Step 5: Enter rescue mode using systemctl."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo systemctl rescue" ]]; then
    print_error "Incorrect. Use systemctl rescue."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "Rescue mode activated."
  echo "You are now in single-user mode with minimal services."
  echo

  # STEP 6: Isolate multi-user target
  echo "  Step 6: Switch back to multi-user (non-graphical) mode."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo systemctl isolate multi-user.target" ]]; then
    print_error "Incorrect. Use systemctl isolate multi-user.target."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "Switched to multi-user.target."
  echo

  # STEP 7: Change default boot target
  echo "  Step 7: Set the default boot target to multi-user."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo systemctl set-default multi-user.target" ]]; then
    print_error "Incorrect. Use systemctl set-default multi-user.target."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "Removed /etc/systemd/system/default.target."
  echo "Created symlink to /usr/lib/systemd/system/multi-user.target."
  echo

  # STEP 8: View current default target
  echo "  Step 8: Verify the current default boot target."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "systemctl get-default" ]]; then
    print_error "Incorrect. Use systemctl get-default."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "multi-user.target"
  echo

  # STEP 9: View boot logs
  echo "  Step 9: View the current boot logs."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo journalctl -b" ]]; then
    print_error "Incorrect. Use journalctl -b."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "-- Logs begin at boot --"
  echo "systemd[1]: Starting Network Manager..."
  echo "kernel: Initializing cgroup subsys cpuset"
  echo "systemd[1]: Reached target Multi-User System."
  echo

  # STEP 10: Forced reboot (conceptual)
  echo "  Step 10: Force a reboot (emergency scenario)."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "sudo reboot --force" ]]; then
    print_error "Incorrect. Use reboot --force."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "System forced to reboot immediately."
  echo "WARNING: services not cleanly stopped."
  echo

  print_success "Excellent work."
  print_info "You demonstrated RHCSA-level mastery of:"
  print_info "- rebooting and shutting down systems safely"
  print_info "- scheduling and canceling shutdowns"
  print_info "- rescue and multi-user targets"
  print_info "- default boot target management"
  print_info "- boot log inspection"
  print_info "- emergency reboot handling"
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
