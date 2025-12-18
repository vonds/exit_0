#!/bin/bash

# Lab 329: A+ Mobile & Device Scenarios Review
# Focus: Smart cameras, stylus input, location services, MAM/MDM, Wi-Fi join info,
#        charging triage, safe battery replacement, keyboard faults, keycap fix,
#        Bluetooth pairing issues

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 329: A+ Section 1"
LAB_ID="lab329"
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
    center_text "Scenario: Review key A+ mobile/device scenarios. Type the correct answer text."
    center_text "Answer each question correctly to advance."
    echo
    center_text "Press Enter to begin..."
    read _

    # Question 1
    draw_lab_ui
    echo "  “Smart” cameras are often marketed with which key feature built in?"
    read -p "  lab@lab329:~$ " cmd1
    echo
    if [[ "$cmd1" != "Wi-Fi" && "$cmd1" != "wifi" && "$cmd1" != "WiFi" ]]; then
        print_error "Incorrect. Smart cameras typically include Wi-Fi."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Wi-Fi"
    echo

    # Question 2
    echo "  Most cost-effective item to purchase if a user's finger input on a tablet is imprecise?"
    read -p "  lab@lab329:~$ " cmd2
    echo
    if [[ "$cmd2" != "Stylus" && "$cmd2" != "stylus" ]]; then
        print_error "Incorrect. A stylus is the most cost-effective solution."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Stylus"
    echo

    # Question 3
    echo "  For rideshare tracking on a phone, what must be enabled to track the device’s position?"
    read -p "  lab@lab329:~$ " cmd3
    echo
    if [[ "$cmd3" != "Location Services" && "$cmd3" != "location services" ]]; then
        print_error "Incorrect. Enable Location Services."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Location Services"
    echo

    # Question 4 (expects a single plain string that contains both terms)
    echo "  To enforce policies and remove corporate apps on remote devices, name the TWO management approaches"
    read -p "  lab@lab329:~$ " cmd4
    echo
    if [[ "$cmd4" != "MAM and MDM" && "$cmd4" != "MDM and MAM" && "$cmd4" != "MAM & MDM" && "$cmd4" != "MDM & MAM" ]]; then
        print_error "Incorrect. Use MAM and MDM."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: MAM and MDM"
    echo

    # Question 5 (expects a single plain string that names both items)
    echo "  You can’t see a friend’s hidden Wi-Fi. What TWO pieces of information do you need from them?"
    read -p "  lab@lab329:~$ " cmd5
    echo
    if [[ "$cmd5" != "SSID and password" && "$cmd5" != "Network name and password" && "$cmd5" != "SSID and security type/password" && "$cmd5" != "Network name and security type/password" ]]; then
        print_error "Incorrect. You need the SSID (network name) and the security type/password."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: SSID (network name) and security type/password"
    echo

    # Question 6
    echo "  An iPhone 13 won’t charge after cleaning the port, and testing the outlet. What should you try next?"
    read -p "  lab@lab329:~$ " cmd6
    echo
    if [[ "$cmd6" != "Use a wireless charging pad" && "$cmd6" != "Wireless charging pad" && "$cmd6" != "wireless charging pad" ]]; then
        print_error "Incorrect. Try using a wireless charging pad to bypass the port."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Use a wireless charging pad"
    echo

    # Question 7
    echo "  A laptop with an internal battery won’t charge and you plan to replace the battery. What must you do first?"
    read -p "  lab@lab329:~$ " cmd7
    echo
    if [[ "$cmd7" != "Disconnect external power" && "$cmd7" != "disconnect external power" ]]; then
        print_error "Incorrect. Always disconnect external power first."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Disconnect external power"
    echo

    # Question 8 (expects a single plain string that contains both causes)
    echo "  Without an external keyboard, a laptop types the wrong characters. Name TWO likely causes."
    read -p "  lab@lab329:~$ " cmd8
    echo
    if [[ "$cmd8" != "Ribbon cable and debris under keys" && "$cmd8" != "Debris under keys and ribbon cable" ]]; then
        print_error "Incorrect. Likely: ribbon cable partially disconnected and debris under keys."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Ribbon cable and debris under keys"
    echo

    # Question 9
    echo "  What is the most cost-effective fix to get a missing key working quickly?"
    read -p "  lab@lab329:~$ " cmd9
    echo
    if [[ "$cmd9" != "Replace the missing key" && "$cmd9" != "replace the missing key" ]]; then
        print_error "Incorrect. Replace the missing key."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Replace the missing key"
    echo

    # Question 10
    echo "  Bluetooth earpiece that worked yesterday no longer works. What is the cause?"
    read -p "  lab@lab329:~$ " cmd10
    echo
    if [[ "$cmd10" != "The earpiece has paired to a different device" && "$cmd10" != "Paired to a different device" && "$cmd10" != "paired to a different device" ]]; then
        print_error "Incorrect. It most likely auto-paired to a different device."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: The earpiece has paired to a different device"
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
