#!/bin/bash

# Lab 322: Laptop Security Components
# Focus: CompTIA A+ Domain 1.1 — Install and configure laptop hardware and components

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 322: Laptop Security Components"
LAB_ID="lab322"
LAB_XP=18250
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
    center_text "Scenario: You’re working as a field technician asked to secure company laptops."
    center_text "You’ll identify and explain core laptop security components."
    echo
    center_text "Press Enter to begin..."
    read _

    # Step 1: Identify biometric authentication method
    draw_lab_ui
    echo "  Step 1: What type of laptop hardware allows authentication using a user’s physical traits (like fingerprints or facial scans)?"
    read -p "  lab@a-plus-lab322:~$ " cmd1
    echo
    if [[ "$cmd1" != "Biometric sensor" && "$cmd1" != "Biometric sensors" ]]; then
        print_error "Incorrect. Laptops often use biometric sensors for authentication, such as fingerprint readers or facial recognition."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Biometric sensors use unique user characteristics for authentication."
    echo

    # Step 2: Fingerprint scanner example
    echo "  Step 2: Which specific biometric component is commonly embedded in a laptop’s power button for authentication?"
    read -p "  lab@a-plus-lab322:~$ " cmd2
    echo
    if [[ "$cmd2" != "Fingerprint scanner" && "$cmd2" != "Fingerprint reader" ]]; then
        print_error "Incorrect. Fingerprint scanners are often integrated into power buttons on laptops for secure authentication."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Fingerprint scanners are integrated for quick, secure access."
    echo

    # Step 3: Facial recognition feature
    echo "  Step 3: What Windows feature allows users to log in using facial recognition?"
    read -p "  lab@a-plus-lab322:~$ " cmd3
    echo
    if [[ "$cmd3" != "Windows Hello" ]]; then
        print_error "Incorrect. The feature is called Windows Hello, which uses a laptop’s webcam for facial recognition."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Windows Hello enables facial recognition login using the built-in webcam."
    echo

    # Step 4: External biometric devices
    echo "  Step 4: If a laptop doesn’t have built-in biometric sensors, what can a user purchase to add this functionality?"
    read -p "  lab@a-plus-lab322:~$ " cmd4
    echo
    if [[ "$cmd4" != "External USB biometric device" && "$cmd4" != "External USB fingerprint scanner" ]]; then
        print_error "Incorrect. Users can add biometric authentication using external USB-based fingerprint scanners or cameras."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: External USB biometric devices provide additional authentication options."
    echo

    # Step 5: NFC scanners
    echo "  Step 5: What does NFC stand for, and what is its purpose in laptops?"
    read -p "  lab@a-plus-lab322:~$ " cmd5
    echo
    if [[ "$cmd5" != "Near Field Communication" && "$cmd5" != "Near Field Communication for pairing peripherals" ]]; then
        print_error "Incorrect. NFC stands for Near Field Communication. It’s used to pair nearby devices or connect peripherals wirelessly."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Near Field Communication (NFC) allows secure short-range pairing between devices."
    echo

    # Step 6: NFC usage
    echo "  Step 6: What’s a common use of NFC on laptops, particularly with Apple devices?"
    read -p "  lab@a-plus-lab322:~$ " cmd6
    echo
    if [[ "$cmd6" != "Pairing peripherals like AirPods" && "$cmd6" != "Pairing devices like AirPods" ]]; then
        print_error "Incorrect. NFC in laptops often pairs peripherals like AirPods or smartphones automatically when nearby."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: NFC is used to pair nearby Apple devices such as AirPods or iPhones."
    echo

    # Step 7: Kensington Lock
    echo "  Step 7: What is the name of the small slot on the side of a laptop used to secure it with a cable?"
    read -p "  lab@a-plus-lab322:~$ " cmd7
    echo
    if [[ "$cmd7" != "Kensington Lock" && "$cmd7" != "Kensington Security Slot" && "$cmd7" != "Case Slot" ]]; then
        print_error "Incorrect. The Kensington Lock or Security Slot allows a cable to physically secure a laptop to a fixed object."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: The Kensington Lock prevents physical theft by securing the laptop with a cable."
    echo

    # Step 8: Kensington Lock use case
    echo "  Step 8: In what type of environment are Kensington Locks most commonly used?"
    read -p "  lab@a-plus-lab322:~$ " cmd8
    echo
    if [[ "$cmd8" != "Office environment" && "$cmd8" != "Corporate office" && "$cmd8" != "Workplace" ]]; then
        print_error "Incorrect. Kensington Locks are often used in office or corporate environments to secure devices at desks."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Offices and workplaces often use Kensington Locks to prevent theft."
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
