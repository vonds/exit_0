#!/bin/bash

# Lab 323: Laptop Disassembly and Workbench Setup
# Focus: CompTIA A+ Domain 1.1 – Given a scenario, install and configure laptop hardware and components

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 323: Laptop Disassembly and Workbench Setup"
LAB_ID="lab323"
LAB_XP=20250
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
    center_text "Scenario: You’re preparing to disassemble a laptop safely and document each step."
    center_text "Your goal: prevent damage, maintain organization, and ensure proper reassembly."
    echo
    center_text "Press Enter to begin..."
    read _

    # Step 1: Antistatic Setup
    draw_lab_ui
    echo "  Step 1: What essential surface should your laptop be placed on to prevent electrostatic discharge (ESD)?"
    read -p "  lab@a-plus-lab323:~$ " cmd1
    echo
    if [[ "$cmd1" != "Antistatic mat" && "$cmd1" != "ESD mat" ]]; then
        print_error "Incorrect. Always place laptops on an antistatic (ESD) mat before disassembly to prevent electrostatic damage."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Use an antistatic mat to safely protect components from ESD."
    echo

    # Step 2: Parts Organization
    echo "  Step 2: What tool can help you organize screws and label their locations during disassembly?"
    read -p "  lab@a-plus-lab323:~$ " cmd2
    echo
    if [[ "$cmd2" != "Magnetic parts board" && "$cmd2" != "Parts organizer" && "$cmd2" != "Magnetic tray" ]]; then
        print_error "Incorrect. Use a magnetic parts board or organizer to label and separate screws to avoid mixing sizes."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Magnetic parts boards keep screws organized and prevent loss or mix-ups."
    echo

    # Step 3: Screw Safety
    echo "  Step 3: Why is it dangerous to use the wrong screw during reassembly?"
    read -p "  lab@a-plus-lab323:~$ " cmd3
    echo
    if [[ "$cmd3" != "It can damage the motherboard" && "$cmd3" != "It can crack the circuit board" && "$cmd3" != "It can damage internal components" ]]; then
        print_error "Incorrect. Using the wrong screw can crack the motherboard or short internal components."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: The wrong screw length can damage internal boards or mounting points."
    echo

    # Step 4: Docking Station Port
    echo "  Step 4: What is the purpose of the proprietary connector found on the bottom of older Dell corporate laptops?"
    read -p "  lab@a-plus-lab323:~$ " cmd4
    echo
    if [[ "$cmd4" != "Docking station port" && "$cmd4" != "Docking connector" ]]; then
        print_error "Incorrect. That connector is a docking station port used to expand ports and peripheral access."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Docking station ports provide additional functionality when connected to a base station."
    echo

    # Step 5: Expansion Slots
    echo "  Step 5: What expansion slot might you find under an access panel for Wi-Fi or cellular cards?"
    read -p "  lab@a-plus-lab323:~$ " cmd5
    echo
    if [[ "$cmd5" != "Mini PCIe" && "$cmd5" != "Mini PCI Express" ]]; then
        print_error "Incorrect. Many laptops include Mini PCIe slots for Wi-Fi or cellular expansion cards."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Mini PCIe slots are used for internal Wi-Fi or cellular adapters."
    echo

    # Step 6: Removable Components
    echo "  Step 6: What laptop components can often be removed without full disassembly on older business models? (Choose two)"
    read -p "  lab@a-plus-lab323:~$ " cmd6
    echo
    if [[ "$cmd6" != "Battery and hard drive" && "$cmd6" != "Hard drive and battery" ]]; then
        print_error "Incorrect. Many older laptops allow battery and hard drive removal through external access bays."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Battery and hard drive are removable on many older laptops."
    echo

    # Step 7: Security Slot
    echo "  Step 7: What small slot can you use to physically secure a laptop to a desk to prevent theft?"
    read -p "  lab@a-plus-lab323:~$ " cmd7
    echo
    if [[ "$cmd7" != "Kensington Lock" && "$cmd7" != "Kensington Security Slot" && "$cmd7" != "Case lock" ]]; then
        print_error "Incorrect. That slot is for a Kensington Lock to secure laptops to fixed objects."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: The Kensington Lock slot prevents physical theft in offices or classrooms."
    echo

    # Step 8: Wireless Toggle
    echo "  Step 8: What is the function of a physical wireless on/off switch found on some laptops?"
    read -p "  lab@a-plus-lab323:~$ " cmd8
    echo
    if [[ "$cmd8" != "Disables or enables the Wi-Fi card" && "$cmd8" != "Turns the Wi-Fi card on or off" ]]; then
        print_error "Incorrect. Hardware switches can disable or enable the wireless radio directly for security or troubleshooting."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Physical switches can toggle the Wi-Fi card’s power directly."
    echo

    # Step 9: Function Keys
    echo "  Step 9: Which key combination allows toggling between internal and external displays on laptops?"
    read -p "  lab@a-plus-lab323:~$ " cmd9
    echo
    if [[ "$cmd9" != "Fn + F7" && "$cmd9" != "Function key and display key" && "$cmd9" != "Fn and display toggle key" ]]; then
        print_error "Incorrect. Most laptops use the Fn key combined with a display-function key like F7 to switch display modes."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Fn + F7 toggles between internal and external displays on many models."
    echo

    # Step 10: ESD Strap
    echo "  Step 10: Before handling internal components, what should you wear to protect against static discharge?"
    read -p "  lab@a-plus-lab323:~$ " cmd10
    echo
    if [[ "$cmd10" != "ESD wrist strap" && "$cmd10" != "Antistatic wrist strap" ]]; then
        print_error "Incorrect. Always wear an ESD wrist strap grounded to the mat or chassis to prevent static discharge."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Wear an ESD wrist strap to protect components from static electricity."
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
