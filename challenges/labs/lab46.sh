#!/bin/bash

# Lab 46: System Logs Monitor (/var/log)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 46: System Logs Monitor (/var/log)"
LAB_ID="lab46"
LAB_XP=22400
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
    center_text "The web server team reports failed SSH attempts and missing cron outputs."
    center_text "You’ve been tasked with reviewing and investigating system logs under /var/log."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: View general system logs."
    read -p "  lab@logmon01:~\$ " cmd1
    echo
    [[ "$cmd1" != "less /var/log/syslog" && "$cmd1" != "less /var/log/messages" ]] && {
        print_error "Use 'less /var/log/syslog' or 'less /var/log/messages'."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Jul 19 13:45:33 logmon01 systemd[1]: Started Session 22 of user devstudent."
    echo "  Jul 19 13:45:35 logmon01 sshd[1145]: Failed password for invalid user root from 192.168.1.5 port 58233 ssh2"
    echo

    echo "  Step 2: View failed authentication attempts."
    read -p "  lab@logmon01:~\$ " cmd2
    echo
    [[ "$cmd2" != "cat /var/log/auth.log | grep Failed" && "$cmd2" != "grep Failed /var/log/auth.log" ]] && {
        print_error "Use 'grep Failed /var/log/auth.log' to view failed auth attempts."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Jul 19 13:45:35 logmon01 sshd[1145]: Failed password for invalid user root from 192.168.1.5 port 58233 ssh2"
    echo "  Jul 19 13:46:02 logmon01 sshd[1148]: Failed password for devstudent from 10.0.2.15 port 49622 ssh2"
    echo

    echo "  Step 3: Check if cron logs exist."
    read -p "  lab@logmon01:~\$ " cmd3
    echo
    [[ "$cmd3" != "ls /var/log/cron*" ]] && {
        print_error "Expected: ls /var/log/cron*"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  /var/log/cron"
    echo "  /var/log/cron.1"
    echo

    echo "  Step 4: View cron job logs."
    read -p "  lab@logmon01:~\$ " cmd4
    echo
    [[ "$cmd4" != "cat /var/log/cron" ]] && {
        print_error "Use 'cat /var/log/cron' to view cron job output."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Jul 19 12:00:01 logmon01 CRON[1010]: (root) CMD (backup.sh)"
    echo "  Jul 19 12:05:01 logmon01 CRON[1022]: (devstudent) CMD (echo 'Hello from CRON')"
    echo

    echo "  Step 5: Monitor real-time logs from syslog."
    read -p "  lab@logmon01:~\$ " cmd5
    echo
    [[ "$cmd5" != "tail -f /var/log/syslog" && "$cmd5" != "tail -f /var/log/messages" ]] && {
        print_error "Expected: tail -f /var/log/syslog"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Jul 19 14:01:55 logmon01 systemd[1]: Started Session 23 of user root."
    echo "  Jul 19 14:01:57 logmon01 sshd[1222]: Accepted password for root from 192.168.1.5 port 58234 ssh2"
    echo

    echo "  Step 6: Find out how many SSH attempts were made today."
    read -p "  lab@logmon01:~\$ " cmd6
    echo
    [[ "$cmd6" != "grep sshd /var/log/auth.log | wc -l" ]] && {
        print_error "Use 'grep sshd /var/log/auth.log | wc -l'"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  42"
    echo

    print_success "Great job monitoring system logs and tracing issues."
    print_info "You earned $LAB_XP XP for completing this log analysis lab."
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
