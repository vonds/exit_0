#!/bin/bash

# Lab 131: Networking Fundamentals

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab Networking: Fundamentals 5"
LAB_ID="lab131"
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
    center_text "Work with networking fundamentals commands and concepts. (set 5)"
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Marketing requests that www.example.com resolve to the local machine on this host only."
    echo "  Provide the single /etc/hosts line you would add to enforce this override."
    read -p "  lab@lab131:~$ " cmd1
    echo
    [[ "$cmd1" != "127.0.0.1 www.example.com" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 2: You modified routes using a command that changes the active default path."
    echo "  Ensure the kernel immediately uses the updated routing information with a one-liner."
    read -p "  lab@lab131:~$ " cmd2
    echo
    [[ "$cmd2" != "ip route flush cache" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 3: A mail administrator asks you to confirm the domain's SPF policy via DNS."
    echo "  Issue a dig query that requests the correct record type for example.org."
    read -p "  lab@lab131:~$ " cmd3
    echo
    [[ "$cmd3" != "dig example.org -t txt" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  ; <<>> DiG <<>> example.org -t txt"
    echo "  ;; ANSWER SECTION:"
    echo "  example.org.    300   IN   TXT   \"v=spf1 include:_spf.example.net -all\""
    echo

    echo "  Step 4: During a postmortem you are asked which transport establishes connections with a three-segment handshake."
    echo "  Reply with the protocol name only."
    read -p "  lab@lab131:~$ " cmd4
    echo
    [[ "$cmd4" != "TCP" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 5: Capacity planning needs the total address count for the private 172.16.0.0/12 range."
    echo "  Provide the number of IPv4 addresses in that block."
    read -p "  lab@lab131:~$ " cmd5
    echo
    [[ "$cmd5" != "1,048,576" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 6: You can load the team's web portal over HTTPS, but all ping attempts to the same host time out."
    echo "  State the most likely cause in a few words."
    read -p "  lab@lab131:~$ " cmd6
    echo
    [[ "$cmd6" != "ICMP blocked" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 7: While reviewing the route table, you notice entries with the flags 'UG'."
    echo "  What does the 'G' indicate? Reply with a single word."
    read -p "  lab@lab131:~$ " cmd7
    echo
    [[ "$cmd7" != "gateway" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 8: For a forensic snapshot, request a full DNS zone transfer of example.org from 192.168.1.4."
    echo "  Provide the exact command."
    read -p "  lab@lab131:~$ " cmd8
    echo
    [[ "$cmd8" != "dig example.org @192.168.1.4 axfr" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  ; <<>> DiG <<>> example.org @192.168.1.4 axfr"
    echo "  ;; ANSWER SECTION:"
    echo "  example.org.   86400  IN  SOA  ns1.example.org. hostmaster.example.org. 2025082801 7200 3600 1209600 3600"
    echo "  example.org.   86400  IN  NS   ns1.example.org."
    echo "  example.org.   86400  IN  NS   ns2.example.org."
    echo "  ;; XFR size: 3 records (messages 1, bytes 200)"
    echo

    echo "  Step 9: Operations asks for cumulative per-protocol networking stats, including packets forwarded by the kernel."
    echo "  Display a summary from the local system."
    read -p "  lab@lab131:~$ " cmd9
    echo
    [[ "$cmd9" != "netstat -s" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Ip:"
    echo "      Forwarding: 42"
    echo "      InReceives: 102394"
    echo "      InDelivers: 101982"
    echo "      OutRequests: 99833"
    echo

    echo "  Step 10: Using the ip utility without specifying a protocol family defaults to which family?"
    echo "  Reply with the keyword only."
    read -p "  lab@lab131:~$ " cmd10
    echo
    [[ "$cmd10" != "inet" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No standard output on success)

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
