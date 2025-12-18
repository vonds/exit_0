#!/bin/bash

# Lab 317: Exploring Legacy Linux Network Configuration – Objectives 109.2 & 109.3
# LPIC-1 Focus: legacy config files, ifconfig, ifdown/ifup workflow.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 317: Legacy Network Configuration"
LAB_ID="lab317"
LAB_XP=43900
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
  center_text "Inspect legacy network config files and manage interfaces with classic tools."
  center_text "No hints or answers appear in prompts. Type exactly what the step requires."
  echo
  center_text "Press Enter to begin..."
  read _

  draw_lab_ui

  # Step 1: list RHEL-style legacy dir
  echo "  Step 1: List the legacy Red Hat network-scripts directory."
  read -p "  lab@lab317:~$ " cmd1
  echo
  if [[ "$cmd1" == "ls -l /etc/sysconfig/network-scripts" ]]; then
    echo "  total 60"
    echo "  -rw-r--r-- 1 root root  312 Oct  2  2020 ifcfg-lo"
    echo "  -rw-r--r-- 1 root root  534 Oct  2  2020 ifcfg-ens33"
    echo "  -rw-r--r-- 1 root root  128 Oct  2  2020 route-ens33"
    echo "  -rwxr-xr-x 1 root root 2331 Oct  2  2020 network-functions"
    echo "  -rwxr-xr-x 1 root root  987 Oct  2  2020 network-functions-ipv6"
    echo
  else
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 2: view a legacy ifcfg file
  echo "  Step 2: Display the legacy config file for ens33."
  read -p "  lab@lab317:~$ " cmd2
  echo
  if [[ "$cmd2" == "cat /etc/sysconfig/network-scripts/ifcfg-ens33" ]]; then
    echo "  # Legacy interface configuration"
    echo "  DEVICE=ens33"
    echo "  BOOTPROTO=none"
    echo "  ONBOOT=yes"
    echo "  IPADDR=192.168.50.10"
    echo "  NETMASK=255.255.255.0"
    echo "  GATEWAY=192.168.50.1"
    echo "  PREFIX=24"
    echo "  IPV6INIT=no"
    echo
  else
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 3: starts at boot? yes/no
  echo "  Step 3: Determine whether ens33 is configured to start at boot. Type yes or no."
  read -p "  lab@lab317:~$ " cmd3
  echo
  [[ "$cmd3" != "yes" ]] && { print_error "Incorrect."; read -p "Press Enter to retry..." _; continue; }

  # Step 4: static or dynamic
  echo "  Step 4: Is ens33 configured for a static or dynamic address?"
  read -p "  lab@lab317:~$ " cmd4
  echo
  [[ "$cmd4" != "static" ]] && { print_error "Incorrect."; read -p "Press Enter to retry..." _; continue; }

  # Step 5: view Ubuntu legacy file
  echo "  Step 5: Display the Debian/Ubuntu legacy interfaces file."
  read -p "  lab@lab317:~$ " cmd5
  echo
  if [[ "$cmd5" == "cat /etc/network/interfaces" ]]; then
    echo "  # This is the legacy Debian/Ubuntu network interfaces file"
    echo "  auto lo"
    echo "  iface lo inet loopback"
    echo
    echo "  auto ens33"
    echo "  iface ens33 inet static"
    echo "      address 192.168.50.10/24"
    echo "      gateway 192.168.50.1"
    echo "      dns-nameservers 1.1.1.1 8.8.8.8"
    echo
  else
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 6: show interfaces up with legacy tool
  echo "  Step 6: Show interface information with the legacy tool."
  read -p "  lab@lab317:~$ " cmd6
  echo
  if [[ "$cmd6" == "ifconfig" || "$cmd6" == "ifconfig -a" ]]; then
    echo "  ens33: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500"
    echo "        inet 192.168.50.10  netmask 255.255.255.0  broadcast 192.168.50.255"
    echo "        ether 00:16:3e:5a:7b:9c  txqueuelen 1000  (Ethernet)"
    echo "        RX packets 12093  bytes 9.7 MiB  TX packets 8231  bytes 8.3 MiB"
    echo
    echo "  lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536"
    echo "      inet 127.0.0.1  netmask 255.0.0.0"
    echo
  else
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 7: stop interface with legacy command
  echo "  Step 7: Stop the ens33 interface using a legacy command."
  read -p "  lab@lab317:~$ " cmd7
  echo
  if [[ "$cmd7" == "ifdown ens33" ]]; then
    echo
  else
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 8: verify ens33 is down
  echo "  Step 8: Verify that ens33 is no longer listed by the legacy tool."
  read -p "  lab@lab317:~$ " cmd8
  echo
  if [[ "$cmd8" == "ifconfig" || "$cmd8" == "ifconfig -a" ]]; then
    echo "  lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536"
    echo "      inet 127.0.0.1  netmask 255.0.0.0"
    echo
  else
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 9: start interface with legacy command
  echo "  Step 9: Start the ens33 interface using a legacy command."
  read -p "  lab@lab317:~$ " cmd9
  echo
  if [[ "$cmd9" == "ifup ens33" ]]; then
    echo
  else
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 10: verify ens33 is up again
  echo "  Step 10: Verify that ens33 is listed again by the legacy tool."
  read -p "  lab@lab317:~$ " cmd10
  echo
  if [[ "$cmd10" == "ifconfig" || "$cmd10" == "ifconfig -a" ]]; then
    echo "  ens33: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500"
    echo "        inet 192.168.50.10  netmask 255.255.255.0  broadcast 192.168.50.255"
    echo "        ether 00:16:3e:5a:7b:9c  txqueuelen 1000  (Ethernet)"
    echo
    echo "  lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536"
    echo "      inet 127.0.0.1  netmask 255.0.0.0"
    echo
  else
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 11: show routes using legacy feel (optional legacy context via route -n)
  echo "  Step 11: Display the routing table with a legacy-style command."
  read -p "  lab@lab317:~$ " cmd11
  echo
  if [[ "$cmd11" == "route -n" ]]; then
    echo "  Kernel IP routing table"
    echo "  Destination     Gateway         Genmask         Flags Metric Ref    Use Iface"
    echo "  0.0.0.0         192.168.50.1    0.0.0.0         UG    100    0        0 ens33"
    echo "  192.168.50.0    0.0.0.0         255.255.255.0   U     100    0        0 ens33"
    echo
  else
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 12: inspect another common legacy path mention (netplan)
  echo "  Step 12: Display a modern replacement path that superseded interfaces on newer Ubuntu."
  read -p "  lab@lab317:~$ " cmd12
  echo
  if [[ "$cmd12" == "ls -1 /etc/netplan" ]]; then
    echo "  01-netcfg.yaml"
    echo
  else
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 13: show contents of a legacy ifcfg with CIDR prefix
  echo "  Step 13: Reopen the ens33 ifcfg file to review static settings."
  read -p "  lab@lab317:~$ " cmd13
  echo
  if [[ "$cmd13" == "cat /etc/sysconfig/network-scripts/ifcfg-ens33" ]]; then
    echo "  DEVICE=ens33"
    echo "  BOOTPROTO=none"
    echo "  ONBOOT=yes"
    echo "  IPADDR=192.168.50.10"
    echo "  NETMASK=255.255.255.0"
    echo "  PREFIX=24"
    echo "  GATEWAY=192.168.50.1"
    echo
  else
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 14: confirm legacy tool shows matching IP
  echo "  Step 14: Confirm the legacy tool shows the same IPv4 address."
  read -p "  lab@lab317:~$ " cmd14
  echo
  if [[ "$cmd14" == "ifconfig ens33" ]]; then
    echo "  ens33: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500"
    echo "        inet 192.168.50.10  netmask 255.255.255.0  broadcast 192.168.50.255"
    echo "        ether 00:16:3e:5a:7b:9c  txqueuelen 1000  (Ethernet)"
    echo
  else
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 15: stop interface again
  echo "  Step 15: Stop ens33 again using the legacy command."
  read -p "  lab@lab317:~$ " cmd15
  echo
  if [[ "$cmd15" == "ifdown ens33" ]]; then
    echo
  else
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 16: start interface again
  echo "  Step 16: Start ens33 again using the legacy command."
  read -p "  lab@lab317:~$ " cmd16
  echo
  if [[ "$cmd16" == "ifup ens33" ]]; then
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
