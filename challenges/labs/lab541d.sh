#!/bin/bash

# Lab 541D: Configure Time Synchronization with Chrony (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 541D: Configure Time Synchronization with Chrony"
LAB_ID="lab541d"
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
  center_text "ServerA must use the correct timezone and synchronize time"
  center_text "using Chrony. Configure the system so time synchronization"
  center_text "is enabled now and persists after reboot."
  echo

  center_text "Requirements:"
  center_text "Timezone: America/New_York"
  center_text "Time source: pool.ntp.org"
  center_text "Service: chronyd enabled at boot"
  echo

  center_text "Press Enter to begin..."
  read _
  draw_lab_ui


  echo "  Step 1: Inspect the current date, time, timezone, and NTP status."
  read -p "$PROMPT" cmd1
  echo

  if [[ "$cmd1" != "timedatectl" ]]; then
    print_error "Incorrect. Use: timedatectl"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "               Local time: Sat 2026-03-14 10:22:11 UTC"
  echo "           Universal time: Sat 2026-03-14 10:22:11 UTC"
  echo "                 RTC time: Sat 2026-03-14 10:22:11"
  echo "                Time zone: UTC (UTC, +0000)"
  echo "System clock synchronized: no"
  echo "              NTP service: inactive"
  echo "          RTC in local TZ: no"
  echo


  echo "  Step 2: Set the system timezone to America/New_York."
  read -p "$PROMPT" cmd2
  echo

  if [[ "$cmd2" != "sudo timedatectl set-timezone America/New_York" ]]; then
    print_error "Incorrect. Use: sudo timedatectl set-timezone America/New_York"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 3: Inspect the active Chrony configuration without comments or blank lines."
  read -p "$PROMPT" cmd3
  echo

  if [[ "$cmd3" != "grep -v '^#' /etc/chrony.conf | grep -v '^$'" ]]; then
    print_error "Incorrect. Use: grep -v '^#' /etc/chrony.conf | grep -v '^$'"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  pool 2.rhel.pool.ntp.org iburst"
  echo "  driftfile /var/lib/chrony/drift"
  echo "  makestep 1.0 3"
  echo "  rtcsync"
  echo


  echo "  Step 4: Configure Chrony to synchronize with pool.ntp.org."
  read -p "$PROMPT" cmd4
  echo

  if [[ "$cmd4" != "echo 'pool pool.ntp.org iburst' | sudo tee /etc/chrony.conf > /dev/null" ]]; then
    print_error "Incorrect. Use: echo 'pool pool.ntp.org iburst' | sudo tee /etc/chrony.conf > /dev/null"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 5: Verify the Chrony configuration file now points to pool.ntp.org."
  read -p "$PROMPT" cmd5
  echo

  if [[ "$cmd5" != "cat /etc/chrony.conf" ]]; then
    print_error "Incorrect. Use: cat /etc/chrony.conf"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  pool pool.ntp.org iburst"
  echo


  echo "  Step 6: Enable and start the Chrony service now."
  read -p "$PROMPT" cmd6
  echo

  if [[ "$cmd6" != "sudo systemctl enable --now chronyd" ]]; then
    print_error "Incorrect. Use: sudo systemctl enable --now chronyd"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  Created symlink /etc/systemd/system/multi-user.target.wants/chronyd.service → /usr/lib/systemd/system/chronyd.service."
  echo


  echo "  Step 7: Verify the Chrony service is active."
  read -p "$PROMPT" cmd7
  echo

  if [[ "$cmd7" != "systemctl status chronyd --no-pager" ]]; then
    print_error "Incorrect. Use: systemctl status chronyd --no-pager"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  ● chronyd.service - NTP client/server"
  echo "     Loaded: loaded (/usr/lib/systemd/system/chronyd.service; enabled; vendor preset: enabled)"
  echo "     Active: active (running)"
  echo


  echo "  Step 8: Verify the timezone change was applied."
  read -p "$PROMPT" cmd8
  echo

  if [[ "$cmd8" != "timedatectl" ]]; then
    print_error "Incorrect. Use: timedatectl"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "               Local time: Sat 2026-03-14 06:22:11 EDT"
  echo "           Universal time: Sat 2026-03-14 10:22:11 UTC"
  echo "                 RTC time: Sat 2026-03-14 10:22:11"
  echo "                Time zone: America/New_York (EDT, -0400)"
  echo "System clock synchronized: yes"
  echo "              NTP service: active"
  echo "          RTC in local TZ: no"
  echo


  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- inspected the current time and NTP state"
  print_info "- set the system timezone to America/New_York"
  print_info "- inspected the Chrony configuration"
  print_info "- configured Chrony to use pool.ntp.org"
  print_info "- enabled and started chronyd"
  print_info "- verified the service status and timezone change"
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
