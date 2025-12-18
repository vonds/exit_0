#!/bin/bash

# Lab 134: Networking Fundamentals

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab Networking: Fundamentals 8"
LAB_ID="lab134"
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
    center_text "Work with networking fundamentals commands and concepts. (set 8)"
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Investigate recent DHCP client activity on this system using the primary system log."
    read -p "  lab@lab34:~$ " cmd1
    echo
    [[ "$cmd1" != "grep -i dhcp /var/log/syslog" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Aug 29 10:21:14 host dhclient[1234]: DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 5"
    echo "  Aug 29 10:21:19 host dhclient[1234]: DHCPOFFER from 192.168.1.1"
    echo "  Aug 29 10:21:20 host dhclient[1234]: DHCPREQUEST on eth0 to 255.255.255.255 port 67"
    echo "  Aug 29 10:21:20 host dhclient[1234]: DHCPACK from 192.168.1.1"
    echo

    echo "  Step 2: State the allowed character set for hostnames in /etc/hosts as a short phrase."
    read -p "  lab@lab34:~$ " cmd2
    echo
    [[ "$cmd2" != "Alphanumerics, minus, and dot" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 3: Enable resolver debugging using a single configuration directive suitable for resolv.conf."
    read -p "  lab@lab34:~$ " cmd3
    echo
    [[ "$cmd3" != "options debug" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 4: View the current journal for the NetworkManager service unit."
    read -p "  lab@lab34:~$ " cmd4
    echo
    [[ "$cmd4" != "journalctl -u NetworkManager" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Aug 29 10:15:01 host NetworkManager[567]: <info>  [1693306501.1234] device (eth0): state change: disconnected -> activated"
    echo "  Aug 29 10:15:02 host NetworkManager[567]: <info>  [1693306502.0543] policy: set 'Wired connection 1' (eth0) as default for IPv4 routing"
    echo

    echo "  Step 5: Provide the file path read at boot that defines the system's hostname."
    read -p "  lab@lab34:~$ " cmd5
    echo
    [[ "$cmd5" != "/etc/hostname" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 6: Perform an IPv6-only route trace to example.com using the IPv6-specific tracer."
    read -p "  lab@lab34:~$ " cmd6
    echo
    [[ "$cmd6" != "traceroute6 example.com" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  traceroute to example.com (2606:2800:220:1:248:1893:25c8:1946), 30 hops max"
    echo "   1  fe80::1  1.021 ms  0.998 ms  0.990 ms"
    echo

    echo "  Step 7: Using dig, request a full DNS zone transfer for example.org."
    read -p "  lab@lab34:~$ " cmd7
    echo
    [[ "$cmd7" != "dig example.org axfr" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  ; <<>> DiG <<>> example.org axfr"
    echo "  ;; ANSWER SECTION:"
    echo "  example.org.   86400  IN  SOA  ns1.example.org. hostmaster.example.org. 2025082901 7200 3600 1209600 3600"
    echo "  example.org.   86400  IN  NS   ns1.example.org."
    echo "  example.org.   86400  IN  NS   ns2.example.org."
    echo

    echo "  Step 8: Query ALL available DNS record types for example.com using the host utility."
    read -p "  lab@lab34:~$ " cmd8
    echo
    [[ "$cmd8" != "host -a example.com" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Trying \"example.com\""
    echo "  ;; ->>HEADER<<- opcode: QUERY, status: NOERROR"
    echo "  example.com has address 93.184.216.34"
    echo

    echo "  Step 9: Provide the per-user defaults file path used by dig."
    read -p "  lab@lab34:~$ " cmd9
    echo
    [[ "$cmd9" != "~/.digrc" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 10: What DNS record type is defined specifically for POP3 servers? Answer succinctly."
    read -p "  lab@lab34:~$ " cmd10
    echo
    [[ "$cmd10" != "none" ]] && {
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
