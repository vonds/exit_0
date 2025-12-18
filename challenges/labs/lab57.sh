#!/bin/bash

# Lab 57: Working with tmux Sessions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 57: tmux Command"
LAB_ID="lab57"
LAB_XP=15000
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
    center_text "You're managing multiple long-running processes."
    center_text "To keep your sessions organized and accessible remotely,"
    center_text "you decide to use tmux."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Start a new tmux session called 'monitor'."
    read -p "  lab@lpic-lab57:~$ " cmd1
    echo
    [[ "$cmd1" != "tmux new -s monitor" ]] && {
        print_error "Incorrect. Use: tmux new -s monitor"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  tmux session 'monitor' started."
    echo

    echo "  Step 2: Detach from the tmux session."
    read -p "  (Inside tmux) Press the correct key sequence: " cmd2
    echo
    [[ "$cmd2" != "Ctrl+b d" ]] && {
        print_error "Incorrect. Use: Ctrl+b followed by d"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Detached from 'monitor' session."
    echo

    echo "  Step 3: List all tmux sessions."
    read -p "  lab@lpic-lab57:~$ " cmd3
    echo
    [[ "$cmd3" != "tmux ls" && "$cmd3" != "tmux list-sessions" ]] && {
        print_error "Incorrect. Use: tmux ls or tmux list-sessions"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  monitor: 1 windows (created Tue Jul 23 14:00:00 2025) [80x24]"
    echo

    echo "  Step 4: Reattach to the 'monitor' session."
    read -p "  lab@lpic-lab57:~$ " cmd4
    echo
    [[ "$cmd4" != "tmux attach -t monitor" ]] && {
        print_error "Incorrect. Use: tmux attach -t monitor"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Reattached to 'monitor' session."
    echo

    echo "  Step 5: Create a new window inside tmux."
    read -p "  (Inside tmux) Press the correct key sequence: " cmd5
    echo
    [[ "$cmd5" != "Ctrl+b c" ]] && {
        print_error "Incorrect. Use: Ctrl+b followed by c"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  New tmux window created."
    echo

    echo "  Step 6: Rename the tmux window to 'logs'."
    read -p "  (Inside tmux) Press the correct key sequence: " cmd6
    echo
    [[ "$cmd6" != "Ctrl+b ," ]] && {
        print_error "Incorrect. Use: Ctrl+b followed by ,"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Window renamed to 'logs'."
    echo

    echo "  Step 7: Kill the tmux session."
    read -p "  lab@lpic-lab57:~$ " cmd7
    echo
    [[ "$cmd7" != "tmux kill-session -t logs" ]] && {
        print_error "Incorrect. Use: tmux kill-session -t logs"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Session 'monitor' terminated."
    echo

    print_success "Great work!"
    print_info "You earned $LAB_XP XP for mastering tmux basics."
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
