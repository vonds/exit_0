#!/bin/bash

# Lab 44: Process Management - bg, fg, nice

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 44: Process Management - bg, fg, nice"
LAB_ID="lab44"
LAB_XP=21425
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
    center_text "You're troubleshooting system responsiveness."
    center_text "You'll manage foreground/background jobs and control process priority."
    echo
    center_text "Press Enter to begin..."
    read _

    draw_lab_ui
    echo "  Step 1: Launch a long-running background job (e.g., sleep 60)."
    read -p "  lab@lpic-lab44:~$ " cmd1
    echo
    [[ "$cmd1" != "sleep 60 &" ]] && {
        print_error "Incorrect. Try: sleep 60 &"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Job [1] 1234 running in background."
    echo

    echo "  Step 2: View background jobs."
    read -p "  lab@lpic-lab44:~$ " cmd2
    echo
    [[ "$cmd2" != "jobs" ]] && {
        print_error "Incorrect. Use: jobs"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  [1]+  Running                 sleep 60 &"
    echo

    echo "  Step 3: Bring the job to foreground."
    read -p "  lab@lpic-lab44:~$ " cmd3
    echo
    [[ "$cmd3" != "fg %1" ]] && {
        print_error "Incorrect. Use: fg %1"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  sleep 60"
    echo
    echo "  (user presses Ctrl+Z to suspend it)"
    echo "  [1]+  Stopped                 sleep 60"
    echo

    echo "  Step 4: Resume it in background."
    read -p "  lab@lpic-lab44:~$ " cmd4
    echo
    [[ "$cmd4" != "bg %1" ]] && {
        print_error "Incorrect. Use: bg %1"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  [1]+ sleep 60 &"
    echo

    echo "  Step 5: Launch a CPU-heavy task with reduced priority."
    read -p "  lab@lpic-lab44:~$ " cmd5
    echo
    [[ "$cmd5" != "nice -n 10 yes > /dev/null &" ]] && {
        print_error "Incorrect. Use: nice -n 10 yes > /dev/null &"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  [2] 1245"
    echo

    print_success "Great work!"
    print_info "You've practiced bg, fg, job control and nice priorities."
    print_info "You earned $LAB_XP XP for this lab!"
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

    echo

done
