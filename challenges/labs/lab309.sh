#!/bin/bash

# Lab 309: IPv4 & IPv6 Fundamentals

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab Networking: IPv4 & IPv6"
LAB_ID="lab309"
LAB_XP=29500
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
    center_text "Work with IPv4/IPv6 concepts and commands."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Send two IPv4 echo requests to the loopback interface."
    read -p "  lab@lab34:~$ " cmd1
    echo
    [[ "$cmd1" != "ping -c 2 127.0.0.1" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  PING 127.0.0.1 (127.0.0.1) 56(84) bytes of data."
    echo "  64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.040 ms"
    echo "  64 bytes from 127.0.0.1: icmp_seq=2 ttl=64 time=0.043 ms"
    echo "  "
    echo "  --- 127.0.0.1 ping statistics ---"
    echo "  2 packets transmitted, 2 received, 0% packet loss, time 1001ms"
    echo "  rtt min/avg/max/mdev = 0.040/0.041/0.043/0.001 ms"
    echo

    echo "  Step 2: Send two IPv6 echo requests to the IPv6 loopback address using the IPv6-specific ping."
    read -p "  lab@lab34:~$ " cmd2
    echo
    [[ "$cmd2" != "ping6 -c 2 ::1" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  PING ::1(::1) 56 data bytes"
    echo "  64 bytes from ::1: icmp_seq=1 ttl=64 time=0.030 ms"
    echo "  64 bytes from ::1: icmp_seq=2 ttl=64 time=0.031 ms"
    echo "  "
    echo "  --- ::1 ping statistics ---"
    echo "  2 packets transmitted, 2 received, 0% packet loss, time 1001ms"
    echo "  rtt min/avg/max/mdev = 0.030/0.030/0.031/0.001 ms"
    echo

    echo "  Step 3: Provide the IPv6 loopback address in shorthand."
    read -p "  lab@lab34:~$ " cmd3
    echo
    [[ "$cmd3" != "::1" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 4: Provide the IPv4 loopback address."
    read -p "  lab@lab34:~$ " cmd4
    echo
    [[ "$cmd4" != "127.0.0.1" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 5: State the layer-3 neighbor discovery protocol used by IPv6 (short acronym)."
    read -p "  lab@lab34:~$ " cmd5
    echo
    [[ "$cmd5" != "NDP" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 6: State the protocol used by IPv4 to map IP addresses to MAC addresses."
    read -p "  lab@lab34:~$ " cmd6
    echo
    [[ "$cmd6" != "ARP" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 7: Show the route lookup for an IPv6 public resolver address using iproute2."
    read -p "  lab@lab34:~$ " cmd7
    echo
    [[ "$cmd7" != "ip -6 route get 2001:4860:4860::8888" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  2001:4860:4860::8888 dev eth0 src 2001:db8::1 metric 1024"
    echo

    echo "  Step 8: Compress this IPv6 address using proper shorthand: 2001:0db8:0000:0000:0000:0000:0000:0001"
    read -p "  lab@lab34:~$ " cmd8
    echo
    [[ "$cmd8" != "2001:db8::1" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 9: Which IP version has multicast built into the base protocol specification?"
    read -p "  lab@lab34:~$ " cmd9
    echo
    [[ "$cmd9" != "IPv6" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 10: Is NAT required for IPv6?"
    read -p "  lab@lab34:~$ " cmd10
    echo
    [[ "$cmd10" != "no" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }

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
