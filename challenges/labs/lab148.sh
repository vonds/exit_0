#!/bin/bash

# Lab 148: Cron Scheduling Basics

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 148: Cron Scheduling Basics"
LAB_ID="lab148"
LAB_XP=15800
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
    center_text "Practice user crontab management: creating/editing entries,"
    center_text "redirecting output, mail delivery, and permissions."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: As an ordinary user, what command opens/creates YOUR crontab?"
    read -p "  lab@lpic-lab148:~$ " cmd1
    echo
    [[ "$cmd1" != "crontab -e" ]] && {
        print_error "Incorrect. Use: crontab -e"
        read -p "Press Enter to try again..." _
        continue
    }
    # typical first-run may prompt for editor; we keep silent here

    echo "  Step 2a: Provide the SINGLE crontab line to run 'date' every Friday at 1:00 PM."
    read -p "  lab@lpic-lab148:~$ " cmd2a
    echo
    if [[ "$cmd2a" != "0 13 * * 5 date" ]]; then
        print_error "Incorrect. Use the 5-field cron format. Example: 0 13 * * 5 date"
        read -p "Press Enter to try again..." _
        continue
    fi
    # no output after adding a line

    echo "  Step 2b: Where will the command's output go by default?"
    read -p "  lab@lpic-lab148:~$ " cmd2b
    echo
    if [[ "$cmd2b" != "/var/mail/username" && "$cmd2b" != "/var/spool/mail/username" ]]; then
        print_error "Tip: On most systems: /var/mail/\$USER  (or)  /var/spool/mail/\$USER"
        read -p "Press Enter to continue..." _
    fi

    echo "  Step 3: Add a crontab line to run '~/foobar.sh' every minute,"
    echo "          redirecting ONLY standard output to '~/output.log' so that ONLY stderr is mailed."
    read -p "  lab@lpic-lab148:~$ " cmd3
    echo
    if [[ "$cmd3" != "*/1 * * * * ./foobar.sh >> output.log" ]]; then
        print_error "Incorrect. Append stdout to a file, leave stderr un-redirected. Example: * * * * * ~/foobar.sh >> ~/output.log"
        read -p "Press Enter to try again..." _
        continue
    fi
    # no output on success

    echo "  Step 4a: Edit the previous foobar entry to REMOVE the redirection."
    echo "           (enter the final cron line for foobar.sh only)"
    read -p "  lab@lpic-lab148:~$ " cmd4a
    echo
    if [[ "$cmd4a" != "* * * * * ~/foobar.sh" && \
          "$cmd4a" != "* * * * * /home/username/foobar.sh" ]]; then
        print_error "Incorrect. Example: * * * * * ~/foobar.sh"
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Step 4b: Disable (comment out) the Friday 'date' job you created earlier."
    read -p "  lab@lpic-lab148:~$ " cmd4b
    echo
    if [[ "$cmd4b" != "#00 13 * * 5 date" && "$cmd4b" != "#0 13 * * 5 date" ]]; then
        print_error "Incorrect. Example: # 0 13 * * 5 date"
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Step 5a: How can you send ALL output from scheduled jobs to user 'emma'?"
    read -p "  lab@lpic-lab148:~$ " cmd5a
    echo
    if [[ "$cmd5a" != "MAILTO=emma" && "$cmd5a" != "MAILTO=\"emma\"" ]]; then
        print_error "Incorrect. Use: MAILTO=emma"
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Step 5b: How can you AVOID sending stdout and stderr emails from a job?"
    read -p "  lab@lpic-lab148:~$ " cmd5b
    echo
    if [[ "$cmd5b" != "MAILTO=''" && "$cmd5b" != "MAILTO=" && \
          "$cmd5b" != "* * * * * somecmd >/dev/null 2>&1" ]]; then
        print_error "Examples: MAILTO=\"\"  (or)  * * * * * somecmd >/dev/null 2>&1"
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Step 6: Show the long listing for the crontab binary."
    read -p "  lab@lpic-lab148:~$ " cmd6a
    echo
    [[ "$cmd6a" != "ls -l /usr/bin/crontab" ]] && {
        print_error "Incorrect. Use: ls -l /usr/bin/crontab"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  -rwsr-xr-x 1 root root  123456 Jan  1 12:00 /usr/bin/crontab"
    echo


    print_success "Excellent work!"
    print_info "You earned $LAB_XP XP for completing this lab!"
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
