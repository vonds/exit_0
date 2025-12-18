#!/bin/bash

# Lab 86: Configuring an rsyslog Client for Remote Logging

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 86: Configuring an rsyslog Client for Remote Logging"
LAB_ID="lab86"
LAB_XP=3750
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
    center_text "Scenario: Your organization now has a central rsyslog server"
    center_text "listening on 192.168.1.10:514. Your task is to configure this"
    center_text "host as an rsyslog *client* so that local logs are forwarded"
    center_text "to the central logging server."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Install the rsyslog package on this client system."
    read -p "  lab@lpic-lab86:~$ " cmd1
    echo
    if [[ "$cmd1" != "sudo apt install rsyslog -y" && \
          "$cmd1" != "sudo dnf install rsyslog -y" && \
          "$cmd1" != "sudo pacman -S rsyslog" ]]; then
        print_error "Incorrect. Install rsyslog using apt, dnf, or pacman."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Reading package lists... Done"
    echo "  Building dependency tree... Done"
    echo "  Reading state information... Done"
    echo "  rsyslog is already the newest version (simulated)."
    echo "  0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded."
    echo

    echo "  Step 2: Configure rsyslog to forward all logs to the central server"
    echo "          at 192.168.1.10 on UDP port 514."
    read -p "  lab@lpic-lab86:~$ " cmd2
    echo
    if [[ "$cmd2" != "sudo nano /etc/rsyslog.d/remote.conf" && \
          "$cmd2" != "sudo vim /etc/rsyslog.d/remote.conf" ]]; then
        print_error "Incorrect. Open /etc/rsyslog.d/remote.conf with nano or vim."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Editing /etc/rsyslog.d/remote.conf..."
    echo "  (Simulated content written):"
    echo "    *.*    @192.168.1.10:514"
    echo "  File saved."
    echo

    echo "  Step 3: Restart the rsyslog service to apply the new client configuration."
    read -p "  lab@lpic-lab86:~$ " cmd3
    echo
    if [[ "$cmd3" != "sudo systemctl restart rsyslog" ]]; then
        print_error "Incorrect. Use: sudo systemctl restart rsyslog"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  [  OK  ] Restarted rsyslog.service (simulated)."
    echo

    echo "  Step 4: Generate a test log message to be forwarded to the central server."
    read -p "  lab@lpic-lab86:~$ " cmd4
    echo
    if [[ "$cmd4" != "logger -t remote-test 'Test message to central rsyslog server'" ]]; then
        print_error "Incorrect. Use: logger -t remote-test 'Test message to central rsyslog server'"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Test log message generated with tag 'remote-test'."
    echo

    echo "  Step 5: Verify that rsyslog processed the test message locally."
    read -p "  lab@lpic-lab86:~$ " cmd5
    echo
    if [[ "$cmd5" != "sudo journalctl -u rsyslog | tail -n 10" ]]; then
        print_error "Incorrect. Use: sudo journalctl -u rsyslog | tail -n 10"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  ● rsyslog.service - System Logging Service"
    echo "       Loaded: loaded (/lib/systemd/system/rsyslog.service; enabled; vendor preset: enabled)"
    echo "       Active: active (running) since Fri 2025-11-28 10:15:42 EST; 2min ago"
    echo "     Main PID: 1023 (rsyslogd)"
    echo "        Tasks: 3 (limit: 1123)"
    echo "       Memory: 5.2M"
    echo "          CPU: 120ms"
    echo "       CGroup: /system.slice/rsyslog.service"
    echo
    echo "  Nov 28 10:17:35 labhost rsyslogd[1023]: [origin software=\"rsyslogd\"] start"
    echo "  Nov 28 10:17:40 labhost remote-test[1456]: Test message to central rsyslog server"
    echo "  (Simulated) This client is now forwarding logs to 192.168.1.10:514."
    echo

    print_success "Lab complete."
    print_info "You earned $LAB_XP XP for completing this lab."
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
