#!/bin/bash

# Lab 355: RHEL Troubleshooting — system boots normally but a required service is missing (disabled/masked)
# RHCSA focus: checking service state with systemctl, inspecting boot logs (journalctl),
# finding why a service is not present (disabled/masked), unmasking/enabling/starting,
# verifying the service is running and enabled at boot, and confirming port reachability if applicable.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 355"
LAB_ID="lab355"
LAB_XP=35500
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

PROMPT="student@lab355:~$ > "

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "RHEL Troubleshooting — the system boots, but an app team reports the required service is missing."
  center_text "Interactive: determine why the service is not running at boot and restore it safely."
  echo
  center_text "Press Enter to begin."
  read _
  draw_lab_ui

  # STEP 1
  echo "  Step 1: Check the current status of the required service."
  read -p "  $PROMPT" cmd1
  if [[ "$cmd1" != "systemctl status chronyd" && "$cmd1" != "sudo systemctl status chronyd" ]]; then
    print_error "Incorrect. Use: systemctl status chronyd"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  ● chronyd.service - NTP client/server"
  echo "     Loaded: loaded (/usr/lib/systemd/system/chronyd.service; enabled; vendor preset: enabled)"
  echo "     Active: inactive (dead) since Fri 2025-12-21 10:21:08 EST; 3min 12s ago"
  echo "       Docs: man:chronyd(8)"
  echo "  "
  echo "  Dec 21 10:18:02 rhel-lab systemd[1]: Starting NTP client/server..."
  echo "  Dec 21 10:18:02 rhel-lab systemd[1]: chronyd.service: Skipped due to 'mask'."
  echo "  Dec 21 10:18:02 rhel-lab systemd[1]: chronyd.service: Unit is masked."

  # STEP 2
  echo
  echo "  Step 2: Confirm whether the service is enabled, disabled, or masked."
  read -p "  $PROMPT" cmd2
  if [[ "$cmd2" != "systemctl is-enabled chronyd" && "$cmd2" != "sudo systemctl is-enabled chronyd" ]]; then
    print_error "Incorrect. Use: systemctl is-enabled chronyd"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  masked"

  # STEP 3
  echo
  echo "  Step 3: Review boot logs for evidence of why the service did not start."
  read -p "  $PROMPT" cmd3
  if [[ "$cmd3" != "journalctl -b -u chronyd" && "$cmd3" != "sudo journalctl -b -u chronyd" ]]; then
    print_error "Incorrect. Use: journalctl -b -u chronyd"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  -- Logs begin at Fri 2025-12-21 10:16:49 EST, end at Fri 2025-12-21 10:21:14 EST. --"
  echo "  Dec 21 10:18:02 rhel-lab systemd[1]: Starting NTP client/server..."
  echo "  Dec 21 10:18:02 rhel-lab systemd[1]: chronyd.service: Skipped due to 'mask'."
  echo "  Dec 21 10:18:02 rhel-lab systemd[1]: chronyd.service: Unit is masked."
  echo "  Dec 21 10:18:02 rhel-lab systemd[1]: chronyd.service: Failed with result 'dependency'."

  # STEP 4
  echo
  echo "  Step 4: Verify what the unit file is masked to (inspect the unit file path)."
  read -p "  $PROMPT" cmd4
  if [[ "$cmd4" != "systemctl cat chronyd" && "$cmd4" != "sudo systemctl cat chronyd" ]]; then
    print_error "Incorrect. Use: systemctl cat chronyd"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  # /usr/lib/systemd/system/chronyd.service"
  echo "  # (masked)"
  echo "  /etc/systemd/system/chronyd.service -> /dev/null"

  # STEP 5
  echo
  echo "  Step 5: Unmask the service."
  read -p "  $PROMPT" cmd5
  if [[ "$cmd5" != "sudo systemctl unmask chronyd" && "$cmd5" != "systemctl unmask chronyd" ]]; then
    print_error "Incorrect. Use: sudo systemctl unmask chronyd"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  Removed \"/etc/systemd/system/chronyd.service\"."

  # STEP 6
  echo
  echo "  Step 6: Enable the service so it starts at boot."
  read -p "  $PROMPT" cmd6
  if [[ "$cmd6" != "sudo systemctl enable chronyd" && "$cmd6" != "systemctl enable chronyd" ]]; then
    print_error "Incorrect. Use: sudo systemctl enable chronyd"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  Created symlink /etc/systemd/system/multi-user.target.wants/chronyd.service → /usr/lib/systemd/system/chronyd.service."

  # STEP 7
  echo
  echo "  Step 7: Start the service now."
  read -p "  $PROMPT" cmd7
  if [[ "$cmd7" != "sudo systemctl start chronyd" && "$cmd7" != "systemctl start chronyd" ]]; then
    print_error "Incorrect. Use: sudo systemctl start chronyd"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  "

  # STEP 8
  echo
  echo "  Step 8: Verify the service is active."
  read -p "  $PROMPT" cmd8
  if [[ "$cmd8" != "systemctl is-active chronyd" && "$cmd8" != "sudo systemctl is-active chronyd" ]]; then
    print_error "Incorrect. Use: systemctl is-active chronyd"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  active"

  # STEP 9
  echo
  echo "  Step 9: Verify the service will start at boot (enabled state)."
  read -p "  $PROMPT" cmd9
  if [[ "$cmd9" != "systemctl is-enabled chronyd" && "$cmd9" != "sudo systemctl is-enabled chronyd" ]]; then
    print_error "Incorrect. Use: systemctl is-enabled chronyd"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  enabled"

  # STEP 10
  echo
  echo "  Step 10: Verify chronyd is responding (check sources output)."
  read -p "  $PROMPT" cmd10
  if [[ "$cmd10" != "chronyc sources -v" && "$cmd10" != "sudo chronyc sources -v" ]]; then
    print_error "Incorrect. Use: chronyc sources -v"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  210 Number of sources = 1"
  echo "  MS Name/IP address         Stratum Poll Reach LastRx Last sample"
  echo "  =============================================================================="
  echo "  ^* time1.example.local           3   6   377    12   +12us[ +21us] +/-  18ms"

  print_success "Excellent work!"
  print_info "You earned $LAB_XP XP for completing this lab!"
  award_xp $LAB_XP
  XP=$(jq '.XP' "$SAVE_JSON")
  LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
  export XP
  export LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've successfully completed this lab $completion_count time(s)."
  echo
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " choice

  if [[ "$choice" == "2" ]]; then
    exit 0
  fi
done
