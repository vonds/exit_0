#!/bin/bash

# Lab 320: A+ Mobile and Network Essentials Review
# Focus: Bluetooth, Batteries, SO-DIMM, Disk Imaging, and Wi-Fi Networking

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 320: A+ Section 1.1"
LAB_ID="lab320"
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
    echo "  Question 1: Bluetooth, short range, and connection with nearby peripherals/devices are characteristics of what type of network?"
    read -p "  lab@a-plus-lab320:~$ " cmd1
    echo
    if [[ "$cmd1" != "PAN" && "$cmd1" != "Personal Area Network" ]]; then
        print_error "Incorrect. Bluetooth is part of a PAN (Personal Area Network)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: PAN (Personal Area Network)"
    echo

    # Question 2
    echo "  Question 2: Which type of batteries don't have a memory effect?"
    read -p "  lab@a-plus-lab320:~$ " cmd2
    echo
    if [[ "$cmd2" != "Lithium-Ion" && "$cmd2" != "Lithium-Ion polymer" && "$cmd2" != "Li-ion and Li-Po" ]]; then
        print_error "Incorrect. Lithium-Ion and Lithium-Ion polymer batteries don't have memory effect."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Li-ion and Li-Po batteries have no memory effect."
    echo

    # Question 3
    echo "  Question 3: What does SO-DIMM stand for?"
    read -p "  lab@a-plus-lab320:~$ " cmd3
    echo
    if [[ "$cmd3" != "Small Outline Dual In-line Memory Module" ]]; then
        print_error "Incorrect. SO-DIMM stands for Small Outline Dual In-Line Memory Module."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Small Outline Dual In-Line Memory Module."
    echo

    # Question 4
    echo "  Question 4: Creating an image file of a storage device and copying it to a new one is done with what type of software?"
    read -p "  lab@a-plus-lab320:~$ " cmd4
    echo
    if [[ "$cmd4" != "Image cloning software" && "$cmd4" != "Cloning software" ]]; then
        print_error "Incorrect. This process uses image cloning software."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Image cloning software."
    echo

    # Question 5
    echo "  Question 5: 802.11 Wi-Fi (Wireless Fidelity) connectivity and high-speed connection are characteristics of what type of network?"
    read -p "  lab@a-plus-lab320:~$ " cmd5
    echo
    if [[ "$cmd5" != "LAN" && "$cmd5" != "Local Area Network" ]]; then
        print_error "Incorrect. Wi-Fi networks typically form a LAN (Local Area Network)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: LAN (Local Area Network)."
    echo

        # Question 6
    echo "  Question 6: Short-distance networking (4cm or less) and authentication without passwords are characteristics of what technology?"
    read -p "  lab@a-plus-lab320:~$ " cmd6
    echo
    if [[ "$cmd6" != "NFC" && "$cmd6" != "Near Field Communication" ]]; then
        print_error "Incorrect. NFC (Near Field Communication) is a short-range wireless technology used for contactless communication and authentication."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: NFC (Near Field Communication)."
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
