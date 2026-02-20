#!/bin/bash

# Lab 25: Log Whisperer – Diagnose Log Issues and Manage Rotation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 25"
LAB_ID="lab25"
LAB_XP=21111
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
    center_text "A user reports slow system performance. Logs may hold the clue."
    center_text "You're tasked with inspecting logs, clearing space, and adjusting logrotate."
    echo
    center_text "Press Enter to begin the lab..."
    read _
    draw_lab_ui

    echo "  Step 1: What command shows the latest system logs in real time?"
    read -p "  lab@lpic-lab25:~\$ > " cmd1
    echo

    if [[ "$cmd1" != "journalctl -f" ]]; then
        print_error "Incorrect. You need the follow flag to watch logs live."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  -- Logs begin at Tue 2025-07-01 09:00:00, end at Tue 2025-07-18 14:30:00 --"
    echo "  Jul 18 14:25:00 lpic-lab25 kernel: CPU soft lockup detected..."
    echo

    echo "  Step 2: A log file is 5GB and eating space. How do you view its size and truncate it?"
    read -p "  lab@lpic-lab25:~\$ > " cmd2
    echo

    if [[ "$cmd2" != "du -sh /var/log/syslog && truncate -s 0 /var/log/syslog" ]]; then
        print_error "Incorrect. Combine size check with truncate (not rm!)."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  5.0G    /var/log/syslog"
    echo "  Log file truncated safely."
    echo

    echo "  Step 3: Where is the main configuration file for logrotate?"
    read -p "  lab@lpic-lab25:~\$ > " cmd3
    echo

    if [[ "$cmd3" != "/etc/logrotate.conf" ]]; then
        print_error "Incorrect. Start with the master config before reviewing subfolders."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Found master configuration: /etc/logrotate.conf"
    echo

    echo "  Step 4: What directory contains package-specific logrotate rules?"
    read -p "  lab@lpic-lab25:~\$ > " cmd4
    echo

    if [[ "$cmd4" != "/etc/logrotate.d" ]]; then
        print_error "Incorrect. Check where nginx, apt, and cron store their rotation rules."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Found: /etc/logrotate.d/nginx, cron, apt, etc."
    echo

    echo "  Step 5: How would you manually force logrotate to run immediately?"
    read -p "  lab@lpic-lab25:~\$ > " cmd5
    echo

    if [[ "$cmd5" != "logrotate -f /etc/logrotate.conf" ]]; then
        print_error "Incorrect. Use the -f flag with the main config file."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  logrotate executed manually using config."
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
    read -p "  > " choice

    if [[ "$choice" == "2" ]]; then
        exit 0
    fi
done
