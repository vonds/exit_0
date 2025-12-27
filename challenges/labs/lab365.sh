#!/bin/bash

# Lab 365: RHEL Troubleshooting — system time is incorrect despite NTP being installed (service inactive + NTP disabled)
# RHCSA focus: checking time status (timedatectl), verifying NTP sync state, inspecting chronyd status,
# enabling NTP, starting/enabling chronyd, validating sources, forcing a step if needed, and confirming sync.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 365"
LAB_ID="lab365"
LAB_XP=36500
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

PROMPT="student@lab365:~$ > "

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "RHEL Troubleshooting — system time is drifting and clearly wrong, even though NTP is installed."
  center_text "Interactive: diagnose why sync isn't happening and restore accurate time synchronization."
  echo
  center_text "Press Enter to begin."
  read _
  draw_lab_ui

  # STEP 1
  echo "  Step 1: Check current time status and NTP sync state."
  read -p "  $PROMPT" cmd1
  if [[ "$cmd1" != "timedatectl" && "$cmd1" != "timedatectl status" ]]; then
    print_error "Incorrect. Use: timedatectl"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "               Local time: Sun 2025-12-21 09:12:41 EST"
  echo "           Universal time: Sun 2025-12-21 14:12:41 UTC"
  echo "                 RTC time: Sun 2025-12-21 14:12:39"
  echo "                Time zone: America/New_York (EST, -0500)"
  echo "System clock synchronized: no"
  echo "              NTP service: inactive"
  echo "          RTC in local TZ: no"

  # STEP 2
  echo
  echo "  Step 2: Verify chronyd is installed and check its service status."
  read -p "  $PROMPT" cmd2
  if [[ "$cmd2" != "systemctl status chronyd" && "$cmd2" != "sudo systemctl status chronyd" ]]; then
    print_error "Incorrect. Use: systemctl status chronyd"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  ● chronyd.service - NTP client/server"
  echo "     Loaded: loaded (/usr/lib/systemd/system/chronyd.service; disabled; vendor preset: enabled)"
  echo "     Active: inactive (dead)"
  echo "       Docs: man:chronyd(8)"

  # STEP 3
  echo
  echo "  Step 3: Enable NTP via timedatectl."
  read -p "  $PROMPT" cmd3
  if [[ "$cmd3" != "sudo timedatectl set-ntp true" ]]; then
    print_error "Incorrect. Use: sudo timedatectl set-ntp true"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  "

  # STEP 4
  echo
  echo "  Step 4: Enable and start chronyd."
  read -p "  $PROMPT" cmd4
  if [[ "$cmd4" != "sudo systemctl enable --now chronyd" ]]; then
    print_error "Incorrect. Use: sudo systemctl enable --now chronyd"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  Created symlink /etc/systemd/system/multi-user.target.wants/chronyd.service → /usr/lib/systemd/system/chronyd.service."
  echo "  "

  # STEP 5
  echo
  echo "  Step 5: Confirm chronyd is active."
  read -p "  $PROMPT" cmd5
  if [[ "$cmd5" != "systemctl is-active chronyd" && "$cmd5" != "sudo systemctl is-active chronyd" ]]; then
    print_error "Incorrect. Use: systemctl is-active chronyd"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  active"

  # STEP 6
  echo
  echo "  Step 6: Check chrony sources to confirm it can reach an NTP source."
  read -p "  $PROMPT" cmd6
  if [[ "$cmd6" != "chronyc sources -v" && "$cmd6" != "sudo chronyc sources -v" ]]; then
    print_error "Incorrect. Use: chronyc sources -v"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  210 Number of sources = 2"
  echo "  MS Name/IP address         Stratum Poll Reach LastRx Last sample"
  echo "  =============================================================================="
  echo "  ^? ntp1.example.local           3   6     1     12   +0ms[  +0ms] +/-  50ms"
  echo "  ^* ntp2.example.local           3   6     1     10   -5ms[ -12ms] +/-  35ms"

  # STEP 7
  echo
  echo "  Step 7: Force an immediate time correction (step) if the clock is far off."
  read -p "  $PROMPT" cmd7
  if [[ "$cmd7" != "sudo chronyc makestep" ]]; then
    print_error "Incorrect. Use: sudo chronyc makestep"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  200 OK"

  # STEP 8
  echo
  echo "  Step 8: Verify the system reports synchronized time now."
  read -p "  $PROMPT" cmd8
  if [[ "$cmd8" != "timedatectl" && "$cmd8" != "timedatectl status" ]]; then
    print_error "Incorrect. Use: timedatectl"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "               Local time: Sun 2025-12-21 14:18:09 EST"
  echo "           Universal time: Sun 2025-12-21 19:18:09 UTC"
  echo "                 RTC time: Sun 2025-12-21 19:18:07"
  echo "                Time zone: America/New_York (EST, -0500)"
  echo "System clock synchronized: yes"
  echo "              NTP service: active"
  echo "          RTC in local TZ: no"

  # STEP 9
  echo
  echo "  Step 9: Confirm chronyd will start on boot."
  read -p "  $PROMPT" cmd9
  if [[ "$cmd9" != "systemctl is-enabled chronyd" && "$cmd9" != "sudo systemctl is-enabled chronyd" ]]; then
    print_error "Incorrect. Use: systemctl is-enabled chronyd"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  enabled"

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
