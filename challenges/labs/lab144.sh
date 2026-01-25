#!/bin/bash

# Lab 144: RHCSA System Services — journald Persistence + rsyslog Remote Forward + Postfix + Chrony Workflow
# Workflow: confirm journald storage mode and disk use, enable persistent journal storage (via drop-in),
# restart journald, verify persistence, configure rsyslog to forward to a remote collector via TCP,
# restart/verify rsyslog, check Postfix queue, and verify chrony sync state.
# RHCSA Focus: journalctl/journald config, systemctl, rsyslog drop-ins, basic mail queue checks, chronyc.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 144: RHCSA System Services — journald + rsyslog + Postfix + Chrony Workflow"
LAB_ID="lab144"
LAB_XP=29500
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@lab144:~$ "

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
    echo
    echo
}

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Scenario:"
    center_text "Ops needs persistent journald logs for auditing, and rsyslog must forward logs"
    center_text "to a central collector over TCP. You will implement and verify both changes,"
    center_text "then confirm mail queue health and NTP sync state."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui

    # STEP 1: Check current journald disk usage
    echo "  Step 1: Check current systemd journal disk usage."
    read -p "$PROMPT" cmd1
    echo
    if [[ "$cmd1" != "journalctl --disk-usage" && "$cmd1" != "sudo journalctl --disk-usage" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  Archived and active journals take up 144.0M in the file system."
    echo

    # STEP 2: Create journald drop-in for persistence (terminal command)
    echo "  Step 2: Create a journald config drop-in to enable persistent storage."
    echo "          (Edit /etc/systemd/journald.conf.d/10-persistent.conf)"
    read -p "$PROMPT" cmd2
    echo
    if [[ "$cmd2" != "sudo nano /etc/systemd/journald.conf.d/10-persistent.conf" && \
          "$cmd2" != "nano /etc/systemd/journald.conf.d/10-persistent.conf" && \
          "$cmd2" != "sudo vi /etc/systemd/journald.conf.d/10-persistent.conf" && \
          "$cmd2" != "vi /etc/systemd/journald.conf.d/10-persistent.conf" && \
          "$cmd2" != "sudo vim /etc/systemd/journald.conf.d/10-persistent.conf" && \
          "$cmd2" != "vim /etc/systemd/journald.conf.d/10-persistent.conf" ]]; then
        print_error "Incorrect. Use an editor to create the drop-in."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  (File created/edited: /etc/systemd/journald.conf.d/10-persistent.conf)"
    echo "  (Add these lines inside the file:)"
    echo "  [Journal]"
    echo "  Storage=persistent"
    echo

    # STEP 3: Restart journald
    echo "  Step 3: Restart systemd-journald to apply the change."
    read -p "$PROMPT" cmd3
    echo
    if [[ "$cmd3" != "sudo systemctl restart systemd-journald" && "$cmd3" != "systemctl restart systemd-journald" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 4: Verify persistent journal directory exists
    echo "  Step 4: Verify the persistent journal directory exists."
    read -p "$PROMPT" cmd4
    echo
    if [[ "$cmd4" != "ls -ld /var/log/journal" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  drwxr-sr-x. 3 root systemd-journal 4096 Jan 25 07:34 /var/log/journal"
    echo

    # STEP 5: Create rsyslog forwarder drop-in to central collector via TCP
    echo "  Step 5: Create an rsyslog drop-in to forward all logs to 192.0.2.10 over TCP/514."
    echo "          (Edit /etc/rsyslog.d/90-forward.conf)"
    read -p "$PROMPT" cmd5
    echo
    if [[ "$cmd5" != "sudo nano /etc/rsyslog.d/90-forward.conf" && \
          "$cmd5" != "nano /etc/rsyslog.d/90-forward.conf" && \
          "$cmd5" != "sudo vi /etc/rsyslog.d/90-forward.conf" && \
          "$cmd5" != "vi /etc/rsyslog.d/90-forward.conf" && \
          "$cmd5" != "sudo vim /etc/rsyslog.d/90-forward.conf" && \
          "$cmd5" != "vim /etc/rsyslog.d/90-forward.conf" ]]; then
        print_error "Incorrect. Use an editor to create the file."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  (File created/edited: /etc/rsyslog.d/90-forward.conf)"
    echo "  (Add this line inside the file:)"
    echo "  *.* @@192.0.2.10:514"
    echo

    # STEP 6: Validate rsyslog config
    echo "  Step 6: Validate rsyslog configuration syntax."
    read -p "$PROMPT" cmd6
    echo
    if [[ "$cmd6" != "rsyslogd -N1" && "$cmd6" != "sudo rsyslogd -N1" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  rsyslogd: version 8.2310.0, config validation run (level 1), master config /etc/rsyslog.conf"
    echo "  rsyslogd: End of config validation run. Bye."
    echo

    # STEP 7: Restart rsyslog
    echo "  Step 7: Restart rsyslog to apply forwarding."
    read -p "$PROMPT" cmd7
    echo
    if [[ "$cmd7" != "sudo systemctl restart rsyslog" && "$cmd7" != "systemctl restart rsyslog" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 8: Generate a test message and confirm it lands locally
    echo "  Step 8: Generate a test log message (facility local0.notice)."
    read -p "$PROMPT" cmd8
    echo
    if [[ "$cmd8" != "logger -p local0.notice 'RHCSA-LAB144 test: forwarding enabled'" ]]; then
        print_error "Incorrect. Use logger with local0.notice."
        read -p "Press Enter to retry..." _
        continue
    fi

    echo "  Step 9: Confirm the test message appears in /var/log/messages (last 5 lines)."
    read -p "$PROMPT" cmd9
    echo
    if [[ "$cmd9" != "tail -n 5 /var/log/messages" && "$cmd9" != "sudo tail -n 5 /var/log/messages" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  Jan 25 07:36:18 lab144 rsyslogd[1043]: [origin software=\"rsyslogd\" swVersion=\"8.2310.0\" x-pid=\"1043\" x-info=\"https://www.rsyslog.com\"] start"
    echo "  Jan 25 07:36:25 lab144 lab[pts/0]: RHCSA-LAB144 test: forwarding enabled"
    echo

    # STEP 10: Check chrony sync and sources
    echo "  Step 10: Verify NTP sync status with chrony."
    read -p "$PROMPT" cmd10
    echo
    if [[ "$cmd10" != "chronyc tracking" ]]; then
        print_error "Incorrect. Use chronyc tracking."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  Reference ID    : C0A80101 (ntp1.example.com)"
    echo "  Stratum         : 3"
    echo "  Ref time (UTC)  : Sun Jan 25 12:36:11 2026"
    echo "  System time     : 0.000012345 seconds fast of NTP time"
    echo "  Last offset     : -0.000004321 seconds"
    echo "  RMS offset      : 0.000015678 seconds"
    echo "  Frequency       : 15.123 ppm fast"
    echo "  Residual freq   : -0.002 ppm"
    echo "  Skew            : 0.045 ppm"
    echo "  Root delay      : 0.012345 seconds"
    echo "  Root dispersion : 0.001234 seconds"
    echo "  Update interval : 64.0 seconds"
    echo "  Leap status     : Normal"
    echo

    print_success "Nice work!"
    print_info "Workflow completed:"
    print_info "- Enabled persistent journald storage via drop-in and verified /var/log/journal"
    print_info "- Configured rsyslog TCP forwarding via drop-in, validated and restarted the service"
    print_info "- Generated and confirmed a test log message"
    print_info "- Verified chrony sync state using chronyc tracking"
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
