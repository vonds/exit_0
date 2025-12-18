#!/bin/bash

# Lab 136: System Services

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab System Services: Fundamentals 1"
LAB_ID="lab136"
LAB_XP=29500
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
    center_text "Work with journaling, logging, time sync, and printing. (set 1)"
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: View the systemd journal on this host."
    read -p "  lab@lab136:~$ " cmd1
    echo
    [[ "$cmd1" != "journalctl" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  -- Logs begin at Mon 2025-08-25 08:01:12 --"
    echo "  Aug 30 10:14:02 host systemd[1]: Started Daily apt download activities."
    echo "  Aug 30 10:14:03 host CRON[1421]: pam_unix(cron:session): session opened for user root"
    echo

    echo "  Step 2: Enter the syslog facility name used for kernel messages."
    read -p "  lab@lab136:~$ " cmd2
    echo
    [[ "$cmd2" != "kern" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output)

    echo "  Step 3: Provide the public NTP pool hostname that selects regionally local servers."
    read -p "  lab@lab136:~$ " cmd3
    echo
    [[ "$cmd3" != "pool.ntp.org" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output)

    echo "  Step 4: Name the systemd service that provides logging facilities."
    read -p "  lab@lab136:~$ " cmd4
    echo
    [[ "$cmd4" != "systemd-journald" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output)

    echo "  Step 5: In logrotate, create a new log with mode 600 owned by www-data:www-data (single line)."
    read -p "  lab@lab136:~$ " cmd5
    echo
    [[ "$cmd5" != "create 600 www-data www-data" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output)

    echo "  Step 6: Give the directory path where CUPS keeps its configuration."
    read -p "  lab@lab136:~$ " cmd6
    echo
    [[ "$cmd6" != "/etc/cups" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output)

    echo "  Step 7: Write the CUPS access directive to allow clients 192.168.1.1–192.168.1.127."
    read -p "  lab@lab136:~$ " cmd7
    echo
    [[ "$cmd7" != "Allow 192.168.1.0/25" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output)

    echo "  Step 8: Perform a one-time immediate time sync against the public pool."
    read -p "  lab@lab136:~$ " cmd8
    echo
    [[ "$cmd8" != "ntpdate pool.ntp.org" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  30 Aug 10:22:11 ntpdate[2154]: adjust time server 162.159.200.1 offset -0.004321 sec"
    echo

    echo "  Step 9: Interpret this message from ntpq: 'read: Connection refused' (short phrase)."
    read -p "  lab@lab136:~$ " cmd9
    echo
    if [[ "$cmd9" == "NTP daemon not running" || "$cmd9" == "ntpd not running" ]]; then
        :
    else
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    fi
    # (No output)

    echo "  Step 10: Name the command used to query or set the hardware clock."
    read -p "  lab@lab136:~$ " cmd10
    echo
    [[ "$cmd10" != "hwclock" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output)

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
