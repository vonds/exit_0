#!/bin/bash

# Lab 139: RHCSA System Services — Remote Syslog Reception + Log Rotation Workflow
# Workflow: enable rsyslog UDP reception, open firewall, restart/verify,
# generate a test message, confirm it lands in logs, then set up logrotate for a custom app log.
# RHCSA Focus: rsyslog config drop-ins, firewall-cmd, systemctl, ss, logger, tail, logrotate test.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 139: RHCSA System Services — Remote Syslog + Logrotate Workflow"
LAB_ID="lab139"
LAB_XP=29500
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@lab139:~$ "

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
    center_text "A team needs this host to receive syslog over UDP/514 from a legacy device."
    center_text "You must enable rsyslog UDP reception safely, allow it through the firewall,"
    center_text "verify the listener, confirm logs arrive, then set up logrotate for a custom app log."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui

    # STEP 1: Enable UDP reception (simple command)
    echo "  Step 1: Create the rsyslog UDP listener config drop-in."
    echo "          (Write two lines into /etc/rsyslog.d/10-udp514.conf)"
    read -p "$PROMPT" cmd1
    echo
    if [[ "$cmd1" != "sudo nano /etc/rsyslog.d/10-udp514.conf" && \
          "$cmd1" != "nano /etc/rsyslog.d/10-udp514.conf" && \
          "$cmd1" != "sudo vi /etc/rsyslog.d/10-udp514.conf" && \
          "$cmd1" != "vi /etc/rsyslog.d/10-udp514.conf" && \
          "$cmd1" != "sudo vim /etc/rsyslog.d/10-udp514.conf" && \
          "$cmd1" != "vim /etc/rsyslog.d/10-udp514.conf" ]]; then
        print_error "Incorrect. Use an editor to create the file."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  (File created/edited: /etc/rsyslog.d/10-udp514.conf)"
    echo "  (Add these lines inside the file:)"
    echo "  module(load=\"imudp\")"
    echo "  input(type=\"imudp\" port=\"514\")"
    echo

    # STEP 2: Validate rsyslog config
    echo "  Step 2: Validate the rsyslog configuration syntax."
    read -p "$PROMPT" cmd2
    echo
    if [[ "$cmd2" != "rsyslogd -N1" && "$cmd2" != "sudo rsyslogd -N1" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  rsyslogd: version 8.2310.0, config validation run (level 1), master config /etc/rsyslog.conf"
    echo "  rsyslogd: End of config validation run. Bye."
    echo

    # STEP 3: Restart rsyslog
    echo "  Step 3: Restart rsyslog to apply the change."
    read -p "$PROMPT" cmd3
    echo
    if [[ "$cmd3" != "sudo systemctl restart rsyslog" && "$cmd3" != "systemctl restart rsyslog" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 4: Open firewall for UDP/514
    echo "  Step 4: Allow UDP port 514 through the firewall permanently."
    read -p "$PROMPT" cmd4
    echo
    if [[ "$cmd4" != "sudo firewall-cmd --permanent --add-port=514/udp" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  success"
    echo

    # STEP 5: Reload firewall
    echo "  Step 5: Reload the firewall to apply permanent rules."
    read -p "$PROMPT" cmd5
    echo
    if [[ "$cmd5" != "sudo firewall-cmd --reload" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  success"
    echo

    # STEP 6: Verify listener exists
    echo "  Step 6: Verify rsyslog is listening on UDP/514."
    read -p "$PROMPT" cmd6
    echo
    if [[ "$cmd6" != "ss -lunp | grep ':514 '" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  UNCONN 0      0              0.0.0.0:514         0.0.0.0:*    users:((\"rsyslogd\",pid=1019,fd=7))"
    echo

    # STEP 7: Generate a test message
    echo "  Step 7: Generate a test syslog message using local0.notice."
    read -p "$PROMPT" cmd7
    echo
    if [[ "$cmd7" != "logger -p local0.notice 'test: UDP syslog receiving enabled'" ]]; then
        print_error "Incorrect. Use logger with local0.notice."
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 8: Confirm message appears in /var/log/messages
    echo "  Step 8: Confirm the test message is present in /var/log/messages."
    read -p "$PROMPT" cmd8
    echo
    if [[ "$cmd8" != "sudo tail -n 8 /var/log/messages" && "$cmd8" != "tail -n 8 /var/log/messages" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  Jan 25 07:14:21 lab139 rsyslogd[1019]: imudp: Acquired UDP socket, server will listen on port 514."
    echo "  Jan 25 07:14:33 lab139 lab[pts/0]: test: UDP syslog receiving enabled"
    echo "  Jan 25 07:14:35 lab139 sudo[1752]:      lab : TTY=pts/0 ; PWD=/home/lab ; USER=root ; COMMAND=/usr/bin/tail -n 8 /var/log/messages"
    echo

    # STEP 9: Create logrotate policy (simple editor command)
    echo "  Step 9: Create the logrotate policy file for /var/log/acmeapp.log."
    echo "          (Create/edit /etc/logrotate.d/acmeapp)"
    read -p "$PROMPT" cmd9
    echo
    if [[ "$cmd9" != "sudo nano /etc/logrotate.d/acmeapp" && \
          "$cmd9" != "nano /etc/logrotate.d/acmeapp" && \
          "$cmd9" != "sudo vi /etc/logrotate.d/acmeapp" && \
          "$cmd9" != "vi /etc/logrotate.d/acmeapp" && \
          "$cmd9" != "sudo vim /etc/logrotate.d/acmeapp" && \
          "$cmd9" != "vim /etc/logrotate.d/acmeapp" ]]; then
        print_error "Incorrect. Use an editor to create the file."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  (File created/edited: /etc/logrotate.d/acmeapp)"
    echo "  (Add this content inside the file:)"
    echo "  /var/log/acmeapp.log {"
    echo "      daily"
    echo "      rotate 7"
    echo "      compress"
    echo "      missingok"
    echo "      notifempty"
    echo "      create 0640 root root"
    echo "  }"
    echo

    # STEP 10: Test logrotate config in debug mode
    echo "  Step 10: Test the new logrotate policy in debug mode (no changes)."
    read -p "$PROMPT" cmd10
    echo
    if [[ "$cmd10" != "sudo logrotate -d /etc/logrotate.d/acmeapp" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  reading config file /etc/logrotate.d/acmeapp"
    echo "  Reading state from file: /var/lib/logrotate/logrotate.status"
    echo "  Handling 1 logs"
    echo "  rotating pattern: /var/log/acmeapp.log  after 1 days (7 rotations)"
    echo "  empty log files are not rotated, old logs are removed"
    echo "  consider log /var/log/acmeapp.log"
    echo "  log does not exist -- skipping"
    echo

    print_success "Nice work!"
    print_info "Workflow completed:"
    print_info "- Enabled rsyslog UDP reception using a safe drop-in config"
    print_info "- Opened firewall for UDP/514 and verified the listener with ss"
    print_info "- Confirmed logging pipeline using logger + /var/log/messages"
    print_info "- Created and tested a logrotate policy with logrotate -d"
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
