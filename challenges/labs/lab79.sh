#!/bin/bash

# Lab 79: Working with System Time using date

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 79: Working with System Time using date"
LAB_ID="lab79"
LAB_XP=2200
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
    center_text "You're working as a sysadmin responsible for checking"
    center_text "time-related settings on several servers. You need to quickly confirm"
    center_text "the local system time, compare it with UTC for log correlation, generate"
    center_text "cleanly formatted timestamps for scripts, and calculate an upcoming"
    center_text "maintenance window using a human-readable date."

    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Show the current local date and time using the default output."
    read -p "  lab@lpic-lab79:~$ " cmd1
    echo
    if [[ "$cmd1" != "date" ]]; then
        print_error "Incorrect. Use the plain date command with no options."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Fri Nov 29 09:34:15 EST 2025"
    echo

    echo "  Step 2: Display the current time in Coordinated Universal Time (UTC)."
    read -p "  lab@lpic-lab79:~$ " cmd2
    echo
    if [[ "$cmd2" != "date -u" ]]; then
        print_error "Incorrect. Use: date -u"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Fri Nov 29 14:34:15 UTC 2025"
    echo

    echo "  Step 3: Print the current date and time in a script-friendly format."
    echo "          Format: YYYY-MM-DD HH:MM:SS TZ"
    read -p "  lab@lpic-lab79:~$ " cmd3
    echo
    if [[ "$cmd3" != "date '+%F %T %Z'" ]]; then
        print_error "Incorrect. Use: date '+%F %T %Z'"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  2025-11-29 09:34:15 EST"
    echo

    echo "  Step 4: Show what the date and time will be on the next Friday at 09:00 local time."
    read -p "  lab@lpic-lab79:~$ " cmd4
    echo
    if [[ "$cmd4" != "date -d 'next Friday 09:00'" ]]; then
        print_error "Incorrect. Use: date -d 'next Friday 09:00'"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Fri Dec 05 09:00:00 EST 2025"
    echo

    print_success "Lab complete."
    print_info "You earned $LAB_XP XP for completing this lab."
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON")
    LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
    export XP
    export LEVEL
    record_lab_completion

    completion_count=$(get_lab_completion_count)
    echo
    print_info "You've completed this lab $completion_count time(s)."
    echo
    center_text "Would you like to:"
    center_text "1) Retry this lab"
    center_text "2) Return to Sysadmin Lab Menu"
    echo
    read -p "  > " post_choice

    [[ "$post_choice" == "2" ]] && exit 0
done
