#!/bin/bash

# Lab 468: Rocky Linux 10 Startup Processes — systemd Service Management (RHCSA Focus)
# Focus: checking service status, identifying unit file paths, managing enable/disable,
# starting/stopping/restarting, masking/unmasking, daemon-reload, targets, and journal review.
# Key skills: systemctl status/is-active/is-enabled/start/stop/restart/enable/disable/mask/unmask,
# systemctl show/cat/list-dependencies/get-default, systemctl daemon-reload,
# journalctl -u, and safe verification workflows.
#
# Note: This lab assumes a Rocky Linux 10 host (RHEL-compatible). Commands are RHCSA-aligned.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 468: Rocky 10 systemd Service Management (RHCSA)"
LAB_ID="lab468"
LAB_XP=46800
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"

[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@rhel-lab468:~$ "

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

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "Scenario:"
  center_text "You're on a Rocky Linux 10 server where a teammate reports inconsistent service behavior after reboots."
  center_text "You must validate unit state, adjust startup behavior, apply a unit change,"
  center_text "reload systemd, verify targets, and confirm via logs — RHCSA-style."
  echo
  center_text "Requirements (type commands exactly):"
  center_text "- Inspect sshd state and confirm it is active"
  center_text "- Identify the sshd unit file path"
  center_text "- Enable and start httpd at boot"
  center_text "- Verify httpd enable state and active state"
  center_text "- Mask httpd (prevent any start), confirm it cannot be started"
  center_text "- Unmask httpd, then disable it (no autostart), and stop it"
  center_text "- Enable rpcbind (do not start it now)"
  center_text "- Apply a unit file change: reload systemd manager (daemon-reload)"
  center_text "- Confirm default target and list key dependencies of multi-user target"
  center_text "- View recent logs for sshd using journalctl -u"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  # STEP 1: systemctl status sshd.service
  echo "  Step 1: Check sshd service status."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "systemctl status sshd.service" && \
        "$cmd1" != "sudo systemctl status sshd.service" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "● sshd.service - OpenSSH server daemon"
  echo "     Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; preset: enabled)"
  echo "     Active: active (running) since Thu 2026-01-15 11:20:18 UTC; 25min ago"
  echo "       Docs: man:sshd(8)"
  echo "             man:sshd_config(5)"
  echo "   Main PID: 1383 (sshd)"
  echo "      Tasks: 1 (limit: 411434)"
  echo "     Memory: 16.9M"
  echo "     CGroup: /system.slice/sshd.service"
  echo "             └─1383 \"sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups\""
  echo

  # STEP 2: Confirm sshd active state
  echo "  Step 2: Confirm sshd is active using systemctl is-active."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "systemctl is-active sshd.service" && \
        "$cmd2" != "sudo systemctl is-active sshd.service" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "active"
  echo

  # STEP 3: Identify unit file path (no random files)
  echo "  Step 3: Display the unit file path for sshd using systemctl show."
  echo "          (Hint: use the FragmentPath property)"
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "systemctl show -p FragmentPath sshd.service" && \
        "$cmd3" != "sudo systemctl show -p FragmentPath sshd.service" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "FragmentPath=/usr/lib/systemd/system/sshd.service"
  echo

  # STEP 4: Check httpd enable state
  echo "  Step 4: Check whether httpd is enabled."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "systemctl is-enabled httpd.service" && \
        "$cmd4" != "sudo systemctl is-enabled httpd.service" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "disabled"
  echo

  # STEP 5: Enable and start httpd
  echo "  Step 5: Enable and start httpd immediately."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo systemctl enable --now httpd.service" && \
        "$cmd5" != "systemctl enable --now httpd.service" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service."
  echo

  # STEP 6: Verify httpd enabled
  echo "  Step 6: Verify httpd is enabled."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "systemctl is-enabled httpd.service" && \
        "$cmd6" != "sudo systemctl is-enabled httpd.service" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "enabled"
  echo

  # STEP 7: Verify httpd active
  echo "  Step 7: Verify httpd is active."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "systemctl is-active httpd.service" && \
        "$cmd7" != "sudo systemctl is-active httpd.service" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "active"
  echo

  # STEP 8: Mask httpd
  echo "  Step 8: Mask httpd so it cannot be started by anything."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo systemctl mask httpd.service" && \
        "$cmd8" != "systemctl mask httpd.service" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "Created symlink /etc/systemd/system/httpd.service → /dev/null."
  echo

  # STEP 9: Attempt to start masked service (expect failure)
  echo "  Step 9: Try to start httpd while it is masked (should fail)."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo systemctl start httpd.service" && \
        "$cmd9" != "systemctl start httpd.service" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "Failed to start httpd.service: Unit httpd.service is masked."
  echo

  # STEP 10: Unmask httpd
  echo "  Step 10: Unmask httpd."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "sudo systemctl unmask httpd.service" && \
        "$cmd10" != "systemctl unmask httpd.service" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "Removed \"/etc/systemd/system/httpd.service\"."
  echo

  # STEP 11: Disable httpd (no autostart)
  echo "  Step 11: Disable httpd so it does not start at boot."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "sudo systemctl disable httpd.service" && \
        "$cmd11" != "systemctl disable httpd.service" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "Removed \"/etc/systemd/system/multi-user.target.wants/httpd.service\"."
  echo

  # STEP 12: Stop httpd
  echo "  Step 12: Stop httpd now."
  read -p "$PROMPT" cmd12
  echo
  if [[ "$cmd12" != "sudo systemctl stop httpd.service" && \
        "$cmd12" != "systemctl stop httpd.service" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo
  echo "  (httpd stopped)"
  echo

  # STEP 13: Enable rpcbind (do not start now)
  echo "  Step 13: Enable rpcbind at boot (do NOT start it now)."
  read -p "$PROMPT" cmd13
  echo
  if [[ "$cmd13" != "sudo systemctl enable rpcbind.service" && \
        "$cmd13" != "systemctl enable rpcbind.service" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "Created symlink /etc/systemd/system/multi-user.target.wants/rpcbind.service → /usr/lib/systemd/system/rpcbind.service."
  echo

  # STEP 14: daemon-reload
  echo "  Step 14: Reload systemd manager configuration (daemon-reload)."
  read -p "$PROMPT" cmd14
  echo
  if [[ "$cmd14" != "sudo systemctl daemon-reload" && \
        "$cmd14" != "systemctl daemon-reload" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo
  echo "  (daemon-reload complete)"
  echo

  # STEP 15: Confirm default target
  echo "  Step 15: Show the current default target."
  read -p "$PROMPT" cmd15
  echo
  if [[ "$cmd15" != "systemctl get-default" && \
        "$cmd15" != "sudo systemctl get-default" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "multi-user.target"
  echo

  # STEP 16: List dependencies of multi-user target
  echo "  Step 16: List dependencies of multi-user.target."
  read -p "$PROMPT" cmd16
  echo
  if [[ "$cmd16" != "systemctl list-dependencies multi-user.target" && \
        "$cmd16" != "sudo systemctl list-dependencies multi-user.target" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "multi-user.target"
  echo "● ├─basic.target"
  echo "● ├─getty.target"
  echo "● ├─network.target"
  echo "● ├─remote-fs.target"
  echo "● ├─sshd.service"
  echo "● └─systemd-user-sessions.service"
  echo

  # STEP 17: View logs for sshd
  echo "  Step 17: Show the most recent 10 journal entries for sshd."
  read -p "$PROMPT" cmd17
  echo
  if [[ "$cmd17" != "sudo journalctl -u sshd.service -n 10" && \
        "$cmd17" != "journalctl -u sshd.service -n 10" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "Jan 15 11:20:18 rocky10 systemd[1]: Starting OpenSSH server daemon..."
  echo "Jan 15 11:20:18 rocky10 sshd[1383]: Server listening on 0.0.0.0 port 22."
  echo "Jan 15 11:20:18 rocky10 sshd[1383]: Server listening on :: port 22."
  echo "Jan 15 11:20:18 rocky10 systemd[1]: Started OpenSSH server daemon."
  echo

  print_success "Great job."
  print_info "You practiced RHCSA systemd skills:"
  print_info "- inspected status and verified active/enabled state"
  print_info "- identified unit file paths using systemctl show"
  print_info "- enabled/started services, disabled/stopped services"
  print_info "- masked/unmasked a service and confirmed masked behavior"
  print_info "- reloaded systemd manager configuration (daemon-reload)"
  print_info "- validated default target and dependencies"
  print_info "- checked service logs with journalctl -u"
  print_info "You earned $LAB_XP XP for completing this lab."
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

  [[ "$choice" == "2" ]] && exit 0
done
