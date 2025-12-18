#!/bin/bash

# Lab 337: A+ Networking Fundamentals (10 Questions, Set 2)
# Focus: Telnet deprecation, Wi-Fi signal survey, HTTPS, Wi-Fi 6/7 bands,
#        IPv6 unicast, WAN scope, RDP/3389, SSH port, private IPs, routers & broadcasts

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 337: A+ Section 2"
LAB_ID="lab337"
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
    echo "  Which deprecated protocol enables a user to log in to another machine and 'see' the"
    echo "  remote computer in a window on their screen?"
    read -p "  lab@lab337:~$ " cmd1
    echo
    if [[ "$cmd1" != "Telnet" && "$cmd1" != "telnet" ]]; then
        print_error "Incorrect. The correct answer is: Telnet."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Telnet"
    echo

    # Question 2
    echo "  You've installed an 802.11ac wireless network. Which tool is designed to test how far"
    echo "  your wireless signal travels outside the building?"
    read -p "  lab@lab337:~$ " cmd2
    echo
    if [[ "$cmd2" != "Wi-Fi analyzer" && "$cmd2" != "wi-fi analyzer" && "$cmd2" != "WiFi analyzer" && "$cmd2" != "wifi analyzer" && "$cmd2" != "Wireless analyzer" && "$cmd2" != "wireless analyzer" ]]; then
        print_error "Incorrect. The correct answer is: Wi-Fi analyzer."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Wi-Fi analyzer"
    echo

    # Question 3
    echo "  Users are concerned about submitting confidential info to a website."
    echo "  What should they look for in the address to indicate it’s appropriate on a trusted site?"
    read -p "  lab@lab337:~$ " cmd3
    echo
    if [[ "$cmd3" != "HTTPS" && "$cmd3" != "https" && "$cmd3" != "HTTPS://" && "$cmd3" != "https://" && "$cmd3" != "Use HTTPS" && "$cmd3" != "use HTTPS" && "$cmd3" != "use https" ]]; then
        print_error "Incorrect. The correct answer is: HTTPS (for example, https://)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: HTTPS"
    echo

    # Question 4
    echo "  Which Wi-Fi standards operate in the 2.4, 5, and 6 GHz frequencies? (Provide both.)"
    read -p "  lab@lab337:~$ " cmd4
    echo
    if [[ "$cmd4" != "802.11ax and 802.11be" && "$cmd4" != "802.11be and 802.11ax" && "$cmd4" != "Wi-Fi 6 and Wi-Fi 7" && "$cmd4" != "WiFi 6 and WiFi 7" ]]; then
        print_error "Incorrect. The correct answers are: 802.11ax and 802.11be."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 802.11ax and 802.11be"
    echo

    # Question 5
    echo "  Which type of IPv6 address identifies a single node on the network?"
    read -p "  lab@lab337:~$ " cmd5
    echo
    if [[ "$cmd5" != "Unicast" && "$cmd5" != "unicast" ]]; then
        print_error "Incorrect. The correct answer is: Unicast."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Unicast"
    echo

    # Question 6
    echo "  What type of network covers large geographical areas and may support thousands of users,"
    echo "  often using lines owned by other entities?"
    read -p "  lab@lab337:~$ " cmd6
    echo
    if [[ "$cmd6" != "WAN" && "$cmd6" != "wan" && "$cmd6" != "Wide Area Network" && "$cmd6" != "wide area network" ]]; then
        print_error "Incorrect. The correct answer is: WAN (Wide Area Network)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: WAN"
    echo

    # Question 7
    echo "  Which TCP/IP protocol, developed by Microsoft, uses port 3389 to connect to a remote computer?"
    read -p "  lab@lab337:~$ " cmd7
    echo
    if [[ "$cmd7" != "RDP" && "$cmd7" != "rdp" && "$cmd7" != "Remote Desktop Protocol" && "$cmd7" != "remote desktop protocol" ]]; then
        print_error "Incorrect. The correct answer is: RDP (Remote Desktop Protocol)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: RDP"
    echo

    # Question 8
    echo "  What port does the SSH protocol use?"
    read -p "  lab@lab337:~$ " cmd8
    echo
    if [[ "$cmd8" != "22" ]]; then
        print_error "Incorrect. The correct answer is: 22."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 22"
    echo

    # Question 9 (Open-Ended, constrained)
    echo "  Among these addresses — 10.1.1.1, 11.1.1.1, 12.1.1.1, 13.1.1.1 — which is NOT routable on the public Internet?"
    echo "  Answer with the address only."
    read -p "  lab@lab337:~$ " cmd9
    echo
    if [[ "$cmd9" != "10.1.1.1" ]]; then
        print_error "Incorrect. The correct answer is: 10.1.1.1."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 10.1.1.1"
    echo    

    # Question 10
    echo "  Which network connectivity device does not forward broadcast messages, creating multiple broadcast domains?"
    read -p "  lab@lab337:~$ " cmd10
    echo
    if [[ "$cmd10" != "Router" && "$cmd10" != "router" ]]; then
        print_error "Incorrect. The correct answer is: Router."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Router"
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
