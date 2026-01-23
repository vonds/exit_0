#!/bin/bash

# Lab 488: Booting Systems into Different Targets Manually
# Focus: understanding and controlling systemd targets at runtime and boot time.
#
# RHCSA Objective:
# 02- Boot systems into different targets manually
#
# This lab validates your ability to:
# - switch targets on a running system
# - change the default boot target
# - understand rescue vs emergency modes
# - boot into specific targets via GRUB (conceptual but exam-critical)
#
# NOTE:
# Actions that would normally reboot the system are simulated.
# The goal is command accuracy and workflow correctness.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 488: Boot Systems into Different Targets"
LAB_ID="lab488"
LAB_XP=48800
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab488:~$ "

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
  center_text "You are administering a RHEL system and must control"
  center_text "how the system enters different operational states."
  center_text "You will switch targets live, configure defaults,"
  center_text "and demonstrate GRUB-based target selection."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: View current default target
  echo "  Step 1: Display the current default boot target."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "systemctl get-default" ]]; then
    print_error "Incorrect. Use systemctl get-default."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "graphical.target"
  echo

  # STEP 2: Switch to multi-user target
  echo "  Step 2: Switch the running system to multi-user (non-graphical) mode."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo systemctl isolate multi-user.target" ]]; then
    print_error "Incorrect. Use systemctl isolate multi-user.target."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "Stopping graphical session..."
  echo "Reached target Multi-User System."
  echo

  # STEP 3: Switch back to graphical target
  echo "  Step 3: Switch the system back to graphical mode."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo systemctl isolate graphical.target" ]]; then
    print_error "Incorrect. Use systemctl isolate graphical.target."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "Starting GNOME Display Manager..."
  echo "Reached target Graphical Interface."
  echo

  # STEP 4: Set default target to multi-user
  echo "  Step 4: Configure the system to boot into multi-user mode by default."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo systemctl set-default multi-user.target" ]]; then
    print_error "Incorrect. Use systemctl set-default multi-user.target."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "Removed default.target."
  echo "Created symlink to multi-user.target."
  echo

  # STEP 5: Verify default target
  echo "  Step 5: Verify the new default boot target."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "systemctl get-default" ]]; then
    print_error "Incorrect. Use systemctl get-default."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "multi-user.target"
  echo

  # STEP 6: Enter rescue mode
  echo "  Step 6: Switch the system into rescue mode."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo systemctl isolate rescue.target" ]]; then
    print_error "Incorrect. Use systemctl isolate rescue.target."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "You are now in rescue mode."
  echo "Only essential services are running."
  echo

  # STEP 7: Enter emergency mode
  echo "  Step 7: Switch the system into emergency mode."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo systemctl isolate emergency.target" ]]; then
    print_error "Incorrect. Use systemctl isolate emergency.target."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "You are now in emergency mode."
  echo "Minimal environment. Filesystems may not be mounted."
  echo

  # STEP 8: GRUB rescue boot (conceptual)
  echo "  Step 8: Identify the GRUB kernel parameter to boot into rescue mode."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "systemd.unit=rescue.target" ]]; then
    print_error "Incorrect. Append systemd.unit=rescue.target."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "Correct. This parameter boots directly into rescue mode."
  echo

  # STEP 9: GRUB emergency boot (conceptual)
  echo "  Step 9: Identify the GRUB kernel parameter to boot into emergency mode."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "systemd.unit=emergency.target" ]]; then
    print_error "Incorrect. Append systemd.unit=emergency.target."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "Correct. This boots into the lowest-level recovery environment."
  echo

  print_success "Excellent work."
  print_info "You demonstrated RHCSA-level control of system boot targets:"
  print_info "- switching targets on a running system"
  print_info "- configuring default boot behavior"
  print_info "- understanding rescue vs emergency modes"
  print_info "- using GRUB kernel parameters for manual target selection"
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
