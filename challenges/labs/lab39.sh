#!/bin/bash

# Lab 39: Managing Processes with kill

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 39: Managing Processes with kill"
LAB_ID="lab39"
LAB_XP=29252
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
    center_text "A process is running out of control on your system."
    center_text "You'll need to locate it and use the 'kill' command to stop it safely."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: List processes and identify the rogue script named 'rogue.sh'."
    read -p "  lab@lpic-lab39:~$ " cmd1
    echo
    [[ "$cmd1" != "ps aux | grep rogue.sh" && "$cmd1" != "pgrep -a rogue.sh" ]] && {
        print_error "Incorrect. Use ps aux | grep rogue.sh or pgrep -a rogue.sh to locate the process."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  user     4012  99.0  0.1  50000  3000 pts/0    R    13:24   0:45 bash rogue.sh"
    echo

    echo "  Step 2: Send a SIGTERM (default) signal to the process."
    read -p "  lab@lpic-lab39:~$ " cmd2
    echo
    [[ "$cmd2" != "kill 4012" ]] && {
        print_error "Incorrect. Use: kill 4012"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Process 4012 terminated with SIGTERM."
    echo

    echo "  Step 3: Confirm process is gone."
    read -p "  lab@lpic-lab39:~$ " cmd3
    echo
    [[ "$cmd3" != "ps -p 4012" && "$cmd3" != "pgrep rogue.sh" ]] && {
        print_error "Incorrect. Use ps -p 4012 or pgrep rogue.sh to verify."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  No such process."
    echo

    echo "  Step 4: Start the rogue process again for testing (in the background)."
    read -p "  lab@lpic-lab39:~$ " cmd4
    echo
    if [[ "$cmd4" != "bash rogue.sh &" && "$cmd4" != "./rogue.sh &" ]]; then
        print_error "Incorrect. Start it in the background, e.g.: bash rogue.sh &"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  [1] 4021"
    echo "  user     4021  95.0  0.1  50000  3000 pts/0    R    13:29   0:02 bash rogue.sh"
    echo


    echo "  Step 5: Send a SIGKILL signal to forcefully stop it."
    read -p "  lab@lpic-lab39:~$ " cmd4
    echo
    [[ "$cmd4" != "kill -9 4021" ]] && {
        print_error "Incorrect. Use: kill -9 4021"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Process 4021 killed with SIGKILL."
    echo

    print_success "Well done"
    print_info "You earned $LAB_XP XP for completing this lab."
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON")
    LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
    export XP
    export LEVEL
    record_lab_completion

    completion_count=$(get_lab_completion_count)
    echo
    print_info "You've successfully completed this lab $completion_count time(s)."
    echo
    center_text "Would you like to:"
    center_text "1) Retry this lab"
    center_text "2) Return to Sysadmin Lab Menu"
    echo
    read -p "  > " post_choice

    [[ "$post_choice" == "2" ]] && exit 0

done
