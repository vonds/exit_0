#!/bin/bash

# Lab 148: RHCSA Cron Scheduling Basics — User Crontab Workflow

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 148: RHCSA Cron Scheduling Basics"
LAB_ID="lab148"
LAB_XP=15800
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@lab148:~$ "

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
    echo
    echo
}

accept_cmd() {
    # Accept command either bare or with sudo (first token)
    local input="$1"; shift
    for candidate in "$@"; do
        if [[ "$input" == "$candidate" || "$input" == "sudo $candidate" ]]; then
            return 0
        fi
    done
    return 1
}

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Scenario:"
    center_text "You need to configure user cron jobs correctly, control email output,"
    center_text "and verify the crontab tool's permissions."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui

    # STEP 1: Open user crontab editor
    echo "  Step 1: As an ordinary user, what command opens/creates YOUR crontab?"
    read -p "$PROMPT" cmd1
    echo
    if [[ "$cmd1" != "crontab -e" ]]; then
        print_error "Incorrect. Use: crontab -e"
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  (crontab editor opened)"
    echo

    # STEP 2a: Provide single crontab line (user types line themselves)
    echo "  Step 2: Provide the SINGLE crontab line to run 'date' every Friday at 1:00 PM."
    read -p "$PROMPT" cmd2
    echo
    if [[ "$cmd2" != "0 13 * * 5 date" ]]; then
        print_error "Incorrect. Use: 0 13 * * 5 date"
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 3: stdout redirect only (stderr mailed)
    echo "  Step 3: Add a crontab line to run '~/foobar.sh' every minute,"
    echo "          redirecting ONLY standard output to '~/output.log' so that ONLY stderr is mailed."
    read -p "$PROMPT" cmd3
    echo
    if [[ "$cmd3" != "* * * * * ~/foobar.sh >> ~/output.log" && \
          "$cmd3" != "*/1 * * * * ~/foobar.sh >> ~/output.log" ]]; then
        print_error "Incorrect. Example: * * * * * ~/foobar.sh >> ~/output.log"
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 4a: Remove redirection (final cron line only)
    echo "  Step 4: Edit the previous foobar entry to REMOVE the redirection."
    read -p "$PROMPT" cmd4
    echo
    if [[ "$cmd4" != "* * * * * ~/foobar.sh" && \
          "$cmd4" != "* * * * * /home/username/foobar.sh" ]]; then
        print_error "Incorrect. Example: * * * * * ~/foobar.sh"
        read -p "Press Enter to retry..." _
        continue
    fi


    # STEP 5a: Route mail to emma
    echo "  Step 5: How can you send ALL output from scheduled jobs to user 'emma'?"
    read -p "$PROMPT" cmd5
    echo
    if [[ "$cmd5" != "MAILTO=emma" && "$cmd5" != "MAILTO=\"emma\"" ]]; then
        print_error "Incorrect. Use: MAILTO=emma"
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 6: Verify permissions on crontab binary
    echo "  Step 6: Show the long listing for the crontab binary."
    read -p "$PROMPT" cmd6
    echo
    if [[ "$cmd6" != "ls -l /usr/bin/crontab" ]]; then
        print_error "Incorrect. Use: ls -l /usr/bin/crontab"
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  -rwsr-xr-x 1 root root  123456 Jan  1 12:00 /usr/bin/crontab"
    echo

    print_success "Excellent work!"
    print_info "Workflow completed:"
    print_info "- Opened a user crontab editor (crontab -e)"
    print_info "- Entered correct schedule lines using 5-field cron format"
    print_info "- Controlled mail behavior using redirection and MAILTO"
    print_info "- Verified crontab binary permissions (setuid) with ls -l"
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
