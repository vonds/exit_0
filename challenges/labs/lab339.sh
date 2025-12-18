#!/bin/bash

# Lab 339: A+ Networking Fundamentals (10 Questions, Set 4)
# Focus: APIPA & DHCP, IPv6 link-local, UPnP, FE80 behavior, FTP port,
#        LDAP & port, Class B mask, 110-block tool, fastest Internet type

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 339: A+ Section 2"
LAB_ID="lab339"
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
    center_text "Scenario: Review key A+ networking fundamentals — open-ended responses only."
    center_text "Answer each question correctly to advance."
    echo
    center_text "Press Enter to begin..."
    read _

    # Q1: 169.254.x.x implications (two facts)
    draw_lab_ui
    echo "  A local computer shows IPv4 address 169.254.2.2. What do you immediately know?"
    read -p "  lab@lab339:~$ " cmd1
    echo
    if [[ "$cmd1" != "APIPA no DHCP" \
        && "$cmd1" != "APIPA; no DHCP" \
        && "$cmd1" != "APIPA, no DHCP" \
        && "$cmd1" != "APIPA and no DHCP" ]]; then
        print_error "Incorrect. Expected: APIPA + no DHCP."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: APIPA address and no DHCP found"
    echo

    # Q2: IPv6 auto-assigned on boot, local segment only
    echo "  Which IPv6 range is auto-assigned by hosts at boot and usable only on the local segment?"
    read -p "  lab@lab339:~$ " cmd2
    echo
    if [[ "$cmd2" != "FE80::/10" && "$cmd2" != "fe80::/10" && "$cmd2" != "Link-local FE80::/10" && "$cmd2" != "link-local FE80::/10" ]]; then
        print_error "Incorrect. The correct answer is: FE80::/10."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: FE80::/10"
    echo

    # Q3: Auto-join and announce presence on LAN (wireless router setting)
    echo "  You want new devices to auto-join and announce their presence to other devices."
    echo "  Which service should be enabled on the wireless router?"
    read -p "  lab@lab339:~$ " cmd3
    echo
    if [[ "$cmd3" != "UPnP" && "$cmd3" != "upnp" && "$cmd3" != "Universal Plug and Play" && "$cmd3" != "universal plug and play" ]]; then
        print_error "Incorrect. The correct answer is: UPnP."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: UPnP"
    echo

    # Q4: Host has only FE80::/10 IPv6 address (two truths)
    # Question 4 (Open-Ended, full prompt)
    echo "  A computer only has an IPv6 address in the FE80::/10 range. What two things are true?"
    read -p "  lab@lab339:~$ " cmd4
    echo
    if [[ "$cmd4" != "No Internet; link-local unicast" \
        && "$cmd4" != "No Internet, link-local unicast" \
        && "$cmd4" != "No Internet and link-local unicast" \
        && "$cmd4" != "Link-local unicast; no Internet" \
        && "$cmd4" != "Link-local; no Internet" \
        && "$cmd4" != "It cannot reach the Internet and it is a link-local unicast address" ]]; then
        print_error "Incorrect. The correct answer is: It cannot reach the Internet AND it is a link-local unicast address."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: No Internet + link-local unicast"
    echo


    # Q5: FTP port for clients on Internet
    echo "  Users cannot access your FTP service on the web server. Which port should they use?"
    read -p "  lab@lab339:~$ " cmd5
    echo
    if [[ "$cmd5" != "21" ]]; then
        print_error "Incorrect. The correct answer is: 21."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 21"
    echo

    # Q6: Protocol to query directory info (phone numbers, emails)
    echo "  Which protocol enables access to directory data like phone numbers and emails?"
    read -p "  lab@lab339:~$ " cmd6
    echo
    if [[ "$cmd6" != "LDAP" && "$cmd6" != "ldap" && "$cmd6" != "Lightweight Directory Access Protocol" && "$cmd6" != "lightweight directory access protocol" ]]; then
        print_error "Incorrect. The correct answer is: LDAP."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: LDAP"
    echo

    # Q7: LDAP port
    echo "  What port is associated with LDAP?"
    read -p "  lab@lab339:~$ " cmd7
    echo
    if [[ "$cmd7" != "389" ]]; then
        print_error "Incorrect. The correct answer is: 389."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 389"
    echo

    # Q8: Default subnet mask for Class B
    echo "  You chose a Class B network. What default subnet mask should hosts use?"
    read -p "  lab@lab339:~$ " cmd8
    echo
    if [[ "$cmd8" != "255.255.0.0" ]]; then
        print_error "Incorrect. The correct answer is: 255.255.0.0."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 255.255.0.0"
    echo

    # Q9: Tool for attaching cables to a 110 block
    echo "  In the telecom room, which tool attaches network cables to a 110 block?"
    read -p "  lab@lab339:~$ " cmd9
    echo
    if [[ "$cmd9" != "Punchdown tool" && "$cmd9" != "punchdown tool" && "$cmd9" != "Punch-down tool" && "$cmd9" != "punch-down tool" ]]; then
        print_error "Incorrect. The correct answer is: Punchdown tool."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Punchdown tool"
    echo

    # Q10: Fastest Internet connection type
    echo "  Which Internet connection type offers the fastest download speeds?"
    read -p "  lab@lab339:~$ " cmd10
    echo
    if [[ "$cmd10" != "Fiber-optic" && "$cmd10" != "fiber-optic" && "$cmd10" != "Fiber" && "$cmd10" != "fiber" && "$cmd10" != "Fibre" && "$cmd10" != "fibre" ]]; then
        print_error "Incorrect. The correct answer is: Fiber-optic."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Fiber-optic"
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
