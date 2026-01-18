#!/bin/bash

# Lab 135: Networking Fundamentals — Fix Wrong Static IP on eth0 (4–8 prompts)
# Scenario: A VM was cloned and eth0 now has the WRONG static IPv4 address. SSH works only from the local console.
# Your job: identify the current address, locate the NetworkManager connection, correct the IPv4 address/gateway/DNS,
# bring the connection up, and verify you can reach the gateway and resolve DNS.
#
# Key skills: ip addr, ip route, nmcli con show, nmcli con mod, nmcli con down/up, ping, getent.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 135: Networking Fundamentals — Fix Static IP (NMCLI)"
LAB_ID="lab135"
LAB_XP=29500
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@rhel-lab135:~$ "

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
  center_text "This RHEL host was cloned from a template."
  center_text "eth0 came up with the wrong static IP, so it cannot reach the gateway."
  center_text "You have local console access only."
  echo
  center_text "Target network settings (must match exactly):"
  center_text "- IPv4: 192.168.50.20/24"
  center_text "- GW:   192.168.50.1"
  center_text "- DNS:  1.1.1.1, 8.8.8.8"
  echo
  center_text "Goal: fix the NM connection, bring it up, verify gateway + DNS resolution."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Check current address (shows wrong subnet)
  echo "  Step 1: Show the current IPv4 address on eth0."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "ip -4 addr show dev eth0" && \
        "$cmd1" != "ip addr show dev eth0" && \
        "$cmd1" != "ip a show dev eth0" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000"
  echo "      inet 192.168.1.20/24 brd 192.168.1.255 scope global noprefixroute eth0"
  echo "         valid_lft forever preferred_lft forever"
  echo

  # STEP 2: Find the NetworkManager connection name
  echo "  Step 2: List NetworkManager connections and identify the one bound to eth0."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "nmcli -t -f NAME,DEVICE con show" && \
        "$cmd2" != "nmcli con show" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  System eth0:eth0"
  echo "  lo:lo"
  echo

  # STEP 3: Set the correct IPv4 method/address/gateway
  echo "  Step 3: Set the connection 'System eth0' to a manual IPv4 address and gateway."
  echo "          (Address must be 192.168.50.20/24 and gateway 192.168.50.1.)"
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo nmcli con mod \"System eth0\" ipv4.method manual ipv4.addresses 192.168.50.20/24 ipv4.gateway 192.168.50.1" && \
        "$cmd3" != "nmcli con mod \"System eth0\" ipv4.method manual ipv4.addresses 192.168.50.20/24 ipv4.gateway 192.168.50.1" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  # STEP 4: Set DNS
  echo "  Step 4: Set IPv4 DNS servers for 'System eth0' to 1.1.1.1 and 8.8.8.8."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo nmcli con mod \"System eth0\" ipv4.dns \"1.1.1.1 8.8.8.8\"" && \
        "$cmd4" != "nmcli con mod \"System eth0\" ipv4.dns \"1.1.1.1 8.8.8.8\"" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  # STEP 5: Bounce connection
  echo "  Step 5: Bring the connection down and back up to apply changes."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo nmcli con down \"System eth0\" && sudo nmcli con up \"System eth0\"" && \
        "$cmd5" != "nmcli con down \"System eth0\" && nmcli con up \"System eth0\"" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Connection 'System eth0' successfully deactivated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/3)"
  echo "  Connection 'System eth0' successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/4)"
  echo

  # STEP 6: Verify address + default route
  echo "  Step 6: Verify eth0 now has 192.168.50.20/24 and a default route via 192.168.50.1."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "ip -4 addr show dev eth0" && \
        "$cmd6" != "ip route" && \
        "$cmd6" != "ip r" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd6" == "ip -4 addr show dev eth0" ]]; then
    echo "  2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000"
    echo "      inet 192.168.50.20/24 brd 192.168.50.255 scope global noprefixroute eth0"
    echo "         valid_lft forever preferred_lft forever"
  else
    echo "  default via 192.168.50.1 dev eth0 proto static metric 100"
    echo "  192.168.50.0/24 dev eth0 proto kernel scope link src 192.168.50.20 metric 100"
  fi
  echo

  # STEP 7: Verify gateway and DNS resolution
  echo "  Step 7: Verify you can reach the gateway and resolve a hostname."
  echo "          (Do both checks with one command line.)"
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "ping -c 2 192.168.50.1 && getent hosts example.com" && \
        "$cmd7" != "ping -c 2 192.168.50.1 && getent ahostsv4 example.com" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  PING 192.168.50.1 (192.168.50.1) 56(84) bytes of data."
  echo "  64 bytes from 192.168.50.1: icmp_seq=1 ttl=64 time=0.451 ms"
  echo "  64 bytes from 192.168.50.1: icmp_seq=2 ttl=64 time=0.437 ms"
  echo
  echo "  --- ping statistics ---"
  echo "  2 packets transmitted, 2 received, 0% packet loss"
  echo
  echo "  93.184.216.34   example.com"
  echo

  print_success "Nice work."
  print_info "You resolved a realistic 'cloned VM wrong static IP' incident by:"
  print_info "- inspecting the live interface config"
  print_info "- identifying the NM connection for eth0"
  print_info "- correcting IPv4 address, gateway, and DNS with nmcli"
  print_info "- bouncing the connection to apply"
  print_info "- verifying routing + DNS resolution"
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
