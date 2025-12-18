#!/bin/bash

# Lab 327: Replace a Laptop Expansion Card (A+ Focus)
# Focus: Mini PCIe expansion cards, Wi-Fi card replacement, antenna handling, and safety

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 327: A+ Section 1.1 — Expansion Card Replacement"
LAB_ID="lab327"
LAB_XP=19200
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
    center_text "Scenario: The laptop’s Wi-Fi card has failed and must be replaced."
    center_text "Goal: Safely remove, replace, and reconnect a Mini PCIe or M.2 expansion card."
    echo
    center_text "Press Enter to begin..."
    read _

    # Question 1 — Location and manual
    draw_lab_ui
    echo "  Question 1: Before removing any covers, what should you check to locate the expansion card on your model?"
    read -p "  lab@a-plus-lab327:~$ " cmd1
    echo
    if [[ "$cmd1" != "Service manual" && "$cmd1" != "Manufacturer documentation" && "$cmd1" != "Model service guide" ]]; then
        print_error "Incorrect. Check the laptop’s service manual or manufacturer documentation to locate the card and access points."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Reference the service manual or manufacturer documentation."
    echo

    # Question 2 — Connector type
    echo "  Question 2: What type of connector do most laptop Wi-Fi cards use?"
    read -p "  lab@a-plus-lab327:~$ " cmd2
    echo
    if [[ "$cmd2" != "Mini PCIe" && "$cmd2" != "M.2" && "$cmd2" != "Mini PCI Express" ]]; then
        print_error "Incorrect. Most laptop Wi-Fi cards use Mini PCIe or M.2 connectors."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Mini PCIe or M.2 connector."
    echo

    # Question 3 — Antenna disconnection
    echo "  Question 3: How should you safely disconnect the Wi-Fi antennas from the card?"
    read -p "  lab@a-plus-lab327:~$ " cmd3
    echo
    if [[ "$cmd3" != "Use tweezers or spudger to lift the antenna connectors vertically" && "$cmd3" != "Lift straight up with tweezers or plastic tool" && "$cmd3" != "Gently pry upward on the button connectors" ]]; then
        print_error "Incorrect. Gently lift the small button connectors vertically using tweezers or a non-metal spudger."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Lift vertically using tweezers or a non-metal tool."
    echo

    # Question 4 — Card removal
    echo "  Question 4: What happens to the expansion card when you remove its single retaining screw?"
    read -p "  lab@a-plus-lab327:~$ " cmd4
    echo
    if [[ "$cmd4" != "It pops up to a 45-degree angle" && "$cmd4" != "It lifts to a 45-degree angle for removal" && "$cmd4" != "The card raises at an angle" ]]; then
        print_error "Incorrect. When the screw is removed, the card pops up to a 45-degree angle, ready for removal."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: It raises to a 45-degree angle for removal."
    echo

    # Question 5 — Installation process
    echo "  Question 5: When installing a new card, at what angle should you insert it before fastening it down?"
    read -p "  lab@a-plus-lab327:~$ " cmd5
    echo
    if [[ "$cmd5" != "45 degrees" && "$cmd5" != "At a 45-degree angle" ]]; then
        print_error "Incorrect. Always insert Mini PCIe/M.2 cards at about a 45-degree angle before securing them with a screw."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Insert at a 45-degree angle."
    echo

    # Question 6 — Antenna reconnection
    echo "  Question 6: Why must you reconnect both antennas to the Wi-Fi card?"
    read -p "  lab@a-plus-lab327:~$ " cmd6
    echo
    if [[ "$cmd6" != "For optimal signal strength and range" && "$cmd6" != "For full signal strength" && "$cmd6" != "To restore proper Wi-Fi range" ]]; then
        print_error "Incorrect. Reconnect both antennas to restore full signal range and MIMO performance."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Ensures full signal strength and range."
    echo

    # Question 7 — Antenna cable caution
    echo "  Question 7: What damage can occur if you pull on the antenna cable instead of the connector?"
    read -p "  lab@a-plus-lab327:~$ " cmd7
    echo
    if [[ "$cmd7" != "You can break or detach the antenna wire" && "$cmd7" != "You can damage the antenna cable" && "$cmd7" != "The antenna wire can snap or pull out" ]]; then
        print_error "Incorrect. Pulling the cable instead of the connector can detach or break the antenna wire, disabling Wi-Fi."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Cable damage or disconnection risk."
    echo

    # Question 8 — Cable routing
    echo "  Question 8: Where are Wi-Fi antenna cables typically routed in a laptop?"
    read -p "  lab@a-plus-lab327:~$ " cmd8
    echo
    if [[ "$cmd8" != "Around the display bezel and through the chassis" && "$cmd8" != "Along the screen bezel and under the case" && "$cmd8" != "Around the outer case, often through the display" ]]; then
        print_error "Incorrect. Antenna cables are routed around the display bezel and through the chassis for optimal signal."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Routed around display bezel and through chassis."
    echo

    # Question 9 — Verification
    echo "  Question 9: After installing the new card, what should you check in the operating system?"
    read -p "  lab@a-plus-lab327:~$ " cmd9
    echo
    if [[ "$cmd9" != "Device recognized and Wi-Fi networks available" && "$cmd9" != "Card detected in Device Manager and Wi-Fi works" && "$cmd9" != "Wireless adapter visible and functional" ]]; then
        print_error "Incorrect. Verify that the OS recognizes the new card and that Wi-Fi networks appear and function properly."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Card recognized and networks available."
    echo

    # Question 10 — Driver setup
    echo "  Question 10: What must you do if the Wi-Fi card is not detected after installation?"
    read -p "  lab@a-plus-lab327:~$ " cmd10
    echo
    if [[ "$cmd10" != "Install or update drivers" && "$cmd10" != "Install manufacturer Wi-Fi drivers" && "$cmd10" != "Update or install correct drivers" ]]; then
        print_error "Incorrect. Install or update the manufacturer’s Wi-Fi card drivers to ensure proper detection."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Install/update manufacturer drivers."
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
