#!/bin/bash

# Lab 338: A+ Networking Fundamentals (10 Questions, Set 3)
# Focus: IP vs MAC addressing, NIC loopback testing, WLAN/WAP context, POP3/IMAP ports,
#        DHCP for dynamic addressing, router vs switch roles, firewalls, default gateway,
#        patch panels, PAN (Bluetooth)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 338: A+ Section 2"
LAB_ID="lab338"
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
    center_text "Scenario: Review key A+ networking fundamentals — open-ended responses only."
    center_text "Answer each question correctly to advance."
    echo
    center_text "Press Enter to begin..."
    read _

    # Question 1
    draw_lab_ui
    echo "  What type of address does a router use to get data to its destination?"
    read -p "  lab@lab338:~$ " cmd1
    echo
    if [[ "$cmd1" != "IP" && "$cmd1" != "ip" && "$cmd1" != "IP address" && "$cmd1" != "ip address" ]]; then
        print_error "Incorrect. The correct answer is: IP (IP address)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: IP address"
    echo

    # Question 2
    echo "  A desktop's wired connection often disconnects without warning. Which tool should you use to"
    echo "  troubleshoot the network adapter itself?"
    read -p "  lab@lab338:~$ " cmd2
    echo
    if [[ "$cmd2" != "Loopback plug" && "$cmd2" != "loopback plug" && "$cmd2" != "Loopback" && "$cmd2" != "loopback" ]]; then
        print_error "Incorrect. The correct answer is: Loopback plug."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Loopback plug"
    echo

    # Question 3
    echo "  You're adding wireless tablets and printers to a business with no existing Wi-Fi."
    echo "  What name is given to the wireless network you create for these devices?"
    read -p "  lab@lab338:~$ " cmd3
    echo
    if [[ "$cmd3" != "WLAN" && "$cmd3" != "wlan" && "$cmd3" != "Wireless LAN" && "$cmd3" != "wireless LAN" && "$cmd3" != "wireless lan" ]]; then
        print_error "Incorrect. The correct answer is: WLAN (Wireless LAN)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: WLAN"
    echo

    # Question 4
    echo "  You want clients to download email from external servers regardless of protocol."
    echo "  Which TWO firewall ports should be opened? (Provide both.)"
    read -p "  lab@lab338:~$ " cmd4
    echo
    if [[ "$cmd4" != "110 and 143" && "$cmd4" != "143 and 110" && "$cmd4" != "110, 143" && "$cmd4" != "143, 110" \
       && "$cmd4" != "POP3 110 and IMAP 143" && "$cmd4" != "IMAP 143 and POP3 110" && "$cmd4" != "110 & 143" ]]; then
        print_error "Incorrect. The correct answers are: 110 and 143 (POP3 and IMAP)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 110 and 143"
    echo

    # Question 5
    echo "  You manage 500 nodes. Instead of manual addressing, what should you do?"
    read -p "  lab@lab338:~$ " cmd5
    echo
    if [[ "$cmd5" != "Assign dynamic IP addresses" && "$cmd5" != "assign dynamic IP addresses" \
       && "$cmd5" != "DHCP" && "$cmd5" != "dhcp" && "$cmd5" != "Use DHCP" && "$cmd5" != "use DHCP" && "$cmd5" != "use dhcp" ]]; then
        print_error "Incorrect. The correct answer is: Assign dynamic IP addresses (use DHCP)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Assign dynamic IP addresses (DHCP)"
    echo

    # Question 6
    echo "  Which device reads destination IP addresses and forwards packets based on that address?"
    read -p "  lab@lab338:~$ " cmd6
    echo
    if [[ "$cmd6" != "Router" && "$cmd6" != "router" ]]; then
        print_error "Incorrect. The correct answer is: Router."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Router"
    echo

    # Question 7
    echo "  Which network device is designed to act as a security guard, blocking malicious data from entering your network?"
    read -p "  lab@lab338:~$ " cmd7
    echo
    if [[ "$cmd7" != "Firewall" && "$cmd7" != "firewall" ]]; then
        print_error "Incorrect. The correct answer is: Firewall."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Firewall"
    echo

    # Question 8
    echo "  When manually configuring TCP/IP hosts, which parameter specifies the internal address of the"
    echo "  router that enables Internet access?"
    read -p "  lab@lab338:~$ " cmd8
    echo
    if [[ "$cmd8" != "Gateway" && "$cmd8" != "gateway" && "$cmd8" != "Default gateway" && "$cmd8" != "default gateway" ]]; then
        print_error "Incorrect. The correct answer is: Gateway (Default gateway)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Default gateway"
    echo

    # Question 9
    echo "  Which device in a telecommunications room congregates horizontal wiring, terminating each run in a female port?"
    read -p "  lab@lab338:~$ " cmd9
    echo
    if [[ "$cmd9" != "Patch panel" && "$cmd9" != "patch panel" && "$cmd9" != "Patchpanel" && "$cmd9" != "patchpanel" ]]; then
        print_error "Incorrect. The correct answer is: Patch panel."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Patch panel"
    echo

    # Question 10
    echo "  What type of network is commonly associated with Bluetooth (keyboards, mice, headphones) and covers a small area?"
    read -p "  lab@lab338:~$ " cmd10
    echo
    if [[ "$cmd10" != "PAN" && "$cmd10" != "pan" && "$cmd10" != "Personal Area Network" && "$cmd10" != "personal area network" ]]; then
        print_error "Incorrect. The correct answer is: PAN (Personal Area Network)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: PAN"
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
