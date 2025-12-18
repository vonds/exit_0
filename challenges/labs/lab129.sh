#!/bin/bash

# Lab 129: Networking Fundamentals

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab Networking: Fundamentals 3"
LAB_ID="lab129"
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
    center_text "Work with networking fundamentals commands and concepts. (set 3)"
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Set the system resolver to use DNS server 192.168.1.4 ."
    read -p "  lab@lab129:~$ " cmd1
    echo
    [[ "$cmd1" != "nameserver 192.168.1.4" ]] && {
        print_error "Incorrect. Use the resolv.conf directive for a DNS server and echo the full line."
        read -p "Press Enter to try again..." _
        continue
    }
    echo

    echo "  Step 2: Identify the file that maps port numbers to service names."
    read -p "  lab@lab129:~$ " cmd2
    echo
    [[ "$cmd2" != "/etc/services" ]] && {
        print_error "Incorrect. Echo the full path to the services database file."
        read -p "Press Enter to try again..." _
        continue
    }
    echo

    echo "  Step 3: Add a static route to 192.168.51.0/24 via 192.168.51.1 using the legacy route tool."
    read -p "  lab@lab129:~$ " cmd3
    echo
    [[ "$cmd3" != "route add -net 192.168.51.0 netmask 255.255.255.0 gw 192.168.51.1" ]] && {
        print_error "Incorrect. Use 'route add -net <net> netmask <mask> gw <gateway>'."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 4: Display socket send and receive queue sizes with netstat (verbose)."
    read -p "  lab@lab129:~$ " cmd4
    echo
    [[ "$cmd4" != "netstat -v" ]] && {
        print_error "Incorrect. Use netstat with the option that shows verbose socket details."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Proto Recv-Q Send-Q Local Address           Foreign Address         State"
    echo "  tcp        0      0 192.168.1.100:ssh       192.168.1.50:51234      ESTABLISHED"
    echo "  tcp        0     64 0.0.0.0:http            0.0.0.0:*               LISTEN"
    echo

    echo "  Step 5: Provide a correct /etc/hosts entry for 192.168.1.4 with FQDN 'cwa.braingia.org' and alias 'cwa'."
    read -p "  lab@lab129:~$ " cmd5
    echo
    [[ "$cmd5" != "192.168.1.4 cwa.braingia.org cwa" ]] && {
        print_error "Incorrect. Start with IP, then FQDN, then aliases; echo the entire line."
        read -p "Press Enter to try again..." _
        continue
    }
    echo

    echo "  Step 6: Configure eth0 with IP 192.168.1.1/24 using ifconfig (legacy syntax)."
    read -p "  lab@lab129:~$ " cmd6
    echo
    [[ "$cmd6" != "ifconfig eth0 192.168.1.1 netmask 255.255.255.0" ]] && {
        print_error "Incorrect. Use: ifconfig <iface> <ip> netmask <mask>"
        read -p "Press Enter to try again..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 7: State the address sizes for IPv4 and IPv6."
    read -p "  lab@lab129:~$ " cmd7
    echo
    [[ "$cmd7" != "IPv4=32 IPv6=128" ]] && {
        print_error "Incorrect. Echo both bit-lengths in the format: IPv4=32 IPv6=128"
        read -p "Press Enter to try again..." _
        continue
    }
    echo

    echo "  Step 8: On which port does ICMP operate?"
    read -p "  lab@lab129:~$ " cmd8
    echo
    [[ "$cmd8" != "no ports" ]] && {
        print_error "Incorrect. Remember: ICMP is not TCP or UDP."
        read -p "Press Enter to try again..." _
        continue
    }
    echo

    echo "  Step 9: Change the default gateway to 192.168.1.1 using eth0 with the modern ip tool."
    read -p "  lab@lab129:~$ " cmd9
    echo
    [[ "$cmd9" != "ip route change default via 192.168.1.1 dev eth0" ]] && {
        print_error "Incorrect. Use: ip route change default via <gw> dev <iface>"
        read -p "Press Enter to try again..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 10: Which port is used for SSH by default?"
    read -p "  lab@lab129:~$ " cmd10
    echo
    [[ "$cmd10" != "tcp/22" ]] && {
        print_error "Incorrect. Echo the protocol/port pair used by SSH."
        read -p "Press Enter to try again..." _
        continue
    }
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
