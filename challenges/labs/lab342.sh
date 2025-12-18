#!/bin/bash

# Lab 342: A+ Networking Fundamentals (10 Questions, Set 7)
# Focus: RJ-45 tools, SPF, PoE, public IPs, DHCP reservations, TLS port,
#        802.11ax compatibility, MAN networks, CIDR /21, required IPv4 config

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 342: A+ Section 2"
LAB_ID="lab342"
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

    # Q1: Two tools needed for RJ-45 connector
    draw_lab_ui
    echo "  What TWO tools do you need to connect an RJ-45 connector to an appropriate cable?"
    read -p "  lab@lab342:~$ " cmd1
    echo
    if [[ "$cmd1" != "Crimper and Cable stripper" && "$cmd1" != "Cable stripper and Crimper" && "$cmd1" != "Crimper, Cable stripper" && "$cmd1" != "Cable stripper, Crimper" ]]; then
        print_error "Incorrect. The correct answer is: Crimper and Cable stripper."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Crimper and Cable stripper"
    echo

    # Q2: DNS feature requiring sender's domain match
    echo "  Which DNS feature requires that a sender’s email be from the same domain as the DNS domain and can reject others?"
    read -p "  lab@lab342:~$ " cmd2
    echo
    if [[ "$cmd2" != "SPF" && "$cmd2" != "spf" && "$cmd2" != "Sender Policy Framework" && "$cmd2" != "sender policy framework" ]]; then
        print_error "Incorrect. The correct answer is: SPF."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: SPF"
    echo

    # Q3: Powering WAP with no outlet
    echo "  You need to install a WAP in a drop ceiling with no power outlet. Which technology enables this?"
    read -p "  lab@lab342:~$ " cmd3
    echo
    if [[ "$cmd3" != "PoE" && "$cmd3" != "poe" && "$cmd3" != "Power over Ethernet" && "$cmd3" != "power over ethernet" ]]; then
        print_error "Incorrect. The correct answer is: PoE (Power over Ethernet)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: PoE"
    echo

    echo "  One of these is PUBLIC (routable). Type the address only:"
    echo "    10.1.2.3, 172.18.31.54, 172.168.38.155, 192.168.38.155"
    read -p "  lab@lab342:~$ " cmd4
    echo
    if [[ "$cmd4" != "172.168.38.155" ]]; then
        print_error "Incorrect. Correct: 172.168.38.155."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 172.168.38.155"
    echo

    # Q5: DHCP setting for fixed IPs for specific devices
    echo "  You want two servers and a printer to always get the same IPs at the beginning of the range. What should you configure?"
    read -p "  lab@lab342:~$ " cmd5
    echo
    if [[ "$cmd5" != "Reservations" && "$cmd5" != "reservations" && "$cmd5" != "DHCP reservations" && "$cmd5" != "dhcp reservations" ]]; then
        print_error "Incorrect. The correct answer is: Reservations."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Reservations"
    echo

    # Q6: TLS encryption port
    echo "  If a website encrypts traffic using TLS, on what port does that traffic travel?"
    read -p "  lab@lab342:~$ " cmd6
    echo
    if [[ "$cmd6" != "443" ]]; then
        print_error "Incorrect. The correct answer is: 443."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 443"
    echo

    # Q7: Wi-Fi standard for upgrade with backward compatibility
    echo "  You have 802.11b/g devices but want the newest compatible tech. Which standard should you choose?"
    read -p "  lab@lab342:~$ " cmd7
    echo
    if [[ "$cmd7" != "802.11ax" && "$cmd7" != "Wi-Fi 6" && "$cmd7" != "wifi 6" && "$cmd7" != "802.11AX" ]]; then
        print_error "Incorrect. The correct answer is: 802.11ax (Wi-Fi 6)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 802.11ax (Wi-Fi 6)"
    echo

    # Q8: Type of network covering several buildings, small geographic area
    echo "  What type of network spans multiple buildings but is still confined to a small area?"
    read -p "  lab@lab342:~$ " cmd8
    echo
    if [[ "$cmd8" != "MAN" && "$cmd8" != "man" && "$cmd8" != "Metropolitan Area Network" && "$cmd8" != "metropolitan area network" ]]; then
        print_error "Incorrect. The correct answer is: MAN (Metropolitan Area Network)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: MAN"
    echo

    # Q9: CIDR notation for 255.255.224.0
    echo "  Which CIDR shorthand corresponds to the subnet mask 255.255.224.0?"
    read -p "  lab@lab342:~$ " cmd9
    echo
    if [[ "$cmd9" != "/19" ]]; then
        print_error "Incorrect. The correct answer is: /19."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: /19"
    echo

    # Q10: Required IPv4 configuration elements
    echo "  Which configuration elements are required for a computer to connect to an IPv4 network?"
    read -p "  lab@lab342:~$ " cmd10
    echo
    if [[ "$cmd10" != "IP address, subnet mask, and default gateway" && "$cmd10" != "ip address, subnet mask, and default gateway" && "$cmd10" != "IP address subnet mask default gateway" && "$cmd10" != "IP address and subnet mask and default gateway" ]]; then
        print_error "Incorrect. The correct answer is: IP address, subnet mask, and default gateway."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: IP address, subnet mask, and default gateway"
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
