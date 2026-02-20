#!/bin/bash

# Lab 12: Schedule and Inspect Cron Jobs

# Dynamically locate root directory and source core scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 12: Schedule and Inspect Cron Jobs"
LAB_ID="lab12"
LAB_XP=3220
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"

[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

draw_lab_ui() {
    clear
    center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
    center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
    echo
    echo
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
    center_text "Your task is to schedule regular backups using cron."
    center_text "You'll view the current user's crontab, add a new job,"
    center_text "verify that it's scheduled, and understand cron syntax."
    echo
    center_text "Press Enter to begin the lab..."
    read _
    draw_lab_ui

    # Step 1: View current user's crontab (interactive)
    echo "  Step 1: What command lists the current user's cron jobs?"
    read -p "  lab@lpic-lab12:~$ " cmd1
    echo

    if [[ "$cmd1" != "crontab -l" ]]; then
        print_error "Incorrect. Hint: Use 'crontab -l' to list your cron jobs."
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  crontab: no crontab for vonds"
    echo

    # Step 2: Open crontab editor
    echo "  Step 2: What command opens the current user's crontab for editing?"
    read -p "  lab@lpic-lab12:~$ " cmd2
    echo

    if [[ "$cmd2" != "crontab -e" ]]; then
        print_error "Incorrect. Hint: Use 'crontab -e' to edit your cron jobs."
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Editing crontab using nano. Use Ctrl+O to save, Ctrl+X to exit."
    echo

    # Step 3: Add a daily backup job at 2 AM
    echo "  Step 3: What line would run '/usr/local/bin/backup.sh' every day at 2am?"
    read -p "  (cron entry) > " cmd3
    echo

    if [[ "$cmd3" != "0 2 * * * /usr/local/bin/backup.sh" ]]; then
        print_error "Incorrect. Hint: Format is MIN HOUR DOM MON DOW CMD (e.g., '0 2 * * * /path/script')."
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Cron job scheduled: 0 2 * * * /usr/local/bin/backup.sh"
    echo

    # Step 4: Verify scheduled jobs
    echo "  Step 4: What command lists all cron jobs for the current user?"
    read -p "  lab@lpic-lab12:~$ " cmd4
    echo

    if [[ "$cmd4" != "crontab -l" ]]; then
        print_error "Incorrect. You ran this earlier to view cron jobs."
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  0 2 * * * /usr/local/bin/backup.sh"
    echo

    # Step 5: Identify cron logs location
    echo "  Step 5: What file logs cron job output or errors?"
    read -p "  lab@lpic-lab12:~$ " cmd5
    echo

    if [[ "$cmd5" != "/var/log/syslog" && "$cmd5" != "/var/log/cron.log" ]]; then
        print_error "Incorrect. Hint: Depends on distro. Try '/var/log/syslog' (Debian/Ubuntu) or '/var/log/cron.log' (some systems)."
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Cron job messages logged in $cmd5"
    echo

    # Step 6: Purpose of /etc/cron.d/
    echo "  Step 6: What is the purpose of /etc/cron.d/ ?"
    read -p "  (short answer) > " cmd6
    echo

    if [[ "$cmd6" != "system-wide cron jobs" && "$cmd6" != "define system-wide cron jobs" && "$cmd6" != "system wide cron jobs" ]]; then
        print_error "Incorrect. Hint: It contains root/system-defined scheduled jobs with explicit user fields."
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Correct. /etc/cron.d/ contains system-wide scheduled jobs."
    echo

    print_success "Fantastic work!"
    print_info "You opened and edited your crontab, scheduled a recurring task,"
    print_info "verified its presence, and reviewed where cron logs are stored."
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
    read -p "  > " choice

    if [[ "$choice" == "2" ]]; then
        exit 0
    fi
done
