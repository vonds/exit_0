#!/bin/bash
#
# Lab 171: Systemd Service Failure Recovery (RHCSA High-Signal)
# Goal: Diagnose why a service fails and restore operational state.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 171: Systemd Service Failure Recovery"
LAB_ID="lab171"
LAB_XP=20000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

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
    echo; echo; echo
}

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "A production service has failed."
    center_text "Diagnose the failure and restore service availability."
    echo
    center_text "Press Enter to begin..."
    read _

    draw_lab_ui
    echo "  Step 1: Check the status of the failed service 'webapp.service'."
    read -p "  lab@lab171:~$ " cmd1
    echo
    if [[ "$cmd1" != "systemctl status webapp.service" ]]; then
        print_error "Incorrect. Use systemctl status webapp.service"
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  ● webapp.service - Internal Web Application"
    echo "     Loaded: loaded (/etc/systemd/system/webapp.service)"
    echo "     Active: failed (Result: exit-code)"
    echo "     Process: ExecStart=/usr/bin/webap (code=exited, status=203/EXEC)"
    echo

    echo "  Step 2: View recent journal logs for the service."
    read -p "  lab@lab171:~$ " cmd2
    echo
    if [[ "$cmd2" != "journalctl -u webapp.service" ]]; then
        print_error "Incorrect. Use journalctl -u webapp.service"
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  webapp.service: Failed to execute /usr/bin/webap: No such file or directory"
    echo

    echo "  Step 3: Inspect the service unit file."
    read -p "  lab@lab171:~$ " cmd3
    echo
    if [[ "$cmd3" != "systemctl cat webapp.service" ]]; then
        print_error "Incorrect. Use systemctl cat webapp.service"
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  ExecStart=/usr/bin/webap"
    echo

    echo "  Step 4: Edit the unit file to correct the binary path."
    read -p "  lab@lab171:~$ " cmd4
    echo
    if [[ "$cmd4" != "vim /etc/systemd/system/webapp.service" ]]; then
        print_error "Incorrect. Use vi /etc/systemd/system/webapp.service"
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  ExecStart corrected to /usr/bin/webapp"
    echo

    echo "  Step 5: Reload systemd manager configuration."
    read -p "  lab@lab171:~$ " cmd5
    echo
    if [[ "$cmd5" != "systemctl daemon-reload" ]]; then
        print_error "Incorrect. Use systemctl daemon-reload"
        read -p "Press Enter to retry..." _
        continue
    fi

    echo "  Step 6: Start the service."
    read -p "  lab@lab171:~$ " cmd6
    echo
    if [[ "$cmd6" != "systemctl start webapp.service" ]]; then
        print_error "Incorrect. Use systemctl start webapp.service"
        read -p "Press Enter to retry..." _
        continue
    fi

    echo "  Step 7: Verify the service is now running."
    read -p "  lab@lab171:~$ " cmd7
    echo
    if [[ "$cmd7" != "systemctl status webapp.service" ]]; then
        print_error "Incorrect. Use systemctl status webapp.service"
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  Active: active (running)"
    echo

    echo "  Step 8: Enable the service to start at boot."
    read -p "  lab@lab171:~$ " cmd8
    echo
    if [[ "$cmd8" != "systemctl enable webapp.service" ]]; then
        print_error "Incorrect. Use systemctl enable webapp.service"
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  Created symlink for multi-user.target."
    echo

    print_success "Service successfully recovered."
    print_info "You earned $LAB_XP XP."
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON")
    LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
    export XP LEVEL
    record_lab_completion

    completion_count=$(get_lab_completion_count)
    echo
    print_info "You've completed this lab $completion_count time(s)."
    echo
    center_text "1) Retry this lab"
    center_text "2) Return to Sysadmin Lab Menu"
    echo
    read -p "  > " post_choice
    [[ "$post_choice" == "2" ]] && exit 0
done