#!/bin/bash

# Lab Networking 1: Fundamentals (part 1)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab Networking: Fundamentals 1"
LAB_ID="lab_net_1"
LAB_XP=12500
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
    center_text "Work with networking fundamentals commands and concepts. (set 1)"
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Show the current default route without performing DNS lookups."
    read -p "  lab@net-1:~$ " cmd1
    echo
    [[ "$cmd1" != "netstat -rn" ]] && {
        print_error "Incorrect. Use: netstat -rn"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Kernel IP routing table"
    echo "  Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface"
    echo "  0.0.0.0         192.168.1.1     0.0.0.0         UG        0 0          0 eth0"
    echo "  192.168.1.0     0.0.0.0         255.255.255.0   U         0 0          0 eth0"
    echo

    echo "  Step 2: Display information about all interfaces, including ones that are down."
    read -p "  lab@net-1:~$ " cmd2
    echo
    [[ "$cmd2" != "ifconfig -a" ]] && {
        print_error "Use: ifconfig -a"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500"
    echo "        inet 192.168.1.100  netmask 255.255.255.0  broadcast 192.168.1.255"
    echo "        ether 08:00:27:9e:3f:5c  txqueuelen 1000  (Ethernet)"
    echo
    echo "  eth1: flags=4098<BROADCAST,MULTICAST>  mtu 1500"
    echo "        ether 08:00:27:aa:bb:cc  txqueuelen 1000  (Ethernet)"
    echo

    echo "  Step 3: Identify which of these addresses is NOT private."
    echo "          172.16.4.2   192.168.40.3   10.74.5.244   143.236.32.231"
    read -p "  lab@net-1:~$ " cmd3
    echo
    [[ "$cmd3" != "143.236.32.231" ]] && {
        print_error "Answer by typing the public IP (143.236.32.231)"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Correct. 143.236.32.231 is public; the others are private ranges."
    echo

    echo "  Step 4: Add a default gateway of 192.168.1.1 for interface eth0."
    read -p "  lab@net-1:~$ " cmd4
    echo
    [[ "$cmd4" != "route add default gw 192.168.1.1 eth0" ]] && {
        print_error "Use: route add default gw 192.168.1.1 eth0"
        read -p "Press Enter to try again..." _
        continue
    }
    echo

    echo "  Step 5: Query for the authoritative name servers of a domain with host."
    read -p "  lab@net-1:~$ " cmd5
    echo
    [[ "$cmd5" != "host -t ns example.com" ]] && {
        print_error "Use: host -t ns DOMAIN"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  example.com name server ns1.example.com."
    echo "  example.com name server ns2.example.com."
    echo

    echo "  Step 6: Open the correct ports/protocols on a firewall to allow DNS primaries and secondaries to communicate."
    read -p "  lab@net-1:~$ " cmd6
    echo
    [[ "$cmd6" != "udp/53 tcp/53" ]] && {
        print_error "Answer by echoing: udp/53 tcp/53"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Correct: UDP/53 is for queries; TCP/53 is for zone transfers."
    echo

    echo "  Step 7: Use ping to choose the interface from which ICMP packets will be generated."
    read -p "  lab@net-1:~$ " cmd7
    echo
    [[ "$cmd7" != "ping -I eth0 8.8.8.8" ]] && {
        print_error "Use: ping -I INTERFACE HOST"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  PING 8.8.8.8 (8.8.8.8) from 192.168.1.100 eth0: 56(84) bytes of data."
    echo "  64 bytes from 8.8.8.8: icmp_seq=1 ttl=118 time=20.4 ms"
    echo

    echo "  Step 8: Split a subnet to enable four subnets with up to 30 hosts each. Provide the correct CIDR mask."
    read -p "  lab@net-1:~$ " cmd8
    echo
    [[ "$cmd8" != "/27" ]] && {
        print_error "Answer with: /27"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Correct: /27 provides 32 addresses, 30 usable hosts."
    echo

    echo "  Step 9: Query mail servers for example.com using dig."
    read -p "  lab@net-1:~$ " cmd9
    echo
    [[ "$cmd9" != "dig example.com mx" ]] && {
        print_error "Use: dig DOMAIN mx"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  ;; ANSWER SECTION:"
    echo "  example.com.    3600    IN  MX  10 mail1.example.com."
    echo "  example.com.    3600    IN  MX  20 mail2.example.com."
    echo

    echo "  Step 10: Identify the IPv6 localhost address."
    read -p "  lab@net-1:~$ " cmd10
    echo
    [[ "$cmd10" != "::1" ]] && {
        print_error "Answer with: ::1"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Correct: ::1 is the IPv6 loopback address."
    echo

    print_success "Nice work!"
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
