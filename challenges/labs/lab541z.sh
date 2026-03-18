#!/bin/bash

# Lab 541Z: Set Multi-User Target as the Default Boot Target (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 541Z: Set Multi-User Target as Default"
LAB_ID="lab541z"
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
  center_text "ServerA must boot into a non-graphical environment by default."
  center_text "Configure the system so that after reboot it starts in the"
  center_text "multi-user target instead of a graphical target."
  echo
  center_text "Requirements:"
  center_text "- Set the default boot target to multi-user.target"
  center_text "- Ensure the system boots to a command-line environment"
  center_text "- Verify the default target was set correctly"
  echo

  center_text "Press Enter to begin..."
  read _
  draw_lab_ui


  echo "  Step 1: Check the current default systemd target."
  read -p "$PROMPT" cmd1
  echo

  if [[ "$cmd1" != "systemctl get-default" ]]; then
    print_error "Incorrect. Use: systemctl get-default"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  graphical.target"
  echo


  echo "  Step 2: Set the system to boot into multi-user.target by default."
  read -p "$PROMPT" cmd2
  echo

  if [[ "$cmd2" != "sudo systemctl set-default multi-user.target" ]]; then
    print_error "Incorrect. Use: sudo systemctl set-default multi-user.target"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Removed /etc/systemd/system/default.target."
  echo "  Created symlink /etc/systemd/system/default.target → /usr/lib/systemd/system/multi-user.target."
  echo


  echo "  Step 3: Verify the default target has been changed."
  read -p "$PROMPT" cmd3
  echo

  if [[ "$cmd3" != "systemctl get-default" ]]; then
    print_error "Incorrect. Use: systemctl get-default"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  multi-user.target"
  echo


  echo "  Step 4: Confirm the default.target symlink points to multi-user.target."
  read -p "$PROMPT" cmd4
  echo

  if [[ "$cmd4" != "ls -l /etc/systemd/system/default.target" ]]; then
    print_error "Incorrect. Use: ls -l /etc/systemd/system/default.target"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  lrwxrwxrwx. 1 root root 41 Mar 15 14:18 /etc/systemd/system/default.target -> /usr/lib/systemd/system/multi-user.target"
  echo


  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- checked the current default target"
  print_info "- changed the default boot target to multi-user.target"
  print_info "- verified the system will boot into a non-graphical environment"
  print_info "- confirmed the default.target symlink"
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