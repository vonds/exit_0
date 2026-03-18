#!/bin/bash

# Lab 541Q: Optimize System Performance with tuned (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 541Q: Optimize System Performance with tuned"
LAB_ID="lab541q"
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
  center_text "ServerA must be tuned for higher throughput performance."
  center_text "Install and enable tuned if needed, inspect the current"
  center_text "profile, switch to throughput-performance, and verify it."
  echo

  center_text "Requirements:"
  center_text "- Package/service: tuned"
  center_text "- Target profile: throughput-performance"
  center_text "- Service enabled at boot"
  echo

  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Check whether the tuned package is already installed."
  read -p "$PROMPT" cmd1
  echo

  if [[ "$cmd1" != "rpm -q tuned" ]]; then
    print_error "Incorrect. Use: rpm -q tuned"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  package tuned is not installed"
  echo

  echo "  Step 2: Install the tuned package."
  read -p "$PROMPT" cmd2
  echo

  if [[ "$cmd2" != "sudo dnf install -y tuned" ]]; then
    print_error "Incorrect. Use: sudo dnf install -y tuned"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  Installed:"
  echo "    tuned"
  echo

  echo "  Step 3: Enable and start the tuned service."
  read -p "$PROMPT" cmd3
  echo

  if [[ "$cmd3" != "sudo systemctl enable --now tuned" ]]; then
    print_error "Incorrect. Use: sudo systemctl enable --now tuned"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  Created symlink /etc/systemd/system/multi-user.target.wants/tuned.service → /usr/lib/systemd/system/tuned.service."
  echo

  echo "  Step 4: Verify the tuned service is active."
  read -p "$PROMPT" cmd4
  echo

  if [[ "$cmd4" != "systemctl status tuned --no-pager" ]]; then
    print_error "Incorrect. Use: systemctl status tuned --no-pager"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  ● tuned.service - Dynamic System Tuning Daemon"
  echo "     Loaded: loaded (/usr/lib/systemd/system/tuned.service; enabled)"
  echo "     Active: active (running)"
  echo

  echo "  Step 5: Identify the currently active tuning profile."
  read -p "$PROMPT" cmd5
  echo

  if [[ "$cmd5" != "tuned-adm active" && "$cmd5" != "sudo tuned-adm active" ]]; then
    print_error "Incorrect. Use: tuned-adm active"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  Current active profile: balanced"
  echo

  echo "  Step 6: Switch the active tuning profile to throughput-performance."
  read -p "$PROMPT" cmd6
  echo

  if [[ "$cmd6" != "sudo tuned-adm profile throughput-performance" ]]; then
    print_error "Incorrect. Use: sudo tuned-adm profile throughput-performance"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  Tuned profile switched to 'throughput-performance'"
  echo

  echo "  Step 7: Verify that the new tuning profile is active."
  read -p "$PROMPT" cmd7
  echo

  if [[ "$cmd7" != "tuned-adm active" && "$cmd7" != "sudo tuned-adm active" ]]; then
    print_error "Incorrect. Use: tuned-adm active"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  Current active profile: throughput-performance"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- checked for the tuned package"
  print_info "- installed tuned"
  print_info "- enabled and started the tuned service"
  print_info "- identified the current active profile"
  print_info "- switched to throughput-performance"
  print_info "- verified the new active profile"
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