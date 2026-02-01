#!/bin/bash

# Lab 512: Configure Time Service Clients (chronyd)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 512: Configure Time Service Clients (chronyd)"
LAB_ID="lab512"
LAB_XP=51200
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab512:~$ "

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
  center_text "System logs show inconsistent timestamps."
  center_text "You must configure the system as a reliable NTP client using chronyd,"
  center_text "verify synchronization, and ensure persistence across reboots."
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Verify that the chrony package is installed."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "rpm -q chrony" ]]; then
    print_error "Incorrect. Use: rpm -q chrony"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  chrony-4.5-1.el9.x86_64"
  echo

  echo "  Step 2: Verify the chronyd service is running."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "systemctl status chronyd" ]]; then
    print_error "Incorrect. Use: systemctl status chronyd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  ● chronyd.service - NTP client/server"
  echo "     Loaded: loaded (/usr/lib/systemd/system/chronyd.service; enabled)"
  echo "     Active: active (running)"
  echo

  echo "  Step 3: Edit the chrony configuration file."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo vim /etc/chrony.conf" && "$cmd3" != "sudo vi /etc/chrony.conf" ]]; then
    print_error "Incorrect. Use: sudo vim /etc/chrony.conf"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (vim opened)"
  echo

  echo "  Step 4: Add a public NTP pool entry that:"
  echo "          - uses pool.ntp.org"
  echo "          - includes the iburst option"
  echo "          Type the EXACT line you added:"
  read -p "  > " ntp1
  if [[ "$ntp1" != "pool 2.pool.ntp.org iburst" ]]; then
    print_error "Incorrect chrony pool line."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo
  echo "  (save and exit the editor)"
  echo

  echo "  Step 5: Restart the chronyd service to apply configuration changes."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo systemctl restart chronyd" ]]; then
    print_error "Incorrect. Use: sudo systemctl restart chronyd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 6: Verify time synchronization tracking status."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "chronyc tracking" ]]; then
    print_error "Incorrect. Use: chronyc tracking"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Reference ID    : 8.8.8.8 (2.pool.ntp.org)"
  echo "  Stratum         : 2"
  echo "  System time     : 0.000000123 seconds fast of NTP time"
  echo

  echo "  Step 7: List configured NTP sources with verbose output."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "chronyc sources -v" ]]; then
    print_error "Incorrect. Use: chronyc sources -v"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  ^* 2.pool.ntp.org  2   10   377   34  +12us[+34us] +/- 25ms"
  echo

  echo "  Step 8: Verify that chronyd is enabled to start at boot."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "systemctl is-enabled chronyd" ]]; then
    print_error "Incorrect. Use: systemctl is-enabled chronyd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  enabled"
  echo

  echo "  Step 9: Verify system-wide time synchronization status."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "timedatectl" ]]; then
    print_error "Incorrect. Use: timedatectl"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  NTP enabled: yes"
  echo "  NTP synchronized: yes"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- verified chrony installation and service state"
  print_info "- configured chronyd as an NTP client"
  print_info "- validated synchronization using chronyc"
  print_info "- ensured persistent time sync across reboots"
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
