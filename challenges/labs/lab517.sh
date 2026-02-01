#!/bin/bash

# Lab 517: Configure Network Services to Start Automatically at Boot (Rocky 10 / RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 517: Network Services Autostart (Rocky 10 / RHCSA)"
LAB_ID="lab517"
LAB_XP=51700
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab517:~$ "

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
  center_text "A server reboot window is scheduled. You must ensure key network services"
  center_text "come back automatically after boot and verify they are enabled and running."
  echo
  center_text "Targets:"
  center_text "- NetworkManager"
  center_text "- firewalld"
  center_text "- sshd"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Verify NetworkManager is enabled to start at boot."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "systemctl is-enabled NetworkManager" && "$cmd1" != "sudo systemctl is-enabled NetworkManager" ]]; then
    print_error "Incorrect. Use: systemctl is-enabled NetworkManager"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  enabled"
  echo

  echo "  Step 2: Enable NetworkManager to start at boot (if it was disabled)."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo systemctl enable NetworkManager" ]]; then
    print_error "Incorrect. Use: sudo systemctl enable NetworkManager"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Created symlink /etc/systemd/system/multi-user.target.wants/NetworkManager.service → /usr/lib/systemd/system/NetworkManager.service."
  echo

  echo "  Step 3: Start NetworkManager now (ensure it is running in this session)."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo systemctl start NetworkManager" ]]; then
    print_error "Incorrect. Use: sudo systemctl start NetworkManager"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 4: Confirm NetworkManager service status is active (running)."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "systemctl status NetworkManager --no-pager" && "$cmd4" != "sudo systemctl status NetworkManager --no-pager" ]]; then
    print_error "Incorrect. Use: systemctl status NetworkManager --no-pager"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  ● NetworkManager.service - Network Manager"
  echo "     Loaded: loaded (/usr/lib/systemd/system/NetworkManager.service; enabled; vendor preset: enabled)"
  echo "     Active: active (running) since Tue 2026-02-01 19:10:12 EST; 1min ago"
  echo

  echo "  Step 5: Enable firewalld to start at boot."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo systemctl enable firewalld" ]]; then
    print_error "Incorrect. Use: sudo systemctl enable firewalld"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Created symlink /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service → /usr/lib/systemd/system/firewalld.service."
  echo "  Created symlink /etc/systemd/system/multi-user.target.wants/firewalld.service → /usr/lib/systemd/system/firewalld.service."
  echo

  echo "  Step 6: Start firewalld now."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo systemctl start firewalld" ]]; then
    print_error "Incorrect. Use: sudo systemctl start firewalld"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 7: Confirm firewalld is active (running)."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "systemctl status firewalld --no-pager" && "$cmd7" != "sudo systemctl status firewalld --no-pager" ]]; then
    print_error "Incorrect. Use: systemctl status firewalld --no-pager"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  ● firewalld.service - firewalld - dynamic firewall daemon"
  echo "     Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; vendor preset: enabled)"
  echo "     Active: active (running) since Tue 2026-02-01 19:11:02 EST; 20s ago"
  echo

  echo "  Step 8: Enable sshd to start at boot."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo systemctl enable sshd" ]]; then
    print_error "Incorrect. Use: sudo systemctl enable sshd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Created symlink /etc/systemd/system/multi-user.target.wants/sshd.service → /usr/lib/systemd/system/sshd.service."
  echo

  echo "  Step 9: Start sshd now."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo systemctl start sshd" ]]; then
    print_error "Incorrect. Use: sudo systemctl start sshd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 10: Confirm sshd is active (running)."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "systemctl status sshd --no-pager" && "$cmd10" != "sudo systemctl status sshd --no-pager" ]]; then
    print_error "Incorrect. Use: systemctl status sshd --no-pager"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  ● sshd.service - OpenSSH server daemon"
  echo "     Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)"
  echo "     Active: active (running) since Tue 2026-02-01 19:11:30 EST; 5s ago"
  echo

  echo "  Step 11: Verify all three services are enabled at boot in one check."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "systemctl is-enabled NetworkManager firewalld sshd" && "$cmd11" != "sudo systemctl is-enabled NetworkManager firewalld sshd" ]]; then
    print_error "Incorrect. Use: systemctl is-enabled NetworkManager firewalld sshd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  enabled"
  echo "  enabled"
  echo "  enabled"
  echo

  echo "  Step 12: List enabled services and confirm sshd, firewalld, and NetworkManager appear."
  read -p "$PROMPT" cmd12
  echo
  if [[ "$cmd12" != "systemctl list-unit-files --type=service --state=enabled" && "$cmd12" != "sudo systemctl list-unit-files --type=service --state=enabled" ]]; then
    print_error "Incorrect. Use: systemctl list-unit-files --type=service --state=enabled"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  UNIT FILE           STATE"
  echo "  firewalld.service   enabled"
  echo "  NetworkManager.service enabled"
  echo "  sshd.service        enabled"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- enabled key network services to start automatically at boot"
  print_info "- started services immediately and verified active status"
  print_info "- confirmed enablement state using systemctl is-enabled"
  print_info "- validated enabled service inventory using systemctl list-unit-files"
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
