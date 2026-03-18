#!/bin/bash
#
# Lab 172: systemd Overrides + Environment Failures (RHCSA High-Signal)
# Goal: Use drop-in overrides to fix a service without editing the vendor unit file.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 172: Systemd Overrides And Environment Failures"
LAB_ID="lab172"
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
    center_text "A service fails due to a bad environment file and ExecStart override."
    center_text "Fix it using a systemd drop-in override."
    echo
    center_text "Press Enter to begin..."
    read _

    draw_lab_ui
    echo "  Step 1: Check service status for 'webapp.service' and note the failure reason."
    read -p "  lab@lab172:~$ " cmd1
    echo
    if [[ "$cmd1" != "systemctl status webapp.service" ]]; then
        print_error "Incorrect. Use systemctl status webapp.service"
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  ● webapp.service - Internal Web Application"
    echo "     Loaded: loaded (/usr/lib/systemd/system/webapp.service; enabled)"
    echo "    Drop-In: /etc/systemd/system/webapp.service.d"
    echo "             └─ override.conf"
    echo "     Active: failed (Result: exit-code)"
    echo "     Process: ExecStart=/usr/bin/webapp (code=exited, status=1/FAILURE)"
    echo

    echo "  Step 2: View the last 20 log lines for this unit."
    read -p "  lab@lab172:~$ " cmd2
    echo
    if [[ "$cmd2" != "journalctl -u webapp.service -n 20" ]]; then
        print_error "Incorrect. Use journalctl -u webapp.service -n 20"
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  webapp[1142]: ERROR: Missing required env var: WEBAPP_PORT"
    echo "  systemd[1]: webapp.service: Main process exited, code=exited, status=1/FAILURE"
    echo "  systemd[1]: webapp.service: Failed with result 'exit-code'."
    echo

    echo "  Step 3: Show the effective unit configuration (including drop-ins)."
    read -p "  lab@lab172:~$ " cmd3
    echo
    if [[ "$cmd3" != "systemctl cat webapp.service" ]]; then
        print_error "Incorrect. Use systemctl cat webapp.service"
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  # /usr/lib/systemd/system/webapp.service"
    echo "  [Service]"
    echo "  EnvironmentFile=-/etc/sysconfig/webapp"
    echo "  ExecStart=/usr/bin/webapp"
    echo
    echo "  # /etc/systemd/system/webapp.service.d/override.conf"
    echo "  [Service]"
    echo "  EnvironmentFile=/etc/sysconfig/webapp"
    echo

    echo "  Step 4: Create or edit the drop-in override for this service."
    read -p "  lab@lab172:~$ " cmd4
    echo
    if [[ "$cmd4" != "systemctl edit webapp.service" ]]; then
        print_error "Incorrect. Use systemctl edit webapp.service"
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  (Editing /etc/systemd/system/webapp.service.d/override.conf)"
    echo "  Step 5: In the drop-in, set WEBAPP_PORT=8080 using an Environment= line."
    echo "          Then save/quit the editor."
    read -p "  Type the exact line you added: " cmd5
    echo
    if [[ "$cmd5" != "Environment=WEBAPP_PORT=8080" ]]; then
        print_error "Incorrect. Add: Environment=WEBAPP_PORT=8080"
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  Saved override.conf"
    echo

    echo "  Step 6: Reload systemd manager configuration."
    read -p "  lab@lab172:~$ " cmd6
    echo
    if [[ "$cmd6" != "systemctl daemon-reload" ]]; then
        print_error "Incorrect. Use systemctl daemon-reload"
        read -p "Press Enter to retry..." _
        continue
    fi

    echo "  Step 7: Restart the service to apply the override."
    read -p "  lab@lab172:~$ " cmd7
    echo
    if [[ "$cmd7" != "systemctl restart webapp.service" ]]; then
        print_error "Incorrect. Use systemctl restart webapp.service"
        read -p "Press Enter to retry..." _
        continue
    fi

    echo "  Step 8: Verify service is active and show its MainPID."
    read -p "  lab@lab172:~$ " cmd8
    echo
    if [[ "$cmd8" != "systemctl show -p ActiveState -p MainPID webapp.service" ]]; then
        print_error "Incorrect. Use systemctl show -p ActiveState -p MainPID webapp.service"
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  ActiveState=active"
    echo "  MainPID=1288"
    echo

    echo "  Step 9: Confirm which environment settings systemd applied to the unit."
    read -p "  lab@lab172:~$ " cmd9
    echo
    if [[ "$cmd9" != "systemctl show -p Environment webapp.service" ]]; then
        print_error "Incorrect. Use systemctl show -p Environment webapp.service"
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  Environment=WEBAPP_PORT=8080"
    echo

    print_success "Nice work! You recovered the service using a systemd drop-in override."
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