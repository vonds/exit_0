#!/bin/bash

# Lab 344: A+ Networking Fundamentals (10 Questions, Set 9)
# Focus: UDP, LAN, high-speed Wi-Fi, dual-band standards, NetBT, managed switch,
#        FCC/IEEE, DHCP ports, PoE distance, NetBT ports

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 344: A+ Section 2"
LAB_ID="lab344"
LAB_XP=18400
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
    center_text "Scenario: Review A+ networking fundamentals — concise, open-ended responses."
    echo
    center_text "Press Enter to begin..."
    read _

    # Q1
    draw_lab_ui
    echo "  Which host-to-host protocol is best-effort and not guaranteed?"
    read -p "  lab@lab320:~$ " cmd1
    echo
    if [[ "$cmd1" != "UDP" && "$cmd1" != "udp" ]]; then
        print_error "Incorrect. Correct: UDP."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: UDP"
    echo

    # Q2
    echo "  What type of network is contained within one office or building?"
    read -p "  lab@lab320:~$ " cmd2
    echo
    if [[ "$cmd2" != "LAN" && "$cmd2" != "lan" ]]; then
        print_error "Incorrect. Correct: LAN."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: LAN"
    echo

    # Q3
    echo "  You need 1 Gbps or faster Wi-Fi. Which TWO standards can provide that?"
    read -p "  lab@lab320:~$ " cmd3
    echo
    if [[ "$cmd3" != "802.11n and 802.11ax" && "$cmd3" != "802.11ax and 802.11n" && "$cmd3" != "11n and 11ax" ]]; then
        print_error "Incorrect. Correct: 802.11n and 802.11ax."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 802.11n and 802.11ax"
    echo

    # Q4
    echo "  Which TWO Wi-Fi standards use both 2.4 GHz and 5 GHz bands?"
    read -p "  lab@lab320:~$ " cmd4
    echo
    if [[ "$cmd4" != "802.11n and 802.11ax" && "$cmd4" != "802.11ax and 802.11n" ]]; then
        print_error "Incorrect. Correct: 802.11n and 802.11ax."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 802.11n and 802.11ax"
    echo

    # Q5
    echo "  What legacy protocol lets NetBIOS apps run over TCP/IP?"
    read -p "  lab@lab320:~$ " cmd5
    echo
    if [[ "$cmd5" != "NetBT" && "$cmd5" != "netbt" && "$cmd5" != "NetBIOS over TCP/IP" && "$cmd5" != "netbios over tcp/ip" ]]; then
        print_error "Incorrect. Correct: NetBT."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: NetBT"
    echo

    # Q6
    echo "  Which feature does NOT require a managed switch?"
    read -p "  lab@lab320:~$ " cmd6
    echo
    if [[ "$cmd6" != "Direct packets out the proper port" && "$cmd6" != "Forward packets" && "$cmd6" != "basic switching" ]]; then
        print_error "Incorrect. Correct: Direct packets out the proper port."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Direct packets out the proper port"
    echo

    # Q7
    echo "  In the U.S., which TWO groups approve wireless channel use?"
    read -p "  lab@lab320:~$ " cmd7
    echo
    if [[ "$cmd7" != "FCC and IEEE" && "$cmd7" != "IEEE and FCC" ]]; then
        print_error "Incorrect. Correct: FCC and IEEE."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: FCC and IEEE"
    echo

    # Q8
    echo "  What ports does DHCP use?"
    read -p "  lab@lab320:~$ " cmd8
    echo
    if [[ "$cmd8" != "67 and 68" && "$cmd8" != "67/68" ]]; then
        print_error "Incorrect. Correct: 67/68."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 67/68"
    echo

    # Q9
    echo "  What’s the max distance between a PoE injector and device on 1000BaseT?"
    read -p "  lab@lab320:~$ " cmd9
    echo
    if [[ "$cmd9" != "100 meters" && "$cmd9" != "100m" && "$cmd9" != "100" ]]; then
        print_error "Incorrect. Correct: 100 meters."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 100 meters"
    echo

    # Q10
    echo "  Which protocol uses ports 137–139?"
    read -p "  lab@lab320:~$ " cmd10
    echo
    if [[ "$cmd10" != "NetBT" && "$cmd10" != "netbt" && "$cmd10" != "NetBIOS over TCP/IP" && "$cmd10" != "netbios over tcp/ip" ]]; then
        print_error "Incorrect. Correct: NetBT."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: NetBT"
    echo

    print_success "Lab complete."
    print_info "You earned $LAB_XP XP for completing this lab."
    award_xp "$LAB_XP"
    XP=$(jq '.XP' "$SAVE_JSON")
    LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
    export XP LEVEL
    record_lab_completion

    completion_count=$(get_lab_completion_count)
    echo
    print_info "You've completed this lab $completion_count time(s)."
    echo
    center_text "Would you like to:"
    center_text "1) Retry this lab"
    center_text "2) Return to A+ Lab Menu"
    echo
    read -p "  > " post_choice
    [[ "$post_choice" == "2" ]] && exit 0
done
