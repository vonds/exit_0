#!/bin/bash

# Lab 130: Networking Fundamentals — Restore Connectivity (Route + DNS) (4–8 prompts)
# Scenario: A small lab VM can reach its gateway but cannot reach the internet by name.
# You must identify whether the issue is routing or DNS, fix it, and verify end-to-end.
# Key skills: ip addr, ip route, ping, resolvectl (or cat /etc/resolv.conf), dig/getent, curl.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 130: Networking Fundamentals — Restore Connectivity"
LAB_ID="lab130"
LAB_XP=19500
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@rhel-lab130:~$ "

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
  center_text "A VM on a training network reports: 'I can ping the gateway, but DNS names fail.'"
  center_text "You must confirm IP config, confirm routing, confirm DNS, fix the issue, and verify."
  echo
  center_text "Network facts (given by the ticket):"
  center_text "- Interface: eth0"
  center_text "- Expected gateway: 10.0.2.2"
  center_text "- Expected DNS server: 10.0.2.3"
  center_text "- Test site: http://example.com"
  echo
  center_text "Goal: restore name resolution and verify internet access."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Confirm interface + IP
  echo "  Step 1: Confirm eth0 has an IPv4 address."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "ip addr show eth0" && \
        "$cmd1" != "ip a show eth0" && \
        "$cmd1" != "sudo ip addr show eth0" && \
        "$cmd1" != "sudo ip a show eth0" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000"
  echo "      link/ether 52:54:00:12:34:56 brd ff:ff:ff:ff:ff:ff"
  echo "      inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic eth0"
  echo

  # STEP 2: Prove L2/L3 to gateway works
  echo "  Step 2: Verify you can reach the gateway (10.0.2.2)."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "ping -c 2 10.0.2.2" && \
        "$cmd2" != "sudo ping -c 2 10.0.2.2" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  PING 10.0.2.2 (10.0.2.2) 56(84) bytes of data."
  echo "  64 bytes from 10.0.2.2: icmp_seq=1 ttl=64 time=0.32 ms"
  echo "  64 bytes from 10.0.2.2: icmp_seq=2 ttl=64 time=0.30 ms"
  echo "  --- 10.0.2.2 ping statistics ---"
  echo "  2 packets transmitted, 2 received, 0% packet loss"
  echo

  # STEP 3: Check routing table for default route
  echo "  Step 3: Check the routing table and confirm whether a default route exists."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "ip route" && \
        "$cmd3" != "sudo ip route" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15"
  echo

  # STEP 4: Add the missing default route
  echo "  Step 4: Add the missing default route via 10.0.2.2 on eth0."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo ip route add default via 10.0.2.2 dev eth0" && \
        "$cmd4" != "ip route add default via 10.0.2.2 dev eth0" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  # STEP 5: Verify you can reach an external IP (routing fixed)
  echo "  Step 5: Verify routing works by pinging an external IP (1.1.1.1)."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "ping -c 2 1.1.1.1" && \
        "$cmd5" != "sudo ping -c 2 1.1.1.1" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data."
  echo "  64 bytes from 1.1.1.1: icmp_seq=1 ttl=54 time=12.4 ms"
  echo "  64 bytes from 1.1.1.1: icmp_seq=2 ttl=54 time=12.1 ms"
  echo "  --- 1.1.1.1 ping statistics ---"
  echo "  2 packets transmitted, 2 received, 0% packet loss"
  echo

  # STEP 6: Check DNS resolver configuration
  echo "  Step 6: Check DNS configuration (choose one method)."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "resolvectl status" && \
        "$cmd6" != "sudo resolvectl status" && \
        "$cmd6" != "cat /etc/resolv.conf" && \
        "$cmd6" != "sudo cat /etc/resolv.conf" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  if [[ "$cmd6" == *"resolvectl status"* ]]; then
    echo "  Global"
    echo "       LLMNR setting: yes"
    echo "  MulticastDNS setting: no"
    echo "    DNSOverTLS setting: no"
    echo "        DNSSEC setting: no"
    echo "  Current DNS Server: 127.0.0.1"
    echo "         DNS Servers: 127.0.0.1"
    echo
    echo "  Link 2 (eth0)"
    echo "      Current Scopes: DNS"
    echo "       DNS Servers: 127.0.0.1"
    echo
  else
    echo "  # Generated by NetworkManager"
    echo "  nameserver 127.0.0.1"
    echo
  fi

  # STEP 7: Fix DNS (set DNS for eth0 using nmcli)
  echo "  Step 7: Fix DNS by setting eth0's IPv4 DNS to 10.0.2.3 and bring the connection up."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo nmcli con mod eth0 ipv4.dns 10.0.2.3" && \
        "$cmd7" != "nmcli con mod eth0 ipv4.dns 10.0.2.3" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  echo "  Step 8: Apply the change by bringing the connection up."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo nmcli con up eth0" && \
        "$cmd8" != "nmcli con up eth0" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/7)"
  echo

  # FINAL VERIFY: Name resolution + HTTP
  echo "  Step 9: Verify name resolution and HTTP access to example.com."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "getent hosts example.com" && \
        "$cmd9" != "dig +short example.com" && \
        "$cmd9" != "curl -I http://example.com" && \
        "$cmd9" != "curl -I https://example.com" && \
        "$cmd9" != "sudo curl -I http://example.com" && \
        "$cmd9" != "sudo curl -I https://example.com" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  if [[ "$cmd9" == "getent hosts example.com" ]]; then
    echo "  93.184.216.34   example.com"
  elif [[ "$cmd9" == "dig +short example.com" ]]; then
    echo "  93.184.216.34"
  else
    echo "  HTTP/1.1 200 OK"
    echo "  Content-Type: text/html; charset=UTF-8"
    echo "  Server: ECS (nyb/1D2B)"
  fi
  echo

  print_success "Nice work."
  print_info "You restored connectivity by:"
  print_info "- verifying interface configuration"
  print_info "- confirming gateway reachability"
  print_info "- detecting a missing default route and fixing it"
  print_info "- confirming routing with an external IP"
  print_info "- identifying broken DNS configuration and correcting it via NetworkManager"
  print_info "- verifying name resolution / HTTP access"
  print_info "You earned $LAB_XP XP for completing this lab."
  award_xp $LAB_XP
  XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON"); export XP; export LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've successfully completed this lab $completion_count time(s)."
  echo
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " post_choice
  [[ "$post_choice" == "2" ]] && exit 0
done
