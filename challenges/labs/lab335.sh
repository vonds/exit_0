#!/bin/bash

# Lab 335: A+ Location Services & BYOD Review (6 Questions)
# Focus: GPS + cellular location, per-app location permissions, streaming slowdowns,
#        BYOD controls (MAM/MDM), 5G throughput, corporate app access options

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 335: A+ Section 1"
LAB_ID="lab335"
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
    echo "  A hiking map app may combine which TWO location technologies?"
    read -p "  lab@lab320:~$ " cmd1
    echo
    if [[ "$cmd1" != "GPS and Cellular location services" && "$cmd1" != "Cellular location services and GPS" ]]; then
        print_error "Incorrect. It commonly uses GPS and Cellular location services."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: GPS and Cellular location services"
    echo

    # Question 2
    echo "  How are app location permissions managed on a smartphone?"
    read -p "  lab@lab320:~$ " cmd2
    echo
    if [[ "$cmd2" != "Per app" && "$cmd2" != "per app" && "$cmd2" != "Per-app" && "$cmd2" != "per-app" \
        && "$cmd2" != "Per application" && "$cmd2" != "per application" && "$cmd2" != "App-specific" && "$cmd2" != "app-specific" \
        && "$cmd2" != "Individually" && "$cmd2" != "individually" ]]; then
        print_error "Incorrect. Location permissions are managed per app (app-specific)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: Per app (app-specific)"
    echo

    # Question 3
    echo "  While streaming a movie, buffering suddenly increases and downloads are slower than normal."
    echo "              What’s a likely cause?"
    read -p "  lab@lab320:~$ " cmd3
    echo
    if [[ "$cmd3" != "The service is overwhelmed with requests" && "$cmd3" != "Service is overwhelmed with requests" ]]; then
        print_error "Incorrect. A common cause is the service being overwhelmed with requests."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: The service is overwhelmed with requests"
    echo

    # Question 4
    echo "  BYOD protections that control corporate data and apps on personal devices are called what TWO things?"
    read -p "  lab@lab320:~$ " cmd4
    echo
    if [[ "$cmd4" != "MAM and MDM" && "$cmd4" != "MDM and MAM" ]]; then
        print_error "Incorrect. Use MAM and MDM controls."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: MAM and MDM"
    echo

    # Question 5
    echo "  Which cellular communication technology is projected to reach up to 20 Gbps?"
    read -p "  lab@lab320:~$ " cmd5
    echo
    if [[ "$cmd5" != "5G" && "$cmd5" != "5g" ]]; then
        print_error "Incorrect. 5G targets multi-gigabit peak rates (up to ~20 Gbps)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: 5G"
    echo

    # Question 6
    echo "  How can a company securely provide employees with access to corporate applications on personal devices?"
    read -p "  lab@lab320:~$ " cmd6
    echo
    if [[ "$cmd6" != "MDM" && "$cmd6" != "MAM" && "$cmd6" != "MDM and MAM" && "$cmd6" != "MAM and MDM" && "$cmd6" != "Cloud access" && "$cmd6" != "cloud access" ]]; then
        print_error "Incorrect. Companies typically use MDM/MAM or secure cloud access for corporate apps."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct: MDM/MAM or secure cloud access"
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
