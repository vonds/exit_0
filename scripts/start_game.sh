#!/bin/bash
clear > /dev/null 2>&1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Silent sourcing to avoid early output
source "$SCRIPT_DIR/ui.sh" > /dev/null 2>&1 || true
source "$SCRIPT_DIR/progress.sh" > /dev/null 2>&1 || true
source "$SCRIPT_DIR/stats.sh" > /dev/null 2>&1 || true
source "$SCRIPT_DIR/xp.sh" > /dev/null 2>&1 || true
source "$SCRIPT_DIR/../assets/prompts.sh" > /dev/null 2>&1 || true

# Linux module (with fallback message later if unavailable)
if ! source "$SCRIPT_DIR/lpic_practice_exam.sh" > /dev/null 2>&1; then
    LPIC_AVAILABLE=0
else
    LPIC_AVAILABLE=1
fi

SAVE_JSON="$SCRIPT_DIR/../data/.player_save.json"
SUCCESS_JSON="$SCRIPT_DIR/../data/.challenge_success.json"
PERFECTS_FILE="$SCRIPT_DIR/../data/.exam_perfects.json"

mkdir -p "$SCRIPT_DIR/../data"
# UPDATED: include GLOBAL_LEVEL on first init
[ ! -f "$SAVE_JSON" ] && echo '{"XP":0,"LEVEL":1,"GLOBAL_LEVEL":1,"COMPLETED":[]}' > "$SAVE_JSON"
[ ! -f "$SUCCESS_JSON" ] && echo '{}' > "$SUCCESS_JSON"
[ ! -f "$PERFECTS_FILE" ] && echo '{}' > "$PERFECTS_FILE"

# UPDATED: load & export GLOBAL_LEVEL too
XP=$(jq '.XP' "$SAVE_JSON")
LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
GLOBAL_LEVEL=$(jq '.GLOBAL_LEVEL // 1' "$SAVE_JSON")
export XP
export LEVEL
export GLOBAL_LEVEL

CHALLENGE_COUNT=$(ls "$SCRIPT_DIR/../challenges/expected"/expected*.sh 2>/dev/null | wc -l)
export CHALLENGE_COUNT

PALETTE_CYAN="\033[38;5;44m"
PALETTE_LAVENDER="\033[38;5;147m"
PALETTE_PINK="\033[38;5;212m"
PALETTE_CREAM="\033[38;5;230m"
PALETTE_TEAL="\033[38;5;37m"
NC="\033[0m"

show_completed_challenges() {
    echo
    center_text "Completed Challenges:"
    echo

    if [ ! -s "$SUCCESS_JSON" ]; then
        center_text "No challenges completed yet."
    else
        while IFS= read -r line; do
            center_text "$line"
        done < <(jq -r 'to_entries[] | "Challenge \(.key) - \(.value) time(s)"' "$SUCCESS_JSON")
    fi

    echo
    center_text "Successful Labs Completed:"
    echo

    LAB_COMPLETION_FILE="$SCRIPT_DIR/../data/.lab_completions.json"
    if [ -s "$LAB_COMPLETION_FILE" ]; then
        while IFS= read -r line; do
            center_text "$line"
        done < <(jq -r 'to_entries[] | "\(.key) - \(.value) time(s)"' "$LAB_COMPLETION_FILE")
    else
        center_text "No labs completed yet."
    fi

    echo
    center_text "Perfect Exams Completed:"
    echo

    if [ -s "$PERFECTS_FILE" ]; then
        while IFS= read -r line; do
            center_text "$line"
        done < <(jq -r 'to_entries[] | "\(.key) - \(.value) time(s)"' "$PERFECTS_FILE")
    else
        center_text "No exams completed perfectly yet."
    fi

    echo
    read -p "   Press Enter to return to the menu..."
}

