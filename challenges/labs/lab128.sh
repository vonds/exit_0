#!/bin/bash

# Lab Networking: Fundamentals 2

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab Networking: Fundamentals 2"
LAB_ID="lab_net_2"
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
    center_text "Work with networking fundamentals commands and concepts (set 2)."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: The perimeter firewall is dropping UDP probes. Trace the path to example.com using a method likely to traverse this filter."
    read -p "  lab@net-2:~$ " cmd1
    echo
    [[ "$cmd1" != "traceroute -T example.com" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  traceroute to example.com (93.184.216.34), 30 hops max"
    echo "   1  192.168.1.1 (192.168.1.1)   0.972 ms  0.905 ms  0.891 ms"
    echo "   2  10.0.0.1 (10.0.0.1)         6.121 ms  6.033 ms  5.998 ms"
    echo

    echo "  Step 2: After maintenance, bring up every interface that is configured to start automatically—use a single command."
    read -p "  lab@net-2:~$ " cmd2
    echo
    [[ "$cmd2" != "ifup -a" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 3: A deployment script needs only the system's DNS search domain. Print that value and nothing else."
    read -p "  lab@net-2:~$ " cmd3
    echo
    [[ "$cmd3" != "hostname -d" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  example.local"
    echo

    echo "  Step 4: You must watch interface state changes and routing updates in real time from the kernel. Start an appropriate monitor."
    read -p "  lab@net-2:~$ " cmd4
    echo
    [[ "$cmd4" != "ip monitor" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  2: eth0: state DOWN group default"
    echo "  2: eth0: state UP group default"
    echo

    echo "  Step 5: Troubleshoot dual-stack reachability by performing an IPv6-only path trace to example.com."
    read -p "  lab@net-2:~$ " cmd5
    echo
    [[ "$cmd5" != "traceroute -6 example.com" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  traceroute to example.com (2606:2800:220:1:248:1893:25c8:1946), 30 hops max"
    echo "   1  fe80::1                                1.012 ms  1.004 ms  0.998 ms"
    echo

    echo "  Step 6: A policy change requires group lookups to consult local files before LDAP. Provide the exact nsswitch configuration line."
    read -p "  lab@net-2:~$ " cmd6
    echo
    [[ "$cmd6" != "group: files ldap" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo

    echo "  Step 7: The local resolver is unreliable. Query example.com directly against the name server at 192.168.2.5, bypassing local resolution."
    read -p "  lab@net-2:~$ " cmd7
    echo
    [[ "$cmd7" != "dig example.com @192.168.2.5" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  ; <<>> DiG <<>> example.com @192.168.2.5"
    echo "  ;; global options: +cmd"
    echo "  ;; Got answer:"
    echo "  ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 12345"
    echo "  ;; ANSWER SECTION:"
    echo "  example.com.     3600    IN   A     93.184.216.34"
    echo

    echo "  Step 8: SNMP monitoring is failing across the firewall. Provide the protocol/port pairs that must be permitted (space-separated, ascending)."
    read -p "  lab@net-2:~$ " cmd8
    echo
    [[ "$cmd8" != "udp/161 udp/162" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo

    echo "  Step 9: Produce a unified list of host entries as resolved by the system's name service switch."
    read -p "  lab@net-2:~$ " cmd9
    echo
    [[ "$cmd9" != "getent hosts" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  127.0.0.1       localhost"
    echo "  ::1             localhost ip6-localhost ip6-loopback"
    echo "  192.168.1.100   server1.example.local server1"
    echo

    echo "  Step 10: A partner assigned your team a /25. Provide the matching dotted-decimal netmask."
    read -p "  lab@net-2:~$ " cmd10
    echo
    [[ "$cmd10" != "255.255.255.128" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output for this answer)

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
