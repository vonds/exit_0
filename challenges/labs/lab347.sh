#!/bin/bash

# Lab 347: A+ Networking Fundamentals (11 Questions, Set 12)
# Focus: Bluetooth freq & range, cellular vs satellite, APIPA & DHCP scope,
#        VLAN & VPN, WLAN components, DHCP setup, IPv6 same subnet, /18 networks, PoE standard

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 347: A+ Section 2"
LAB_ID="lab347"
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

    # Q1: Bluetooth frequency
    draw_lab_ui
    echo "  What wireless frequency does Bluetooth use?"
    read -p "  lab@lab320:~$ " cmd1
    echo
    if [[ "$cmd1" != "2.4 GHz" && "$cmd1" != "2.4ghz" && "$cmd1" != "2.4" ]]; then
        print_error "Incorrect. Correct: 2.4 GHz."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 2.4 GHz"
    echo

    # Q2: Best option for traveling photographer (no Wi-Fi, mobile)
    echo "  Traveling photographer in parks needs to upload regularly. Viable networking option?"
    read -p "  lab@lab320:~$ " cmd2
    echo
    if [[ "$cmd2" != "Cellular" && "$cmd2" != "cellular" && "$cmd2" != "Mobile hotspot" && "$cmd2" != "mobile hotspot" ]]; then
        print_error "Incorrect. Correct: Cellular (mobile hotspot)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Cellular"
    echo

    # Q3: Bluetooth 5.0 headset max distance
    echo "  Max typical range for a Bluetooth 5.0 headset?"
    read -p "  lab@lab320:~$ " cmd3
    echo
    if [[ "$cmd3" != "10 meters" && "$cmd3" != "10m" && "$cmd3" != "10" ]]; then
        print_error "Incorrect. Correct: 10 meters."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 10 meters"
    echo

    # Q4: Many PCs show 169.254.x.x on Monday
    echo "  New PCs show 169.254.x.x. What do you check next?"
    read -p "  lab@lab320:~$ " cmd4
    echo
    if [[ "$cmd4" != "DHCP scope" && "$cmd4" != "dhcp scope" && "$cmd4" != "DHCP server" && "$cmd4" != "dhcp server" ]]; then
        print_error "Incorrect. Correct: DHCP scope/server."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: DHCP scope/server"
    echo

    # Q5: Reduce broadcast domains & add same-LAN security
    echo "  Which segmentation reduces broadcast domains and adds same-LAN isolation?"
    read -p "  lab@lab320:~$ " cmd5
    echo
    if [[ "$cmd5" != "VLAN" && "$cmd5" != "vlan" ]]; then
        print_error "Incorrect. Correct: VLAN."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: VLAN"
    echo

    # Q6: Secure remote access to company server
    echo "  Secure a remote user’s connection to the company server. What do you set up?"
    read -p "  lab@lab320:~$ " cmd6
    echo
    if [[ "$cmd6" != "VPN" && "$cmd6" != "vpn" ]]; then
        print_error "Incorrect. Correct: VPN."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: VPN"
    echo

    # Q7: Not typically part of a WLAN
    echo "  Which is NOT typically a WLAN component?"
    read -p "  lab@lab320:~$ " cmd7
    echo
    if [[ "$cmd7" != "WLAN server" && "$cmd7" != "wlan server" && "$cmd7" != "Server" && "$cmd7" != "server" ]]; then
        print_error "Incorrect. Correct: WLAN server."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: WLAN server"
    echo

    # Q8: Enable dynamic IP addressing (two actions)
    echo "  How do you enable dynamic IP addressing? (Give TWO actions.)"
    read -p "  lab@lab320:~$ " cmd8
    echo
    if [[ "$cmd8" != "Enable DHCP on the router and set NICs to obtain IP automatically" \
       && "$cmd8" != "Enable DHCP and NICs to obtain IP automatically" \
       && "$cmd8" != "Turn on DHCP and auto IP on NICs" ]]; then
        print_error "Incorrect. Correct: Enable DHCP on router AND set NICs to obtain IP automatically."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: DHCP on router + NICs auto IP"
    echo

    # Q09: PoE standard
    echo "  Name any valid IEEE PoE standard (for example, one of the 802.3 PoE specifications)."
    read -p "  lab@lab320:~$ " cmd9
    echo
    if [[ "$cmd9" != "802.3bt" && "$cmd9" != "802.3af" && "$cmd9" != "802.3at" ]]; then
        print_error "Incorrect. Correct examples include: 802.3af, 802.3at, 802.3bt."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: PoE standard recognized."
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
