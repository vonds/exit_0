#!/bin/bash

# Lab 142: RHCSA System Services — Journald + Aliases + Printing + Time Workflow
# Workflow: rebuild aliases, write evidence into journald, verify it, clear a stuck print job,
# submit a test print, check queue, and set time in a controlled way, then verify time state.
# RHCSA Focus: newaliases, systemd-cat, journalctl, lp/lpstat/cancel, timedatectl/date.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 142: RHCSA System Services — journald + Aliases + Printing + Time Workflow"
LAB_ID="lab142"
LAB_XP=29500
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@lab142:~$ "

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
    center_text "You updated /etc/aliases and must apply it. You also need to log evidence into journald,"
    center_text "clear a stuck print job, submit a test print, and adjust system time for a maintenance window."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui

    # STEP 1: Apply aliases change (real command)
    echo "  Step 1: Rebuild the aliases database so changes in /etc/aliases apply."
    read -p "$PROMPT" cmd1
    echo
    if [[ "$cmd1" != "sudo newaliases" && "$cmd1" != "newaliases" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  /etc/aliases: 86 aliases, longest 52 bytes, 948 bytes total"
    echo

    # STEP 2: Write a message into journald using systemd-cat
    echo "  Step 2: Write an incident note into journald using systemd-cat."
    echo "          (Tag it as lab142)"
    echo "          use the following message: aliases rebuilt and printing/time checks in progress"
    read -p "$PROMPT" cmd2
    echo
    if [[ "$cmd2" != "echo 'aliases rebuilt and printing/time checks in progress' | systemd-cat -t lab142" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 3: Verify the message in journald by tag
    echo "  Step 3: Verify the message appears in the journal (last 3 lines for tag lab142)."
    read -p "$PROMPT" cmd3
    echo
    if [[ "$cmd3" != "journalctl -t lab142 -n 3" && "$cmd3" != "sudo journalctl -t lab142 -n 3" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  Jan 25 07:19:02 lab142 lab142[1822]: aliases rebuilt and printing/time checks in progress"
    echo

    # STEP 4: Show pending print jobs
    echo "  Step 4: Show pending print jobs on the default printer."
    read -p "$PROMPT" cmd4
    echo
    if [[ "$cmd4" != "lpstat -o" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  Office_Printer-31  lab  1024  Sun 25 Jan 2026 07:16:55 AM EST"
    echo

    # STEP 5: Cancel the stuck job (real workflow)
    echo "  Step 5: Cancel the pending job Office_Printer-31."
    read -p "$PROMPT" cmd5
    echo
    if [[ "$cmd5" != "cancel Office_Printer-31" && "$cmd5" != "sudo cancel Office_Printer-31" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 6: Submit a test print
    echo "  Step 6: Submit /etc/hosts to the print queue using lp."
    read -p "$PROMPT" cmd6
    echo
    if [[ "$cmd6" != "lp /etc/hosts" ]]; then
        print_error "Incorrect. Use lp with a real file."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  request id is Office_Printer-32 (1 file(s))"
    echo

    # STEP 7: Confirm the new job is queued
    echo "  Step 7: Confirm the new job is queued."
    read -p "$PROMPT" cmd7
    echo
    if [[ "$cmd7" != "lpstat -o" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  Office_Printer-32  lab  1024  Sun 25 Jan 2026 07:19:31 AM EST"
    echo

    # STEP 8: Set system time using date -s (controlled)
    echo "  Step 8: Set the system time to Sun Jan 25 07:25:00 (local time) using date -s."
    read -p "$PROMPT" cmd8
    echo
    if [[ "$cmd8" != "sudo date -s '2026-01-25 07:25:00'" && "$cmd8" != "date -s '2026-01-25 07:25:00'" ]]; then
        print_error "Incorrect. Use date -s with the given timestamp."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  Sun Jan 25 07:25:00 EST 2026"
    echo

    # STEP 9: Verify time state with timedatectl
    echo "  Step 9: Verify the current time and time zone with timedatectl."
    read -p "$PROMPT" cmd9
    echo
    if [[ "$cmd9" != "timedatectl" && "$cmd9" != "timedatectl status" ]]; then
        print_error "Incorrect. Use timedatectl."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  Local time: Sun 2026-01-25 07:25:08 EST"
    echo "  Universal time: Sun 2026-01-25 12:25:08 UTC"
    echo "  RTC time: Sun 2026-01-25 12:25:08"
    echo "  Time zone: America/New_York (EST, -0500)"
    echo "  System clock synchronized: yes"
    echo "  NTP service: active"
    echo "  RTC in local TZ: no"
    echo

    # STEP 10: Show kernel messages from journald (last 5)
    echo "  Step 10: Display only kernel messages from the journal (last 5)."
    read -p "$PROMPT" cmd10
    echo
    if [[ "$cmd10" != "journalctl -k -n 5" && "$cmd10" != "sudo journalctl -k -n 5" ]]; then
        print_error "Incorrect. Use journalctl -k with -n."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  Jan 25 06:58:21 lab142 kernel: Linux version 6.6.7 (builder@ci) ..."
    echo "  Jan 25 06:58:31 lab142 kernel: e1000e 0000:00:03.0 eth0: Link is Up 1000 Mbps Full Duplex"
    echo "  Jan 25 07:02:14 lab142 kernel: IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready"
    echo "  Jan 25 07:18:09 lab142 kernel: audit: type=1100 audit(1737807489.112:231): pid=1 uid=0 auid=4294967295 msg='unit=cups comm=\"systemd\"'"
    echo "  Jan 25 07:24:57 lab142 kernel: audit: type=1105 audit(1737807897.551:244): pid=1822 uid=0 auid=1000 msg='op=login acct=\"lab\" exe=\"/usr/bin/sudo\" hostname=? addr=? terminal=/dev/pts/0 res=success'"
    echo

    print_success "Nice work!"
    print_info "Workflow completed:"
    print_info "- Applied /etc/aliases changes using newaliases"
    print_info "- Wrote and verified an incident note in journald using systemd-cat + journalctl"
    print_info "- Cleared a stuck print job, submitted a test job, and verified the queue"
    print_info "- Set time with date -s and verified time zone/state with timedatectl"
    print_info "- Queried kernel logs with journalctl -k"
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
