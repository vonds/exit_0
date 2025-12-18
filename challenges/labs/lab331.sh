#!/bin/bash

# Lab 331: A+ Mobile Device & Networking Features Review
# Focus: Biometrics, NFC tags, iPhone NFC, NFC use cases, video conferencing,
#        display components, smart camera networking, megapixels, Bluetooth setup, USB tethering

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 331: A+ Section 1"
LAB_ID="lab331"
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
    center_text "Scenario: Review A+ mobile and hardware concepts."
    center_text "Answer each question correctly to advance."
    echo
    center_text "Press Enter to begin..."
    read _

    # Question 1
    draw_lab_ui
    echo "  Which two biometric device technologies are commonly found and configurable on laptops?"
    read -p "  lab@lab320:~$ " cmd1
    echo
    if [[ "$cmd1" != "Face ID and Fingerprint reader" && "$cmd1" != "Fingerprint reader and Face ID" ]]; then
        print_error "Incorrect. Common laptop biometrics are Face ID and Fingerprint reader."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Face ID and Fingerprint reader"
    echo

    # Question 2
    echo "  An NFC Type 4 tag in a poster can hold how much information?"
    read -p "  lab@lab320:~$ " cmd2
    echo
    if [[ "$cmd2" != "32 KB" && "$cmd2" != "32KB" ]]; then
        print_error "Incorrect. NFC Type 4 tags can store about 32 KB of data."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 32 KB"
    echo

    # Question 3
    echo "  Your customer has an iPhone 8 and wants to read and write NFC tags. What advice should you give?"
    read -p "  lab@lab320:~$ " cmd3
    echo
    if [[ "$cmd3" != "With iOS 13 or better, they can read and write NFC tags using a third-party app" && "$cmd3" != "iOS 13 or better with a third-party app" ]]; then
        print_error "Incorrect. With iOS 13 or newer, iPhone 8 can read and write NFC tags via third-party apps."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: With iOS 13 or newer, they can read and write NFC tags using a third-party app."
    echo

    # Question 4
    echo "  Besides making payments, name three additional things NFC can do."
    read -p "  lab@lab320:~$ " cmd4
    echo
    if [[ "$cmd4" != "Securely share data, transfer files, and add URLs to business cards" && "$cmd4" != "Share data, transfer files, and add URLs to business cards" ]]; then
        print_error "Incorrect. NFC can securely share data, transfer files, and embed URLs in business cards."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Securely share data, transfer files, and add URLs to business cards."
    echo

    # Question 5
    echo "  Which two components are most useful when making a videoconference call?"
    read -p "  lab@lab320:~$ " cmd5
    echo
    if [[ "$cmd5" != "Webcam and Microphone/speaker" && "$cmd5" != "Microphone/speaker and Webcam" ]]; then
        print_error "Incorrect. Webcam and Microphone/speaker are essential for video calls."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Webcam and Microphone/speaker"
    echo

    # Question 6
    echo "  In most laptops, which sound-producing component is usually not built into the display?"
    read -p "  lab@lab320:~$ " cmd6
    echo
    if [[ "$cmd6" != "Speakers" && "$cmd6" != "speakers" ]]; then
        print_error "Incorrect. Speakers are least likely to be built into the display."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Speakers"
    echo

    # Question 7
    echo "  What types of networking will smart cameras most often have built in?"
    read -p "  lab@lab320:~$ " cmd7
    echo
    if [[ "$cmd7" != "Bluetooth and Wi-Fi" && "$cmd7" != "Wi-Fi and Bluetooth" ]]; then
        print_error "Incorrect. Smart cameras typically include both Bluetooth and Wi-Fi."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Bluetooth and Wi-Fi"
    echo

    # Question 8
    echo "  What component or characteristic on most mobile phones has its ability measured in megapixels?"
    read -p "  lab@lab320:~$ " cmd8
    echo
    if [[ "$cmd8" != "Camera" && "$cmd8" != "camera" ]]; then
        print_error "Incorrect. Camera resolution is measured in megapixels."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Camera"
    echo

    # Question 9
    echo "  Your coworker bought an external Bluetooth trackpad for their tablet."
    echo "              What two actions must you take to install and configure it?"
    read -p "  lab@lab320:~$ " cmd9
    echo
    if [[ "$cmd9" != "Pair the device in Bluetooth settings and configure speed and scrolling" && "$cmd9" != "Put in pairing mode, add device, and configure speed and scrolling" ]]; then
        print_error "Incorrect. Pair it via Bluetooth settings, then adjust speed and scrolling in Settings."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Pair via Bluetooth and configure speed/scrolling in Settings."
    echo

    # Question 10
    echo "  What type of connection is used when a laptop is connected to a cellphone with a USB cable to share its mobile Internet?"
    read -p "  lab@lab320:~$ " cmd10
    echo
    if [[ "$cmd10" != "Tethering" && "$cmd10" != "tethering" ]]; then
        print_error "Incorrect. That’s USB tethering."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Tethering"
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
