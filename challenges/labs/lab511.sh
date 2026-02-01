#!/bin/bash

# Lab 511: Configure Default Boot Target (systemd) (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 511: Configure Default Boot Target (systemd)"
LAB_ID="lab511"
LAB_XP=51100
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab511:~$ "

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
  center_text "A server must boot into the correct systemd target for its role."
  center_text "You will identify the current default target, inspect available targets,"
  center_text "change the default target persistently, switch targets temporarily, and verify."
  echo
  center_text "Targets:"
  center_text "- multi-user.target (server mode, no GUI)"
  center_text "- graphical.target (GUI mode, if installed)"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Show the current default boot target."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "systemctl get-default" ]]; then
    print_error "Incorrect. Use: systemctl get-default"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  graphical.target"
  echo

  echo "  Step 2: List loaded targets so you can confirm multi-user.target and graphical.target exist."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "systemctl list-units --type=target" ]]; then
    print_error "Incorrect. Use: systemctl list-units --type=target"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  UNIT                LOAD   ACTIVE SUB    DESCRIPTION"
  echo "  basic.target        loaded active active Basic System"
  echo "  multi-user.target   loaded active active Multi-User System"
  echo "  graphical.target    loaded active active Graphical Interface"
  echo "  ..."
  echo

  echo "  Step 3: Persistently set the default boot target to multi-user.target."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo systemctl set-default multi-user.target" ]]; then
    print_error "Incorrect. Use: sudo systemctl set-default multi-user.target"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Removed /etc/systemd/system/default.target."
  echo "  Created symlink /etc/systemd/system/default.target → /usr/lib/systemd/system/multi-user.target."
  echo

  echo "  Step 4: Verify the default boot target is now multi-user.target."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "systemctl get-default" ]]; then
    print_error "Incorrect. Use: systemctl get-default"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  multi-user.target"
  echo

  echo "  Step 5: Switch to multi-user.target immediately (temporary change) without rebooting."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo systemctl isolate multi-user.target" ]]; then
    print_error "Incorrect. Use: sudo systemctl isolate multi-user.target"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 6: Confirm the currently active target after isolating."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "systemctl get-default" ]]; then
    print_error "Incorrect. Use: systemctl get-default"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  multi-user.target"
  echo

  echo "  Step 7: Persistently set the default boot target back to graphical.target."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo systemctl set-default graphical.target" ]]; then
    print_error "Incorrect. Use: sudo systemctl set-default graphical.target"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Removed /etc/systemd/system/default.target."
  echo "  Created symlink /etc/systemd/system/default.target → /usr/lib/systemd/system/graphical.target."
  echo

  echo "  Step 8: Verify the default boot target is now graphical.target."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "systemctl get-default" ]]; then
    print_error "Incorrect. Use: systemctl get-default"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  graphical.target"
  echo

  echo "  Step 9: Show detailed status for multi-user.target."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "systemctl status multi-user.target --no-pager" ]]; then
    print_error "Incorrect. Use: systemctl status multi-user.target --no-pager"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  ● multi-user.target - Multi-User System"
  echo "     Loaded: loaded (/usr/lib/systemd/system/multi-user.target; enabled; vendor preset: enabled)"
  echo "     Active: active"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- viewed the system default boot target"
  print_info "- listed available targets"
  print_info "- set the default target persistently with set-default"
  print_info "- switched targets temporarily using isolate"
  print_info "- verified target configuration with get-default and status"
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
