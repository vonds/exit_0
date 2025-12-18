#!/bin/bash

# Lab 158: at Command Job Scheduling (10 questions, realistic outputs)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 158: at Command Job Scheduling"
LAB_ID="lab158"
LAB_XP=20000
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
    center_text "Scenario: You need to schedule one-time jobs for system maintenance."
    center_text "Your task is to use the at suite to submit, inspect, and remove jobs."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Schedule a job to run 'date' at 3:30 PM today."
    echo "          Hint: pipe the command into 'at' with the specified time."
    read -p "  lab@lpic-lab158:~$ " cmd1
    echo
    [[ "$cmd1" != "echo date | at 3:30 PM" ]] && {
        print_error "Incorrect. Pipe the command into 'at' with the requested time expression."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  job 5 at Sun Sep 14 15:30:00 2025"
    echo

    echo "  Step 2: Schedule a job to run '/home/satoshi/backup.sh' at midnight."
    echo "          Hint: provide the absolute path and a valid 'at' time keyword."
    read -p "  lab@lpic-lab158:~$ " cmd2
    echo
    [[ "$cmd2" != "echo /home/satoshi/backup.sh | at midnight" ]] && {
        print_error "Incorrect. Use a pipeline and a recognized 'at' time keyword."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  job 6 at Mon Sep 15 00:00:00 2025"
    echo

    echo "  Step 3: Schedule a job to run 'reboot' at 6:00 AM tomorrow."
    echo "          Hint: include the relative day in the time expression."
    read -p "  lab@lpic-lab158:~$ " cmd3
    echo
    [[ "$cmd3" != "echo reboot | at 6:00 AM tomorrow" ]] && {
        print_error "Incorrect. Combine the time with a relative day like 'tomorrow'."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  job 7 at Mon Sep 15 06:00:00 2025"
    echo

    echo "  Step 4: List all pending jobs in the at queue."
    echo "          Hint: use the command that displays scheduled 'at' jobs."
    read -p "  lab@lpic-lab158:~$ " cmd4
    echo
    [[ "$cmd4" != "atq" ]] && {
        print_error "Incorrect. Use the queue viewer for the 'at' subsystem."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  5  Sun Sep 14 15:30:00 2025 a lab"
    echo "  6  Mon Sep 15 00:00:00 2025 a lab"
    echo "  7  Mon Sep 15 06:00:00 2025 a lab"
    echo

    echo "  Step 5: Remove the job with ID 6 from the queue."
    echo "          Hint: remove by numeric job ID."
    read -p "  lab@lpic-lab158:~$ " cmd5
    echo
    [[ "$cmd5" != "atrm 6" ]] && {
        print_error "Incorrect. Use the removal command with the target job ID."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Job 6 removed from the at queue."
    echo

    echo "  Step 6: Submit a job that echoes 'Hello' tomorrow at noon using a here-string."
    echo "          Hint: send the command directly to 'at' using a here-string (<<<)."
    read -p "  lab@lpic-lab158:~$ " cmd6
    echo
    [[ "$cmd6" != "at noon tomorrow <<< 'echo Hello'" ]] && {
        print_error "Incorrect. Use a here-string with the requested time expression."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  job 8 at Mon Sep 15 12:00:00 2025"
    echo

    echo "  Step 7: View the contents of job 5 to see what will be executed."
    echo "          Hint: print the queued script for a given job ID."
    read -p "  lab@lpic-lab158:~$ " cmd7
    echo
    [[ "$cmd7" != "at -c 5" ]] && {
        print_error "Incorrect. Show the saved job content for the specified ID."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  #!/bin/sh"
    echo "  # atrun uid=1001 gid=1001"
    echo "  date"
    echo

    echo "  Step 8: Schedule 'uptime' to run in 10 minutes."
    echo "          Hint: use a relative time format like 'now + N minutes'."
    read -p "  lab@lpic-lab158:~$ " cmd8
    echo
    [[ "$cmd8" != "echo uptime | at now + 10 minutes" ]] && {
        print_error "Incorrect. Use 'now + <number> minutes' with a pipeline."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  job 9 at Sun Sep 14 19:12:00 2025"
    echo

    echo "  Step 9: Check the manual for 'at' to learn how to remove jobs."
    echo "          Hint: open the primary manual page for the 'at' suite."
    read -p "  lab@lpic-lab158:~$ " cmd9
    echo
    [[ "$cmd9" != "man at" ]] && {
        print_error "Incorrect. Open the manual for the 'at' commands."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  The 'atrm' command is used to remove jobs from the at queue."
    echo

    echo "  Step 10: Remove job 7 and immediately list remaining jobs in one command."
    echo "           Hint: chain the removal and listing so the second runs only if the first succeeds."
    read -p "  lab@lpic-lab158:~$ " cmd10
    echo
    [[ "$cmd10" != "atrm 7 && atq" ]] && {
        print_error "Incorrect. Chain the removal and queue listing with a conditional operator."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  5  Sun Sep 14 15:30:00 2025 a lab"
    echo "  8  Mon Sep 15 12:00:00 2025 a lab"
    echo "  9  Sun Sep 14 19:12:00 2025 a lab"
    echo

    print_success "Excellent work!"
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
