#!/bin/bash

# Lab 313: Exploring Network Masking – Objective 109.1
# LPIC-1 Focus: Understanding IPv4 and IPv6 network masks, classful vs CIDR notation,
# and distinguishing between network and host portions of an address.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 313: Network Masking"
LAB_ID="lab313"
LAB_XP=33800
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
  center_text "Explore how IPv4 and IPv6 network masks define network and host portions."
  center_text "Practice classful masks, CIDR notation, and IPv6 prefix interpretation."
  echo
  center_text "Press Enter to begin..."
  read _

  draw_lab_ui

  # Step 1
  echo "  Step 1: Display current network interface configuration."
  read -p "  lab@lab313:~$ " cmd1
  echo
  if [[ "$cmd1" == "ifconfig" ]]; then
    echo "  eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500"
    echo "        inet 192.168.1.42  netmask 255.255.255.0  broadcast 192.168.1.255"
    echo "        inet6 2601:600:9200:400:abcd::1  prefixlen 64  scopeid 0x0<global>"
    echo "        ether 00:16:3e:5a:7b:9c  txqueuelen 1000  (Ethernet)"
    echo "        RX packets 124593  bytes 97.1 MiB  TX packets 102311  bytes 83.4 MiB"
    echo
  elif [[ "$cmd1" == "ip addr show" ]]; then
    echo "  2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000"
    echo "      link/ether 00:16:3e:5a:7b:9c brd ff:ff:ff:ff:ff:ff"
    echo "      inet 192.168.1.42/24 brd 192.168.1.255 scope global eth0"
    echo "         valid_lft forever preferred_lft forever"
    echo "      inet6 2601:600:9200:400:abcd::1/64 scope global dynamic mngtmpaddr"
    echo "         valid_lft 2592000sec preferred_lft 604800sec"
    echo
  else
    print_error "Incorrect. Use either 'ifconfig' or 'ip addr show'."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 2
  echo "  Step 2: Provide the Class A default netmask in dotted-decimal form."
  read -p "  lab@lab313:~$ " cmd2
  echo
  [[ "$cmd2" != "255.0.0.0" ]] && {
    print_error "Incorrect. Class A uses 255.0.0.0 as its default mask."
    read -p "Press Enter to retry..." _
    continue
  }

  # Step 3
  echo "  Step 3: Provide the Class B default netmask."
  read -p "  lab@lab313:~$ " cmd3
  echo
  [[ "$cmd3" != "255.255.0.0" ]] && {
    print_error "Incorrect. Class B uses 255.255.0.0."
    read -p "Press Enter to retry..." _
    continue
  }

  # Step 4
  echo "  Step 4: Provide the Class C default netmask."
  read -p "  lab@lab313:~$ " cmd4
  echo
  [[ "$cmd4" != "255.255.255.0" ]] && {
    print_error "Incorrect. Class C uses 255.255.255.0."
    read -p "Press Enter to retry..." _
    continue
  }

  # Step 5
  echo "  Step 5: Convert /24 into its equivalent dotted-decimal mask."
  read -p "  lab@lab313:~$ " cmd5
  echo
  [[ "$cmd5" != "255.255.255.0" ]] && {
    print_error "Incorrect. /24 = 255.255.255.0."
    read -p "Press Enter to retry..." _
    continue
  }

  # Step 6
  echo "  Step 6: Convert /16 into its equivalent dotted-decimal mask."
  read -p "  lab@lab313:~$ " cmd6
  echo
  [[ "$cmd6" != "255.255.0.0" ]] && {
    print_error "Incorrect. /16 = 255.255.0.0."
    read -p "Press Enter to retry..." _
    continue
  }

  # Step 7
  echo "  Step 7: Determine the network portion of 192.168.44.77/27."
  read -p "  lab@lab313:~$ " cmd7
  echo
  [[ "$cmd7" != "192.168.44.64" ]] && {
    print_error "Incorrect. The network address is 192.168.44.64."
    read -p "Press Enter to retry..." _
    continue
  }

  # Step 8
  echo "  Step 8: Provide the broadcast address for 192.168.44.77/27."
  read -p "  lab@lab313:~$ " cmd8
  echo
  [[ "$cmd8" != "192.168.44.95" ]] && {
    print_error "Incorrect. The broadcast address is 192.168.44.95."
    read -p "Press Enter to retry..." _
    continue
  }

  # Step 9
  echo "  Step 9: State how many usable host addresses exist in a /27 network."
  read -p "  lab@lab313:~$ " cmd9
  echo
  [[ "$cmd9" != "30" ]] && {
    print_error "Incorrect. /27 provides 32 total addresses, 30 usable hosts."
    read -p "Press Enter to retry..." _
    continue
  }

  # Step 10
  echo "  Step 10: Identify the command used to view interface IP and netmask details."
  read -p "  lab@lab313:~$ " cmd10
  echo
  if [[ "$cmd10" == "ip addr show" || "$cmd10" == "ip a" ]]; then
    echo "  2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500"
    echo "      inet 192.168.1.42/24 brd 192.168.1.255 scope global eth0"
    echo "      inet6 2601:600:9200:400:abcd::1/64 scope global"
    echo
  elif [[ "$cmd10" == "ifconfig" ]]; then
    echo "  eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500"
    echo "        inet 192.168.1.42  netmask 255.255.255.0  broadcast 192.168.1.255"
    echo "        inet6 2601:600:9200:400:abcd::1  prefixlen 64  scopeid 0x0<global>"
    echo
  else
    print_error "Incorrect. Common commands: 'ip addr show' or 'ifconfig'."
    read -p "Press Enter to retry..." _
    continue
  fi

  # Step 11
  echo "  Step 11: Provide the CIDR notation for the mask 255.255.255.128."
  read -p "  lab@lab313:~$ " cmd11
  echo
  [[ "$cmd11" != "/25" && "$cmd11" != "25" ]] && {
    print_error "Incorrect. 255.255.255.128 = /25."
    read -p "Press Enter to retry..." _
    continue
  }

  # Step 12
  echo "  Step 12: Provide the CIDR notation for the mask 255.255.255.192."
  read -p "  lab@lab313:~$ " cmd12
  echo
  [[ "$cmd12" != "/26" && "$cmd12" != "26" ]] && {
    print_error "Incorrect. 255.255.255.192 = /26."
    read -p "Press Enter to retry..." _
    continue
  }

  # Step 13
  echo "  Step 13: Provide the CIDR notation for the mask 255.255.254.0."
  read -p "  lab@lab313:~$ " cmd13
  echo
  [[ "$cmd13" != "/23" && "$cmd13" != "23" ]] && {
    print_error "Incorrect. 255.255.254.0 = /23."
    read -p "Press Enter to retry..." _
    continue
  }

  # Step 14
  echo "  Step 14: Determine how many bits are in an IPv6 address."
  read -p "  lab@lab313:~$ " cmd14
  echo
  [[ "$cmd14" != "128" ]] && {
    print_error "Incorrect. IPv6 addresses are 128 bits long."
    read -p "Press Enter to retry..." _
    continue
  }

  # Step 15
  echo "  Step 15: In typical IPv6 addressing, how many bits represent the network portion?"
  read -p "  lab@lab313:~$ " cmd15
  echo
  [[ "$cmd15" != "64" ]] && {
    print_error "Incorrect. The first 64 bits are the network prefix in standard IPv6 addressing."
    read -p "Press Enter to retry..." _
    continue
  }

  # Step 16
  echo "  Step 16: Provide the symbol that separates the prefix length in IPv6."
  read -p "  lab@lab313:~$ " cmd16
  echo
  [[ "$cmd16" != "/" ]] && {
    print_error "Incorrect. IPv6 uses a forward slash (/) before the prefix length."
    read -p "Press Enter to retry..." _
    continue
  }

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
