#!/bin/bash

# Lab 341: A+ Networking Fundamentals (10 Questions, Set 6)
# Focus: SMTP port, Wi-Fi range choice, cable short testing, broadcast boundary,
#        DKIM, DSL, Wi-Fi channel planning, IMAP port, PoE, AP count (802.11ac)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 341: A+ Section 2"
LAB_ID="lab341"
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

    # Q1: Port used by an email client to push email to its server (SMTP)
    draw_lab_ui
    echo "  Which TCP/IP port will an email client use to push email to its email server?"
    read -p "  lab@lab320:~$ " cmd1
    echo
    if [[ "$cmd1" != "25" && "$cmd1" != "SMTP 25" && "$cmd1" != "smtp 25" ]]; then
        print_error "Incorrect. The correct answer is: 25."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 25"
    echo

    # Q2: Wi-Fi standard for greatest distance with omnidirectional antenna
    echo "  Using a standard omnidirectional antenna, which Wi-Fi standard should you choose for greatest distance?"
    read -p "  lab@lab320:~$ " cmd2
    echo
    if [[ "$cmd2" != "802.11n" && "$cmd2" != "802.11N" && "$cmd2" != "11n" && "$cmd2" != "n" ]]; then
        print_error "Incorrect. The correct answer is: 802.11n."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 802.11n"
    echo

    # Q3: Tool to determine a short in a Cat 6 connection
    echo "  You suspect a short on a Cat 6 run. Which tool can determine this?"
    read -p "  lab@lab320:~$ " cmd3
    echo
    if [[ "$cmd3" != "Cable tester" && "$cmd3" != "cable tester" && "$cmd3" != "TDR" && "$cmd3" != "tdr" ]]; then
        print_error "Incorrect. The correct answer is: Cable tester (TDR functionality)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Cable tester"
    echo

    # Q4: Boundary of an IPv4 broadcast domain
    echo "  What marks the boundary of an IPv4 broadcast domain?"
    read -p "  lab@lab320:~$ " cmd4
    echo
    if [[ "$cmd4" != "Router" && "$cmd4" != "router" ]]; then
        print_error "Incorrect. The correct answer is: Router."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Router"
    echo

    # Q5: DNS feature verifying email origin with public/private keys
    echo "  Which DNS feature uses public/private keys to verify that an email originated where it claims?"
    read -p "  lab@lab320:~$ " cmd5
    echo
    if [[ "$cmd5" != "DKIM" && "$cmd5" != "dkim" ]]; then
        print_error "Incorrect. The correct answer is: DKIM."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: DKIM"
    echo

    # Q6: Asymmetrical speeds over phone lines once popular for home
    echo "  Which Internet connection type, once popular for home use, offers asymmetrical speeds over phone lines?"
    read -p "  lab@lab320:~$ " cmd6
    echo
    if [[ "$cmd6" != "DSL" && "$cmd6" != "dsl" ]]; then
        print_error "Incorrect. The correct answer is: DSL."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: DSL"
    echo

    # Q7: Channel planning with overlapping 802.11n APs
    echo "  You have overlapping 802.11n APs. Which channel configuration principle should you follow?"
    read -p "  lab@lab320:~$ " cmd7
    echo
    if [[ "$cmd7" != "Use nonoverlapping channels" && "$cmd7" != "use nonoverlapping channels" && "$cmd7" != "Nonoverlapping channels" && "$cmd7" != "nonoverlapping channels" ]]; then
        print_error "Incorrect. The correct answer is: Configure nonoverlapping channels."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Nonoverlapping channels"
    echo

    # Q8: IMAP port
    echo "  You need to configure email settings for IMAP. Which port will you configure?"
    read -p "  lab@lab320:~$ " cmd8
    echo
    if [[ "$cmd8" != "143" ]]; then
        print_error "Incorrect. The correct answer is: 143."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 143"
    echo

    # Q9: Powering devices where no outlets exist
    echo "  Which technology enables installing network devices where there are no power outlets?"
    read -p "  lab@lab320:~$ " cmd9
    echo
    if [[ "$cmd9" != "PoE" && "$cmd9" != "poe" && "$cmd9" != "Power over Ethernet" && "$cmd9" != "power over ethernet" ]]; then
        print_error "Incorrect. The correct answer is: PoE (Power over Ethernet)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: PoE"
    echo

    # Q10: Minimum AP count for 802.11ac in 100m x 25m building
    echo "  A building is ~100m long and 25m wide. Using 802.11ac, what is the minimum number of APs you need?"
    read -p "  lab@lab320:~$ " cmd10
    echo
    if [[ "$cmd10" != "Four" && "$cmd10" != "four" && "$cmd10" != "4" ]]; then
        print_error "Incorrect. The correct answer is: Four."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Four"
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
