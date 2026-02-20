#!/bin/bash

# Lab 41: Job Control - jobs, fg, bg, and kill

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 41: Job Control - jobs, fg, bg, kill"
LAB_ID="lab41"
LAB_XP=23250
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
    center_text "You are multitasking in the shell and need to manage background processes."
    center_text "Use job control tools to switch between and control running tasks."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Start a background job called 'sleep 1000'."
    read -p "  lab@lpic-lab41:~\$ " cmd1
    echo
    [[ "$cmd1" != "sleep 1000 &" ]] && {
        print_error "Incorrect. Use: sleep 1000 &"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  [1] 1843"
    echo

    echo "  Step 2: List background and suspended jobs."
    read -p "  lab@lpic-lab41:~\$ " cmd2
    echo
    [[ "$cmd2" != "jobs" ]] && {
        print_error "Incorrect. Use: jobs"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  [1]+  Running                 sleep 1000 &"
    echo

    echo "  Step 3: Bring the background job to the foreground."
    read -p "  lab@lpic-lab41:~\$ " cmd3
    echo
    [[ "$cmd3" != "fg %1" && "$cmd3" != "fg" ]] && {
        print_error "Incorrect. Use: fg %1 (or just fg if it's the only job)"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  sleep 1000"
    echo "  ^Z"
    echo "  [1]+  Stopped                 sleep 1000"
    echo

    echo "  Step 4: Resume the job in the background."
    read -p "  lab@lpic-lab41:~\$ " cmd4
    echo
    [[ "$cmd4" != "bg %1" && "$cmd4" != "bg" ]] && {
        print_error "Incorrect. Use: bg %1"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  [1]+ sleep 1000 &"
    echo

    echo "  Step 5: Kill the background job using its PID (use 1843)."
    read -p "  lab@lpic-lab41:~\$ " cmd5
    echo
    [[ "$cmd5" != "kill 1843" && "$cmd5" != "kill -15 1843" ]] && {
        print_error "Incorrect. Use: kill 1843 or kill -15 1843"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  [1]+  Terminated              sleep 1000"
    echo

    print_success "Well done!"
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
