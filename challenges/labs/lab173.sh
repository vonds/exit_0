#!/bin/bash
# Lab 173: systemd Targets + Boot-Time Recovery (RHCSA High-Signal)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 173: Systemd Targets And Boot Recovery"
LAB_ID="lab173"
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
    center_text "System boots into rescue because a critical unit failed."
    center_text "Recover service health, restore normal boot target, and validate."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Show the current default target."
    read -p "  lab@lab173:~$ " cmd1
    echo
    if [[ "$cmd1" != "systemctl get-default" ]]; then
        print_error "Incorrect. Try again. (Use systemctl get-default)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  rescue.target"
    echo

    echo "  Step 2: List failed units."
    read -p "  lab@lab173:~$ " cmd2
    echo
    if [[ "$cmd2" != "systemctl --failed" ]]; then
        print_error "Incorrect. Try again. (Use systemctl --failed)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  UNIT                 LOAD   ACTIVE SUB    DESCRIPTION"
    echo "  webapp.service       loaded failed failed Internal Web Application"
    echo
    echo "  LOAD   = Reflects whether the unit definition was properly loaded."
    echo "  ACTIVE = The high-level unit activation state."
    echo "  SUB    = The low-level unit activation state."
    echo

    echo "  Step 3: Inspect the failure status of webapp.service."
    read -p "  lab@lab173:~$ " cmd3
    echo
    if [[ "$cmd3" != "systemctl status webapp.service" ]]; then
        print_error "Incorrect. Try again. (Use systemctl status webapp.service)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  ● webapp.service - Internal Web Application"
    echo "     Loaded: loaded (/usr/lib/systemd/system/webapp.service; enabled)"
    echo "     Active: failed (Result: exit-code)"
    echo "     Process: ExecStart=/usr/bin/webapp (code=exited, status=1/FAILURE)"
    echo

    echo "  Step 4: View recent logs and identify why it failed."
    read -p "  lab@lab173:~$ " cmd4
    echo
    if [[ "$cmd4" != "journalctl -u webapp.service -n 30" ]]; then
        print_error "Incorrect. Try again. (Use journalctl -u webapp.service -n 30)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  webapp[982]: ERROR: Config file missing: /etc/webapp/webapp.conf"
    echo "  systemd[1]: webapp.service: Main process exited, code=exited, status=1/FAILURE"
    echo

    echo "  Step 5: Create the missing config directory and config file."
    read -p "  lab@lab173:~$ " cmd5
    echo
    if [[ "$cmd5" != "mkdir -p /etc/webapp && touch /etc/webapp/webapp.conf" ]]; then
        print_error "Incorrect. Try again. (Use mkdir -p /etc/webapp && touch /etc/webapp/webapp.conf)"
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Step 6: Restart the service and confirm it's active."
    read -p "  lab@lab173:~$ " cmd6
    echo
    if [[ "$cmd6" != "systemctl restart webapp.service" ]]; then
        print_error "Incorrect. Try again. (Use systemctl restart webapp.service)"
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Step 7: Verify webapp.service is running."
    read -p "  lab@lab173:~$ " cmd7
    echo
    if [[ "$cmd7" != "systemctl is-active webapp.service" ]]; then
        print_error "Incorrect. Try again. (Use systemctl is-active webapp.service)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  active"
    echo

    echo "  Step 8: Reset failed state so units no longer appear failed."
    read -p "  lab@lab173:~$ " cmd8
    echo
    if [[ "$cmd8" != "systemctl reset-failed" ]]; then
        print_error "Incorrect. Try again. (Use systemctl reset-failed)"
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Step 9: Set the default target back to multi-user."
    read -p "  lab@lab173:~$ " cmd9
    echo
    if [[ "$cmd9" != "systemctl set-default multi-user.target" ]]; then
        print_error "Incorrect. Try again. (Use systemctl set-default multi-user.target)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Removed /etc/systemd/system/default.target."
    echo "  Created symlink /etc/systemd/system/default.target → /usr/lib/systemd/system/multi-user.target."
    echo

    echo "  Step 10: Switch to the multi-user target now (without reboot)."
    read -p "  lab@lab173:~$ " cmd10
    echo
    if [[ "$cmd10" != "systemctl isolate multi-user.target" ]]; then
        print_error "Incorrect. Try again. (Use systemctl isolate multi-user.target)"
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Step 11: Confirm the current default target is multi-user.target."
    read -p "  lab@lab173:~$ " cmd11
    echo
    if [[ "$cmd11" != "systemctl get-default" ]]; then
        print_error "Incorrect. Try again. (Use systemctl get-default)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  multi-user.target"
    echo

    echo "  Step 12: Confirm webapp.service is enabled (will start at boot)."
    read -p "  lab@lab173:~$ " cmd12
    echo
    if [[ "$cmd12" != "systemctl is-enabled webapp.service" ]]; then
        print_error "Incorrect. Try again. (Use systemctl is-enabled webapp.service)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  enabled"
    echo

    print_success "Nice work! You recovered from rescue-mode conditions and restored normal boot."
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