#!/bin/bash

# Lab 34: System Utility Commands Practice
# Commands: date, uptime, hostname, uname, cal, bc

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 34: System Utilities"
LAB_ID="lab34"
LAB_XP=20950
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

draw_lab_ui() {
    clear
    center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
    center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
    echo; echo
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
    center_text "As a sysadmin, you often need quick access to time, system info, and calculators."
    center_text "This lab covers essential utility commands you'll use daily."
    echo
    center_text "Press Enter to begin..."
    read _

    draw_lab_ui
    echo "  Step 1: Display the current system date and time."
    read -p "  user@server:~$ " cmd1
    echo
    [[ "$cmd1" != "date" ]] && {
        print_error "Incorrect. Use the 'date' command to show current system time."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Wed Oct  1 14:32:08 EDT 2025"
    echo "  "

    echo "  Step 2: Check system uptime."
    read -p "  user@server:~$ " cmd2
    echo
    [[ "$cmd2" != "uptime" ]] && {
        print_error "Incorrect. Use the 'uptime' command to see how long the system has been running."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  14:32:10 up 3 days,  4:28,  2 users,  load average: 0.48, 0.52, 0.47"
    echo "  "

    echo "  Step 3: Show the system’s hostname."
    read -p "  user@server:~$ " cmd3
    echo
    [[ "$cmd3" != "hostname" ]] && {
        print_error "Incorrect. Use the 'hostname' command."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  lab-server"
    echo "  "

    echo "  Step 4: Display the system’s kernel and architecture info."
    read -p "  user@server:~$ " cmd4
    echo
    [[ "$cmd4" != "uname -a" ]] && {
        print_error "Incorrect. Use 'uname -a' to show full system info."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Linux lab-server 5.15.0-89-generic #99-Ubuntu SMP Fri Sep  6 12:34:56 UTC 2025 x86_64 GNU/Linux"
    echo "  "

    echo "  Step 5: View the current month's calendar."
    read -p "  user@server:~$ " cmd5
    echo
    [[ "$cmd5" != "cal" ]] && {
        print_error "Incorrect. Use 'cal' to display a calendar."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  October 2025"
    echo "  Su Mo Tu We Th Fr Sa"
    echo "            1  2  3  4"
    echo "   5  6  7  8  9 10 11"
    echo "  12 13 14 15 16 17 18"
    echo "  19 20 21 22 23 24 25"
    echo "  26 27 28 29 30 31"
    echo "  "

    echo "  Step 6: Use bc as a simple calculator to solve: (8 + 2) * 5"
    read -p "  user@server:~$ " cmd6
    echo
    if [[ "$cmd6" != "echo '(8 + 2) * 5' | bc" ]]; then
        print_error "Incorrect. Use: echo '(8 + 2) * 5' | bc"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  50"
    echo "  "

    print_success "Well done! You’ve practiced key system utility tools."
    print_info "You earned $LAB_XP XP for completing this lab!"
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
