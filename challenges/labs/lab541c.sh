#!/bin/bash

# Lab 541C: Configure Persistent IPv4 and IPv6 Networking with NetworkManager

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 541C: Configure Persistent Networking with NetworkManager"
LAB_ID="lab541c"
LAB_XP=54100
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@servera:~$ "

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
  center_text "ServerA requires a persistent NetworkManager configuration."
  center_text "Create a connection profile named lab-link for the primary"
  center_text "network interface and configure the required IPv4 and IPv6"
  center_text "addresses so they persist after reboot."
  echo

  center_text "Requirements:"
  center_text "Primary IPv4:   192.168.1.10/24"
  center_text "Secondary IPv4: 10.0.0.5/24"
  center_text "IPv4 Gateway:   192.168.1.1"
  center_text "IPv4 DNS:       8.8.8.8"
  center_text "Primary IPv6:   fd00::10/64"
  center_text "IPv6 Gateway:   fd00::1"
  echo

  center_text "Press Enter to begin..."
  read _
  draw_lab_ui


  echo "  Step 1: Inspect the available network interfaces."
  read -p "$PROMPT" cmd1
  echo

  if [[ "$cmd1" != "nmcli device status" ]]; then
    print_error "Incorrect. Use: nmcli device status"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  DEVICE   TYPE      STATE                   CONNECTION"
  echo "  enp0s3   ethernet  disconnected            --"
  echo "  lo       loopback  connected (externally)  lo"
  echo


  echo "  Step 2: Create a NetworkManager connection profile named lab-link for interface enp0s3."
  read -p "$PROMPT" cmd2
  echo

  if [[ "$cmd2" != "sudo nmcli con add type ethernet ifname enp0s3 con-name lab-link" ]]; then
    print_error "Incorrect. Use: sudo nmcli con add type ethernet ifname enp0s3 con-name lab-link"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  Connection 'lab-link' successfully added."
  echo


  echo "  Step 3: Configure the primary IPv4 address."
  read -p "$PROMPT" cmd3
  echo

  if [[ "$cmd3" != "sudo nmcli con modify lab-link ipv4.addresses 192.168.1.10/24" ]]; then
    print_error "Incorrect. Use: sudo nmcli con modify lab-link ipv4.addresses 192.168.1.10/24"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 4: Add the secondary IPv4 address without overwriting the primary address."
  read -p "$PROMPT" cmd4
  echo

  if [[ "$cmd4" != "sudo nmcli con modify lab-link +ipv4.addresses 10.0.0.5/24" ]]; then
    print_error "Incorrect. Use: sudo nmcli con modify lab-link +ipv4.addresses 10.0.0.5/24"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 5: Configure the IPv4 gateway."
  read -p "$PROMPT" cmd5
  echo

  if [[ "$cmd5" != "sudo nmcli con modify lab-link ipv4.gateway 192.168.1.1" ]]; then
    print_error "Incorrect. Use: sudo nmcli con modify lab-link ipv4.gateway 192.168.1.1"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 6: Configure the IPv4 DNS server."
  read -p "$PROMPT" cmd6
  echo

  if [[ "$cmd6" != "sudo nmcli con modify lab-link ipv4.dns 8.8.8.8" ]]; then
    print_error "Incorrect. Use: sudo nmcli con modify lab-link ipv4.dns 8.8.8.8"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 7: Set the IPv4 method to manual."
  read -p "$PROMPT" cmd7
  echo

  if [[ "$cmd7" != "sudo nmcli con modify lab-link ipv4.method manual" ]]; then
    print_error "Incorrect. Use: sudo nmcli con modify lab-link ipv4.method manual"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 8: Configure the IPv6 address."
  read -p "$PROMPT" cmd8
  echo

  if [[ "$cmd8" != "sudo nmcli con modify lab-link ipv6.addresses fd00::10/64" ]]; then
    print_error "Incorrect. Use: sudo nmcli con modify lab-link ipv6.addresses fd00::10/64"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 9: Configure the IPv6 gateway."
  read -p "$PROMPT" cmd9
  echo

  if [[ "$cmd9" != "sudo nmcli con modify lab-link ipv6.gateway fd00::1" ]]; then
    print_error "Incorrect. Use: sudo nmcli con modify lab-link ipv6.gateway fd00::1"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 10: Set the IPv6 method to manual."
  read -p "$PROMPT" cmd10
  echo

  if [[ "$cmd10" != "sudo nmcli con modify lab-link ipv6.method manual" ]]; then
    print_error "Incorrect. Use: sudo nmcli con modify lab-link ipv6.method manual"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 11: Activate the connection."
  read -p "$PROMPT" cmd11
  echo

  if [[ "$cmd11" != "sudo nmcli con up lab-link" ]]; then
    print_error "Incorrect. Use: sudo nmcli con up lab-link"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  Connection successfully activated."
  echo


  echo "  Step 12: Verify the assigned addresses on enp0s3."
  read -p "$PROMPT" cmd12
  echo

  if [[ "$cmd12" != "ip addr show enp0s3" ]]; then
    print_error "Incorrect. Use: ip addr show enp0s3"
    read -p "Press Enter to retry..." _
    continue
  fi

  echo "  inet 192.168.1.10/24"
  echo "  inet 10.0.0.5/24"
  echo "  inet6 fd00::10/64"
  echo


  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- inspected available network interfaces"
  print_info "- created a persistent NetworkManager connection"
  print_info "- configured primary and secondary IPv4 addresses"
  print_info "- configured gateway and DNS"
  print_info "- configured IPv6 addressing"
  print_info "- activated and verified the connection"
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
