#!/bin/bash

# Lab 19: File Search and Manipulation with find, locate, and xargs

# Dynamically locate root directory and source core scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 19: File Search and Manipulation with find, locate, and xargs"
LAB_ID="lab19"
LAB_XP=4000
389
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
    center_text "You've been asked to find log files older than 7 days,"
    center_text "locate all configuration files on the system, and clean up"
    center_text "temporary files using find, locate, exec, and xargs."
    echo
    center_text "Press Enter to begin the lab..."
    read _
    draw_lab_ui

    echo "  Step 1: What command finds all .log files under /var/log?"
    read -p "  lab@lpic-lab19:~\$ > " cmd1
    echo

    if [[ "$cmd1" != "find /var/log -type f -name '*.log'" ]]; then
        print_error "Incorrect. Hint: Use find with -type f and -name."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  /var/log/syslog.log"
    echo "  /var/log/auth.log"
    echo

    echo "  Step 2: What command finds files older than 7 days in /tmp?"
    read -p "  lab@lpic-lab19:~\$ > " cmd2
    echo

    if [[ "$cmd2" != "find /tmp -type f -mtime +7" ]]; then
        print_error "Incorrect. Hint: Use -mtime +7 for older than 7 days."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  /tmp/debug_old.txt"
    echo "  /tmp/archive_001.tmp"
    echo

    echo "  Step 3: What command deletes those files (older than 7 days) in-place?"
    read -r -p "  lab@lpic-lab19:~\$ > " cmd3
    echo

    if [[ "$cmd3" != "find /tmp -type f -mtime +7 -exec rm {} \;" ]]; then
        print_error "Incorrect. Hint: Use -exec with rm, ending in \;"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Old temp files deleted."
    echo

    echo "  Step 4: What command updates the mlocate database used by locate?"
    read -p "  lab@lpic-lab19:~\$ > " cmd4
    echo

    if [[ "$cmd4" != "sudo updatedb" ]]; then
        print_error "Incorrect. Hint: Use this before using locate on new files."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  mlocate database updated."
    echo

    echo "  Step 5: What command uses locate to list all *.conf files?"
    read -p "  lab@lpic-lab19:~\$ > " cmd5
    echo

    if [[ "$cmd5" != "locate '*.conf'" ]]; then
        print_error "Incorrect. Hint: Use locate with a quoted pattern."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  /etc/ssh/sshd_config"
    echo "  /etc/nginx/nginx.conf"
    echo "  /etc/systemd/journald.conf"
    echo

    print_success "Outstanding!"
    print_info "You searched for logs, cleaned old files, refreshed the locate database,"
    print_info "and explored all config files on the system with ease."
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
