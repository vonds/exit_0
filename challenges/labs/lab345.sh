#!/bin/bash

# Lab 345: A+ Networking Fundamentals (10 Questions, Set 10)
# Focus: DHCP/static config, MAC filtering, IoT/DHCP, NFC vs RFID,
#        Web/File/Proxy/FTP servers, IoT control devices

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 345: A+ Section 2"
LAB_ID="lab345"
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
    center_text "Scenario: Review A+ networking fundamentals — concise open-ended answers."
    echo
    center_text "Press Enter to begin..."
    read _

    # Q1
    draw_lab_ui
    echo "  How do SOHO devices learn what IP to use? (Give two methods.)"
    read -p "  lab@lab320:~$ " cmd1
    echo
    if [[ "$cmd1" != "Static and DHCP" && "$cmd1" != "DHCP and static" && "$cmd1" != "Static IP and DHCP" ]]; then
        print_error "Incorrect. Correct: Static and DHCP."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Static and DHCP"
    echo

    # Q2
    echo "  A wireless network should only allow five known devices. How do you control this?"
    read -p "  lab@lab320:~$ " cmd2
    echo
    if [[ "$cmd2" != "MAC filtering" && "$cmd2" != "mac filtering" && "$cmd2" != "MAC address filtering" ]]; then
        print_error "Incorrect. Correct: MAC filtering."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: MAC filtering"
    echo

    # Q3
    echo "  How do IoT devices on a home network get dynamic IPs?"
    read -p "  lab@lab320:~$ " cmd3
    echo
    if [[ "$cmd3" != "DHCP" && "$cmd3" != "dhcp" ]]; then
        print_error "Incorrect. Correct: DHCP."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: DHCP"
    echo

    # Q4
    echo "  Which tech is used when paying with a phone near a reader?"
    read -p "  lab@lab320:~$ " cmd4
    echo
    if [[ "$cmd4" != "NFC" && "$cmd4" != "nfc" ]]; then
        print_error "Incorrect. Correct: NFC."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: NFC"
    echo

    # Q5
    echo "  Which tech allows passive tag reading from a few to dozens of feet?"
    read -p "  lab@lab320:~$ " cmd5
    echo
    if [[ "$cmd5" != "RFID" && "$cmd5" != "rfid" ]]; then
        print_error "Incorrect. Correct: RFID."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: RFID"
    echo

    # Q6
    echo "  What type of server provides public company info online?"
    read -p "  lab@lab320:~$ " cmd6
    echo
    if [[ "$cmd6" != "Web server" && "$cmd6" != "web server" && "$cmd6" != "HTTP server" && "$cmd6" != "http server" ]]; then
        print_error "Incorrect. Correct: Web server."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Web server"
    echo

    # Q7
    echo "  Your friend controls their home thermostat from work. What device do they have?"
    read -p "  lab@lab320:~$ " cmd7
    echo
    if [[ "$cmd7" != "IoT" && "$cmd7" != "iot" && "$cmd7" != "Smart device" && "$cmd7" != "smart device" ]]; then
        print_error "Incorrect. Correct: IoT."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: IoT"
    echo

    # Q8
    echo "  What server provides shared storage for internal users?"
    read -p "  lab@lab320:~$ " cmd8
    echo
    if [[ "$cmd8" != "File server" && "$cmd8" != "file server" && "$cmd8" != "Fileshare" && "$cmd8" != "fileshare" ]]; then
        print_error "Incorrect. Correct: File server."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: File server"
    echo

    # Q9
    echo "  Which server protects users and filters websites?"
    read -p "  lab@lab320:~$ " cmd9
    echo
    if [[ "$cmd9" != "Proxy server" && "$cmd9" != "proxy server" && "$cmd9" != "Proxy" && "$cmd9" != "proxy" ]]; then
        print_error "Incorrect. Correct: Proxy server."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Proxy server"
    echo

    # Q10
    echo "  Which server hosts files for download over the Internet?"
    read -p "  lab@lab320:~$ " cmd10
    echo
    if [[ "$cmd10" != "FTP server" && "$cmd10" != "ftp server" && "$cmd10" != "FTP" && "$cmd10" != "ftp" ]]; then
        print_error "Incorrect. Correct: FTP server."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: FTP server"
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
