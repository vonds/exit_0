#!/bin/bash

# Lab 523: Configure Firewall Settings Using firewall-cmd + firewalld (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 523: Firewall Settings (firewalld) (RHCSA)"
LAB_ID="lab523"
LAB_XP=52300
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab523:~$ "

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
  center_text "A server is being prepared for production. You must enforce firewall policy"
  center_text "using firewalld. The security team requires service-based rules, port rules,"
  center_text "zone awareness, interface assignment, and persistent configuration."
  echo
  center_text "Targets:"
  center_text "- start/enable firewalld"
  center_text "- zones: list, default, active"
  center_text "- allow/remove services"
  center_text "- open/close ports"
  center_text "- interface to zone assignment"
  center_text "- persistence vs runtime"
  center_text "- verify configuration with list-all"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Start the firewalld service now."
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
  echo "  Created symlink /etc/systemd/system/multi-user.target.wants/firewalld.service -> /usr/lib/systemd/system/firewalld.service."
  echo

  echo "  Step 3: Verify firewalld is running (check status)."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo systemctl status firewalld" ]]; then
    print_error "Incorrect. Use: sudo systemctl status firewalld"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  ● firewalld.service - firewalld - dynamic firewall daemon"
  echo "     Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; vendor preset: enabled)"
  echo "     Active: active (running)"
  echo

  echo "  Step 4: List all available firewalld zones."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo firewall-cmd --get-zones" ]]; then
    print_error "Incorrect. Use: sudo firewall-cmd --get-zones"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  block dmz drop external home internal public trusted work"
  echo

  echo "  Step 5: Display the current default zone."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo firewall-cmd --get-default-zone" ]]; then
    print_error "Incorrect. Use: sudo firewall-cmd --get-default-zone"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  public"
  echo

  echo "  Step 6: Show the active zone(s) and which interface(s) are assigned."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo firewall-cmd --get-active-zones" ]]; then
    print_error "Incorrect. Use: sudo firewall-cmd --get-active-zones"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  public"
  echo "    interfaces: eth0"
  echo

  echo "  Step 7: Add ssh and http services to the public zone (runtime)."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo firewall-cmd --zone=public --add-service=ssh && sudo firewall-cmd --zone=public --add-service=http" ]]; then
    print_error "Incorrect. Use: sudo firewall-cmd --zone=public --add-service=ssh && sudo firewall-cmd --zone=public --add-service=http"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  success"
  echo "  success"
  echo

  echo "  Step 8: Verify allowed services in the public zone (runtime view)."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo firewall-cmd --zone=public --list-services" ]]; then
    print_error "Incorrect. Use: sudo firewall-cmd --zone=public --list-services"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  dhcpv6-client http ssh"
  echo

  echo "  Step 9: Open TCP port 8080 in the public zone (runtime)."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo firewall-cmd --zone=public --add-port=8080/tcp" ]]; then
    print_error "Incorrect. Use: sudo firewall-cmd --zone=public --add-port=8080/tcp"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  success"
  echo

  echo "  Step 10: Verify open ports in the public zone (runtime view)."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "sudo firewall-cmd --zone=public --list-ports" ]]; then
    print_error "Incorrect. Use: sudo firewall-cmd --zone=public --list-ports"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  8080/tcp"
  echo

  echo "  Step 11: Make current runtime rules persistent."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "sudo firewall-cmd --runtime-to-permanent" ]]; then
    print_error "Incorrect. Use: sudo firewall-cmd --runtime-to-permanent"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  success"
  echo

  echo "  Step 12: Remove the http service AND close port 8080/tcp (runtime)."
  read -p "$PROMPT" cmd12
  echo
  if [[ "$cmd12" != "sudo firewall-cmd --zone=public --remove-service=http && sudo firewall-cmd --zone=public --remove-port=8080/tcp" ]]; then
    print_error "Incorrect. Use: sudo firewall-cmd --zone=public --remove-service=http && sudo firewall-cmd --zone=public --remove-port=8080/tcp"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  success"
  echo "  success"
  echo

  echo "  Step 13: Verify http is removed and port 8080 is closed (runtime view)."
  read -p "$PROMPT" cmd13
  echo
  if [[ "$cmd13" != "sudo firewall-cmd --zone=public --list-services && sudo firewall-cmd --zone=public --list-ports" ]]; then
    print_error "Incorrect. Use: sudo firewall-cmd --zone=public --list-services && sudo firewall-cmd --zone=public --list-ports"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  dhcpv6-client ssh"
  echo "  (no output)"
  echo

  echo "  Step 14: Persist the removal changes by writing runtime rules to permanent."
  read -p "$PROMPT" cmd14
  echo
  if [[ "$cmd14" != "sudo firewall-cmd --runtime-to-permanent" ]]; then
    print_error "Incorrect. Use: sudo firewall-cmd --runtime-to-permanent"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  success"
  echo

  echo "  Step 15: Move interface eth0 into the trusted zone (runtime)."
  read -p "$PROMPT" cmd15
  echo
  if [[ "$cmd15" != "sudo firewall-cmd --zone=trusted --change-interface=eth0" ]]; then
    print_error "Incorrect. Use: sudo firewall-cmd --zone=trusted --change-interface=eth0"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  success"
  echo

  echo "  Step 16: Verify active zones now show eth0 under trusted."
  read -p "$PROMPT" cmd16
  echo
  if [[ "$cmd16" != "sudo firewall-cmd --get-active-zones" ]]; then
    print_error "Incorrect. Use: sudo firewall-cmd --get-active-zones"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  trusted"
  echo "    interfaces: eth0"
  echo

  echo "  Step 17: Make the interface assignment persistent."
  read -p "$PROMPT" cmd17
  echo
  if [[ "$cmd17" != "sudo firewall-cmd --runtime-to-permanent" ]]; then
    print_error "Incorrect. Use: sudo firewall-cmd --runtime-to-permanent"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  success"
  echo

  echo "  Step 18: Reload firewalld to ensure permanent configuration is applied cleanly."
  read -p "$PROMPT" cmd18
  echo
  if [[ "$cmd18" != "sudo firewall-cmd --reload" ]]; then
    print_error "Incorrect. Use: sudo firewall-cmd --reload"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  success"
  echo

  echo "  Step 19: Show the full firewall configuration for the trusted zone."
  read -p "$PROMPT" cmd19
  echo
  if [[ "$cmd19" != "sudo firewall-cmd --zone=trusted --list-all" ]]; then
    print_error "Incorrect. Use: sudo firewall-cmd --zone=trusted --list-all"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  trusted (active)"
  echo "    target: ACCEPT"
  echo "    interfaces: eth0"
  echo "    services:"
  echo "    ports:"
  echo "    protocols:"
  echo "    masquerade: no"
  echo "    forward-ports:"
  echo "    source-ports:"
  echo "    icmp-blocks:"
  echo "    rich rules:"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- started and enabled firewalld"
  print_info "- inspected zones (available, default, active)"
  print_info "- added and removed services and ports"
  print_info "- distinguished runtime vs permanent rules and persisted changes correctly"
  print_info "- assigned an interface to a different zone and verified the result"
  print_info "- verified configuration with --list-all and applied with --reload"
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
