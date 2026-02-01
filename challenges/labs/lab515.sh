#!/bin/bash

# Lab 515: Configure IPv4 and IPv6 Addresses (Rocky Linux 10 / RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 515: Configure IPv4 and IPv6 Addresses (Rocky 10 / RHCSA)"
LAB_ID="lab515"
LAB_XP=51500
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab515:~$ "

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
  center_text "A server NIC must be configured with STATIC IPv4 and IPv6 addressing."
  center_text "You will use NetworkManager (nmcli) to set addresses, gateways, and DNS,"
  center_text "bring the connection up, and verify the configuration."
  echo
  center_text "Targets:"
  center_text "- Interface: eth0"
  center_text "- IPv4: 192.168.50.10/24, GW 192.168.50.1, DNS 8.8.8.8"
  center_text "- IPv6: 2001:db8:50::10/64, GW 2001:db8:50::1, DNS 2001:4860:4860::8888"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Display NetworkManager device status to confirm eth0 is present."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "nmcli dev status" ]]; then
    print_error "Incorrect. Use: nmcli dev status"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  DEVICE  TYPE      STATE      CONNECTION"
  echo "  eth0    ethernet  connected  System eth0"
  echo "  lo      loopback  unmanaged  --"
  echo

  echo "  Step 2: Show the current IPv4/IPv6 addressing on eth0."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "ip addr show eth0" ]]; then
    print_error "Incorrect. Use: ip addr show eth0"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000"
  echo "      link/ether 52:54:00:12:34:56 brd ff:ff:ff:ff:ff:ff"
  echo "      inet 192.168.50.20/24 brd 192.168.50.255 scope global dynamic noprefixroute eth0"
  echo "         valid_lft 3500sec preferred_lft 3500sec"
  echo "      inet6 fe80::5054:ff:fe12:3456/64 scope link noprefixroute"
  echo "         valid_lft forever preferred_lft forever"
  echo

  echo "  Step 3: Set a static IPv4 address on the 'eth0' connection."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo nmcli con mod eth0 ipv4.addresses 192.168.50.10/24" ]]; then
    print_error "Incorrect. Use: sudo nmcli con mod eth0 ipv4.addresses 192.168.50.10/24"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 4: Set the IPv4 default gateway for the 'eth0' connection."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo nmcli con mod eth0 ipv4.gateway 192.168.50.1" ]]; then
    print_error "Incorrect. Use: sudo nmcli con mod eth0 ipv4.gateway 192.168.50.1"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 5: Set the IPv4 DNS server for the 'eth0' connection."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo nmcli con mod eth0 ipv4.dns 8.8.8.8" ]]; then
    print_error "Incorrect. Use: sudo nmcli con mod eth0 ipv4.dns 8.8.8.8"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 6: Set IPv4 method to manual (static) for the 'eth0' connection."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo nmcli con mod eth0 ipv4.method manual" ]]; then
    print_error "Incorrect. Use: sudo nmcli con mod eth0 ipv4.method manual"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 7: Set a static IPv6 address on the 'eth0' connection."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo nmcli con mod eth0 ipv6.addresses 2001:db8:50::10/64" ]]; then
    print_error "Incorrect. Use: sudo nmcli con mod eth0 ipv6.addresses 2001:db8:50::10/64"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 8: Set the IPv6 default gateway for the 'eth0' connection."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo nmcli con mod eth0 ipv6.gateway 2001:db8:50::1" ]]; then
    print_error "Incorrect. Use: sudo nmcli con mod eth0 ipv6.gateway 2001:db8:50::1"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 9: Set the IPv6 DNS server for the 'eth0' connection."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo nmcli con mod eth0 ipv6.dns 2001:4860:4860::8888" ]]; then
    print_error "Incorrect. Use: sudo nmcli con mod eth0 ipv6.dns 2001:4860:4860::8888"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 10: Set IPv6 method to manual (static) for the 'eth0' connection."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "sudo nmcli con mod eth0 ipv6.method manual" ]]; then
    print_error "Incorrect. Use: sudo nmcli con mod eth0 ipv6.method manual"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 11: Bring the eth0 connection up to apply changes immediately."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "sudo nmcli con up eth0" ]]; then
    print_error "Incorrect. Use: sudo nmcli con up eth0"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/3)"
  echo

  echo "  Step 12: Verify the applied IPv4 address and gateway using nmcli."
  read -p "$PROMPT" cmd12
  echo
  if [[ "$cmd12" != "nmcli con show eth0" ]]; then
    print_error "Incorrect. Use: nmcli con show eth0"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  connection.id:                          eth0"
  echo "  ipv4.method:                           manual"
  echo "  ipv4.addresses:                        192.168.50.10/24"
  echo "  ipv4.gateway:                          192.168.50.1"
  echo "  ipv4.dns:                              8.8.8.8"
  echo "  ipv6.method:                           manual"
  echo "  ipv6.addresses:                        2001:db8:50::10/64"
  echo "  ipv6.gateway:                          2001:db8:50::1"
  echo "  ipv6.dns:                              2001:4860:4860::8888"
  echo

  echo "  Step 13: Verify the ACTIVE IPv4 address on eth0."
  read -p "$PROMPT" cmd13
  echo
  if [[ "$cmd13" != "ip -4 addr show eth0" ]]; then
    print_error "Incorrect. Use: ip -4 addr show eth0"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000"
  echo "      inet 192.168.50.10/24 brd 192.168.50.255 scope global noprefixroute eth0"
  echo "         valid_lft forever preferred_lft forever"
  echo

  echo "  Step 14: Verify the ACTIVE IPv6 address on eth0."
  read -p "$PROMPT" cmd14
  echo
  if [[ "$cmd14" != "ip -6 addr show eth0" ]]; then
    print_error "Incorrect. Use: ip -6 addr show eth0"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 state UP qlen 1000"
  echo "      inet6 2001:db8:50::10/64 scope global noprefixroute"
  echo "         valid_lft forever preferred_lft forever"
  echo "      inet6 fe80::5054:ff:fe12:3456/64 scope link noprefixroute"
  echo "         valid_lft forever preferred_lft forever"
  echo

  echo "  Step 15: Test IPv4 and IPv6 gateway reachability."
  read -p "$PROMPT" cmd15
  echo
  if [[ "$cmd15" != "ping -c 2 192.168.50.1" ]]; then
    print_error "Incorrect. Use: ping -c 2 192.168.50.1"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  PING 192.168.50.1 (192.168.50.1) 56(84) bytes of data."
  echo "  64 bytes from 192.168.50.1: icmp_seq=1 ttl=64 time=0.6 ms"
  echo "  64 bytes from 192.168.50.1: icmp_seq=2 ttl=64 time=0.5 ms"
  echo
  echo "  --- 192.168.50.1 ping statistics ---"
  echo "  2 packets transmitted, 2 received, 0% packet loss, time 1002ms"
  echo

  echo "  Step 16: Test IPv6 gateway reachability."
  read -p "$PROMPT" cmd16
  echo
  if [[ "$cmd16" != "ping -c 2 2001:db8:50::1" ]]; then
    print_error "Incorrect. Use: ping -c 2 2001:db8:50::1"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  PING 2001:db8:50::1(2001:db8:50::1) 56 data bytes"
  echo "  64 bytes from 2001:db8:50::1: icmp_seq=1 ttl=64 time=0.7 ms"
  echo "  64 bytes from 2001:db8:50::1: icmp_seq=2 ttl=64 time=0.6 ms"
  echo
  echo "  --- 2001:db8:50::1 ping statistics ---"
  echo "  2 packets transmitted, 2 received, 0% packet loss, time 1002ms"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- configured static IPv4 + IPv6 addressing with nmcli"
  print_info "- set gateways and DNS for both stacks"
  print_info "- activated the connection and verified live addressing"
  print_info "- tested basic connectivity with ping"
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
