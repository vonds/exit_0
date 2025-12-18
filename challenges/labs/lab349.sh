#!/bin/bash

# Lab 349: A+ Networking Fundamentals (10 Questions, Set 14)
# Focus: Wi-Fi channels, OTARD/WISP, host numbers, AAA model,
#        load balancing, SCADA systems, DHCP leases, DNS AAAA, MX, SPF

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 349: A+ Section 2"
LAB_ID="lab349"
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
    echo "  Which Wi-Fi channel range doesn’t require DFS or TPC?"
    read -p "  lab@lab320:~$ " cmd1
    echo
    if [[ "$cmd1" != "36 to 48" && "$cmd1" != "Channels 36 to 48" && "$cmd1" != "36-48" ]]; then
        print_error "Incorrect. Correct: Channels 36 to 48."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Channels 36 to 48"
    echo

    # Q2
    echo "  Which broadband tech gained FCC OTARD protection in 2021?"
    read -p "  lab@lab320:~$ " cmd2
    echo
    if [[ "$cmd2" != "WISPs" && "$cmd2" != "wisps" && "$cmd2" != "Wireless ISPs" && "$cmd2" != "wireless isps" ]]; then
        print_error "Incorrect. Correct: WISPs."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: WISPs"
    echo

    # Q3
    echo "  What’s the host number in 192.168.2.200 with mask 255.255.255.0?"
    read -p "  lab@lab320:~$ " cmd3
    echo
    if [[ "$cmd3" != "200" ]]; then
        print_error "Incorrect. Correct: 200."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 200"
    echo

    # Q4
    echo "  What are the three As used by authentication servers?"
    read -p "  lab@lab320:~$ " cmd4
    echo
    if [[ "$cmd4" != "Authentication, Authorization, Accounting" && "$cmd4" != "AAA" ]]; then
        print_error "Incorrect. Correct: Authentication, Authorization, Accounting."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Authentication, Authorization, Accounting"
    echo

    # Q5
    echo "  Which Internet appliance distributes incoming traffic among multiple servers?"
    read -p "  lab@lab320:~$ " cmd5
    echo
    if [[ "$cmd5" != "Load balancer" && "$cmd5" != "load balancer" ]]; then
        print_error "Incorrect. Correct: Load balancer."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Load balancer"
    echo

    # Q6
    echo "  What system controls and monitors industrial machines and processes?"
    read -p "  lab@lab320:~$ " cmd6
    echo
    if [[ "$cmd6" != "SCADA" && "$cmd6" != "scada" ]]; then
        print_error "Incorrect. Correct: SCADA."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: SCADA"
    echo

    # Q7
    echo "  Restaurant Wi-Fi full; new users can’t connect. What router setting can help?"
    read -p "  lab@lab320:~$ " cmd7
    echo
    if [[ "$cmd7" != "DHCP lease duration" && "$cmd7" != "dhcp lease duration" && "$cmd7" != "Lease duration" && "$cmd7" != "lease duration" ]]; then
        print_error "Incorrect. Correct: DHCP lease duration."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: DHCP lease duration"
    echo

    # Q8
    echo "  What type of address is a DNS AAAA record used for?"
    read -p "  lab@lab320:~$ " cmd8
    echo
    if [[ "$cmd8" != "IPv6" && "$cmd8" != "ipv6" ]]; then
        print_error "Incorrect. Correct: IPv6."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: IPv6"
    echo

    # Q9
    echo "  What DNS record type is used to load balance incoming mail?"
    read -p "  lab@lab320:~$ " cmd9
    echo
    if [[ "$cmd9" != "MX" && "$cmd9" != "mx" ]]; then
        print_error "Incorrect. Correct: MX record."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: MX"
    echo

    # Q10
    echo "  What DNS record lists authorized IPs that can send mail for a domain?"
    read -p "  lab@lab320:~$ " cmd10
    echo
    if [[ "$cmd10" != "SPF" && "$cmd10" != "spf" ]]; then
        print_error "Incorrect. Correct: SPF."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: SPF"
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
