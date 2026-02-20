#!/bin/bash

# Lab 11: Basic Network Troubleshooting and Configuration

# Dynamically locate root directory and source core scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 11: Basic Network Troubleshooting and Configuration"
LAB_ID="lab11"
LAB_XP=2111
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"

[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

draw_lab_ui() {
    clear
    center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
    center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
    echo
    echo
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
    center_text "A user reports they can't access external websites."
    center_text "Your task is to diagnose the problem by checking IP settings,"
    center_text "DNS resolution, and connectivity to the outside network."
    echo
    center_text "Press Enter to begin the lab..."
    read _
    draw_lab_ui

    # Step 1: Interfaces & IP addresses (interactive)
    echo "  Step 1: What command shows network interfaces and IP addresses?"
    read -p "  lab@lpic-lab11:~$ " cmd1
    echo

    if [[ "$cmd1" != "ip a" && "$cmd1" != "ip addr" && "$cmd1" != "ip addr show" && "$cmd1" != "ip address" && "$cmd1" != "ip address show" ]]; then
        print_error "Incorrect. Hint: Use 'ip addr' (short form: 'ip a')."
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500"
    echo "      inet 192.168.1.42/24 brd 192.168.1.255 scope global eth0"
    echo "      inet6 fe80::a00:27ff:fe4e:66a1/64 scope link"
    echo

    # Step 2: Default gateway / routing table
    echo "  Step 2: What command would display the system’s default gateway?"
    read -p "  lab@lpic-lab11:~$ " cmd2
    echo

    if [[ "$cmd2" != "ip route" && "$cmd2" != "ip r" ]]; then
        print_error "Incorrect. Hint: Use 'ip route' (short form: 'ip r')."
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  default via 192.168.1.1 dev eth0 proto dhcp metric 100"
    echo "  192.168.1.0/24 dev eth0 proto kernel scope link src 192.168.1.42"
    echo

    # Step 3: DNS resolution test
    echo "  Step 3: What command tests if DNS resolution is working?"
    read -p "  lab@lpic-lab11:~$ " cmd3
    echo

    if [[ "$cmd3" != "dig google.com" && "$cmd3" != "host google.com" && "$cmd3" != "nslookup google.com" ]]; then
        print_error "Incorrect. Hint: Use a DNS lookup tool like dig, host, or nslookup."
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  google.com.   300 IN A 142.250.190.78"
    echo

    # Step 4: Reachability to an IP (bypass DNS)
    echo "  Step 4: What command checks if you can reach an IP (like 1.1.1.1)?"
    read -p "  lab@lpic-lab11:~$ " cmd4
    echo

    if [[ "$cmd4" != "ping -c 4 1.1.1.1" ]]; then
        print_error "Incorrect. Hint: Use 'ping' with -c to limit packet count."
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data."
    echo "  64 bytes from 1.1.1.1: icmp_seq=1 ttl=56 time=3.12 ms"
    echo "  --- 1.1.1.1 ping statistics ---"
    echo "  4 packets transmitted, 4 received, 0% packet loss"
    echo

    # Step 5: System DNS configuration file
    echo "  Step 5: What file would you check for system DNS configuration?"
    read -p "  lab@lpic-lab11:~$ " cmd5
    echo

    if [[ "$cmd5" != "/etc/resolv.conf" ]]; then
        print_error "Incorrect. Hint: Classic file used by libc for name resolution."
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  nameserver 1.1.1.1"
    echo "  nameserver 8.8.8.8"
    echo

    # Step 6: Interface view (again) as a quick summary tool
    echo "  Step 6: What tool provides interface details in one view?"
    read -p "  lab@lpic-lab11:~$ " cmd6
    echo

    if [[ "$cmd6" != "ip addr show" && "$cmd6" != "ip a" ]]; then
        print_error "Incorrect. Hint: You used this earlier to view addresses."
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  eth0: inet 192.168.1.42/24 brd 192.168.1.255 scope global"
    echo "  eth0: inet6 fe80::a00:27ff:fe4e:66a1/64 scope link"
    echo

    print_success "Excellent!"
    print_info "You reviewed network interfaces, verified the default route,"
    print_info "confirmed DNS resolution, and used ping to test connectivity."
    print_info "You earned $LAB_XP XP for completing this lab!"
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON")
    LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
    export XP
    export LEVEL
    record_lab_completion

    completion_count=$(get_lab_completion_count)
    echo
    print_info "You've successfully completed this lab $completion_count time(s)."
    echo
    center_text "Would you like to:"
    center_text "1) Retry this lab"
    center_text "2) Return to Sysadmin Lab Menu"
    echo
    read -p "  > " choice

    if [[ "$choice" == "2" ]]; then
        exit 0
    fi
done
