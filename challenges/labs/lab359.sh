#!/bin/bash

# Lab 359: RHEL Troubleshooting — service is enabled but not running after reboot (systemd unit failure)
# RHCSA focus: distinguishing enabled vs active, verifying boot-time state (systemctl is-enabled/is-active),
# inspecting failures (systemctl status, journalctl -u), checking unit definitions (systemctl cat),
# finding root cause (bad ExecStart path / missing file / invalid permissions),
# fixing safely (restore correct path/permissions, daemon-reload), and validating persistence across reboot.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 359"
LAB_ID="lab359"
LAB_XP=35900
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

PROMPT="student@lab359:~$ > "

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "RHEL Troubleshooting — after reboot, required service 'acme-backup.service' is ENABLED but NOT RUNNING."
  center_text "Diagnose why it did not start at boot and fix the underlying cause."
  echo
  center_text "Press Enter to begin."
  read _
  draw_lab_ui

  # STEP 1
  echo "  Step 1: Confirm the service is enabled."
  read -p "  $PROMPT" cmd1
  if [[ "$cmd1" != "systemctl is-enabled acme-backup.service" ]]; then
    print_error "Incorrect. Use: systemctl is-enabled acme-backup.service"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  enabled"

  # STEP 2
  echo
  echo "  Step 2: Confirm the service is not active (not running)."
  read -p "  $PROMPT" cmd2
  if [[ "$cmd2" != "systemctl is-active acme-backup.service" ]]; then
    print_error "Incorrect. Use: systemctl is-active acme-backup.service"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  inactive"

  # STEP 3
  echo
  echo "  Step 3: Check the current status to see failure details."
  read -p "  $PROMPT" cmd3
  if [[ "$cmd3" != "systemctl status acme-backup.service --no-pager" ]]; then
    print_error "Incorrect. Use: systemctl status acme-backup.service --no-pager"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  ● acme-backup.service - ACME Backup Agent"
  echo "     Loaded: loaded (/etc/systemd/system/acme-backup.service; enabled; vendor preset: disabled)"
  echo "     Active: failed (Result: exit-code) since Sun 2025-12-21 08:14:02 EST; 1min 12s ago"
  echo "    Process: 1881 ExecStart=/usr/local/bin/acme-backupd (code=exited, status=203/EXEC)"
  echo "   Main PID: 1881 (code=exited, status=203/EXEC)"
  echo "  "
  echo "  Dec 21 08:14:02 lab359 systemd[1]: acme-backup.service: Failed to execute command: No such file or directory"
  echo "  Dec 21 08:14:02 lab359 systemd[1]: acme-backup.service: Failed at step EXEC spawning /usr/local/bin/acme-backupd: No such file or directory"
  echo "  Dec 21 08:14:02 lab359 systemd[1]: acme-backup.service: Failed with result 'exit-code'."

  # STEP 4
  echo
  echo "  Step 4: Inspect the unit file to confirm what systemd is trying to start."
  read -p "  $PROMPT" cmd4
  if [[ "$cmd4" != "systemctl cat acme-backup.service" ]]; then
    print_error "Incorrect. Use: systemctl cat acme-backup.service"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  # /etc/systemd/system/acme-backup.service"
  echo "  [Unit]"
  echo "  Description=ACME Backup Agent"
  echo "  After=network-online.target"
  echo "  Wants=network-online.target"
  echo "  "
  echo "  [Service]"
  echo "  Type=simple"
  echo "  ExecStart=/usr/local/bin/acme-backupd"
  echo "  Restart=on-failure"
  echo "  "
  echo "  [Install]"
  echo "  WantedBy=multi-user.target"

  # STEP 5
  echo
  echo "  Step 5: Verify whether the ExecStart path exists on disk."
  read -p "  $PROMPT" cmd5
  if [[ "$cmd5" != "ls -l /usr/local/bin/acme-backupd" ]]; then
    print_error "Incorrect. Use: ls -l /usr/local/bin/acme-backupd"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  ls: cannot access '/usr/local/bin/acme-backupd': No such file or directory"

  # STEP 6
  echo
  echo "  Step 6: Locate the actual binary/script that should be executed."
  read -p "  $PROMPT" cmd6
  if [[ "$cmd6" != "command -v acme-backupd || find /usr/local/bin /usr/bin -maxdepth 1 -type f -name 'acme-backupd*' 2>/dev/null" ]]; then
    print_error "Incorrect. Use: command -v acme-backupd || find /usr/local/bin /usr/bin -maxdepth 1 -type f -name 'acme-backupd*' 2>/dev/null"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  /usr/local/bin/acme-backupd.sh"

  # STEP 7
  echo
  echo "  Step 7: Fix the service so ExecStart points to the correct path."
  read -p "  $PROMPT" cmd7
  if [[ "$cmd7" != "sudo systemctl edit --full acme-backup.service" ]]; then
    print_error "Incorrect. Use: sudo systemctl edit --full acme-backup.service"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  (editor opened)"
  echo "  Update ExecStart to: ExecStart=/usr/local/bin/acme-backupd.sh"
  echo "  Save and exit."

  # STEP 8
  echo
  echo "  Step 8: Reload systemd so it recognizes the updated unit file."
  read -p "  $PROMPT" cmd8
  if [[ "$cmd8" != "sudo systemctl daemon-reload" ]]; then
    print_error "Incorrect. Use: sudo systemctl daemon-reload"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  (no output)"

  # STEP 9
  echo
  echo "  Step 9: Start the service and confirm it runs successfully now."
  read -p "  $PROMPT" cmd9
  if [[ "$cmd9" != "sudo systemctl start acme-backup.service && systemctl is-active acme-backup.service" ]]; then
    print_error "Incorrect. Use: sudo systemctl start acme-backup.service && systemctl is-active acme-backup.service"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  active"

  # STEP 10
  echo
  echo "  Step 10: Check logs for a clean startup and confirm there are no new errors."
  read -p "  $PROMPT" cmd10
  if [[ "$cmd10" != "journalctl -u acme-backup.service -b --no-pager | tail -n 10" ]]; then
    print_error "Incorrect. Use: journalctl -u acme-backup.service -b --no-pager | tail -n 10"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  Dec 21 08:16:44 lab359 systemd[1]: Started ACME Backup Agent."
  echo "  Dec 21 08:16:44 lab359 acme-backupd.sh[2410]: acme-backup: initialized"
  echo "  Dec 21 08:16:44 lab359 acme-backupd.sh[2410]: acme-backup: running"

  # STEP 11
  echo
  echo "  Step 11: Verify the service is enabled AND will start on future boots."
  read -p "  $PROMPT" cmd11
  if [[ "$cmd11" != "systemctl is-enabled acme-backup.service && systemctl status acme-backup.service --no-pager | sed -n '1,6p'" ]]; then
    print_error "Incorrect. Use: systemctl is-enabled acme-backup.service && systemctl status acme-backup.service --no-pager | sed -n '1,6p'"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  enabled"
  echo "  ● acme-backup.service - ACME Backup Agent"
  echo "     Loaded: loaded (/etc/systemd/system/acme-backup.service; enabled; vendor preset: disabled)"
  echo "     Active: active (running) since Sun 2025-12-21 08:16:44 EST; 12s ago"

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
