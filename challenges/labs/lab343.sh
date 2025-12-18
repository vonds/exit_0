#!/bin/bash

# Lab 343: A+ Networking Fundamentals (10 Questions, Set 8)
# Focus: Duplicate IP causes, DHCP/static setup, Telnet/DNS ports, DNS firewall rule,
#        APIPA, HTTP blocking, name resolution, remote Internet (Satellite/WISP)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 343: A+ Section 2"
LAB_ID="lab343"
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
    center_text "Scenario: Review key A+ networking fundamentals — short, open-ended answers only."
    echo
    center_text "Press Enter to begin..."
    read _

    # Q1
    draw_lab_ui
    echo "  A user gets a 'duplicate IP' error. Give two reasons why."
    read -p "  lab@lab320:~$ " cmd1
    echo
    if [[ "$cmd1" != "Duplicate IP and static in DHCP range" && "$cmd1" != "Unique IPs required and static in DHCP" && "$cmd1" != "Duplicate IP, static IP conflict" ]]; then
        print_error "Incorrect. Correct: Duplicate IP and static in DHCP range."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Duplicate IP + static in DHCP range"
    echo

    # Q2
    echo "  A printer needs an IP that doesn’t change. Give two ways to do it."
    read -p "  lab@lab320:~$ " cmd2
    echo
    if [[ "$cmd2" != "Static IP or DHCP reservation" && "$cmd2" != "DHCP reservation or static IP" ]]; then
        print_error "Incorrect. Correct: Static IP or DHCP reservation."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Static IP or DHCP reservation"
    echo

    # Q3
    echo "  What port does Telnet use?"
    read -p "  lab@lab320:~$ " cmd3
    echo
    if [[ "$cmd3" != "23" ]]; then
        print_error "Incorrect. Correct: 23."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 23"
    echo

    # Q4
    echo "  Which port does DNS use?"
    read -p "  lab@lab320:~$ " cmd4
    echo
    if [[ "$cmd4" != "53" ]]; then
        print_error "Incorrect. Correct: 53."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 53"
    echo

    # Q5
    echo "  Users can reach sites by IP but not by name. What port must be reopened?"
    read -p "  lab@lab320:~$ " cmd5
    echo
    if [[ "$cmd5" != "53" ]]; then
        print_error "Incorrect. Correct: 53."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 53"
    echo

    # Q6
    echo "  What address range shows a PC couldn’t find a DHCP server?"
    read -p "  lab@lab320:~$ " cmd6
    echo
    if [[ "$cmd6" != "169.254.x.x" && "$cmd6" != "169.254" && "$cmd6" != "APIPA" && "$cmd6" != "apipa" ]]; then
        print_error "Incorrect. Correct: 169.254.x.x (APIPA)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 169.254.x.x (APIPA)"
    echo

    # Q7
    echo "  Which port can you block to stop unsecured web access?"
    read -p "  lab@lab320:~$ " cmd7
    echo
    if [[ "$cmd7" != "80" ]]; then
        print_error "Incorrect. Correct: 80."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 80"
    echo

    # Q8
    echo "  Which protocol resolves hostnames to IPs?"
    read -p "  lab@lab320:~$ " cmd8
    echo
    if [[ "$cmd8" != "DNS" && "$cmd8" != "dns" ]]; then
        print_error "Incorrect. Correct: DNS."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: DNS"
    echo

    # Q9
    echo "  What’s the best Internet option for a tower far from power lines?"
    read -p "  lab@lab320:~$ " cmd9
    echo
    if [[ "$cmd9" != "Satellite" && "$cmd9" != "satellite" ]]; then
        print_error "Incorrect. Correct: Satellite."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Satellite"
    echo

    # Q10
    echo "  Which wireless option is faster than satellite and needs line-of-sight?"
    read -p "  lab@lab320:~$ " cmd10
    echo
    if [[ "$cmd10" != "WISP" && "$cmd10" != "wisp" && "$cmd10" != "Fixed wireless" && "$cmd10" != "fixed wireless" ]]; then
        print_error "Incorrect. Correct: WISP (fixed wireless)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: WISP (fixed wireless)"
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
