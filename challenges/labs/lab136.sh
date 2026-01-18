#!/bin/bash

# Lab 136: System Services — Fix Logging + Time Sync Incident (4–8 prompts)
# Scenario: After a hard reboot, a Rocky/RHEL host shows two problems:
# 1) Your app team says "logs aren't showing up" in the journal when they run their service.
# 2) TLS checks are failing because the system clock is drifting.
#
# Your job: verify journald is running, inspect logs for a service unit, restart journald,
# check time sync status, enable NTP with chronyd (or timedatectl), and verify time is synced.
#
# Key skills: systemctl status/restart, journalctl -u, journalctl -b, systemd-journald,
# timedatectl, chronyc tracking/sources, systemctl enable --now chronyd.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 136: System Services — Journald + Time Sync Fix"
LAB_ID="lab136"
LAB_XP=29500
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@rhel-lab136:~$ "

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
  center_text "This host is failing health checks after an outage."
  center_text "Symptoms:"
  center_text "- App team can't find recent service logs in the journal."
  center_text "- TLS checks fail because the system time is drifting."
  echo
  center_text "Goal: verify journald, inspect service logs, restore logging, and re-enable time sync."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Verify journald is running
  echo "  Step 1: Check whether the system journal service is running."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "systemctl status systemd-journald --no-pager" && \
        "$cmd1" != "sudo systemctl status systemd-journald --no-pager" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  ● systemd-journald.service - Journal Service"
  echo "       Loaded: loaded (/usr/lib/systemd/system/systemd-journald.service; static)"
  echo "       Active: active (running) since Thu 2026-01-15 11:03:12 UTC; 6min ago"
  echo "     Main PID: 610 (systemd-journald)"
  echo

  # STEP 2: Inspect logs for a service unit (real action toward the issue)
  echo "  Step 2: View recent logs for the service unit 'webapp.service' (limit output)."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "journalctl -u webapp.service -n 20 --no-pager" && \
        "$cmd2" != "sudo journalctl -u webapp.service -n 20 --no-pager" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Jan 15 11:06:41 host webapp[2142]: ERROR: failed to write to journal (No space left on device)"
  echo "  Jan 15 11:06:41 host webapp[2142]: WARN: continuing without structured logs"
  echo

  # STEP 3: Restart journald (common first remediation when journaling is wedged)
  echo "  Step 3: Restart the journal service to restore logging."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo systemctl restart systemd-journald" && \
        "$cmd3" != "systemctl restart systemd-journald" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  # STEP 4: Confirm logs are flowing again (check current boot)
  echo "  Step 4: Show journal entries from the current boot for webapp.service."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "journalctl -b -u webapp.service -n 10 --no-pager" && \
        "$cmd4" != "sudo journalctl -b -u webapp.service -n 10 --no-pager" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Jan 15 11:09:02 host systemd[1]: Started webapp.service - Internal Web App."
  echo "  Jan 15 11:09:02 host webapp[2310]: INFO: listening on 0.0.0.0:8080"
  echo

  # STEP 5: Check time sync status
  echo "  Step 5: Check current time synchronization status."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "timedatectl status" && \
        "$cmd5" != "sudo timedatectl status" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "               Local time: Thu 2026-01-15 11:09:10 UTC"
  echo "           Universal time: Thu 2026-01-15 11:09:10 UTC"
  echo "                 RTC time: Thu 2026-01-15 10:37:51"
  echo "                Time zone: UTC (UTC, +0000)"
  echo "  System clock synchronized: no"
  echo "              NTP service: inactive"
  echo

  # STEP 6: Enable NTP (chronyd is the standard on RHEL/Rocky)
  echo "  Step 6: Enable and start chronyd now (and set NTP on)."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo systemctl enable --now chronyd && sudo timedatectl set-ntp true" && \
        "$cmd6" != "systemctl enable --now chronyd && timedatectl set-ntp true" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 7: Verify chrony is syncing
  echo "  Step 7: Verify time sync is working with chrony."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "chronyc tracking" && \
        "$cmd7" != "sudo chronyc tracking" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Reference ID    : 203.0.113.10 (ntp1.example.net)"
  echo "  Stratum         : 3"
  echo "  System time     : 0.000002341 seconds slow of NTP time"
  echo "  Last offset     : -0.000001102 seconds"
  echo "  Leap status     : Normal"
  echo

  print_success "Great job."
  print_info "You handled a realistic system-services incident by:"
  print_info "- verifying systemd-journald health and inspecting unit logs"
  print_info "- restarting journald and confirming logs for the current boot"
  print_info "- checking time sync status and enabling chronyd + NTP"
  print_info "- validating sync via chronyc"
  print_info "You earned $LAB_XP XP for completing this lab."
  award_xp $LAB_XP

  XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON"); export XP; export LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've successfully completed this lab $completion_count time(s)."
  echo
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " post_choice
  [[ "$post_choice" == "2" ]] && exit 0
done
