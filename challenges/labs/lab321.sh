#!/bin/bash

# Lab 321: Laptop Hardware Components and Replacement Procedures
# Focus: CompTIA A+ Domain 1.1 – Install and Configure Laptop Hardware and Components

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 321: Laptop Hardware Components and Replacement Procedures"
LAB_ID="lab321"
LAB_XP=19500
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
    center_text "Scenario: You're an IT technician tasked with upgrading and maintaining laptops."
    center_text "You’ll perform hardware replacements and apply safe handling procedures."
    echo
    center_text "Press Enter to begin..."
    read _

    # Step 1: Identify Laptop Security Components
    draw_lab_ui
    echo "  Step 1: Identify two common laptop security components used for user authentication."
    read -p "  lab@a-plus-lab321:~$ " cmd1
    echo
    if [[ "$cmd1" != "Fingerprint reader and NFC scanner" && "$cmd1" != "Fingerprint reader and Near Field Communication scanner" ]]; then
        print_error "Incorrect. Common laptop security components include fingerprint readers and NFC (Near Field Communication) scanners."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Fingerprint reader and NFC scanner are key laptop security components."
    echo

    # Step 2: Safety and Disassembly
    echo "  Step 2: Before disassembling a laptop to access internal components, what should you always do first?"
    read -p "  lab@a-plus-lab321:~$ " cmd2
    echo
    if [[ "$cmd2" != "Disconnect power and remove battery" && "$cmd2" != "Remove power source and battery" ]]; then
        print_error "Incorrect. Always disconnect AC power and remove the internal or removable battery before disassembly."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Power should be disconnected and the battery removed before disassembly."
    echo

    # Step 3: Battery Replacement
    echo "  Step 3: When replacing a laptop’s battery, what type of component is it considered?"
    read -p "  lab@a-plus-lab321:~$ " cmd3
    echo
    if [[ "$cmd3" != "Field Replaceable Unit" && "$cmd3" != "FRU" ]]; then
        print_error "Incorrect. A laptop battery is a Field Replaceable Unit (FRU)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Laptop batteries are Field Replaceable Units (FRUs)."
    echo

    # Step 4: Keyboard Replacement
    echo "  Step 4: When replacing a laptop keyboard, what should you be careful not to damage during removal?"
    read -p "  lab@a-plus-lab321:~$ " cmd4
    echo
    if [[ "$cmd4" != "Ribbon cable" && "$cmd4" != "Keyboard ribbon cable" ]]; then
        print_error "Incorrect. Always handle and disconnect the keyboard ribbon cable carefully to avoid tearing or bending pins."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: The keyboard ribbon cable must be handled carefully during replacement."
    echo

    # Step 5: Memory Upgrade
    echo "  Step 5: What form factor of memory is typically used in laptops?"
    read -p "  lab@a-plus-lab321:~$ " cmd5
    echo
    if [[ "$cmd5" != "SO-DIMM" && "$cmd5" != "Small Outline DIMM" ]]; then
        print_error "Incorrect. Laptops use SO-DIMM (Small Outline DIMM) memory modules."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: SO-DIMM (Small Outline DIMM) modules are used in laptops."
    echo

    # Step 6: Expansion Card Upgrade
    echo "  Step 6: What type of internal expansion card might provide wireless network access in a laptop?"
    read -p "  lab@a-plus-lab321:~$ " cmd6
    echo
    if [[ "$cmd6" != "Mini PCIe Wi-Fi card" && "$cmd6" != "M.2 Wi-Fi card" && "$cmd6" != "Wireless card" ]]; then
        print_error "Incorrect. Laptops use Mini PCIe or M.2 wireless cards for network connectivity."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Mini PCIe or M.2 Wi-Fi cards provide wireless connectivity."
    echo

    # Step 7: Storage Replacement
    echo "  Step 7: When replacing a laptop’s storage drive, which two drive types are most common today?"
    read -p "  lab@a-plus-lab321:~$ " cmd7
    echo
    if [[ "$cmd7" != "2.5-inch SATA and M.2 NVMe" && "$cmd7" != "SATA and M.2" ]]; then
        print_error "Incorrect. Most laptops use 2.5-inch SATA or M.2 NVMe drives for storage."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 2.5-inch SATA and M.2 NVMe are common laptop storage formats."
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
