#!/bin/bash

# Lab 518: Restrict Network Access Using firewalld / firewall-cmd (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 518: Restrict Network Access Using firewalld (RHCSA)"
LAB_ID="lab518"
LAB_XP=51800
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab518:~$ "

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
  center_text "You are hardening a server's firewall policy before exposing it to a public network."
  center_text "The server must allow SSH for admin access and allow a web app on TCP 8080."
  center_text "HTTP (80) must NOT be allowed. All changes must be persistent."
  echo
  center_text "Targets:"
  center_text "- firewalld service"
  center_text "- public zone rules"
  center_text "- ssh service allowed"
  center_text "- tcp/8080 allowed"
  center_text "- http service removed/blocked"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Start the firewalld service."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "sudo systemctl start firewalld" ]]; then
    print_error "Incorrect. Use: sudo systemctl start firewalld"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 2: Enable firewalld to start automatically at boot."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo systemctl enable firewalld" ]]; then
    print_error "Incorrect. Use: sudo systemctl enable firewalld"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Created symlink /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service → /usr/lib/systemd/system/firewalld.service."
  echo "  Created symlink /etc/systemd/system/multi-user.target.wants/firewalld.service → /usr/lib/systemd/system/firewalld.service."
  echo

  echo "  Step 3: Verify firewalld is active (running)."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "systemctl status firewalld --no-pager" && "$cmd3" != "sudo systemctl status firewalld --no-pager" ]]; then
    print_error "Incorrect. Use: systemctl status firewalld --no-pager"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  ● firewalld.service - firewalld - dynamic firewall daemon"
  echo "     Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; vendor preset: enabled)"
  echo "     Active: active (running) since Tue 2026-02-01 19:20:10 EST; 30s ago"
  echo

  echo "  Step 4: Confirm the default zone is public."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "firewall-cmd --get-default-zone" && "$cmd4" != "sudo firewall-cmd --get-default-zone" ]]; then
    print_error "Incorrect. Use: firewall-cmd --get-default-zone"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  public"
  echo

  echo "  Step 5: List currently allowed services in the public zone."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "firewall-cmd --zone=public --list-services" && "$cmd5" != "sudo firewall-cmd --zone=public --list-services" ]]; then
    print_error "Incorrect. Use: firewall-cmd --zone=public --list-services"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  ssh dhcpv6-client"
  echo

  echo "  Step 6: Ensure SSH is allowed in the public zone (add it if missing)."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo firewall-cmd --zone=public --add-service=ssh" ]]; then
    print_error "Incorrect. Use: sudo firewall-cmd --zone=public --add-service=ssh"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  success"
  echo

  echo "  Step 7: Add TCP port 8080 to the public zone (runtime)."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo firewall-cmd --zone=public --add-port=8080/tcp" ]]; then
    print_error "Incorrect. Use: sudo firewall-cmd --zone=public --add-port=8080/tcp"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  success"
  echo

  echo "  Step 8: Verify TCP 8080 is currently open in the public zone."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "firewall-cmd --zone=public --list-ports" && "$cmd8" != "sudo firewall-cmd --zone=public --list-ports" ]]; then
    print_error "Incorrect. Use: firewall-cmd --zone=public --list-ports"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  8080/tcp"
  echo

  echo "  Step 9: Remove HTTP service from the public zone (ensure port 80 is NOT allowed)."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo firewall-cmd --zone=public --remove-service=http" ]]; then
    print_error "Incorrect. Use: sudo firewall-cmd --zone=public --remove-service=http"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  success"
  echo

  echo "  Step 10: Save the current runtime firewall configuration to permanent."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "sudo firewall-cmd --runtime-to-permanent" ]]; then
    print_error "Incorrect. Use: sudo firewall-cmd --runtime-to-permanent"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  success"
  echo

  echo "  Step 11: Reload firewalld so permanent rules are applied cleanly."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "sudo firewall-cmd --reload" ]]; then
    print_error "Incorrect. Use: sudo firewall-cmd --reload"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  success"
  echo

  echo "  Step 12: Verify permanent rules: list services and ports in public zone."
  read -p "$PROMPT" cmd12
  echo
  if [[ "$cmd12" != "firewall-cmd --zone=public --list-all" && "$cmd12" != "sudo firewall-cmd --zone=public --list-all" ]]; then
    print_error "Incorrect. Use: firewall-cmd --zone=public --list-all"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  public (active)"
  echo "    target: default"
  echo "    icmp-block-inversion: no"
  echo "    interfaces: eth0"
  echo "    sources:"
  echo "    services: ssh dhcpv6-client"
  echo "    ports: 8080/tcp"
  echo "    protocols:"
  echo "    forward: no"
  echo "    masquerade: no"
  echo "    forward-ports:"
  echo "    source-ports:"
  echo "    icmp-blocks:"
  echo "    rich rules:"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- ensured firewalld is running and enabled at boot"
  print_info "- restricted access using the public zone"
  print_info "- allowed SSH for administration"
  print_info "- allowed only TCP 8080 for the web app"
  print_info "- removed HTTP service (no port 80 exposure)"
  print_info "- made changes persistent and verified after reload"
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
