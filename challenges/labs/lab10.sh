#!/bin/bash

# Lab 10: Manage File Permissions and Ownership

# Dynamically locate root directory and source core scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 10: Manage File Permissions and Ownership"
LAB_ID="lab10"
LAB_XP=3000
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
    center_text "You've received a report that the 'audit.log' file in /var/log"
    center_text "is accessible to users who shouldn't see it. You must inspect the"
    center_text "file permissions, adjust ownership, and restrict access."
    echo
    center_text "Press Enter to begin the lab..."
    read _
    draw_lab_ui

    # Step 1: Inspect current permissions (interactive)
    echo "  Step 1: What command lists permissions for /var/log/audit.log?"
    read -p "  lab@lpic-lab10:~$ " cmd1
    echo

    if [[ "$cmd1" != "ls -l /var/log/audit.log" ]]; then
        print_error "Incorrect. Hint: Use ls -l with the full path to the file."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  -rw-r--r-- 1 root root 4523 Jul 18 14:32 /var/log/audit.log"
    echo

    # Step 2: Remove 'read' from others
    echo "  Step 2: What command would remove 'read' access for others?"
    read -p "  lab@lpic-lab10:~$ " cmd2
    echo

    if [[ "$cmd2" != "chmod o-r /var/log/audit.log" ]]; then
        print_error "Incorrect. Hint: Use chmod to remove 'r' from 'others' (o)."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    # Step 3: Change group owner to 'adm'
    echo "  Step 3: What command changes the group owner to 'adm'?"
    read -p "  lab@lpic-lab10:~$ " cmd3
    echo

    if [[ "$cmd3" != "chgrp adm /var/log/audit.log" ]]; then
        print_error "Incorrect. Hint: Use chgrp to change group ownership."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    # Step 4: Give read-only to group (rw-r-----)
    echo "  Step 4: What command gives read-only access to the group?"
    read -p "  lab@lpic-lab10:~$ " cmd4
    echo

    if [[ "$cmd4" != "chmod 640 /var/log/audit.log" ]]; then
        print_error "Incorrect. Hint: Use numeric mode to set rw-r----- (640)."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    # Step 5: Show current umask
    echo "  Step 5: What command shows the current umask for new files?"
    read -p "  lab@lpic-lab10:~$ " cmd5
    echo

    if [[ "$cmd5" != "umask" ]]; then
        print_error "Incorrect. Hint: Just type the command that shows the default mask."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  0022"
    echo

    # Step 6: Set umask for default 640 files
    echo "  Step 6: What umask would set default perms to 640 for files?"
    read -p "  lab@lpic-lab10:~$ " cmd6
    echo

    if [[ "$cmd6" != "umask 0027" ]]; then
        print_error "Incorrect. Hint: Start from 666 for files; 666 - 027 = 640."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  umask set to 0027"
    echo

    print_success "Great job!"
    print_info "You corrected file permissions, updated group ownership,"
    print_info "set stricter access, and verified the default umask behavior."
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
