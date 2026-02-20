#!/bin/bash

# Lab 13: Log Management and Troubleshooting with journalctl

# Dynamically locate root directory and source core scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 13: Log Management and Troubleshooting with journalctl"
LAB_ID="lab13"
LAB_XP=3177
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
    center_text "A user reports that cron jobs are not being executed properly."
    center_text "Your task: inspect service logs, filter errors, and identify where"
    center_text "persistent logs are stored and how rotation works."
    echo
    center_text "Press Enter to begin the lab..."
    read _
    draw_lab_ui

    # Step 1: Make 'journalctl -u cron' interactive
    echo "  Step 1: Show logs for the cron service (unit). What command do you run?"
    read -p "  lab@lpic-lab13:~$ " cmd1
    echo

    if [[ "$cmd1" != "journalctl -u cron" && "$cmd1" != "journalctl -u cron.service" && "$cmd1" != "journalctl -u crond" && "$cmd1" != "journalctl -u crond.service" ]]; then
        print_error "Incorrect. Hint: Use journalctl with -u on the cron/crond unit (e.g., 'journalctl -u cron')."
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Jul 18 15:45:01 lab systemd[1]: Starting Regular background program processing daemon..."
    echo "  Jul 18 15:45:01 lab cron[891]: (root) CMD (/usr/local/bin/daily-report.sh)"
    echo "  Jul 18 15:45:01 lab systemd[1]: Started Regular background program processing daemon."
    echo

    # Step 2: Most recent cron logs with explanations/priorities
    echo "  Step 2: Show the most recent cron log messages with extra context and explanations."
    read -p "  lab@lpic-lab13:~$ " cmd2
    echo

    if [[ "$cmd2" != "journalctl -xeu cron" && "$cmd2" != "journalctl -xeu cron.service" && "$cmd2" != "journalctl -xeu crond" && "$cmd2" != "journalctl -xeu crond.service" ]]; then
        print_error "Incorrect. Combine -x (explain), -e (end/recent), and -u <unit> (e.g., 'journalctl -xeu cron')."
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Jul 18 16:00:01 lab CRON[1023]: (lab) CMD (/usr/local/bin/backup.sh)"
    echo "  Jul 18 16:00:01 lab CRON[1023]: pam_unix(cron:session): session opened for user lab by (uid=0)"
    echo "  Jul 18 16:00:01 lab CRON[1023]: pam_unix(cron:session): session closed for user lab"
    echo

    # Step 3: Filter logs for failures
    echo "  Step 3: Filter system logs for failures. Show one command that works."
    read -p "  lab@lpic-lab13:~$ " cmd3
    echo

    if [[ "$cmd3" != "journalctl | grep -i fail" && "$cmd3" != "journalctl -p err" && "$cmd3" != "journalctl -p err..alert" && "$cmd3" != "journalctl -p err -b" ]]; then
        print_error "Incorrect. Try 'journalctl | grep -i fail' or use a priority filter like 'journalctl -p err'."
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Jul 18 15:20:43 lab sshd[572]: Failed password for invalid user guest from 10.0.0.23 port 53218 ssh2"
    echo

    # Step 4: View persistent logs with rsyslog
    echo "  Step 4: Which command displays the contents of /var/log/syslog?"
    read -p "  lab@lpic-lab13:~$ " cmd4
    echo

    if [[ "$cmd4" != "cat /var/log/syslog" && "$cmd4" != "less /var/log/syslog" && "$cmd4" != "more /var/log/syslog" && "$cmd4" != "tail /var/log/syslog" ]]; then
        print_error "Incorrect. Try using cat, less, more, or tail on /var/log/syslog."
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Jul 18 16:10:01 lab CRON[1201]: (lab) CMD (/usr/local/bin/backup.sh)"
    echo "  Jul 18 16:10:01 lab CRON[1201]: pam_unix(cron:session): session opened for user lab by (uid=0)"
    echo "  Jul 18 16:10:01 lab CRON[1201]: pam_unix(cron:session): session closed for user lab"
    echo "  Jul 18 16:11:22 lab systemd[1]: Starting Cleanup of Temporary Directories..."
    echo "  Jul 18 16:11:22 lab systemd[1]: Finished Cleanup of Temporary Directories."
    echo "  Jul 18 16:12:44 lab sshd[1350]: Failed password for invalid user admin from 192.168.1.50 port 45822 ssh2"
    echo "  Jul 18 16:12:46 lab sshd[1350]: Connection closed by invalid user admin 192.168.1.50 port 45822 [preauth]"
    echo

    # Step 5: Show last 20 journal entries
    echo "  Step 5: List the last 20 journal entries."
    read -p "  lab@lpic-lab13:~$ " cmd5
    echo

    if [[ "$cmd5" != "journalctl -n 20" && "$cmd5" != "journalctl -n20" ]]; then
        print_error "Incorrect. Use journalctl -n 20 to limit the number of entries."
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  -- Logs begin Mon 2025-07-01 08:00:00 --"
    echo "  Jul 18 16:05:01 lab CRON[1127]: (root) CMD (/usr/local/bin/daily-report.sh)"
    echo "  Jul 18 16:05:02 lab systemd[1]: Starting Rotate log files..."
    echo "  Jul 18 16:05:02 lab systemd[1]: Finished Rotate log files."
    echo "  ... (truncated to 20 lines) ..."
    echo

    # Step 6: Trigger log rotation
    echo "  Step 6: Which command rotates and compresses old log files?"
    read -p "  lab@lpic-lab13:~$ " cmd6
    echo

    if [[ "$cmd6" != "logrotate" && "$cmd6" != "sudo logrotate /etc/logrotate.conf" && "$cmd6" != "sudo logrotate -f /etc/logrotate.conf" ]]; then
        print_error "Incorrect. Use logrotate, typically with /etc/logrotate.conf (optionally -f to force)."
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Log rotation invoked. Check /etc/logrotate.d/ for per-service policies."
    echo

    print_success "Well done!"
    print_info "You inspected cron service logs, pulled recent context with -xeu, filtered failures,"
    print_info "identified persistent rsyslog files, tailed recent journal entries, and triggered rotation."
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

    [[ "$choice" == "2" ]] && exit 0
done
