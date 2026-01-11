#!/bin/bash

# Lab 127: Networking Troubleshooting — Fix No Internet (Route + DNS)
# Focus: diagnose and fix a real connectivity outage caused by a missing default route
# and a broken DNS resolver configuration.
# Key skills: ip, ping, resolvectl, and verification workflow.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 127: Fix No Internet (Route + DNS)"
LAB_ID="lab127"
LAB_XP=12700
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

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "Scenario:"
  center_text "You SSH'd into a Linux VM (net-ops-127) after an app deploy."
  center_text "The node can reach the local gateway but cannot reach the internet."
  center_text "Your job is to diagnose the issue and restore outbound connectivity."
  echo
  center_text "Notes:"
  center_text "- Assume interface is eth0 and gateway should be 192.168.56.1"
  center_text "- DNS should end up using 1.1.1.1 and 8.8.8.8"
  center_text "- This VM uses systemd-resolved (use resolvectl)"
  center_text "- Use sudo where required."
  echo
  center_text "Press Enter to begin the lab..."
  read -r _
  draw_lab_ui

  # STEP 1
  echo "  Step 1: Confirm the system has an IPv4 address on eth0."
  read -r -p "  lab@net-ops-127:~$ " cmd1
  echo
  if [[ "$cmd1" != "ip -4 addr show eth0" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000"
  echo "      inet 192.168.56.20/24 brd 192.168.56.255 scope global dynamic eth0"
  echo "         valid_lft 85803sec preferred_lft 85803sec"
  echo

  # STEP 2
  echo "  Step 2: Verify you can reach the local gateway."
  read -r -p "  lab@net-ops-127:~$ " cmd2
  echo
  if [[ "$cmd2" != "ping -c 2 192.168.56.1" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  PING 192.168.56.1 (192.168.56.1) 56(84) bytes of data."
  echo "  64 bytes from 192.168.56.1: icmp_seq=1 ttl=64 time=0.418 ms"
  echo "  64 bytes from 192.168.56.1: icmp_seq=2 ttl=64 time=0.391 ms"
  echo
  echo "  --- 192.168.56.1 ping statistics ---"
  echo "  2 packets transmitted, 2 received, 0% packet loss, time 1001ms"
  echo

  # STEP 3
  echo "  Step 3: Try to ping a public IP (bypasses DNS) to test routing."
  read -r -p "  lab@net-ops-127:~$ " cmd3
  echo
  if [[ "$cmd3" != "ping -c 2 1.1.1.1" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data."
  echo "  From 192.168.56.20 icmp_seq=1 Destination Host Unreachable"
  echo "  From 192.168.56.20 icmp_seq=2 Destination Host Unreachable"
  echo
  echo "  --- 1.1.1.1 ping statistics ---"
  echo "  2 packets transmitted, 0 received, +2 errors, 100% packet loss, time 1025ms"
  echo

  # STEP 4
  echo "  Step 4: Check the routing table for a default route."
  read -r -p "  lab@net-ops-127:~$ " cmd4
  echo
  if [[ "$cmd4" != "ip route" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  192.168.56.0/24 dev eth0 proto kernel scope link src 192.168.56.20"
  echo

  # STEP 5
  echo "  Step 5: Add the missing default route via 192.168.56.1."
  read -r -p "  lab@net-ops-127:~$ " cmd5
  echo
  if [[ "$cmd5" != "sudo ip route add default via 192.168.56.1 dev eth0" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 6
  echo "  Step 6: Verify the default route now exists."
  read -r -p "  lab@net-ops-127:~$ " cmd6
  echo
  if [[ "$cmd6" != "ip route" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  default via 192.168.56.1 dev eth0"
  echo "  192.168.56.0/24 dev eth0 proto kernel scope link src 192.168.56.20"
  echo

  # STEP 7
  echo "  Step 7: Re-test ping to a public IP."
  read -r -p "  lab@net-ops-127:~$ " cmd7
  echo
  if [[ "$cmd7" != "ping -c 2 1.1.1.1" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data."
  echo "  64 bytes from 1.1.1.1: icmp_seq=1 ttl=57 time=12.8 ms"
  echo "  64 bytes from 1.1.1.1: icmp_seq=2 ttl=57 time=12.4 ms"
  echo
  echo "  --- 1.1.1.1 ping statistics ---"
  echo "  2 packets transmitted, 2 received, 0% packet loss, time 1001ms"
  echo

  # STEP 8 (fixed: uniform prompt line)
  echo "  Step 8: Test DNS by pinging a hostname (example.com)."
  read -r -p "  lab@net-ops-127:~$ " cmd8
  echo
  if [[ "$cmd8" != "ping -c 1 example.com" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  ping: example.com: Temporary failure in name resolution"
  echo

  # STEP 9 (replaced: short + uniform)
  echo "  Step 9: Check resolver status (confirm DNS is misconfigured)."
  read -r -p "  lab@net-ops-127:~$ " cmd9
  echo
  if [[ "$cmd9" != "resolvectl status" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  Global"
  echo "         Protocols: -LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported"
  echo "  Link 2 (eth0)"
  echo "      Current Scopes: DNS"
  echo "       DNS Servers: 192.168.56.250"
  echo

  # STEP 10 (short fix, easy to type)
  echo "  Step 10: Set working DNS servers on eth0 (1.1.1.1 and 8.8.8.8)."
  read -r -p "  lab@net-ops-127:~$ " cmd10
  echo
  if [[ "$cmd10" != "sudo resolvectl dns eth0 1.1.1.1 8.8.8.8" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 11
  echo "  Step 11: Verify DNS resolution works now using getent."
  read -r -p "  lab@net-ops-127:~$ " cmd11
  echo
  if [[ "$cmd11" != "getent hosts example.com" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  93.184.216.34   example.com"
  echo

  # STEP 12
  echo "  Step 12: Final check: ping the hostname."
  read -r -p "  lab@net-ops-127:~$ " cmd12
  echo
  if [[ "$cmd12" != "ping -c 1 example.com" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  PING example.com (93.184.216.34) 56(84) bytes of data."
  echo "  64 bytes from 93.184.216.34: icmp_seq=1 ttl=56 time=14.9 ms"
  echo
  echo "  --- example.com ping statistics ---"
  echo "  1 packets transmitted, 1 received, 0% packet loss, time 0ms"
  echo

  print_success "Nice work."
  print_info "You restored outbound connectivity by fixing routing first, then DNS:"
  print_info "- verified interface IP and local gateway reachability"
  print_info "- detected missing default route and added it"
  print_info "- verified internet IP reachability"
  print_info "- diagnosed DNS failure and corrected resolvers (resolvectl)"
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
  read -r -p "  > " post_choice

  [[ "$post_choice" == "2" ]] && exit 0
done
