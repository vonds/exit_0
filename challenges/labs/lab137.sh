#!/bin/bash

# Lab 137: RHCSA System Services — Time Sync + Logging Workflow (chrony + journald + rsyslog)
# Workflow: verify time sync state, apply a safe chrony config change, restart/verify service,
# inspect journald storage, query recent logs, and validate rsyslog is receiving messages.
# RHCSA Focus: systemctl, timedatectl, chronyc, journalctl, rsyslog verification, realistic ops flow.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 137: RHCSA System Services — Time Sync + Logging Workflow"
LAB_ID="lab137"
LAB_XP=29500
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@lab137:~$ "

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
    center_text "Scenario:"
    center_text "A RHEL server has time drift alerts and logs are needed for a quick incident review."
    center_text "Verify NTP/time status, confirm chronyd, apply a safe config change,"
    center_text "restart/verify, then review journald usage and confirm rsyslog is receiving messages."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui

    # STEP 1: timedatectl status
    echo "  Step 1: Check the system time and NTP sync state."
    read -p "$PROMPT" cmd1
    echo
    if [[ "$cmd1" != "timedatectl status" ]]; then
        print_error "Incorrect."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  Local time: Sun 2026-01-25 07:12:19 EST"
    echo "  Universal time: Sun 2026-01-25 12:12:19 UTC"
    echo "  RTC time: Sun 2026-01-25 12:12:18"
    echo "  Time zone: America/New_York (EST, -0500)"
    echo "  System clock synchronized: yes"
    echo "  NTP service: active"
    echo "  RTC in local TZ: no"
    echo

    # STEP 2: systemctl status chronyd
    echo "  Step 2: Verify the chrony service is running."
    read -p "$PROMPT" cmd2
    echo
    if [[ "$cmd2" != "systemctl status chronyd" && "$cmd2" != "sudo systemctl status chronyd" ]]; then
        print_error "Incorrect."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  ● chronyd.service - NTP client/server"
    echo "       Loaded: loaded (/usr/lib/systemd/system/chronyd.service; enabled; preset: enabled)"
    echo "       Active: active (running) since Sun 2026-01-25 06:58:41 EST; 13min ago"
    echo "     Main PID: 1042 (chronyd)"
    echo "        Tasks: 1 (limit: 411434)"
    echo "       Memory: 2.9M"
    echo "          CPU: 221ms"
    echo "       CGroup: /system.slice/chronyd.service"
    echo "               └─1042 /usr/sbin/chronyd -F 2"
    echo

    # STEP 3: chronyc sources -v
    echo "  Step 3: Query chrony sources to confirm the system is syncing to a source."
    read -p "$PROMPT" cmd3
    echo
    if [[ "$cmd3" != "chronyc sources -v" ]]; then
        print_error "Incorrect."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  210 Number of sources = 2"
    echo "  MS Name/IP address         Stratum Poll Reach LastRx Last sample"
    echo "  ==============================================================================="
    echo "  ^* time1.example.net             2   6   377    32   -18us[ -41us] +/-  22ms"
    echo "  ^+ time2.example.net             2   6   377    33   +12us[  -8us] +/-  24ms"
    echo

    # STEP 4: Backup chrony.conf
    echo "  Step 4: Make a backup of the current chrony configuration file."
    read -p "$PROMPT" cmd4
    echo
    if [[ "$cmd4" != "sudo cp -a /etc/chrony.conf /etc/chrony.conf.bak" && \
          "$cmd4" != "cp -a /etc/chrony.conf /etc/chrony.conf.bak" ]]; then
        print_error "Incorrect."
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 5: Add makestep line (append)
    echo "  Step 5: Append a safe makestep setting so large offsets are corrected quickly on boot."
    echo "  (Add: makestep 1.0 3)"
    read -p "$PROMPT" cmd5
    echo
    if [[ "$cmd5" != "echo 'makestep 1.0 3' | sudo tee -a /etc/chrony.conf" && \
          "$cmd5" != "echo 'makestep 1.0 3' | tee -a /etc/chrony.conf" ]]; then
        print_error "Incorrect."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  makestep 1.0 3"
    echo

    # STEP 6: Restart chronyd
    echo "  Step 6: Restart chronyd to apply the change."
    read -p "$PROMPT" cmd6
    echo
    if [[ "$cmd6" != "sudo systemctl restart chronyd" && "$cmd6" != "systemctl restart chronyd" ]]; then
        print_error "Incorrect."
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 7: Verify chronyd active
    echo "  Step 7: Confirm chronyd is active."
    read -p "$PROMPT" cmd7
    echo
    if [[ "$cmd7" != "systemctl is-active chronyd" && "$cmd7" != "sudo systemctl is-active chronyd" ]]; then
        print_error "Incorrect."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  active"
    echo

    # STEP 8: journalctl --disk-usage
    echo "  Step 8: Check journald disk usage."
    read -p "$PROMPT" cmd8
    echo
    if [[ "$cmd8" != "journalctl --disk-usage" && "$cmd8" != "sudo journalctl --disk-usage" ]]; then
        print_error "Incorrect."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  Archived and active journals take up 72.0M in the file system."
    echo

    # STEP 9: journalctl for chronyd (recent)
    echo "  Step 9: Show the last 8 log lines for chronyd from the journal."
    read -p "$PROMPT" cmd9
    echo
    if [[ "$cmd9" != "journalctl -u chronyd -n 8" && "$cmd9" != "sudo journalctl -u chronyd -n 8" ]]; then
        print_error "Incorrect."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  Jan 25 06:58:41 lab137 systemd[1]: Starting NTP client/server..."
    echo "  Jan 25 06:58:41 lab137 chronyd[1042]: chronyd version 4.4 starting (+CMDMON +NTP +REFCLOCK +RTC +PRIVDROP +SCFILTER +SIGND +ASYNCDNS +NTS)"
    echo "  Jan 25 06:58:42 lab137 chronyd[1042]: Loaded seccomp filter"
    echo "  Jan 25 06:58:43 lab137 chronyd[1042]: Selected source time1.example.net"
    echo "  Jan 25 07:11:58 lab137 systemd[1]: Stopping NTP client/server..."
    echo "  Jan 25 07:11:58 lab137 chronyd[1042]: chronyd exiting"
    echo "  Jan 25 07:11:58 lab137 systemd[1]: Started NTP client/server."
    echo "  Jan 25 07:11:59 lab137 chronyd[1189]: Selected source time1.example.net"
    echo

    # STEP 10: systemctl status rsyslog
    echo "  Step 10: Confirm rsyslog is running (so logs are being written to files)."
    read -p "$PROMPT" cmd10
    echo
    if [[ "$cmd10" != "systemctl status rsyslog" && "$cmd10" != "sudo systemctl status rsyslog" ]]; then
        print_error "Incorrect."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  ● rsyslog.service - System Logging Service"
    echo "       Loaded: loaded (/usr/lib/systemd/system/rsyslog.service; enabled; preset: enabled)"
    echo "       Active: active (running) since Sun 2026-01-25 06:58:38 EST; 13min ago"
    echo "     Main PID: 1019 (rsyslogd)"
    echo "        Tasks: 3 (limit: 411434)"
    echo "       Memory: 5.1M"
    echo "          CPU: 339ms"
    echo "       CGroup: /system.slice/rsyslog.service"
    echo "               └─1019 /usr/sbin/rsyslogd -n"
    echo

    # STEP 11: logger test message
    echo "  Step 11: Send a test message to syslog to confirm the logging pipeline."
    read -p "$PROMPT" cmd11
    echo
    if [[ "$cmd11" != "logger -p user.notice 'test: logging pipeline OK'" ]]; then
        print_error "Incorrect."
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 12: Verify message landed in /var/log/messages (Rocky/RHEL style)
    echo "  Step 12: Verify the test message landed in /var/log/messages."
    read -p "$PROMPT" cmd12
    echo
    if [[ "$cmd12" != "sudo tail -n 5 /var/log/messages" && "$cmd12" != "tail -n 5 /var/log/messages" ]]; then
        print_error "Incorrect."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  Jan 25 07:12:05 lab137 systemd[1]: Started Session 7 of User lab."
    echo "  Jan 25 07:12:11 lab137 sudo[1422]:      lab : TTY=pts/0 ; PWD=/home/lab ; USER=root ; COMMAND=/usr/bin/tail -n 5 /var/log/messages"
    echo "  Jan 25 07:12:13 lab137 lab[pts/0]: test: logging pipeline OK"
    echo "  Jan 25 07:12:14 lab137 rsyslogd[1019]: [origin software=\"rsyslogd\" swVersion=\"8.2310.0\" x-pid=\"1019\" x-info=\"https://www.rsyslog.com\"] rsyslogd was HUPed"
    echo "  Jan 25 07:12:17 lab137 systemd[1]: Reloaded System Logging Service."
    echo

    print_success "Nice work."
    print_info "Workflow completed:"
    print_info "- Verified NTP/time state (timedatectl) and chrony health (systemctl/chronyc)"
    print_info "- Backed up and changed chrony config safely, restarted, and validated active state"
    print_info "- Checked journald disk usage and reviewed unit logs with journalctl"
    print_info "- Validated rsyslog service and confirmed end-to-end logging with logger + /var/log/messages"
    print_info "You earned $LAB_XP XP for completing this lab."
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
    read -p "  > " post_choice
    [[ "$post_choice" == "2" ]] && exit 0
done
