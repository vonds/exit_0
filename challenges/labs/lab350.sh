#!/bin/bash

# Lab 350: A+ Section 2 (6 Questions)
# Focus: IPv6 interface ID, WISP terms, 2.4 vs 5 GHz channels, NTP, SQL server, spam gateway

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 350: A+ Section 2"
LAB_ID="lab350"
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
    center_text "Scenario: Answer each prompt with the correct short, open-ended response."
    echo
    center_text "Press Enter to begin..."
    read _

    # Q1: IPv6 interface ID
    draw_lab_ui
    echo "  What is the interface ID of 2001::1a3:f1a:308:833 ?"
    read -p "  lab@lab320:~$ " cmd1
    echo
    if [[ "$cmd1" != "1a3:f1a:308:833" ]]; then
        print_error "Incorrect. Correct: 1a3:f1a:308:833."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 1a3:f1a:308:833"
    echo

    # Q2: WISP terms (two)
    echo "  Name TWO terms for an ISP using PtP microwave backbones and PtMP to customers."
    read -p "  lab@lab320:~$ " cmd2
    echo
    if [[ "$cmd2" != "WISP and long-range fixed wireless" && "$cmd2" != "Long-range fixed wireless and WISP" && "$cmd2" != "WISP & long-range fixed wireless" ]]; then
        print_error "Incorrect. Correct: WISP and long-range fixed wireless."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: WISP + long-range fixed wireless"
    echo

    # Q3: 2.4 vs 5 GHz channels (two ideas)
    echo "  Give TWO facts: choose 2.4 GHz nonoverlapping channels and a key 5 GHz advantage."
    read -p "  lab@lab320:~$ " cmd3
    echo
    if [[ "$cmd3" != "1,6,11 and 5 GHz has more bandwidth and less interference" \
       && "$cmd3" != "1,6,11 and 5 GHz offers higher throughput and less interference" \
       && "$cmd3" != "Channels 1,6,11 and 5 GHz more bandwidth/less interference" ]]; then
        print_error "Incorrect. Example: 1,6,11 AND 5 GHz has more bandwidth and less interference."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 1,6,11 + 5 GHz more bandwidth/less interference"
    echo

    # Q4: Time sync server
    echo "  What server type synchronizes time on network devices?"
    read -p "  lab@lab320:~$ " cmd4
    echo
    if [[ "$cmd4" != "NTP" && "$cmd4" != "ntp" && "$cmd4" != "NTP server" && "$cmd4" != "ntp server" ]]; then
        print_error "Incorrect. Correct: NTP."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: NTP"
    echo

    # Q5: SQL server role
    echo "  What does an SQL server do?"
    read -p "  lab@lab320:~$ " cmd5
    echo
    if [[ "$cmd5" != "Provides access to databases" && "$cmd5" != "Provide access to databases" && "$cmd5" != "Database access" && "$cmd5" != "Database server" ]]; then
        print_error "Incorrect. Correct: Provides access to databases."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Provides access to databases"
    echo

    # Q6: Spam gateway job
    echo "  What is the job of a spam gateway?"
    read -p "  lab@lab320:~$ " cmd6
    echo
    if [[ "$cmd6" != "Keep spam out" && "$cmd6" != "Blocks spam" && "$cmd6" != "Filter spam" ]]; then
        print_error "Incorrect. Correct: Keep spam out."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Keep spam out"
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
