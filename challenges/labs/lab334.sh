#!/bin/bash

# Lab 334: A+ Cloud, Accounts & Mobile Sync Review
# Focus: iCloud, email setup basics, IMEI vs IMSI/SIM, sync best practices,
#        calendar sharing, ActiveSync, Bluetooth pairing flow, GPS tracking

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 334: A+ Section 1"
LAB_ID="lab334"
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
    echo "  What Apple-built service lets users store documents, media, and contacts remotely?"
    read -p "  lab@lab320:~$ " cmd1
    echo
    if [[ "$cmd1" != "iCloud" && "$cmd1" != "icloud" ]]; then
        print_error "Incorrect. Apple’s cloud storage/sync service is iCloud."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: iCloud"
    echo

    # Question 2 (expects three items in one line)
    echo "  When setting up email from an online provider, name the common configuration settings you need."
    read -p "  lab@lab320:~$ " cmd2
    echo
    if [[ "$cmd2" != "Email server name, Port and TLS settings, Username and password" \
       && "$cmd2" != "Email server name, Username and password, Port and TLS settings" \
       && "$cmd2" != "Username and password, Email server name, Port and TLS settings" ]]; then
        print_error "Incorrect. You typically need the email server name, port/TLS settings, and username/password."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Email server name, Port and TLS settings, Username and password"
    echo

    # Question 3
    echo "  Which GSM number is hardcoded in the phone and identifies the hardware to the tower?"
    read -p "  lab@lab320:~$ " cmd3
    echo
    if [[ "$cmd3" != "IMEI" && "$cmd3" != "imei" ]]; then
        print_error "Incorrect. IMEI identifies the physical handset."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: IMEI"
    echo

    # Question 4
    echo "  Which unique component identifies you as a subscriber and is provisioned by the user or provider?"
    read -p "  lab@lab320:~$ " cmd4
    echo
    if [[ "$cmd4" != "SIM" && "$cmd4" != "SIM card" && "$cmd4" != "Subscriber Identity Module" && "$cmd4" != "eSIM" ]]; then
        print_error "Incorrect. The SIM (or eSIM) identifies the subscriber."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: SIM (or eSIM)"
    echo

    # Question 5
    echo "  What best practice helps prevent losing data like contacts and calendar entries if a device is lost?"
    read -p "  lab@lab320:~$ " cmd5
    echo
    if [[ "$cmd5" != "Synchronization" && "$cmd5" != "synchronization" && "$cmd5" != "Sync" && "$cmd5" != "sync" ]]; then
        print_error "Incorrect. Synchronization protects your data across devices."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Synchronization"
    echo

    # Question 6
    echo "  A user wants their calendar on laptop, desktop, and phone. What’s the best option?"
    read -p "  lab@lab320:~$ " cmd6
    echo
    if [[ "$cmd6" != "Synchronize calendars" && "$cmd6" != "Synchronize calendar" && "$cmd6" != "Calendar synchronization" ]]; then
        print_error "Incorrect. Synchronize calendars across devices."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Synchronize calendars"
    echo

    # Question 7
    echo "  Two parents want to share appointment dates/times between their devices. What’s the best option?"
    read -p "  lab@lab320:~$ " cmd7
    echo
    if [[ "$cmd7" != "Synchronize their calendars" && "$cmd7" != "Share synchronized calendars" && "$cmd7" != "Share calendars via sync" ]]; then
        print_error "Incorrect. Synchronize (share) their calendars."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Synchronize their calendars"
    echo

    # Question 8
    echo "  Which Windows app is used to synchronize data between smartphones and a desktop computer?"
    read -p "  lab@lab320:~$ " cmd8
    echo
    if [[ "$cmd8" != "ActiveSync" && "$cmd8" != "activesync" ]]; then
        print_error "Incorrect. ActiveSync is the Windows synchronization utility."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: ActiveSync"
    echo

    # Question 9
    echo "  You’ve just entered the PIN to connect Bluetooth speakers in a conference room. What’s the next step?"
    read -p "  lab@lab320:~$ " cmd9
    echo
    if [[ "$cmd9" != "Test connectivity" && "$cmd9" != "test connectivity" && "$cmd9" != "Test the connection" ]]; then
        print_error "Incorrect. Next, test connectivity (play audio to confirm)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Test connectivity"
    echo

    # Question 10
    echo "  A shuttle company wants to track all vehicles using satellite-based navigation systems. What tech is most likely used?"
    read -p "  lab@lab320:~$ " cmd10
    echo
    if [[ "$cmd10" != "GPS" && "$cmd10" != "gps" && "$cmd10" != "Global Positioning System" ]]; then
        print_error "Incorrect. GPS provides satellite-based location tracking."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: GPS"
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
