#!/bin/bash

# Lab 314: Network Configuration Components – Objectives 109.2 & 109.3
# LPIC-1 Focus: hostnames, DHCP lease workflow, wired vs wireless, predictable NIC names,
# loopback, routing table, and default gateway identification.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 314: Network Configuration Components"
LAB_ID="lab314"
LAB_XP=50500
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

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
  center_text "Explore hostnames, DHCP, NIC naming, loopback, and routing/default gateway."
  center_text "Type the requested command or answer exactly as prompted."
  echo
  center_text "Press Enter to begin..."
  read _

  draw_lab_ui

  # Step 1: hostname
  echo "  Step 1: Display your system hostname. Use a standard command."
  read -p "  lab@lab314:~$ " cmd1
  echo
  if [[ "$cmd1" == "hostname" ]]; then
    echo "  lab-station"
    echo
  elif [[ "$cmd1" == "hostnamectl" ]]; then
    echo "   Static hostname: lab-station"
    echo "         Icon name: computer-vm"
    echo "           Chassis: vm"
    echo "        Machine ID: 11111111111111111111111111111111"
    echo "           Boot ID: 22222222222222222222222222222222"
    echo "  Operating System: Rocky Linux 10 (Red Quartz)"
    echo "            Kernel: Linux 6.12.0"
    echo "      Architecture: x86-64"
    echo
  else
    print_error "Incorrect. Use 'hostname' or 'hostnamectl'."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 2: ip addr show
  echo "  Step 2: Show interface IP addresses using the modern tool."
  read -p "  lab@lab314:~$ " cmd2
  echo
  if [[ "$cmd2" == "ip addr show" || "$cmd2" == "ip a" ]]; then
    echo "  2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 state UP qlen 1000"
    echo "      link/ether 08:00:27:aa:bb:cc brd ff:ff:ff:ff:ff:ff"
    echo "      inet 192.168.1.42/24 brd 192.168.1.255 scope global enp0s3"
    echo "         valid_lft forever preferred_lft forever"
    echo "      inet6 2601:600:9200:400:abcd::1/64 scope global"
    echo "         valid_lft 2592000sec preferred_lft 604800sec"
    echo "  3: wlp2s0: <BROADCAST,MULTICAST> mtu 1500 state DOWN qlen 1000"
    echo "      link/ether 34:de:1a:11:22:33 brd ff:ff:ff:ff:ff:ff"
    echo "  1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 state UNKNOWN qlen 1000"
    echo "      inet 127.0.0.1/8 scope host lo"
    echo "      inet6 ::1/128 scope host"
    echo
  else
    print_error "Incorrect. Use 'ip addr show' (or 'ip a')."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 3: predictable naming prefixes (Ethernet)
  echo "  Step 3: Type the two-letter prefix commonly used by predictable names for Ethernet interfaces."
  read -p "  lab@lab314:~$ " cmd3
  echo
  [[ "$cmd3" != "en" ]] && { print_error "Incorrect. Ethernet uses 'en' (e.g., enp0s3)."; read -p "Press Enter to retry..." _; continue; }

  # Step 4: predictable naming prefixes (Wi-Fi)
  echo "  Step 4: Type the two-letter prefix commonly used by predictable names for Wi-Fi interfaces."
  read -p "  lab@lab314:~$ " cmd4
  echo
  [[ "$cmd4" != "wl" ]] && { print_error "Incorrect. Wi-Fi uses 'wl' (e.g., wlp2s0)."; read -p "Press Enter to retry..." _; continue; }

  # Step 5: loopback test
  echo "  Step 5: Ping loopback three times using IPv4."
  read -p "  lab@lab314:~$ " cmd5
  echo
  if [[ "$cmd5" == "ping -c 3 127.0.0.1" || "$cmd5" == "ping -c 3 localhost" ]]; then
    echo "  PING 127.0.0.1 (127.0.0.1) 56(84) bytes of data."
    echo "  64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.039 ms"
    echo "  64 bytes from 127.0.0.1: icmp_seq=2 ttl=64 time=0.042 ms"
    echo "  64 bytes from 127.0.0.1: icmp_seq=3 ttl=64 time=0.041 ms"
    echo
    echo "  --- 127.0.0.1 ping statistics ---"
    echo "  3 packets transmitted, 3 received, 0% packet loss, time 2ms"
    echo "  rtt min/avg/max/mdev = 0.039/0.041/0.042/0.001 ms"
    echo
  else
    print_error "Incorrect. Use 'ping -c 3 127.0.0.1' (or 'ping -c 3 localhost')."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 6: brief link listing
  echo "  Step 6: Show a brief list of interfaces with states."
  read -p "  lab@lab314:~$ " cmd6
  echo
  if [[ "$cmd6" == "ip -brief link" ]]; then
    echo "  lo               UNKNOWN        00:00:00:00:00:00"
    echo "  enp0s3           UP             08:00:27:aa:bb:cc"
    echo "  wlp2s0           DOWN           34:de:1a:11:22:33"
    echo
  else
    print_error "Incorrect. Use 'ip -brief link'."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 7: DHCP release
  echo "  Step 7: Release your DHCP lease using a common client."
  read -p "  lab@lab314:~$ " cmd7
  echo
  if [[ "$cmd7" == "dhclient -r" || "$cmd7" == "sudo dhclient -r" ]]; then
    echo "  DHCPRELEASE on enp0s3 to 192.168.1.1 port 67"
    echo
  else
    print_error "Incorrect. Use 'dhclient -r' (optionally with sudo)."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 8: DHCP renew (verbose; identify server)
  echo "  Step 8: Renew your DHCP lease verbosely so you can see the server address."
  read -p "  lab@lab314:~$ " cmd8
  echo
  if [[ "$cmd8" == "dhclient -v" || "$cmd8" == "sudo dhclient -v" ]]; then
    echo "  Internet Systems Consortium DHCP Client 4.4.3"
    echo "  Listening on LPF/enp0s3/08:00:27:aa:bb:cc"
    echo "  Sending on   LPF/enp0s3/08:00:27:aa:bb:cc"
    echo "  DHCPDISCOVER on enp0s3 to 255.255.255.255 port 67 interval 3"
    echo "  DHCPOFFER of 192.168.1.42 from 192.168.1.1"
    echo "  DHCPREQUEST for 192.168.1.42 on enp0s3 to 192.168.1.1 port 67"
    echo "  DHCPACK of 192.168.1.42 from 192.168.1.1"
    echo "  bound to 192.168.1.42 -- renewal in 3600 seconds."
    echo
  else
    print_error "Incorrect. Use 'dhclient -v' (optionally with sudo)."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 9: Extract DHCP server IP
  echo "  Step 9: From the output above, what is the DHCP server IP address?"
  read -p "  lab@lab314:~$ " cmd9
  echo
  [[ "$cmd9" != "192.168.1.1" ]] && { print_error "Incorrect. DHCP server is 192.168.1.1 (seen in OFFER/ACK lines)."; read -p "Press Enter to retry..." _; continue; }

  # Step 10: Show routing table
  echo "  Step 10: Show the kernel routing table using the modern tool."
  read -p "  lab@lab314:~$ " cmd10
  echo
  if [[ "$cmd10" == "ip route show" || "$cmd10" == "ip route" ]]; then
    echo "  default via 192.168.1.1 dev enp0s3 proto dhcp metric 100"
    echo "  192.168.1.0/24 dev enp0s3 proto kernel scope link src 192.168.1.42 metric 100"
    echo
  else
    print_error "Incorrect. Use 'ip route show' (or 'ip route')."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 11: Identify default gateway
  echo "  Step 11: Provide the default gateway IP from the routing table."
  read -p "  lab@lab314:~$ " cmd11
  echo
  [[ "$cmd11" != "192.168.1.1" ]] && { print_error "Incorrect. Default gateway is 192.168.1.1 (after 'default via')."; read -p "Press Enter to retry..." _; continue; }

  # Step 12: Wired or wireless classification
  echo "  Step 12: Is 'enp0s3' a wired or wireless interface?"
  read -p "  lab@lab314:~$ " cmd12
  echo
  [[ "$cmd12" != "wired" ]] && { print_error "Incorrect. 'enp0s3' is wired (Ethernet)."; read -p "Press Enter to retry..." _; continue; }

  # Step 13: SSID expansion
  echo "  Step 13: What does SSID stand for? Answer exactly"
  read -p "  lab@lab314:~$ " cmd13
  echo
  [[ "$cmd13" != "Service Set Identifier" ]] && { print_error "Incorrect. SSID = Service Set Identifier."; read -p "Press Enter to retry..." _; continue; }

  # Step 14: Current secure Wi-Fi standard
  echo "  Step 14: Name the current WPA standard recommended for security."
  read -p "  lab@lab314:~$ " cmd14
  echo
  [[ "$cmd14" != "WPA3" ]] && { print_error "Incorrect. The current secure standard is WPA3."; read -p "Press Enter to retry..." _; continue; }

  # Step 15: Loopback interface name
  echo "  Step 15: Provide the conventional name of the loopback interface."
  read -p "  lab@lab314:~$ " cmd15
  echo
  [[ "$cmd15" != "lo" ]] && { print_error "Incorrect. Loopback interface is 'lo'."; read -p "Press Enter to retry..." _; continue; }

# Step 16: Identify which command shows hostname AND status details (systemd-based)
echo "  Step 16: Which command shows hostname plus additional system info (systemd-based)?"
read -p "  lab@lab314:~$ " cmd16
echo
if [[ "$cmd16" == "hostnamectl" ]]; then
  echo "   Static hostname: lab-station"
  echo "         Icon name: computer-vm"
  echo "           Chassis: vm"
  echo "        Machine ID: 11111111111111111111111111111111"
  echo "           Boot ID: 22222222222222222222222222222222"
  echo "  Operating System: Rocky Linux 10 (Red Quartz)"
  echo "            Kernel: Linux 6.12.0"
  echo "      Architecture: x86-64"
  echo
else
  print_error "Incorrect."
  read -p "Press Enter to retry..." _
  continue
fi

  print_success "Excellent work!"
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
