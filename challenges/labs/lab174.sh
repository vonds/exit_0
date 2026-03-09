#!/bin/bash

# Lab 174: systemd Timers — Daily Log Cleanup

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 174: systemd Timers — Daily Log Cleanup"
LAB_ID="lab174"
LAB_XP=50000
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
    center_text "Scenario: Old application logs in /var/log/app-cache are filling disk space."
    center_text "Ops already created a systemd service and timer to clean logs older than 7 days."
    center_text "Your job is to inspect, enable, and verify the timer."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    # --- Step 1: Inspect the timer unit ---
    echo "  Step 1: Inspect the timer unit to confirm schedule and target service."
    read -p "  lab@lab174:~$ " cmd1
    echo
    if [[ "$cmd1" != "systemctl cat app-log-cleanup.timer" ]]; then
        print_error "Incorrect. Try again. (Use: systemctl cat app-log-cleanup.timer)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  [Timer]"
    echo "  OnCalendar=*-*-* 01:30:00"
    echo "  Persistent=true"
    echo "  Unit=app-log-cleanup.service"
    echo

    # --- Step 2: Inspect the service ---
    echo "  Step 2: Inspect the service unit to confirm what command will run."
    read -p "  lab@lab174:~$ " cmd2
    echo
    if [[ "$cmd2" != "systemctl cat app-log-cleanup.service" ]]; then
        print_error "Incorrect. Try again. (Use: systemctl cat app-log-cleanup.service)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  [Service]"
    echo "  Type=oneshot"
    echo "  ExecStart=/usr/bin/find /var/log/app-cache -type f -name '*.log' -mtime +7 -delete"
    echo

    # --- Step 3: Enable and start the timer ---
    echo "  Step 3: Enable and start the timer."
    read -p "  lab@lab174:~$ " cmd3
    echo
    if [[ "$cmd3" != "sudo systemctl enable --now app-log-cleanup.timer" ]]; then
        print_error "Incorrect. Try again. (Use: sudo systemctl enable --now app-log-cleanup.timer)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Created symlink /etc/systemd/system/timers.target.wants/app-log-cleanup.timer."
    echo

    # --- Step 4: Verify timer status ---
    echo "  Step 4: Confirm the timer is active."
    read -p "  lab@lab174:~$ " cmd4
    echo
    if [[ "$cmd4" != "systemctl status app-log-cleanup.timer --no-pager" ]]; then
        print_error "Incorrect. Try again. (Use: systemctl status app-log-cleanup.timer --no-pager)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  ● app-log-cleanup.timer - Daily cleanup of /var/log/app-cache"
    echo "     Active: active (waiting)"
    echo "    Trigger: Fri 2026-03-06 01:30:00 EST"
    echo "   Triggers: ● app-log-cleanup.service"
    echo

    # --- Step 5: List timers ---
    echo "  Step 5: List all timers and confirm the next trigger time."
    read -p "  lab@lab174:~$ " cmd5
    echo
    if [[ "$cmd5" != "systemctl list-timers --all --no-pager" ]]; then
        print_error "Incorrect. Try again. (Use: systemctl list-timers --all --no-pager)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  NEXT                        LEFT        UNIT                     ACTIVATES"
    echo "  Fri 2026-03-06 01:30:00 EST 12h left    app-log-cleanup.timer     app-log-cleanup.service"
    echo

    # --- Step 6: Test run the service ---
    echo "  Step 6: Manually start the service to confirm it works."
    read -p "  lab@lab174:~$ " cmd6
    echo
    if [[ "$cmd6" != "sudo systemctl start app-log-cleanup.service" ]]; then
        print_error "Incorrect. Try again. (Use: sudo systemctl start app-log-cleanup.service)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  (no output)"
    echo

    # --- Step 7: Verify logs ---
    echo "  Step 7: Confirm the cleanup ran successfully."
    read -p "  lab@lab174:~$ " cmd7
    echo
    if [[ "$cmd7" != "journalctl -u app-log-cleanup.service -n 5 --no-pager" ]]; then
        print_error "Incorrect. Try again. (Use: journalctl -u app-log-cleanup.service -n 5 --no-pager)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Mar 05 13:02:11 lab174 systemd[1]: Starting Cleanup old app-cache logs..."
    echo "  Mar 05 13:02:11 lab174 systemd[1]: Finished Cleanup old app-cache logs."
    echo

    print_success "Nice work!"
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