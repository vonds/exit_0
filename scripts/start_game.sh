#!/bin/bash
clear > /dev/null 2>&1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Required modules (fail fast if missing)
source "$SCRIPT_DIR/ui.sh"       > /dev/null 2>&1 || { echo "Failed to load ui.sh"; exit 1; }
source "$SCRIPT_DIR/xp.sh"       > /dev/null 2>&1 || { echo "Failed to load xp.sh"; exit 1; }

SAVE_JSON="$SCRIPT_DIR/../data/.player_save.json"
SUCCESS_JSON="$SCRIPT_DIR/../data/.challenge_success.json"

mkdir -p "$SCRIPT_DIR/../data"

# New, simplified save format: XP + LEVEL only (xp.sh is truth)
[ ! -f "$SAVE_JSON" ] && echo '{"XP":0,"LEVEL":1,"COMPLETED":[]}' > "$SAVE_JSON"
[ ! -f "$SUCCESS_JSON" ] && echo '{}' > "$SUCCESS_JSON"

# Load canonical values (no GLOBAL_LEVEL)
XP="$(jq -r '.XP // 0' "$SAVE_JSON" 2>/dev/null)"
LEVEL="$(jq -r '.LEVEL // 1' "$SAVE_JSON" 2>/dev/null)"

# Validate numeric
[[ "$XP" =~ ^[0-9]+$ ]] || XP=0
[[ "$LEVEL" =~ ^[0-9]+$ ]] || LEVEL=1
[ "$LEVEL" -ge 1 ] 2>/dev/null || LEVEL=1

export XP
export LEVEL

CHALLENGE_COUNT=$(ls "$SCRIPT_DIR/../challenges/expected"/expected*.sh 2>/dev/null | wc -l)
export CHALLENGE_COUNT

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
    read -p "   Press Enter to return to the menu..."
}

main_menu() {
    clear
    while true; do
        clear

        # xp.sh calculates XP-to-next from LEVEL (single source of truth)
        local xp_to_next
        xp_to_next="$(calculate_xp_to_next_level)"

        center_draw_stats_panel "$LEVEL" "$XP" "$xp_to_next"
        center_draw_progress_bar "$XP" "$xp_to_next"

        echo
        echo
        print_banner "Main Menu"
        echo
        center_menu "1) Linux Lab Mode"
        center_menu "2) Study Stats "
        center_menu "3) Exit"
        echo
        echo

        read -p "   Choose an option: " menu_choice

        case "$menu_choice" in
            1)
                if [ -f "$SCRIPT_DIR/labs_menu.sh" ]; then
                    source "$SCRIPT_DIR/labs_menu.sh"
                    main_lab_menu
                else
                    print_error "   Linux Lab module not found."
                    read -p "   Press Enter to return to menu..."
                fi
                ;;
            2)
                show_completed_challenges
                ;;
            3)
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
