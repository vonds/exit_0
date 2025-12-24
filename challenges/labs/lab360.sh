#!/bin/bash

# Lab 360: RHEL Troubleshooting — service runs but listens on the wrong port (socket/bind/config mismatch)
# RHCSA focus: verifying listeners (ss), mapping ports to processes (ss -lntp), checking unit state (systemctl),
# inspecting service config/environment (systemctl cat, /etc/sysconfig, /etc/*), validating firewall/SELinux context if needed,
# correcting the configured port safely, reloading daemons, restarting services, and verifying persistence across reboot.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 360"
LAB_ID="lab360"
LAB_XP=36000
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

PROMPT="student@lab360:~$ > "

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "RHEL Troubleshooting — 'acme-api.service' is RUNNING, but clients can't connect on the expected port."
  center_text "The service should listen on TCP 8080, but it's listening on the wrong port."
  center_text "Find the cause, correct it safely, and verify it stays correct after restart/reboot."
  echo
  center_text "Press Enter to begin."
  read _
  draw_lab_ui

  # STEP 1
  echo "  Step 1: Confirm the service is running."
  read -p "  $PROMPT" cmd1
  if [[ "$cmd1" != "systemctl is-active acme-api.service" ]]; then
    print_error "Incorrect. Use: systemctl is-active acme-api.service"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  active"

  # STEP 2
  echo
  echo "  Step 2: Verify which TCP port the service is listening on (show listening TCP sockets)."
  read -p "  $PROMPT" cmd2
  if [[ "$cmd2" != "ss -lntp" ]]; then
    print_error "Incorrect. Use: ss -lntp"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  State  Recv-Q Send-Q Local Address:Port  Peer Address:Port Process"
  echo "  LISTEN 0      4096   0.0.0.0:9090       0.0.0.0:*     users:((\"acme-api\",pid=2140,fd=7))"

  # STEP 3
  echo
  echo "  Step 3: Confirm expected port is NOT listening (8080)."
  read -p "  $PROMPT" cmd3
  if [[ "$cmd3" != "ss -lntp | grep -E ':8080\\b' || echo 'not listening on 8080'" ]]; then
    print_error "Incorrect. Use: ss -lntp | grep -E ':8080\\b' || echo 'not listening on 8080'"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  not listening on 8080"

  # STEP 4
  echo
  echo "  Step 4: Inspect the systemd unit to see how the service is started (look for config/env flags)."
  read -p "  $PROMPT" cmd4
  if [[ "$cmd4" != "systemctl cat acme-api.service" ]]; then
    print_error "Incorrect. Use: systemctl cat acme-api.service"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  # /etc/systemd/system/acme-api.service"
  echo "  [Unit]"
  echo "  Description=ACME API Service"
  echo "  After=network-online.target"
  echo "  Wants=network-online.target"
  echo "  "
  echo "  [Service]"
  echo "  Type=simple"
  echo "  EnvironmentFile=-/etc/sysconfig/acme-api"
  echo "  ExecStart=/usr/local/bin/acme-api --port \${ACME_PORT}"
  echo "  Restart=on-failure"
  echo "  "
  echo "  [Install]"
  echo "  WantedBy=multi-user.target"

  # STEP 5
  echo
  echo "  Step 5: Show the configured port from the environment file."
  read -p "  $PROMPT" cmd5
  if [[ "$cmd5" != "sudo cat /etc/sysconfig/acme-api" ]]; then
    print_error "Incorrect. Use: sudo cat /etc/sysconfig/acme-api"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  ACME_PORT=9090"

  # STEP 6
  echo
  echo "  Step 6: Fix the configuration so the service uses the expected port (8080)."
  read -p "  $PROMPT" cmd6
  if [[ "$cmd6" != "sudo sed -i 's/^ACME_PORT=.*/ACME_PORT=8080/' /etc/sysconfig/acme-api" ]]; then
    print_error "Incorrect. Use: sudo sed -i 's/^ACME_PORT=.*/ACME_PORT=8080/' /etc/sysconfig/acme-api"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  (no output)"

  # STEP 7
  echo
  echo "  Step 7: Restart the service so it picks up the updated environment."
  read -p "  $PROMPT" cmd7
  if [[ "$cmd7" != "sudo systemctl restart acme-api.service" ]]; then
    print_error "Incorrect. Use: sudo systemctl restart acme-api.service"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  (no output)"

  # STEP 8
  echo
  echo "  Step 8: Verify the service is now listening on 8080 and no longer on 9090."
  read -p "  $PROMPT" cmd8
  if [[ "$cmd8" != "ss -lntp | grep -E ':(8080|9090)\\b'" ]]; then
    print_error "Incorrect. Use: ss -lntp | grep -E ':(8080|9090)\\b'"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  LISTEN 0      4096   0.0.0.0:8080       0.0.0.0:*     users:((\"acme-api\",pid=2288,fd=7))"

  # STEP 9
  echo
  echo "  Step 9: Confirm systemd sees the service as running and that it loaded the environment file."
  read -p "  $PROMPT" cmd9
  if [[ "$cmd9" != "systemctl status acme-api.service --no-pager | sed -n '1,10p'" ]]; then
    print_error "Incorrect. Use: systemctl status acme-api.service --no-pager | sed -n '1,10p'"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  ● acme-api.service - ACME API Service"
  echo "     Loaded: loaded (/etc/systemd/system/acme-api.service; enabled; vendor preset: disabled)"
  echo "     Active: active (running) since Sun 2025-12-21 09:02:11 EST; 9s ago"
  echo "   Main PID: 2288 (acme-api)"
  echo "      Tasks: 5"
  echo "     Memory: 12.3M"
  echo "        CPU: 120ms"
  echo "     CGroup: /system.slice/acme-api.service"
  echo "             └─2288 /usr/local/bin/acme-api --port 8080"

  # STEP 10
  echo
  echo "  Step 10: Validate the local endpoint responds on the expected port."
  read -p "  $PROMPT" cmd10
  if [[ "$cmd10" != "curl -sS http://127.0.0.1:8080/health || echo 'health check failed'" ]]; then
    print_error "Incorrect. Use: curl -sS http://127.0.0.1:8080/health || echo 'health check failed'"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  ok"

  # STEP 11
  echo
  echo "  Step 11: Ensure the service will keep using 8080 after reboot (confirm the config persists)."
  read -p "  $PROMPT" cmd11
  if [[ "$cmd11" != "grep -E '^ACME_PORT=' /etc/sysconfig/acme-api" ]]; then
    print_error "Incorrect. Use: grep -E '^ACME_PORT=' /etc/sysconfig/acme-api"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  ACME_PORT=8080"

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
