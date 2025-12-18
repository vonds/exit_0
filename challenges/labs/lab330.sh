#!/bin/bash

# Lab 330: A+ Mobile and Hardware Scenarios Review
# Focus: RAM upgrades, iPad storage limits, SATA SSD choice, drive bay access,
#        mobile hotspot, LTE naming, NFC payments, Bluetooth headsets,
#        smartwatch payments, Wi-Fi antenna replacement

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 330: A+ Section 1"
LAB_ID="lab330"
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
    center_text "Scenario: Review key A+ essentials related to hardware, batteries, and networking."
    center_text "Answer each question correctly to advance."
    echo
    center_text "Press Enter to begin..."
    read _

    # Question 1
    draw_lab_ui
    echo "  Laptop max RAM is 32 GB DDR5, with 16 GB onboard and one empty slot."
    echo "              What RAM module should you purchase to maximize RAM?"
    read -p "  lab@lab320:~$ " cmd1
    echo
    if [[ "$cmd1" != "16 GB SODIMM" && "$cmd1" != "One 16 GB SODIMM" && "$cmd1" != "DDR5 16 GB SODIMM" ]]; then
        print_error "Incorrect. Install a 16 GB DDR5 SODIMM in the empty slot."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 16 GB SODIMM"
    echo

    # Question 2
    echo "  An iPad shows insufficient space for an update. Can you upgrade storage?"
    read -p "  lab@lab320:~$ " cmd2
    echo
    if [[ "$cmd2" != "Storage can’t be upgraded, but you can offload apps" \
       && "$cmd2" != "Storage can't be upgraded, but you can offload apps" \
       && "$cmd2" != "Storage can’t be upgraded; offload unused apps" \
       && "$cmd2" != "Storage can't be upgraded; offload unused apps" ]]; then
        print_error "Incorrect. iPad storage isn’t upgradable; offload unused apps/data."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Storage can’t be upgraded; offload unused apps."
    echo

    # Question 3
    echo "  Replacing a failed SATA drive in a 10-year-old laptop for maximum speed."
    echo "              What kind of drive should you install?"
    read -p "  lab@lab320:~$ " cmd3
    echo
    if [[ "$cmd3" != "SSD" && "$cmd3" != "Solid-state drive" && "$cmd3" != "Solid state drive" ]]; then
        print_error "Incorrect. Install an SSD."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: SSD"
    echo

    # Question 4
    echo "  No obvious bottom access for the hard drive. What will you most likely remove to reach the drive bay?"
    read -p "  lab@lab320:~$ " cmd4
    echo
    if [[ "$cmd4" != "Keyboard" && "$cmd4" != "Remove the keyboard" && "$cmd4" != "keyboard" ]]; then
        print_error "Incorrect. Most models require removing the keyboard to access the bay."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Keyboard"
    echo

    # Question 5
    echo "  Which mobile connection lets you share your cellular Internet with a Wi-Fi device?"
    read -p "  lab@lab320:~$ " cmd5
    echo
    if [[ "$cmd5" != "Hotspot" && "$cmd5" != "hotspot" && "$cmd5" != "Tethering" && "$cmd5" != "tethering" ]]; then
        print_error "Incorrect. Use a mobile hotspot (tethering)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Hotspot"
    echo

    # Question 6
    echo "  Which cellular communication generation is known as LTE?"
    read -p "  lab@lab320:~$ " cmd6
    echo
    if [[ "$cmd6" != "4G" && "$cmd6" != "4g" && "$cmd6" != "Fourth generation" && "$cmd6" != "Fourth-generation" ]]; then
        print_error "Incorrect. LTE corresponds to 4G."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 4G"
    echo

    # Question 7
    echo "  Phone payments require the device to be held within a few inches of the reader."
    echo "              What radio communication should be configured?"
    read -p "  lab@lab320:~$ " cmd7
    echo
    if [[ "$cmd7" != "NFC" && "$cmd7" != "Near Field Communication" && "$cmd7" != "Near-field communication" ]]; then
        print_error "Incorrect. Configure NFC."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: NFC"
    echo

    # Question 8
    echo "  You purchased a wireless headset and need it to work with your laptop."
    echo "              What wireless technology must be enabled on the laptop?"
    read -p "  lab@lab320:~$ " cmd8
    echo
    if [[ "$cmd8" != "Bluetooth" && "$cmd8" != "bluetooth" ]]; then
        print_error "Incorrect. Enable Bluetooth."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Bluetooth"
    echo

    # Question 9
    echo "  Your smartwatch can make contactless payments. What connection technology does it use?"
    read -p "  lab@lab320:~$ " cmd9
    echo
    if [[ "$cmd9" != "NFC" && "$cmd9" != "Near Field Communication" && "$cmd9" != "Near-field communication" ]]; then
        print_error "Incorrect. It uses NFC."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: NFC"
    echo

    # Question 10
    echo "  While upgrading a laptop’s Wi-Fi card, you find the antenna cable is frayed."
    echo "               What will you likely need to do to replace the antenna?"
    read -p "  lab@lab320:~$ " cmd10
    echo
    if [[ "$cmd10" != "Open the display to replace the cable" && "$cmd10" != "Open the display" ]]; then
        print_error "Incorrect. The antennas live in the display bezel; open the display to replace the cable."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Open the display to replace the cable"
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
