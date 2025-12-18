#!/bin/bash

# Lab 35: Processes, Jobs, and Scheduling

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 35: Processes, Jobs, and Scheduling"
LAB_ID="lab35"
LAB_XP=27730
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
    center_text "A developer reports that a long-running job is freezing up the dev server."
    center_text "Investigate processes, manage background/foreground jobs, and schedule cleanup tasks."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Display all active processes sorted by memory usage."
    read -p "  lab@dev-node:~$ " cmd1
    echo
    [[ "$cmd1" != "ps -eo pid,user,%mem,comm --sort=-%mem" ]] && {
        print_error "Use: ps -eo pid,user,%mem,comm --sort=-%mem"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  PID   USER     %MEM COMMAND"
    echo "  2387  alice    13.2 code"
    echo "  2194  alice     9.8 firefox"
    echo "  2381  dev       6.9 python3"
    echo

    echo "  Step 2: Start the data job in the background."
    read -p "  lab@dev-node:~$ " cmd2
    echo
    [[ "$cmd2" != "python3 data_job.py &" ]] && {
        print_error "Use: python3 data_job.py &"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  [1] 2381"
    echo

    echo "  Step 3: List all background jobs."
    read -p "  lab@dev-node:~$ " cmd3
    echo
    [[ "$cmd3" != "jobs" ]] && {
        print_error "Use: jobs"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  [1]+  Running                 python3 data_job.py &"
    echo

    echo "  Step 4: Bring the job to the foreground (then suspend it with Ctrl+Z)."
    read -p "  lab@dev-node:~$ " cmd4
    echo
    [[ "$cmd4" != "fg %1" && "$cmd4" != "fg" ]] && {
        print_error "Use: fg %1"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  python3 data_job.py"
    echo "  [1]+  Stopped                 python3 data_job.py"
    echo

    echo "  Step 5: Kill the stuck job with SIGTERM."
    read -p "  lab@dev-node:~$ " cmd5
    echo
    if [[ "$cmd5" != "kill %1" && "$cmd5" != "kill -15 %1" && "$cmd5" != "kill 2381" && "$cmd5" != "kill -15 2381" ]]; then
        print_error "Use: kill %1   (or: kill -15 2381)"
        read -p "Press Enter to try again..." _
        continue
    fi
    # (kill prints no output on success)
    echo

    echo "  Step 6: Schedule a cleanup script to run once in 2 minutes."
    read -p "  lab@dev-node:~$ " cmd6
    echo
    [[ "$cmd6" != "echo '/usr/local/bin/cleanup.sh' | at now + 2 minutes" ]] && {
        print_error "Use: echo '/usr/local/bin/cleanup.sh' | at now + 2 minutes"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  job 4 at Sat Jul 20 21:59:00 2025"
    echo

    echo "  Step 7: Create a cron job to run 'monitor.sh' every day at midnight."
    read -p "  lab@dev-node:~$ " cmd7
    echo
    if [[ "$cmd7" != "(crontab -l; echo '0 0 * * * /usr/local/bin/monitor.sh') | crontab -" ]]; then
        print_error "Use: (crontab -l; echo '0 0 * * * /usr/local/bin/monitor.sh') | crontab -"
        read -p "Press Enter to try again..." _
        continue
    fi
    # (crontab - accepts the new table silently)
    echo

    print_success "Nice work! You managed jobs and processes accurately."
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
