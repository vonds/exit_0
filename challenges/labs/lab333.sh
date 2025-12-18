#!/bin/bash

# Lab 333: A+ Mobile & Connectivity Concepts Review
# Focus: Dock connections, GPS satellites, laptop drive form factors, shared video memory,
#        VR/AR makers, DisplayPort ID, Lightning devices, RP-SMA antennas, Bluetooth pairing flow

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 333: A+ Section 1"
LAB_ID="lab333"
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
    center_text "Scenario: Review key A+ essentials related to mobile, connectors, and wireless."
    center_text "Answer each question correctly to advance."
    echo
    center_text "Press Enter to begin..."
    read _

    # Question 1
    draw_lab_ui
    echo "  How do modern docking stations typically connect to laptops?"
    read -p "  lab@lab320:~$ " cmd1
    echo
    if [[ "$cmd1" != "USB-C and Thunderbolt 3 or 4" && "$cmd1" != "Thunderbolt 3 or 4 and USB-C" ]]; then
        print_error "Incorrect. Modern docks use USB-C and Thunderbolt 3 or 4."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: USB-C and Thunderbolt 3 or 4"
    echo

    # Question 2
    echo "  Minimum number of GPS satellites needed for a 3D location fix?"
    read -p "  lab@lab320:~$ " cmd2
    echo
    if [[ "$cmd2" != "Four" && "$cmd2" != "4" && "$cmd2" != "four" ]]; then
        print_error "Incorrect. A 3D fix typically requires four satellites."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Four"
    echo

    # Question 3
    echo "  A technician is replacing a failed laptop hard drive. Which two form factors might the laptop require?"
    read -p "  lab@lab320:~$ " cmd3
    echo
    if [[ "$cmd3" != "M.2 and 2.5-inch" && "$cmd3" != "2.5-inch and M.2" ]]; then
        print_error "Incorrect. Likely form factors: M.2 and 2.5-inch."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: M.2 and 2.5-inch"
    echo

    # Question 4
    echo "  Older laptop: 4 GB RAM, integrated graphics reserving 512 MB. How much RAM remains for the CPU?"
    read -p "  lab@lab320:~$ " cmd4
    echo
    if [[ "$cmd4" != "3.5 GB" && "$cmd4" != "3.5GB" && "$cmd4" != "3.5 gigabytes" ]]; then
        print_error "Incorrect. 4 GB - 512 MB = 3.5 GB."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 3.5 GB"
    echo

    # Question 5
    echo "  Oculus, Samsung, and HTC are makers of what specific wearable technology?"
    read -p "  lablab320:~$ " cmd5
    echo
    if [[ "$cmd5" != "VR/AR headsets" && "$cmd5" != "VR headsets" && "$cmd5" != "Virtual reality headsets" ]]; then
        print_error "Incorrect. They manufacture VR/AR headsets."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: VR/AR headsets"
    echo

    # Question 6 (photo-style → descriptive)
    echo "  On a graphics card backplate you see two rectangular video ports with one corner slightly beveled."
    echo "  What connector type are those?"
    read -p "  lab@lab320:~$ " cmd6
    echo
    if [[ "$cmd6" != "DisplayPort" && "$cmd6" != "displayport" ]]; then
        print_error "Incorrect. That description matches DisplayPort."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: DisplayPort"
    echo

    # Question 7
    echo "  What kind of device uses a Lightning connector to charge and transfer data?"
    read -p "  lab@lab320:~$ " cmd7
    echo
    if [[ "$cmd7" != "Apple iPhone" && "$cmd7" != "iPhone" && "$cmd7" != "Apple iPhone (Lightning models)" ]]; then
        print_error "Incorrect. Lightning is used by Apple iPhone (non-USB-C models)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Apple iPhone"
    echo

    # Question 8
    echo "  Likely external Wi-Fi antenna connector on a laptop (jack on the device) uses which type?"
    read -p "  lab@lab320:~$ " cmd8
    echo
    if [[ "$cmd8" != "SMA-female-RP" && "$cmd8" != "RP-SMA female" && "$cmd8" != "RP-SMA female" ]]; then
        print_error "Incorrect. Expect an RP-SMA female jack (SMA-female-RP)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: SMA-female-RP (RP-SMA female)"
    echo

    # Question 9
    echo "  After enabling your device for IEEE 802.15.1 communication, what is the next step?"
    read -p "  lab@lab320:~$ " cmd9
    echo
    if [[ "$cmd9" != "Enable pairing" && "$cmd9" != "Enable Bluetooth pairing" && "$cmd9" != "Enable pairing mode" ]]; then
        print_error "Incorrect. Next step is to enable pairing (make the device discoverable)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Enable pairing"
    echo

    # Question 10
    echo "  Headset and laptop have Bluetooth on and are in pairing mode; they discover each other."
    echo "  What is the typical next step?"
    read -p "  lab@lab320:~$ " cmd10
    echo
    if [[ "$cmd10" != "Enter the Bluetooth PIN code" && "$cmd10" != "Enter the PIN code" && "$cmd10" != "Enter the Bluetooth password" ]]; then
        print_error "Incorrect. Typically you enter the Bluetooth PIN code."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Enter the Bluetooth PIN code"
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
