#!/bin/bash

# Lab 133: Networking Fundamentals

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab Networking: Fundamentals 7"
LAB_ID="lab133"
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
    center_text "Work with networking fundamentals commands and concepts. (set 7)"
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: You’re tracing a suspected bad cable. Rapidly generate ICMP echoes to 198.51.100.10 so the NIC LEDs are obvious."
    read -p "  lab@lab33:~$ " cmd1
    echo
    [[ "$cmd1" != "ping -f 198.51.100.10" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  PING 198.51.100.10 (198.51.100.10) 56(84) bytes of data."
    echo "  . . ."
    echo

    echo "  Step 2: Telnet is unavailable on this system. Test TCP reachability to example.com on 443 from the CLI."
    read -p "  lab@lab33:~$ " cmd2
    echo
    [[ "$cmd2" != "nc -vz example.com 443" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Connection to example.com 443 port [tcp/https] succeeded!"
    echo

    echo "  Step 3: Before capturing packets, list the interfaces your sniffer can attach to."
    read -p "  lab@lab33:~$ " cmd3
    echo
    [[ "$cmd3" != "tcpdump -D" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  1.eth0"
    echo "  2.lo"
    echo "  3.wlan0"
    echo

    echo "  Step 4: Send ICMP requests over IPv6 to 2001:db8::1."
    read -p "  lab@lab33:~$ " cmd4
    echo
    [[ "$cmd4" != "ping6 2001:db8::1" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  PING 2001:db8::1(2001:db8::1) 56 data bytes"
    echo "  64 bytes from 2001:db8::1: icmp_seq=1 ttl=64 time=0.52 ms"
    echo

    echo "  Step 5: Show only the IPv6 addresses currently configured on this host."
    read -p "  lab@lab33:~$ " cmd5
    echo
    [[ "$cmd5" != "ip -6 addr" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  2: eth0    inet6 2001:db8:1::100/64 scope global dynamic"
    echo "             valid_lft 86399sec preferred_lft 14399sec"
    echo "  1: lo      inet6 ::1/128 scope host"
    echo

    echo "  Step 6: For a controlled test, disable ARP on eth0."
    read -p "  lab@lab33:~$ " cmd6
    echo
    [[ "$cmd6" != "ifconfig eth0 -arp" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 7: Add a host route to 203.0.113.5 forcing traffic out of eth0 explicitly."
    read -p "  lab@lab33:~$ " cmd7
    echo
    [[ "$cmd7" != "route add -host 203.0.113.5 dev eth0" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 8: Identify which processes own open sockets on this system."
    read -p "  lab@lab33:~$ " cmd8
    echo
    [[ "$cmd8" != "ss -p" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  tcp  ESTAB  0  0  192.168.1.100:ssh  192.168.1.50:51234  users:(('sshd',pid=1324,fd=3))"
    echo

    echo "  Step 9: Trace the path to example.com using ICMP echo requests instead of UDP."
    read -p "  lab@lab33:~$ " cmd9
    echo
    [[ "$cmd9" != "traceroute -I example.com" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  traceroute to example.com (93.184.216.34), 30 hops max"
    echo "   1  192.168.1.1   0.901 ms  0.867 ms  0.853 ms"
    echo

    echo "  Step 10: Name the libc/system call the hostname utility uses to retrieve the system name."
    read -p "  lab@lab33:~$ " cmd10
    echo
    [[ "$cmd10" != "gethostname" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No standard output for this answer)

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
