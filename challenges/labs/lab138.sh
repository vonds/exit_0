#!/bin/bash

# Lab 138: RHCSA System Services — Printing + Mail Queue Triage Workflow (CUPS + Postfix + journald)
# Workflow: verify CUPS service + default printer, submit a test print, confirm in CUPS,
# then triage Postfix queue, flush, delete a stuck message, and confirm logs in journald.
# RHCSA Focus: systemctl, lpstat/lp/lpr/lpoptions, journalctl, postqueue/mailq/postsupers/postcat.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 138: RHCSA System Services — Printing + Mail Queue Workflow"
LAB_ID="lab138"
LAB_XP=29500
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@lab138:~$ "

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
    center_text "A helpdesk ticket says printing is 'working sometimes' and outbound mail is backing up."
    center_text "You must validate CUPS, submit a test job, confirm job state, then triage Postfix queue"
    center_text "and remove a stuck message. Finish by validating evidence in the journal."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui

    # STEP 1: Check CUPS service
    echo "  Step 1: Verify the CUPS print service is running."
    read -p "$PROMPT" cmd1
    echo
    if [[ "$cmd1" != "systemctl status cups" && "$cmd1" != "sudo systemctl status cups" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  ● cups.service - CUPS Scheduler"
    echo "       Loaded: loaded (/usr/lib/systemd/system/cups.service; enabled; preset: enabled)"
    echo "       Active: active (running) since Sun 2026-01-25 06:41:12 EST; 31min ago"
    echo "     Main PID: 1126 (cupsd)"
    echo "        Tasks: 2 (limit: 411434)"
    echo "       Memory: 6.8M"
    echo "          CPU: 412ms"
    echo "       CGroup: /system.slice/cups.service"
    echo "               └─1126 /usr/sbin/cupsd -l"
    echo

    # STEP 2: Show printers and default
    echo "  Step 2: List printers and identify the default destination."
    read -p "$PROMPT" cmd2
    echo
    if [[ "$cmd2" != "lpstat -p -d" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  printer Office_Printer is idle.  enabled since Sun 25 Jan 2026 06:41:14 AM EST"
    echo "  system default destination: Office_Printer"
    echo

    # STEP 3: Submit a test job (terminal command, real workflow)
    echo "  Step 3: Submit a test print job using the default printer."
    echo "          (Print /etc/hosts)"
    read -p "$PROMPT" cmd3
    echo
    if [[ "$cmd3" != "lp /etc/hosts" && "$cmd3" != "lpr /etc/hosts" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    if [[ "$cmd3" == "lp /etc/hosts" ]]; then
        echo "  request id is Office_Printer-23 (1 file(s))"
        echo
    fi

    # STEP 4: Confirm the queue shows the job (real terminal command)
    echo "  Step 4: Check the print queue for the newly submitted job."
    read -p "$PROMPT" cmd4
    echo
    if [[ "$cmd4" != "lpq" && "$cmd4" != "lpstat -o" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    if [[ "$cmd4" == "lpq" ]]; then
        echo "  Office_Printer is ready"
        echo "  Rank   Owner   Job  File(s)                         Total Size"
        echo "  active lab     23   hosts                           1024 bytes"
        echo
    else
        echo "  Office_Printer-23  lab  1024  Sun 25 Jan 2026 07:12:55 AM EST"
        echo
    fi

    # STEP 5: Check Postfix service
    echo "  Step 5: Verify the mail service (Postfix) is running."
    read -p "$PROMPT" cmd5
    echo
    if [[ "$cmd5" != "systemctl is-active postfix" && "$cmd5" != "sudo systemctl is-active postfix" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  active"
    echo

    # STEP 6: Inspect mail queue
    echo "  Step 6: Show the current Postfix mail queue."
    read -p "$PROMPT" cmd6
    echo
    if [[ "$cmd6" != "postqueue -p" && "$cmd6" != "mailq" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  -Queue ID-  --Size-- ----Arrival Time---- -Sender/Recipient-------"
    echo "  3F2C61A012*     1468 Sun Jan 25 07:06:11  alerts@example.com"
    echo "                                           ops@example.com"
    echo "                                           (connect to mx.example.com[203.0.113.25]:25: Connection timed out)"
    echo "  1F9B77C0A9       912 Sun Jan 25 07:07:04  root@lab138"
    echo "                                           admin@example.com"
    echo "  -- 2 Kbytes in 2 Requests."
    echo

    # STEP 7: Flush the queue (force delivery attempt)
    echo "  Step 7: Force Postfix to attempt delivery now."
    read -p "$PROMPT" cmd7
    echo
    if [[ "$cmd7" != "postqueue -f" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 8: Remove the stuck message by queue ID (real command)
    echo "  Step 8: Delete the stuck message with queue ID 3F2C61A012 from the queue."
    read -p "$PROMPT" cmd8
    echo
    if [[ "$cmd8" != "postsuper -d 3F2C61A012" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  postsuper: Deleted: 1 message"
    echo

    # STEP 9: Confirm queue is clean(er)
    echo "  Step 9: Re-check the mail queue to confirm the deletion."
    read -p "$PROMPT" cmd9
    echo
    if [[ "$cmd9" != "mailq" && "$cmd9" != "postqueue -p" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  -Queue ID-  --Size-- ----Arrival Time---- -Sender/Recipient-------"
    echo "  1F9B77C0A9       912 Sun Jan 25 07:07:04  root@lab138"
    echo "                                           admin@example.com"
    echo "  -- 1 Kbytes in 1 Request."
    echo

    # STEP 10: Validate evidence in journal (follow or query)
    echo "  Step 10: Show the last 8 journal entries for postfix (evidence of queue activity)."
    read -p "$PROMPT" cmd10
    echo
    if [[ "$cmd10" != "journalctl -u postfix -n 8" && "$cmd10" != "sudo journalctl -u postfix -n 8" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  Jan 25 07:06:11 lab138 postfix/qmgr[1288]: 3F2C61A012: from=<alerts@example.com>, size=1468, nrcpt=1 (queue active)"
    echo "  Jan 25 07:06:44 lab138 postfix/smtp[1410]: 3F2C61A012: to=<ops@example.com>, relay=mx.example.com[203.0.113.25]:25, delay=33, delays=0.01/0.02/33/0, dsn=4.4.1, status=deferred (connect to mx.example.com[203.0.113.25]:25: Connection timed out)"
    echo "  Jan 25 07:07:04 lab138 postfix/qmgr[1288]: 1F9B77C0A9: from=<root@lab138>, size=912, nrcpt=1 (queue active)"
    echo "  Jan 25 07:12:20 lab138 postfix/postqueue[1467]: warning: flush request received"
    echo "  Jan 25 07:12:22 lab138 postfix/smtp[1471]: 3F2C61A012: to=<ops@example.com>, relay=mx.example.com[203.0.113.25]:25, delay=371, delays=0.01/0.01/371/0, dsn=4.4.1, status=deferred (connect to mx.example.com[203.0.113.25]:25: Connection timed out)"
    echo "  Jan 25 07:12:30 lab138 postfix/postsuper[1481]: Deleted: 3F2C61A012"
    echo "  Jan 25 07:12:31 lab138 postfix/qmgr[1288]: 3F2C61A012: removed"
    echo "  Jan 25 07:12:33 lab138 postfix/qmgr[1288]: 1F9B77C0A9: from=<root@lab138>, size=912, nrcpt=1 (queue active)"
    echo

    print_success "Great job!"
    print_info "Workflow completed:"
    print_info "- Verified CUPS service and default printer, submitted a test job, confirmed queue state"
    print_info "- Verified Postfix service, inspected queue, flushed delivery attempts, deleted a stuck message"
    print_info "- Confirmed actions via journald unit logs (journalctl -u)"
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
