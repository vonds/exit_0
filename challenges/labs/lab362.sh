#!/bin/bash

# Lab 362: RHEL Troubleshooting — find why a systemd timer isn't triggering its service (unit name mismatch)
# RHCSA focus: inspecting timers (systemctl list-timers), checking timer status, verifying unit linkage,
# identifying why a timer doesn't start its service, fixing the unit relationship, reloading systemd,
# enabling/starting the timer, and verifying the service runs.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 362"
LAB_ID="lab362"
LAB_XP=36200
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

PROMPT="student@lab362:~$ > "

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "RHEL Troubleshooting — a systemd timer should run a cleanup service every 2 minutes, but it never fires."
  center_text "Interactive: diagnose why the timer isn't triggering its service and restore correct behavior."
  echo
  center_text "Press Enter to begin."
  read _
  draw_lab_ui

  # STEP 1
  echo "  Step 1: List active timers and look for the expected one."
  read -p "  $PROMPT" cmd1
  if [[ "$cmd1" != "systemctl list-timers --all" && "$cmd1" != "sudo systemctl list-timers --all" ]]; then
    print_error "Incorrect. Use: systemctl list-timers --all"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  NEXT                         LEFT     LAST                         PASSED    UNIT                       ACTIVATES"
  echo "  Fri 2025-12-21 14:20:00 EST  1min 3s  Fri 2025-12-21 14:18:00 EST  56s ago   cleanup.timer              cleanup.service"
  echo "  "
  echo "  1 timers listed."

  # STEP 2
  echo
  echo "  Step 2: Check the status of the timer unit."
  read -p "  $PROMPT" cmd2
  if [[ "$cmd2" != "systemctl status cleanup.timer" && "$cmd2" != "sudo systemctl status cleanup.timer" ]]; then
    print_error "Incorrect. Use: systemctl status cleanup.timer"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  ● cleanup.timer - Run cleanup job every 2 minutes"
  echo "     Loaded: loaded (/etc/systemd/system/cleanup.timer; enabled; vendor preset: disabled)"
  echo "     Active: active (waiting) since Fri 2025-12-21 14:18:00 EST; 2min ago"
  echo "    Trigger: Fri 2025-12-21 14:20:00 EST; 1min 3s left"
  echo "  "
  echo "  Dec 21 14:18:00 rhel-lab systemd[1]: Started Run cleanup job every 2 minutes."

  # STEP 3
  echo
  echo "  Step 3: Confirm which service the timer activates."
  read -p "  $PROMPT" cmd3
  if [[ "$cmd3" != "systemctl cat cleanup.timer" && "$cmd3" != "sudo systemctl cat cleanup.timer" ]]; then
    print_error "Incorrect. Use: systemctl cat cleanup.timer"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  # /etc/systemd/system/cleanup.timer"
  echo "  [Unit]"
  echo "  Description=Run cleanup job every 2 minutes"
  echo "  "
  echo "  [Timer]"
  echo "  OnUnitActiveSec=2min"
  echo "  Unit=cleanup.service"
  echo "  "
  echo "  [Install]"
  echo "  WantedBy=timers.target"

  # STEP 4
  echo
  echo "  Step 4: Check whether the activated service exists and is loadable."
  read -p "  $PROMPT" cmd4
  if [[ "$cmd4" != "systemctl status cleanup.service" && "$cmd4" != "sudo systemctl status cleanup.service" ]]; then
    print_error "Incorrect. Use: systemctl status cleanup.service"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  Unit cleanup.service could not be found."

  # STEP 5
  echo
  echo "  Step 5: Locate the actual cleanup service unit present on the system."
  read -p "  $PROMPT" cmd5
  if [[ "$cmd5" != "systemctl list-unit-files | grep cleanup" && "$cmd5" != "sudo systemctl list-unit-files | grep cleanup" ]]; then
    print_error "Incorrect. Use: systemctl list-unit-files | grep cleanup"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  cleanup-job.service                         static"
  echo "  cleanup.timer                               enabled"

  # STEP 6
  echo
  echo "  Step 6: Inspect the cleanup job service unit."
  read -p "  $PROMPT" cmd6
  if [[ "$cmd6" != "systemctl cat cleanup-job.service" && "$cmd6" != "sudo systemctl cat cleanup-job.service" ]]; then
    print_error "Incorrect. Use: systemctl cat cleanup-job.service"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  # /etc/systemd/system/cleanup-job.service"
  echo "  [Unit]"
  echo "  Description=Cleanup Job Service"
  echo "  "
  echo "  [Service]"
  echo "  Type=oneshot"
  echo "  ExecStart=/usr/local/bin/cleanup.sh"

  # STEP 7
  echo
  echo "  Step 7: Fix the timer so it activates the correct service."
  read -p "  $PROMPT" cmd7
  if [[ "$cmd7" != "sudo sed -i 's/Unit=cleanup.service/Unit=cleanup-job.service/' /etc/systemd/system/cleanup.timer" ]]; then
    print_error "Incorrect. Use: sudo sed -i 's/Unit=cleanup.service/Unit=cleanup-job.service/' /etc/systemd/system/cleanup.timer"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  "

  # STEP 8
  echo
  echo "  Step 8: Reload systemd to pick up the updated timer unit file."
  read -p "  $PROMPT" cmd8
  if [[ "$cmd8" != "sudo systemctl daemon-reload" && "$cmd8" != "systemctl daemon-reload" ]]; then
    print_error "Incorrect. Use: sudo systemctl daemon-reload"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  "

  # STEP 9
  echo
  echo "  Step 9: Restart the timer to apply the change."
  read -p "  $PROMPT" cmd9
  if [[ "$cmd9" != "sudo systemctl restart cleanup.timer" && "$cmd9" != "systemctl restart cleanup.timer" ]]; then
    print_error "Incorrect. Use: sudo systemctl restart cleanup.timer"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  "

  # STEP 10
  echo
  echo "  Step 10: Confirm the timer now activates the correct service."
  read -p "  $PROMPT" cmd10
  if [[ "$cmd10" != "systemctl list-timers --all | grep cleanup.timer" && "$cmd10" != "sudo systemctl list-timers --all | grep cleanup.timer" ]]; then
    print_error "Incorrect. Use: systemctl list-timers --all | grep cleanup.timer"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  Fri 2025-12-21 14:22:00 EST  1min 10s  Fri 2025-12-21 14:20:00 EST  50s ago   cleanup.timer  cleanup-job.service"

  # STEP 11
  echo
  echo "  Step 11: Manually start the service once to confirm it runs successfully."
  read -p "  $PROMPT" cmd11
  if [[ "$cmd11" != "sudo systemctl start cleanup-job.service" && "$cmd11" != "systemctl start cleanup-job.service" ]]; then
    print_error "Incorrect. Use: sudo systemctl start cleanup-job.service"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  "

  # STEP 12
  echo
  echo "  Step 12: Verify the service executed (check its last run status)."
  read -p "  $PROMPT" cmd12
  if [[ "$cmd12" != "systemctl status cleanup-job.service" && "$cmd12" != "sudo systemctl status cleanup-job.service" ]]; then
    print_error "Incorrect. Use: systemctl status cleanup-job.service"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  ● cleanup-job.service - Cleanup Job Service"
  echo "     Loaded: loaded (/etc/systemd/system/cleanup-job.service; static)"
  echo "     Active: inactive (dead) since Fri 2025-12-21 14:20:40 EST; 5s ago"
  echo "    Process: 1988 ExecStart=/usr/local/bin/cleanup.sh (code=exited, status=0/SUCCESS)"
  echo "  "
  echo "  Dec 21 14:20:40 rhel-lab systemd[1]: Started Cleanup Job Service."
  echo "  Dec 21 14:20:40 rhel-lab systemd[1]: cleanup-job.service: Succeeded."

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
