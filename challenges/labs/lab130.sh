#!/bin/bash

# Lab 130: Networking Fundamentals

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab Networking: Fundamentals 4"
LAB_ID="lab130"
LAB_XP=19500
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
    center_text "Work with networking fundamentals commands and concepts. (set 4)"
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Create a simple TCP listener on port 8080 using netcat."
    read -p "  lab@lab129:~$ " cmd1
    echo
    [[ "$cmd1" != "nc -l -p 8080" ]] && {
        print_error "Incorrect. Use netcat in listen mode and specify port 8080."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 2: Display the SOA (Start of Authority) record for example.com."
    read -p "  lab@lab129:~$ " cmd2
    echo
    [[ "$cmd2" != "dig example.com soa" ]] && {
        print_error "Incorrect. Query the SOA record for the domain."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  ; <<>> DiG <<>> example.com soa"
    echo "  ;; ANSWER SECTION:"
    echo "  example.com.       3600    IN  SOA ns1.example.com. hostmaster.example.com. 2025010101 7200 3600 1209600 3600"
    echo

    echo "  Step 3: Configure short hostnames to try example.com and example.org automatically."
    read -p "  lab@lab129:~$ " cmd3
    echo
    [[ "$cmd3" != "search example.com example.org" ]] && {
        print_error "Incorrect. Provide the resolv.conf search directive with both domains."
        read -p "Press Enter to try again..." _
        continue
    }
    echo

    echo "  Step 4: Send an IPv6 ping to the ULA address fdd6:551:b09f::."
    read -p "  lab@lab129:~$ " cmd4
    echo
    [[ "$cmd4" != "ping -6 fdd6:551:b09f::" ]] && {
        print_error "Incorrect. Use ping with IPv6 forced to the given address."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  PING fdd6:551:b09f::(fdd6:551:b09f::) 56 data bytes"
    echo "  64 bytes from fdd6:551:b09f::: icmp_seq=1 ttl=64 time=0.532 ms"
    echo

    echo "  Step 5: Prevent traffic from reaching host 192.168.1.3 using a legacy routing rule."
    read -p "  lab@lab129:~$ " cmd5
    echo
    [[ "$cmd5" != "route add -host 192.168.1.3 reject" ]] && {
        print_error "Incorrect. Add a host route that rejects traffic to 192.168.1.3."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 6: State a key difference between tracepath and traceroute regarding MTU."
    read -p "  lab@lab129:~$ " cmd6
    echo
    [[ "$cmd6" != "tracepath shows MTU per hop" ]] && {
        print_error "Incorrect. Summarize that tracepath reports MTU per hop."
        read -p "Press Enter to try again..." _
        continue
    }
    echo

    echo "  Step 7: Send exactly four ICMP echo requests and then exit."
    read -p "  lab@lab129:~$ " cmd7
    echo
    [[ "$cmd7" != "ping -c 4" ]] && {
        print_error "Incorrect. Use ping with a count of 4."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  PING target (192.0.2.1) 56(84) bytes of data."
    echo "  64 bytes from 192.0.2.1: icmp_seq=1 ttl=64 time=0.42 ms"
    echo "  64 bytes from 192.0.2.1: icmp_seq=2 ttl=64 time=0.41 ms"
    echo "  64 bytes from 192.0.2.1: icmp_seq=3 ttl=64 time=0.40 ms"
    echo "  64 bytes from 192.0.2.1: icmp_seq=4 ttl=64 time=0.39 ms"
    echo "  --- target ping statistics ---"
    echo "  4 packets transmitted, 4 received, 0% packet loss, time 3ms"
    echo

    echo "  Step 8: Name the terminal interface for NetworkManager."
    read -p "  lab@lab129:~$ " cmd8
    echo
    [[ "$cmd8" != "nmcli" ]] && {
        print_error "Incorrect. Provide the CLI used to manage NetworkManager."
        read -p "Press Enter to try again..." _
        continue
    }
    echo

    echo "  Step 9: Add an additional IPv6 address fdd6:551:b09e::/128 to eth1 using ifconfig."
    read -p "  lab@lab129:~$ " cmd9
    echo
    [[ "$cmd9" != "ifconfig eth1 inet6 add fdd6:551:b09e::/128" ]] && {
        print_error "Incorrect. Use: ifconfig <iface> inet6 add <addr>/<prefix>"
        read -p "Press Enter to try again..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 10: Which port is used for LDAP over SSL (LDAPS)?"
    read -p "  lab@lab129:~$ " cmd10
    echo
    [[ "$cmd10" != "tcp/636" ]] && {
        print_error "Incorrect. Provide the protocol/port pair for LDAPS."
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
