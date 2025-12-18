#!/bin/bash

# Lab 348: A+ Networking Fundamentals (10 Questions, Set 13)
# Focus: PoE types, ONT facts, Wi-Fi channels, WISP licensing, WLAN, SAN,
#        Network TAP, file share server, Wi-Fi analyzer, FCC 2.4 GHz EIRP (PtMP)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 348: A+ Section 2"
LAB_ID="lab348"
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
    center_text "Scenario: Review A+ networking fundamentals — concise, open-ended answers."
    echo
    center_text "Press Enter to begin..."
    read _

    # Q1: PoE Type 2 device compatible switches (two)
    draw_lab_ui
    echo "  A PoE Type 2 device needs a compatible switch. Name TWO compliant switch types."
    read -p "  lab@lab320:~$ " cmd1
    echo
    if [[ "$cmd1" != "802.3at and 802.3bt" && "$cmd1" != "802.3bt and 802.3at" && "$cmd1" != "PoE+ and 802.3bt" ]]; then
        print_error "Incorrect. Correct: 802.3at and 802.3bt."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 802.3at and 802.3bt"
    echo

    # Q2: ONT truths (two)
    echo "  Give TWO true statements about an ONT."
    read -p "  lab@lab320:~$ " cmd2
    echo
    if [[ "$cmd2" != "Converts fiber to Ethernet and requires external power" \
       && "$cmd2" != "Fiber-to-Ethernet and needs power" \
       && "$cmd2" != "Converts fiber to Ethernet + needs power" ]]; then
        print_error "Incorrect. Correct: Converts fiber to Ethernet AND requires external power."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Fiber→Ethernet + external power"
    echo

    # Q3: Smaller groups of frequencies within a band (two)
    echo "  What are the smaller groups of frequencies within a band called? Give TWO terms."
    read -p "  lab@lab320:~$ " cmd3
    echo
    if [[ "$cmd3" != "Channels and ranges" && "$cmd3" != "Ranges and channels" && "$cmd3" != "Channels and channel ranges" ]]; then
        print_error "Incorrect. Acceptable: Channels and ranges."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Channels and ranges"
    echo

    # Q4: WISP frequency type with no fees and cheaper gear
    echo "  Which WISP frequencies have no fees and cheaper gear?"
    read -p "  lab@lab320:~$ " cmd4
    echo
    if [[ "$cmd4" != "Unlicensed" && "$cmd4" != "unlicensed" ]]; then
        print_error "Incorrect. Correct: Unlicensed."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Unlicensed"
    echo

    # Q5: Doctor's office cable-free tablets network
    echo "  Cable-free tablets across an office: what network type will you set up?"
    read -p "  lab@lab320:~$ " cmd5
    echo
    if [[ "$cmd5" != "WLAN" && "$cmd5" != "wlan" && "$cmd5" != "Wireless LAN" && "$cmd5" != "wireless lan" ]]; then
        print_error "Incorrect. Correct: WLAN."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: WLAN"
    echo

    # Q6: Storage network accessed like a local drive
    echo "  What storage network lets a server access disks as if local?"
    read -p "  lab@lab320:~$ " cmd6
    echo
    if [[ "$cmd6" != "SAN" && "$cmd6" != "san" ]]; then
        print_error "Incorrect. Correct: SAN."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: SAN"
    echo

    # Q7: Network TAP truths (two)
    echo "  Give TWO truths about a network TAP."
    read -p "  lab@lab320:~$ " cmd7
    echo
    if [[ "$cmd7" != "Test access point and lets admins monitor traffic" \
       && "$cmd7" != "Allows monitoring and is a test access point" \
       && "$cmd7" != "Lets admins monitor traffic and test access point" ]]; then
        print_error "Incorrect. Correct: Test Access Point AND enables traffic monitoring."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Test access point + monitoring"
    echo

    # Q8: Software on the host that holds files and controls access
    echo "  What software runs on the host with data files and controls access?"
    read -p "  lab@lab320:~$ " cmd8
    echo
    if [[ "$cmd8" != "Fileshare server" && "$cmd8" != "fileshare server" && "$cmd8" != "File server" && "$cmd8" != "file server" ]]; then
        print_error "Incorrect. Correct: Fileshare (file) server."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Fileshare server"
    echo

    # Q9: Tool to find best Wi-Fi channel
    echo "  Apartment Wi-Fi is slow/dropping. What tool finds the best channel?"
    read -p "  lab@lab320:~$ " cmd9
    echo
    if [[ "$cmd9" != "Wi-Fi analyzer" && "$cmd9" != "wifi analyzer" && "$cmd9" != "WiFi analyzer" ]]; then
        print_error "Incorrect. Correct: Wi-Fi analyzer."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Wi-Fi analyzer"
    echo

    # Q10: FCC max EIRP 2.4 GHz PtMP WISP
    echo "  In the U.S., what is the FCC max EIRP for 2.4 GHz point-to-multipoint WISP?"
    read -p "  lab@lab320:~$ " cmd10
    echo
    if [[ "$cmd10" != "4 watts" && "$cmd10" != "4 W" && "$cmd10" != "36 dBm" && "$cmd10" != "36dbm" ]]; then
        print_error "Incorrect. Correct: 4 watts (36 dBm)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 4 watts (36 dBm)"
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
