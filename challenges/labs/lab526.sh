#!/bin/bash

# Lab 526: Set Enforcing and Permissive Modes for SELinux (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 526: SELinux Enforcing vs Permissive (RHCSA)"
LAB_ID="lab526"
LAB_XP=52600
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab526:~$ "

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
  center_text "SELinux is enabled on this system and enforcing access controls."
  center_text "You must inspect the current mode, switch between enforcing and"
  center_text "permissive modes temporarily, and configure SELinux persistently."
  echo
  center_text "Targets:"
  center_text "- sestatus"
  center_text "- getenforce / setenforce"
  center_text "- /etc/selinux/config"
  center_text "- reboot verification"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Check the current SELinux status."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "sestatus" ]]; then
    print_error "Incorrect. Use: sestatus"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Current mode: enforcing"
  echo

  echo "  Step 2: Display the current SELinux mode using getenforce."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "getenforce" ]]; then
    print_error "Incorrect. Use: getenforce"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Enforcing"
  echo

  echo "  Step 3: Temporarily switch SELinux to permissive mode."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo setenforce 0" ]]; then
    print_error "Incorrect. Use: sudo setenforce 0"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 4: Verify SELinux is now permissive."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "getenforce" ]]; then
    print_error "Incorrect. Use: getenforce"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Permissive"
  echo

  echo "  Step 5: Switch SELinux back to enforcing mode temporarily."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo setenforce 1" ]]; then
    print_error "Incorrect. Use: sudo setenforce 1"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 6: Verify SELinux is enforcing again."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "getenforce" ]]; then
    print_error "Incorrect. Use: getenforce"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Enforcing"
  echo

  echo "  Step 7: Open the SELinux configuration file to set enforcing permanently."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo vi /etc/selinux/config" ]]; then
    print_error "Incorrect. Use: sudo vi /etc/selinux/config"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  SELINUX=enforcing"
  echo

  echo "  Step 8: Reboot the system to apply persistent SELinux settings."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo reboot" ]]; then
    print_error "Incorrect. Use: sudo reboot"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 9: After reboot, verify SELinux mode."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sestatus" ]]; then
    print_error "Incorrect. Use: sestatus"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Current mode: enforcing"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- inspected SELinux status and mode"
  print_info "- switched SELinux between permissive and enforcing modes"
  print_info "- configured SELinux mode persistently"
  print_info "- verified SELinux behavior after reboot"
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
