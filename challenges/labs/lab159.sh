#!/bin/bash

# Lab 159: atq View Scheduled Jobs

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 159: atq View Scheduled Jobs"
LAB_ID="lab159"
LAB_XP=20000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

record_lab_completion() {
    tmpfile=$(mktemp)
    jq --arg lab "$LAB_ID" '.[$lab] += 1 // 1' "$LAB_TRACK_FILE" > "$tmpfile" && mv "$tmpfile" "$LAB_TRACK_FILE"
}
get_lab_completion_count() {
    jq -r --arg lab "$LAB_ID" '.[$lab] // 0' "$LAB_TRACK_FILE"
}
draw_lab_ui() {
    clear
    center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
    center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
    echo; echo; echo
}

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "List and inspect queued one-time jobs with atq."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: List all scheduled jobs in the queue."
    read -p "  lab@lab159:~$ " cmd1
    echo
    [[ "$cmd1" != "atq" ]] && {
        print_error "Incorrect. Use: atq"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  3  Sun Sep 14 15:30:00 2025 a lab"
    echo "  4  Sun Sep 14 16:00:00 2025 a lab"
    echo

    echo "  Step 2: Interpret the job ID of the first queued job."
    read -p "  lab@lab159:~$ " cmd2
    echo
    [[ "$cmd2" != "3" ]] && {
        print_error "The job ID is the first column (3)."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Correct. Job ID 3 will run at 15:30."
    echo

    echo "  Step 3: Remove job 3 from the queue."
    read -p "  lab@lab159:~$ " cmd3
    echo
    [[ "$cmd3" != "atrm 3" ]] && {
        print_error "Incorrect. Use: atrm 3"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Job 3 removed from the at queue."
    echo

    echo "  Step 4: Verify the queue after removing job 3."
    read -p "  lab@lab159:~$ " cmd4
    echo
    [[ "$cmd4" != "atq" ]] && {
        print_error "Incorrect. Use: atq"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  4  Sun Sep 14 16:00:00 2025 a lab"
    echo

    echo "  Step 5: Show the details of queued job ID 4."
    read -p "  lab@lab159:~$ " cmd5
    echo
    [[ "$cmd5" != "at -c 4" ]] && {
        print_error "Incorrect. Use: at -c 4"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  #!/bin/sh"
    echo "  # atrun uid=1001 gid=1001"
    echo "  # mail lab 0"
    echo "  # job 4 at Sun Sep 14 16:00:00 2025"
    echo "  uptime"
    echo

    echo "  Step 6: Submit a new job 'uptime' for 5:00 PM and show it in atq."
    read -p "  lab@lab159:~$ " cmd6
    echo
    [[ "$cmd6" != "echo uptime | at 5:00 PM" ]] && {
        print_error "Incorrect. Example: echo uptime | at 5:00 PM"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  job 5 at Sun Sep 14 17:00:00 2025"
    echo "  atq output:"
    echo "  4  Sun Sep 14 16:00:00 2025 a lab"
    echo "  5  Sun Sep 14 17:00:00 2025 a lab"
    echo

    echo "  Step 7: Which user column appears at the end of each atq entry?"
    read -p "  lab@lab159:~$ " cmd7
    echo
    [[ "$cmd7" != "lab" ]] && {
        print_error "Incorrect. The user who scheduled the job is shown (lab)."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Correct. User 'lab' scheduled the jobs."
    echo

    echo "  Step 8: Submit a job 'ls /tmp' to run now + 1 hour and confirm in atq."
    read -p "  lab@lab159:~$ " cmd8
    echo
    [[ "$cmd8" != "echo ls /tmp | at now + 1 hour" ]] && {
        print_error "Incorrect. Example: echo ls /tmp | at now + 1 hour"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  job 6 at Sun Sep 14 20:00:00 2025"
    echo "  atq output:"
    echo "  4  Sun Sep 14 16:00:00 2025 a lab"
    echo "  5  Sun Sep 14 17:00:00 2025 a lab"
    echo "  6  Sun Sep 14 20:00:00 2025 a lab"
    echo

    echo "  Step 9: Cancel all queued jobs with a single command."
    read -p "  lab@lab159:~$ " cmd9
    echo
    if [[ ! "$cmd9" =~ ^for\ job\ in\ \$\(atq\ \|\ awk\ \'\{print\ \$1\}\'\)\;\ do\ atrm\ \$job\;\ done$ && "$cmd9" != "atq | awk '{print $1}' | xargs -r atrm" ]]; then
        print_error "Incorrect. Examples: for job in \$(atq | awk '{print \$1}'); do atrm \$job; done   OR   atq | awk '{print \$1}' | xargs -r atrm"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  All jobs removed."
    echo

    echo "  Step 10: Verify the at queue is empty."
    read -p "  lab@lab159:~$ " cmd10
    echo
    [[ "$cmd10" != "atq" ]] && {
        print_error "Incorrect. Use: atq"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (no output – the queue is empty)"
    echo

    print_success "Nice work!"
    print_info "You earned $LAB_XP XP for completing this lab."
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON"); export XP; export LEVEL
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
