#!/bin/bash

# Lab 346: A+ Networking Fundamentals (10 Questions, Set 11)
# Focus: Print/DNS/AAA/Syslog/Mail servers, TCP conn-oriented, IDS vs IPS, UTM, Bluetooth band

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 346: A+ Section 2"
LAB_ID="lab346"
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
    center_text "Scenario: Review A+ networking fundamentals — concise, open-ended answers."
    echo
    center_text "Press Enter to begin..."
    read _

    # Q1
    draw_lab_ui
    echo "  You added a device so many users can access several printers. What is it?"
    read -p "  lab@lab320:~$ " cmd1
    echo
    if [[ "$cmd1" != "Print server" && "$cmd1" != "print server" ]]; then
        print_error "Incorrect. Correct: Print server."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Print server"
    echo

    # Q2
    echo "  What server resolves names to IPs?"
    read -p "  lab@lab320:~$ " cmd2
    echo
    if [[ "$cmd2" != "DNS server" && "$cmd2" != "dns server" && "$cmd2" != "DNS" && "$cmd2" != "dns" ]]; then
        print_error "Incorrect. Correct: DNS server."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: DNS server"
    echo

    # Q3
    echo "  Which server validates user credentials for resource access?"
    read -p "  lab@lab320:~$ " cmd3
    echo
    if [[ "$cmd3" != "AAA" && "$cmd3" != "aaa" && "$cmd3" != "Authentication server" && "$cmd3" != "authentication server" ]]; then
        print_error "Incorrect. Correct: AAA (authentication) server."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: AAA server"
    echo

    # Q4
    echo "  Which server collects and journals system messages from devices?"
    read -p "  lab@lab320:~$ " cmd4
    echo
    if [[ "$cmd4" != "Syslog" && "$cmd4" != "syslog" && "$cmd4" != "Syslog server" && "$cmd4" != "syslog server" ]]; then
        print_error "Incorrect. Correct: Syslog server."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Syslog server"
    echo

    # Q5
    echo "  You're configuring a phone to send/receive company email. What server type?"
    read -p "  lab@lab320:~$ " cmd5
    echo
    if [[ "$cmd5" != "Mail server" && "$cmd5" != "mail server" && "$cmd5" != "Email server" && "$cmd5" != "email server" ]]; then
        print_error "Incorrect. Correct: Mail server."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Mail server"
    echo

    # Q6
    echo "  Question 6: Of the following, which TWO protocols are connection-oriented (use TCP)?"
    echo "    - SSH"
    echo "    - HTTPS"
    echo "    - TFTP"
    echo "    - DNS (UDP)"
    read -p "  lab@lab320:~$ " cmd6
    echo
    if [[ "$cmd6" != "HTTPS and SSH" && "$cmd6" != "SSH and HTTPS" && "$cmd6" != "SSH & HTTPS" ]]; then
        print_error "Incorrect. Correct: HTTPS and SSH."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: HTTPS and SSH"
    echo    

    # Q7
    echo "  What TWO services would you deploy to detect suspect activity?"
    read -p "  lab@lab320:~$ " cmd7
    echo
    if [[ "$cmd7" != "IDS and UTM" && "$cmd7" != "UTM and IDS" ]]; then
        print_error "Incorrect. Correct: IDS and UTM."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: IDS and UTM"
    echo

    # Q8
    echo "  Key difference: IDS vs IPS?"
    read -p "  lab@lab320:~$ " cmd8
    echo
    if [[ "$cmd8" != "IPS reacts" && "$cmd8" != "IPS actively blocks" && "$cmd8" != "IPS takes action" ]]; then
        print_error "Incorrect. Correct: IPS reacts (blocks); IDS only detects."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: IPS reacts"
    echo

    # Q9
    echo "  Peers suggest one device to centralize security management. What is it?"
    read -p "  lab@lab320:~$ " cmd9
    echo
    if [[ "$cmd9" != "UTM" && "$cmd9" != "utm" && "$cmd9" != "Unified Threat Management" && "$cmd9" != "unified threat management" ]]; then
        print_error "Incorrect. Correct: UTM."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: UTM"
    echo

    # Q10
    echo "  Bluetooth operates at what wireless frequency?"
    read -p "  lab@lab320:~$ " cmd10
    echo
    if [[ "$cmd10" != "2.4 GHz" && "$cmd10" != "2.4ghz" && "$cmd10" != "2.4" ]]; then
        print_error "Incorrect. Correct: 2.4 GHz."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 2.4 GHz"
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
