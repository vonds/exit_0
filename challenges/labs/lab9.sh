#!/bin/bash

# Lab 9: Diagnose and Manage a Faulty Service (Systemd)

# Dynamically locate root directory and source core scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 9: Diagnose and Manage a Faulty Service (Systemd)"
LAB_ID="lab9"
LAB_XP=2948
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
    center_text "The nginx.service is failing to start on boot."
    center_text "You must investigate the cause, fix it, and ensure it"
    center_text "runs now and on future boots."
    echo
    center_text "Press Enter to begin the lab..."
    read _
    draw_lab_ui

    # Step 1: Initial service status check
    echo "  Step 1: What command would you use to check the status of nginx?"
    read -p "  lab@lpic-lab9:~$ " cmd0
    echo

    if [[ "$cmd0" != "systemctl status nginx" ]]; then
        print_error "Incorrect. Hint: Use systemctl with 'status' to check services."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  ● nginx.service - A high performance web server"
    echo "     Loaded: loaded (/lib/systemd/system/nginx.service; enabled)"
    echo "     Active: failed (Result: exit-code) since ..."
    echo "     Docs: man:nginx(8)"
    echo "     Process: 1356 ExecStart=/usr/sbin/nginx -g 'daemon on;' (code=exited, status=1/FAILURE)"
    echo

    # Step 2: View detailed logs
    echo "  Step 2: What command would give more detailed log output for nginx?"
    read -p "  lab@lpic-lab9:~$ " cmd1
    echo

    if [[ "$cmd1" != "journalctl -xeu nginx" ]]; then
        print_error "Incorrect. Hint: Use journalctl with -xeu for detailed service logs."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Jul 18 12:43:01 nginx[1356]: nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)"
    echo "  Jul 18 12:43:01 systemd[1]: nginx.service: Failed with result 'exit-code'."
    echo

    # Step 3: Restart nginx
    echo "  Step 3: You stop the conflicting service. What command restarts nginx?"
    read -p "  lab@lpic-lab9:~$ " cmd2
    echo

    if [[ "$cmd2" != "sudo systemctl restart nginx" ]]; then
        print_error "Incorrect. Hint: Use systemctl to restart the service."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    # Step 4: Verify nginx is running
    echo "  Step 4: What command verifies that nginx is now running?"
    read -p "  lab@lpic-lab9:~$ " cmd3
    echo

    if [[ "$cmd3" != "systemctl status nginx" ]]; then
        print_error "Incorrect. Hint: You've already used it earlier."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  ● nginx.service - A high performance web server"
    echo "     Loaded: loaded (/lib/systemd/system/nginx.service; enabled)"
    echo "     Active: active (running) since ..."
    echo

    # Step 5: Enable nginx on boot
    echo "  Step 5: What command ensures nginx starts on boot?"
    read -p "  lab@lpic-lab9:~$ " cmd4
    echo

    if [[ "$cmd4" != "sudo systemctl enable nginx" ]]; then
        print_error "Incorrect. Hint: Use systemctl to manage boot behavior."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Created symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /lib/systemd/system/nginx.service"
    echo

    print_success "Great job!"
    print_info "You diagnosed the cause of the service failure, fixed the port conflict,"
    print_info "restarted nginx, confirmed it was running, and set it to start on boot."
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
sg