#!/bin/bash

# Lab 332: A+ Mobile Connectors & Accessories Review
# Focus: iPhone charging connector, USB-C ID, Bluetooth pairing, docks vs port replicators,
#        docking behavior, legacy MicroUSB, combo audio jack, motherboard swaps,
#        airplane power, AC adapter requirements

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 332: A+ Section 1"
LAB_ID="lab332"
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
    center_text "Scenario: Review key A+ essentials related to hardware, connectors, and accessories."
    center_text "Answer each question correctly to advance."
    echo
    center_text "Press Enter to begin..."
    read _

    # Question 1
    draw_lab_ui
    echo "  Your president misplaced the cable for an iPhone 14. What charging connector does this iPhone use?"
    read -p "  lab@lab320:~$ " cmd1
    echo
    if [[ "$cmd1" != "Lightning" && "$cmd1" != "lightning" ]]; then
        print_error "Incorrect. iPhone 14 charges via Lightning."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Lightning"
    echo

    # Question 2 (photo-style → descriptive)
    echo "  You see a small, oval, fully reversible connector on a modern Android phone and laptop. What connector is this?"
    read -p "  lab@lab320:~$ " cmd2
    echo
    if [[ "$cmd2" != "USB-C" && "$cmd2" != "USB C" && "$cmd2" != "usb-c" && "$cmd2" != "usb c" ]]; then
        print_error "Incorrect. That description matches USB-C."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: USB-C"
    echo

    # Question 3
    echo "  You’re pairing a phone with a new car to use voice commands and hands-free calling. What protocol is used?"
    read -p "  lab@lab320:~$ " cmd3
    echo
    if [[ "$cmd3" != "Bluetooth" && "$cmd3" != "bluetooth" ]]; then
        print_error "Incorrect. Car phone pairing uses Bluetooth."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Bluetooth"
    echo

    # Question 4 (two items; answer as single string)
    echo "  A laptop user wants a full-size display/keyboard plus external drive and speakers without replugging each time."
    echo "              Which two accessories could they buy?"
    read -p "  lab@lab320:~$ " cmd4
    echo
    if [[ "$cmd4" != "Docking station and Port replicator" && "$cmd4" != "Port replicator and Docking station" ]]; then
        print_error "Incorrect. Docking station and Port replicator are the right choices."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Docking station and Port replicator"
    echo

    # Question 5
    echo "  A user wants peripherals to stay connected to each other even when the laptop isn’t present."
    echo "              What provides that option?"
    read -p "  lab@lab320:~$ " cmd5
    echo
    if [[ "$cmd5" != "Docking station" && "$cmd5" != "docking station" ]]; then
        print_error "Incorrect. A Docking station provides this capability."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Docking station"
    echo

    # Question 6 (photo-style → descriptive)
    echo "  You’re handed a device with a small, non-reversible, trapezoid-shaped connector used on many older Android phones."
    echo "              It’s smaller than MiniUSB. What connector is this?"
    read -p "  lab@lab320:~$ " cmd6
    echo
    if [[ "$cmd6" != "MicroUSB" && "$cmd6" != "microUSB" && "$cmd6" != "micro-usb" && "$cmd6" != "Micro-USB" ]]; then
        print_error "Incorrect. That description matches MicroUSB."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: MicroUSB"
    echo

    # Question 7 (photo-style → descriptive)
    echo "  A laptop has a 3.5mm TRRS combo audio jack. Which two device types can you plug into this port?"
    read -p "  lab@lab320:~$ " cmd7
    echo
    if [[ "$cmd7" != "Speaker and Headset" && "$cmd7" != "Headset and Speaker" ]]; then
        print_error "Incorrect. You can connect a Speaker and a Headset."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Speaker and Headset"
    echo

    # Question 8
    echo "  A Lenovo laptop motherboard has failed. What replacement choice is most likely to work?"
    read -p "  lab@lab320:~$ " cmd8
    echo
    if [[ "$cmd8" != "Only a motherboard from that same model will work" \
       && "$cmd8" != "Only a motherboard from that same model of Lenovo laptop will work" ]]; then
        print_error "Incorrect. Use a motherboard from the exact same model."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Only a motherboard from that same model will work"
    echo

    # Question 9
    echo "  You need to use airplane auxiliary DC power to run your AC laptop charger on a 10-hour flight."
    echo "              What should you have on hand?"
    read -p "  lab@lab320:~$ " cmd9
    echo
    if [[ "$cmd9" != "Power inverter" && "$cmd9" != "power inverter" ]]; then
        print_error "Incorrect. You need a Power inverter (DC to AC)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Power inverter"
    echo

    # Question 10 (two items; answer as single string)
    echo "  You’re replacing a faulty laptop AC adapter. What TWO factors are most important?"
    read -p "  lab@lab320:~$ " cmd10
    echo
    if [[ "$cmd10" != "Polarity and same wattage as the original" && "$cmd10" != "Same wattage as the original and Polarity" ]]; then
        print_error "Incorrect. Ensure correct Polarity and the Same wattage as the original."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Polarity and Same wattage as the original"
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
