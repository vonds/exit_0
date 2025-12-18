#!/bin/bash

# Lab 139: System Services

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab System Services: Fundamentals 4"
LAB_ID="lab139"
LAB_XP=29500
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
    center_text "Practice with rsyslog, Postfix, NTP, CUPS, journald, and logrotate. (set 4)"
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Enable the rsyslog UDP listener on port 514 (legacy imudp already loaded)."
    echo "          Type the exact directive used to start the UDP server."
    read -p "  lab@lab139:~$ " cmd1
    echo
    [[ "$cmd1" != "\$UDPServerRun 514" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 2: Immediately process (flush) all queued mail on a Postfix server."
    read -p "  lab@lab139:~$ " cmd2
    echo
    [[ "$cmd2" != "postqueue -f" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 3: Allow ntpd to sync even when the initial time offset is very large."
    echo "          Provide the ntpd option that permits a one-time big step at startup."
    read -p "  lab@lab139:~$ " cmd3
    echo
    if [[ "$cmd3" == "ntpd -g" || "$cmd3" == "ntpd -g 0" ]]; then
        :
    else
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    # (No output for this answer)

    echo "  Step 4: Name the journald.conf key that limits the size of individual persistent journal files."
    read -p "  lab@lab139:~$ " cmd4
    echo
    [[ "$cmd4" != "SystemMaxFileSize" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }
    # (No output for this answer)

    echo "  Step 5: Show completed CUPS jobs from the command line."
    read -p "  lab@lab139:~$ " cmd5
    echo
    [[ "$cmd5" != "lpstat -W completed" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }
    echo "  HP_LaserJet_01-219  username  1024   Mon 10:45  Completed"
    echo "  PDF_Printer-220     buildbot  5632   Mon 10:47  Completed"
    echo

    echo "  Step 6: In logrotate, specify the directive that runs a script after rotation completes."
    read -p "  lab@lab139:~$ " cmd6
    echo
    [[ "$cmd6" != "postrotate" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }
    # (No output for this answer)

    echo "  Step 7: State the protocol/port to allow inbound on the firewall for standard SMTP."
    read -p "  lab@lab139:~$ " cmd7
    echo
    [[ "$cmd7" != "tcp/25" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }
    # (No output for this answer)

    echo "  Step 8: Rebuild the sendmail access database after editing /etc/access."
    read -p "  lab@lab139:~$ " cmd8
    echo
    if [[ "$cmd8" =~ ^makemap($|\s) ]]; then
        :
    else
        print_error "Incorrect. Try again. (Hint: rebuild the DB from /etc/access)"
        read -p "Press Enter to retry..." _
        continue
    fi
    # (No standard output on success)

    echo "  Step 9: Provide the absolute path to the primary syslog-ng configuration file."
    read -p "  lab@lab139:~$ " cmd9
    echo
    [[ "$cmd9" != "/etc/syslog-ng/syslog-ng.conf" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }
    # (No output for this answer)

    echo "  Step 10: Choose an appropriate syslog facility for a custom application."
    read -p "  lab@lab139:~$ " cmd10
    echo
    if [[ "$cmd10" =~ ^local[0-7]$ ]]; then
        :
    else
        print_error "Incorrect. Use a single facility like local0 through local7."
        read -p "Press Enter to retry..." _
        continue
    fi
    # (No output for this answer)

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
