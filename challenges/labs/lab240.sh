#!/bin/bash

# Lab 240: Configure a Static IP with nmcli (server2) — SIMULATED & SAFE
# SAFETY: Validates typed commands and prints canned outputs only. No real network changes occur.
# Output policy: Only show realistic, canned command output. Silent steps print nothing.
# Formatting policy: Every simulated command OUTPUT line begins with exactly two spaces.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 240: nmcli static IP (server2)"
LAB_ID="lab240"
LAB_XP=20550
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

CON="server2"
IFACE="eth1"
IP4_CIDR="192.168.60.20/24"
GW4="192.168.60.1"
DNS="8.8.8.8 1.1.1.1"
UUID="b2c3d4e5-2222-3333-4444-fedcba987654"

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
  center_text "Goal: Create an nmcli connection '${CON}' on ${IFACE} with a static IPv4 address,"
  center_text "set DNS & gateway, bring it up, and verify connectivity (SIMULATED)."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Show device status
  draw_lab_ui
  echo "  Step 1: List network devices and their states."
  read -p "  lab@lab240:~$ " cmd1
  if [[ "$cmd1" == "nmcli device status" || "$cmd1" == "nmcli dev status" ]]; then
    echo "  DEVICE  TYPE      STATE         CONNECTION"
    echo "  ${IFACE}  ethernet  disconnected  --"
    echo "  lo      loopback  unmanaged     --"
  else
    print_error "Hint: Use nmcli device status."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 2: Create the connection with static IP & gateway
  echo "  Step 2: Create '${CON}' on ${IFACE} with ${IP4_CIDR} and gateway ${GW4}."
  read -p "  lab@lab240:~$ " cmd2
  if [[ "$cmd2" == "nmcli con add type ethernet ifname ${IFACE} con-name ${CON} ip4 ${IP4_CIDR} gw4 ${GW4}" ]] || \
     [[ "$cmd2" == "nmcli con add type ethernet ifname ${IFACE} con-name ${CON} ipv4.addresses ${IP4_CIDR} ipv4.gateway ${GW4} ipv4.method manual" ]]; then
    echo "  Connection '${CON}' (${UUID}) successfully added."
  else
    print_error "Hint: Use nmcli con add ... ifname ${IFACE} con-name ${CON} with ip4/gw4 or ipv4.addresses + ipv4.gateway + ipv4.method manual."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 3: Set DNS servers & autoconnect (silent on success)
  echo "  Step 3: Add DNS servers '${DNS}' to '${CON}' and enable autoconnect."
  read -p "  lab@lab240:~$ " cmd3a
  [[ "$cmd3a" != "nmcli con mod ${CON} ipv4.dns \"${DNS}\"" ]] && {
    print_error "Hint: nmcli con mod ${CON} ipv4.dns \"${DNS}\""
    read -p "Press Enter to try again..." _
    continue
  }
  read -p "  lab@lab240:~$ " cmd3b
  [[ "$cmd3b" != "nmcli con mod ${CON} connection.autoconnect yes" ]] && {
    print_error "Hint: nmcli con mod ${CON} connection.autoconnect yes"
    read -p "Press Enter to try again..." _
    continue
  }
  echo

  # Step 4: Bring the connection up
  echo "  Step 4: Activate the '${CON}' connection."
  read -p "  lab@lab240:~$ " cmd4
  if [[ "$cmd4" == "nmcli con up ${CON}" ]]; then
    echo "  Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/9)"
  else
    print_error "Hint: nmcli con up ${CON}"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 5: Show connection details (key IPv4 fields)
  echo "  Step 5: Show key IPv4 details for '${CON}'."
  read -p "  lab@lab240:~$ " cmd5
  if [[ "$cmd5" == "nmcli con show ${CON}" || "$cmd5" == "nmcli connection show ${CON}" ]]; then
    echo "  connection.id:                          ${CON}"
    echo "  connection.interface-name:              ${IFACE}"
    echo "  ipv4.method:                            manual"
    echo "  ipv4.addresses:                         ${IP4_CIDR}"
    echo "  ipv4.gateway:                           ${GW4}"
    echo "  ipv4.dns:                               ${DNS}"
  else
    print_error "Hint: nmcli con show ${CON}"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 6: Confirm kernel address on the interface
  echo "  Step 6: Verify the IP on ${IFACE} at the kernel level."
  read -p "  lab@lab240:~$ " cmd6
  if [[ "$cmd6" == "ip -4 addr show dev ${IFACE}" ]]; then
    echo "  3: ${IFACE}: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000"
    echo "      link/ether 52:54:00:de:ad:be brd ff:ff:ff:ff:ff:ff"
    echo "      inet ${IP4_CIDR} brd 192.168.60.255 scope global noprefixroute ${IFACE}"
    echo "         valid_lft forever preferred_lft forever"
  else
    print_error "Hint: ip -4 addr show dev ${IFACE}"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 7: Quick connectivity test to the gateway
  echo "  Step 7: Test reachability of the default gateway."
  read -p "  lab@lab240:~$ " cmd7
  if [[ "$cmd7" == "ping -c 2 ${GW4}" ]]; then
    echo "  PING ${GW4} (${GW4}) 56(84) bytes of data."
    echo "  64 bytes from ${GW4}: icmp_seq=1 ttl=64 time=0.412 ms"
    echo "  64 bytes from ${GW4}: icmp_seq=2 ttl=64 time=0.436 ms"
    echo
    echo "  --- ${GW4} ping statistics ---"
    echo "  2 packets transmitted, 2 received, 0% packet loss, time 1002ms"
    echo "  rtt min/avg/max/mdev = 0.412/0.424/0.436/0.012 ms"
  else
    print_error "Hint: ping -c 2 ${GW4}"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  print_success "Nice work! Static IP configured for '${CON}' with DNS and gateway, activation and verification complete (simulated)."
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