run_challenge() {
    local num=$1
    local input=""
    local attempt_file="$SCRIPT_DIR/../data/attempt.sh"
    local expected_script="$SCRIPT_DIR/../challenges/expected/expected${num}.sh"

    clear
    center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
    center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
    print_banner "Challenge $num"
    show_prompt "$num"

    while true; do
        echo -e "#!/bin/bash\n\n" > "$attempt_file"
        chmod +x "$attempt_file"
        chmod u+w "$attempt_file"
        vi "$attempt_file"

        if ! bash -n "$attempt_file"; then
            print_error "Your script has syntax errors. Please fix them first."
            read -p "   Press Enter to try again..." input
            continue
        fi

        output1=$(echo "$input" | "$expected_script")
        output2=$(echo "$input" | "$attempt_file")

        if [ "$output1" == "$output2" ]; then
            print_success "Success! Challenge $num complete!"
            update_success_log "$num"
            award_xp 200
            print_info "You earned 200 XP!"

            rm -f "$attempt_file"

            local count
            count=$(jq -r --arg num "$num" '.[$num] // 0' "$SUCCESS_JSON")
            print_info "Successful Challenge $num Completions: $count"

            while true; do
                echo "   What would you like to do next?"
                echo "   1) Retry this challenge"
                echo "   2) Practice (20 or 100 times)"
                echo "   3) Return to main menu"
                read -p "   Choose: " choice
                case "$choice" in
                    1) run_challenge "$num"; return ;;
                    2) read -p "   Practice how many times? (20/100): " reps
                       practice_script "$reps" "$num"; return ;;
                    3) return ;;
                    *) print_error "   Invalid option." ;;
                esac
            done
        else
            print_error "Output did not match. Try again."
            print_info "Expected: $output1"
            print_info "Yours: $output2"
            read -p "   Press Enter to try again or type 'menu' to return: " input
            [[ "$input" == "menu" ]] && return
        fi
    done
}

practice_script() {
    local reps=$1
    local num=$2
    if [ -z "$reps" ]; then
        reps=20
    fi

    for ((i = 1; i <= reps; i++)); do
        echo "   🧪 Practice $i of $reps for Challenge $num..."
        run_challenge "$num"
    done
}

main_menu() {
    clear
    while true; do
        clear
        center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
        center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
        echo
        echo
        print_banner "Main Menu"
        center_menu "1) Start Full Challenge Run"
        center_menu "2) Run a Specific Challenge"
        center_menu "3) Practice a Challenge"
        center_menu "4) Linux Practice Exam"
        center_menu "5) Linux Lab Mode"
        center_menu "6) Study Stats "
        center_menu "7) Exit"
        echo
        echo
        read -p "   Choose an option: " menu_choice

        case "$menu_choice" in
            1)
                for i in $(seq 1 "$CHALLENGE_COUNT"); do
                    run_challenge "$i"
                done
                ;;
            2)
                read -p "   Enter challenge number: " cid
                if [[ "$cid" =~ ^[0-9]+$ ]] && (( cid >= 1 && cid <= CHALLENGE_COUNT )); then
                    run_challenge "$cid"
                else
                    print_error "   Invalid number."
                    read -p "   Press Enter to continue..."
                fi
                ;;
            3)
                read -p "   Enter challenge number: " cid
                if [[ "$cid" =~ ^[0-9]+$ ]] && (( cid >= 1 && cid <= CHALLENGE_COUNT )); then
                    practice_script "" "$cid"
                else
                    print_error "   Invalid number."
                    read -p "   Press Enter to continue..."
                fi
                ;;
            4)
                if [[ "$LPIC_AVAILABLE" -eq 1 ]]; then
                    choose_exam
                else
                    print_error "   Linux Practice Exam module failed to load."
                    read -p "   Press Enter to return to menu..."
                fi
                ;;
            5)
                if [ -f "$SCRIPT_DIR/labs_menu.sh" ]; then
                    source "$SCRIPT_DIR/labs_menu.sh"
                    main_lab_menu
                else
                    print_error "   Linux Lab module not found."
                    read -p "   Press Enter to return to menu..."
                fi
                ;;
            6)
                show_completed_challenges
                ;;
            7)
                echo
                echo
                echo
                echo
                print_info "   Application Closed"
                echo
                echo
                echo
                echo
                exit 0
                ;;
            *)
                print_error "   Invalid option."
                read -p "   Press Enter to continue..."
                ;;
        esac
    done
}

sleep 0.1
clear
main_menu
