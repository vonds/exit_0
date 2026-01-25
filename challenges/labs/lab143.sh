#!/bin/bash

# Lab 143: RHCSA System Services — Journal Cleanup + Postfix Queue + Printing Workflow
# Workflow: vacuum journal to a target size, filter logs for today's window,
# verify journald config key, inspect Postfix queue and spool path using terminal commands,
# submit a print job, and verify the queue.
# RHCSA Focus: journalctl (vacuum/filter/unit), basic Postfix queue inspection, printing tools (lp/lpstat).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 143: RHCSA System Services — journald + Postfix + Printing Workflow"
LAB_ID="lab143"
LAB_XP=29500
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@lab143:~$ "

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
    center_text "The journal grew too large overnight and Ops wants it capped quickly."
    center_text "There is also a mail queue backlog to inspect and a printer test job to submit."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui

    # STEP 1: Vacuum by size (with sudo acceptable)
    echo "  Step 1: Reduce total journal size on this host to 200M immediately."
    read -p "$PROMPT" cmd1
    echo
    if [[ "$cmd1" != "journalctl --vacuum-size=200M" && "$cmd1" != "sudo journalctl --vacuum-size=200M" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  Vacuuming done, freed 42.3M of archived journals on disk."
    echo

    # STEP 2: Show entries since 09:00 today (real usage)
    echo "  Step 2: Show only journal entries from 09:00 today onward."
    read -p "$PROMPT" cmd2
    echo
    if [[ "$cmd2" != "journalctl --since 'today 09:00'" && "$cmd2" != "journalctl --since 09:00" && \
          "$cmd2" != "sudo journalctl --since 'today 09:00'" && "$cmd2" != "sudo journalctl --since 09:00" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  Jan 25 09:01:12 lab143 kernel: eth0: Link is Up 1000 Mbps Full Duplex"
    echo "  Jan 25 09:05:44 lab143 sshd[1324]: Accepted publickey for admin from 192.0.2.50 port 51522 ssh2"
    echo

    # STEP 3: Confirm journald persistent cap key by printing it from man page query (terminal command)
    echo "  Step 3: Search the journald.conf man page for the key that caps total persistent journal usage."
    read -p "$PROMPT" cmd3
    echo
    if [[ "$cmd3" != "man journald.conf | grep -n SystemMaxUse | head -n 1" ]]; then
        print_error "Incorrect. Use man + grep to find the key."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  164:SystemMaxUse="
    echo

    # STEP 4: Inspect the Postfix queue (real command)
    echo "  Step 4: Inspect the Postfix mail queue."
    read -p "$PROMPT" cmd4
    echo
    if [[ "$cmd4" != "mailq" && "$cmd4" != "postqueue -p" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  -Queue ID-  --Size-- ----Arrival Time---- -Sender/Recipient-------"
    echo "  9F1D2C3B4A*     2104 Sun Jan 25 06:22:10  reports@example.com"
    echo "                                           ops@example.com"
    echo "                                           (connect to mx.example.com[203.0.113.25]:25: Connection timed out)"
    echo "  2A7B8C9D0E      1189 Sun Jan 25 06:41:33  root@lab143"
    echo "                                           admin@example.com"
    echo "  -- 4 Kbytes in 2 Requests."
    echo

    # STEP 5: Print Postfix config value for queue_directory (terminal command, not trivia)
    echo "  Step 5: Show Postfix's queue_directory value using postconf."
    read -p "$PROMPT" cmd5
    echo
    if [[ "$cmd5" != "postconf queue_directory" && "$cmd5" != "sudo postconf queue_directory" ]]; then
        print_error "Incorrect. Use postconf to query queue_directory."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  queue_directory = /var/spool/postfix"
    echo

    # STEP 6: Verify the spool directory exists
    echo "  Step 6: Verify the Postfix spool directory exists."
    read -p "$PROMPT" cmd6
    echo
    if [[ "$cmd6" != "ls -ld /var/spool/postfix" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  drwxr-xr-x. 20 root root 4096 Jan 25 06:02 /var/spool/postfix"
    echo

    # STEP 7: Submit a test print job (confirm printer name exists)
    echo "  Step 7: Submit /etc/hosts to the printer named 'office' using lp."
    read -p "$PROMPT" cmd7
    echo
    if [[ "$cmd7" != "lp -d office /etc/hosts" ]]; then
        print_error "Incorrect. Use lp -d office with a real file."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  request id is office-17 (1 file(s))"
    echo

    # STEP 8: Verify the print queue
    echo "  Step 8: Show the active print jobs."
    read -p "$PROMPT" cmd8
    echo
    if [[ "$cmd8" != "lpstat -o" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  office-17  lab  1024  Sun 25 Jan 2026 07:28:11 AM EST"
    echo

    # STEP 9: Cancel the print job (real workflow cleanup)
    echo "  Step 9: Cancel the job office-17."
    read -p "$PROMPT" cmd9
    echo
    if [[ "$cmd9" != "cancel office-17" && "$cmd9" != "sudo cancel office-17" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 10: Verify the queue is empty
    echo "  Step 10: Verify there are no pending print jobs."
    read -p "$PROMPT" cmd10
    echo
    if [[ "$cmd10" != "lpstat -o" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  no entries"
    echo

    print_success "Nice work!"
    print_info "Workflow completed:"
    print_info "- Vacuumed journald to a target size and reviewed logs since a time"
    print_info "- Identified journald cap key via man page search (SystemMaxUse)"
    print_info "- Inspected Postfix queue and verified queue_directory + spool path"
    print_info "- Submitted and cleaned up a test print job using lp/lpstat/cancel"
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
