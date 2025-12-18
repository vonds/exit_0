#!/bin/bash

# Lab 58: Network Commands and Diagnostics

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 58: Network Commands and Diagnostics"
LAB_ID="lab58"
LAB_XP=21743
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

INTERFACE="enp0s3"

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
    center_text "Scenario: The networking team reports intermittent connectivity issues"
    center_text "on several systems in the 192.168.1.0/24 subnet. You've been asked"
    center_text "to perform basic diagnostics on your system and validate interface behavior."
    echo
    center_text "Press Enter to begin troubleshooting..."
    read _

    draw_lab_ui
    echo "  Step 1: Ping 127.0.0.1 and send 2 packets to verify local TCP/IP stack."
    read -p "  lab@lpic-lab58:~$ " cmd1
    echo
    [[ "$cmd1" != "ping -c 2 127.0.0.1" ]] && {
        print_error "Incorrect. Use ping -c 2 127.0.0.1."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  PING 127.0.0.1 56(84) bytes of data."
    echo "  64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.039 ms"
    echo "  64 bytes from 127.0.0.1: icmp_seq=2 ttl=64 time=0.041 ms"
    echo
    echo "  --- 127.0.0.1 ping statistics ---"
    echo "  2 packets transmitted, 2 received, 0% packet loss, time 1010ms"
    echo "  rtt min/avg/max/mdev = 0.039/0.040/0.041/0.001 ms"
    echo

    echo "  Step 2: Temporarily bring down the interface '$INTERFACE' for testing."
    read -p "  lab@lpic-lab58:~$ " cmd2
    echo
    [[ "$cmd2" != "sudo ifdown $INTERFACE" ]] && {
        print_error "Incorrect. Use sudo ifdown $INTERFACE."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Bringing down interface $INTERFACE:  [  OK  ]"
    echo "  Network interface '$INTERFACE' is now inactive."
    echo

    echo "  Step 3: Bring the interface '$INTERFACE' back online."
    read -p "  lab@lpic-lab58:~$ " cmd3
    echo
    [[ "$cmd3" != "sudo ifup $INTERFACE" ]] && {
        print_error "Incorrect. Use sudo ifup $INTERFACE."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Bringing up interface $INTERFACE:  [  OK  ]"
    echo "  Assigned IP address: 192.168.1.42/24"
    echo "  Gateway: 192.168.1.1"
    echo

    echo "  Step 4: Check active listening ports and services to confirm availability."
    read -p "  lab@lpic-lab58:~$ " cmd4
    echo
    [[ "$cmd4" != "netstat -tuln" ]] && {
        print_error "Incorrect. Use netstat -tuln."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Active Internet connections (only servers)"
    echo "  Proto Recv-Q Send-Q Local Address           Foreign Address         State"
    echo "  tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN"
    echo "  tcp6       0      0 :::80                   :::*                    LISTEN"
    echo "  udp        0      0 127.0.0.1:323           0.0.0.0:*"
    echo "  udp6       0      0 ::1:323                 :::*"
    echo

    echo "  Step 5: Capture ICMP traffic using tcpdump for further packet inspection."
    read -p "  lab@lpic-lab58:~$ " cmd5
    echo
    [[ "$cmd5" != "sudo tcpdump icmp" ]] && {
        print_error "Incorrect. Use sudo tcpdump icmp."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  tcpdump: verbose output suppressed, use -v or -vv for full protocol decode"
    echo "  listening on $INTERFACE, link-type EN10MB (Ethernet), capture size 262144 bytes"
    echo "  10:42:15.123456 IP 192.168.1.42 > 192.168.1.1: ICMP echo request, id 1234, seq 1, length 64"
    echo "  10:42:15.123789 IP 192.168.1.1 > 192.168.1.42: ICMP echo reply, id 1234, seq 1, length 64"
    echo "  10:42:16.125321 IP 192.168.1.42 > 192.168.1.1: ICMP echo request, id 1234, seq 2, length 64"
    echo "  10:42:16.125654 IP 192.168.1.1 > 192.168.1.42: ICMP echo reply, id 1234, seq 2, length 64"
    echo "^C"
    echo "  4 packets captured"
    echo "  4 packets received by filter"
    echo "  0 packets dropped by kernel"
    echo

    print_success "Lab complete."
    print_info "You earned $LAB_XP XP for completing this lab."
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON")
    LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
    export XP
    export LEVEL
    record_lab_completion

    completion_count=$(get_lab_completion_count)
    echo
    print_info "You've completed this lab $completion_count time(s)."
    echo
    center_text "Would you like to:"
    center_text "1) Retry this lab"
    center_text "2) Return to Sysadmin Lab Menu"
    echo
    read -p "  > " post_choice

    [[ "$post_choice" == "2" ]] && exit 0
done
