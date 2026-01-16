#!/bin/bash

# Lab 470: Rocky Linux 10 Networking — Interfaces, Routes, Ports, Hosts, DNS (RHCSA Focus)
# Focus: inspecting interfaces/routes, checking listening ports, and MANUALLY editing
# /etc/hosts and /etc/resolv.conf using vi-style entry (RHCSA expectations).
# Key skills: ip, ss, netstat, editing critical network files, hostnamectl.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 470: Networking Inspection & Configuration (Rocky 10)"
LAB_ID="lab470"
LAB_XP=47000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"

[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@rhel-lab470:~$ "

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
  center_text "You're validating and adjusting network configuration on a Rocky Linux 10 server."
  center_text "You must inspect interfaces and routes, verify listening services,"
  center_text "and manually update name resolution files using vi."
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  # STEP 1: ip a
  echo "  Step 1: Display all network interfaces."
  read -p "$PROMPT" cmd1
  echo
  [[ "$cmd1" != "ip a" && "$cmd1" != "ip addr" ]] && { print_error "Incorrect."; read _; continue; }
  echo "  4: eth0: <UP> mtu 1410"
  echo "      inet 192.168.58.136/32 scope global eth0"
  echo

  # STEP 2: ip route show
  echo "  Step 2: Show routing table."
  read -p "$PROMPT" cmd2
  echo
  [[ "$cmd2" != "ip route show" ]] && { print_error "Incorrect."; read _; continue; }
  echo "  default via 169.254.1.1 dev eth0"
  echo

  # STEP 3: ss -tlnp | grep :22
  echo "  Step 3: Verify SSH is listening on port 22."
  read -p "$PROMPT" cmd3
  echo
  [[ "$cmd3" != "sudo ss -tlnp | grep :22" && "$cmd3" != "ss -tlnp | grep :22" ]] && { print_error "Incorrect."; read _; continue; }
  echo "  LISTEN 0 128 0.0.0.0:22 users:(\"sshd\")"
  echo

  # STEP 4: netstat -natp | grep :8080
  echo "  Step 4: Check port 8080 usage."
  read -p "$PROMPT" cmd4
  echo
  [[ "$cmd4" != "sudo netstat -natp | grep :8080" && "$cmd4" != "netstat -natp | grep :8080" ]] && { print_error "Incorrect."; read _; continue; }
  echo "  tcp 0 0 0.0.0.0:8080 LISTEN"
  echo

  # STEP 5: Edit /etc/hosts
  echo "  Step 5: Open /etc/hosts in vi."
  read -p "$PROMPT" cmd5
  echo
  [[ "$cmd5" != "sudo vi /etc/hosts" ]] && { print_error "Incorrect."; read _; continue; }
  echo "  (vi opened)"
  echo

  echo "  Step 6: In vi, type the following line EXACTLY:"
  read -p "  > " hosts_entry
  if [[ "$hosts_entry" != "8.8.8.8         example.com" ]]; then
    print_error "Incorrect entry."
    read _
    continue
  fi
  echo
  echo "  (save and exit vi)"
  echo

  # STEP 7: Add IP address
  echo "  Step 7: Add IP address 10.0.0.50/24 to eth0."
  read -p "$PROMPT" cmd7
  echo
  [[ "$cmd7" != "sudo ip a add 10.0.0.50/24 dev eth0" ]] && { print_error "Incorrect."; read _; continue; }
  echo

  # STEP 8: ip route show
  echo "  Step 8: Verify routing table again."
  read -p "$PROMPT" cmd8
  echo
  [[ "$cmd8" != "ip route show" ]] && { print_error "Incorrect."; read _; continue; }
  echo "  10.0.0.0/24 dev eth0 src 10.0.0.50"
  echo

  # STEP 9: Edit /etc/resolv.conf
  echo "  Step 9: Open /etc/resolv.conf in vi."
  read -p "$PROMPT" cmd9
  echo
  [[ "$cmd9" != "sudo vi /etc/resolv.conf" ]] && { print_error "Incorrect."; read _; continue; }
  echo "  (vi opened)"
  echo

  echo "  Step 10: In vi, type the following line EXACTLY:"
  read -p "  > " resolv_entry
  if [[ "$resolv_entry" != "nameserver 8.8.8.8" ]]; then
    print_error "Incorrect entry."
    read _
    continue
  fi
  echo
  echo "  (save and exit vi)"
  echo

  # STEP 11: hostnamectl
  echo "  Step 11: Display hostname information."
  read -p "$PROMPT" cmd11
  echo
  [[ "$cmd11" != "hostnamectl" ]] && { print_error "Incorrect."; read _; continue; }
  echo "  Operating System: Rocky Linux 10"
  echo

  print_success "Great job."
  print_info "You practiced RHCSA-style networking tasks:"
  print_info "- inspected interfaces and routes"
  print_info "- verified listening services"
  print_info "- manually edited /etc/hosts and /etc/resolv.conf"
  print_info "- added an IP address using ip"
  print_info "- validated hostname configuration"
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
