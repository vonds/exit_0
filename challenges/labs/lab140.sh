#!/bin/bash

# Lab 140: System Services

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab System Services: Fundamentals 5"
LAB_ID="lab140"
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
    center_text "Practice with CUPS, logrotate, sendmail/Postfix, journald, and service management. (set 5)"
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Grant printer administration rights to the account named 'username'."
    read -p "  lab@lab140:~$ " cmd1
    echo
    [[ "$cmd1" != "usermod -aG lpadmin username" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 2: Disable compression for a rotated log in a logrotate stanza (single directive)."
    read -p "  lab@lab140:~$ " cmd2
    echo
    [[ "$cmd2" != "nocompress" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }
    # (No output for this answer)

    echo "  Step 3: Enable printer sharing for all locally configured printers via CUPS."
    read -p "  lab@lab140:~$ " cmd3
    echo
    [[ "$cmd3" != "cupsctl --share-printers" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 4: Display sendmail traffic and queue statistics."
    read -p "  lab@lab140:~$ " cmd4
    echo
    [[ "$cmd4" != "mailstats" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }
    echo "  Statistics from Sun Jan 12 10:00:00 2025"
    echo "   M   msgsfr  bytes_from   msgsto    bytes_to  msgsrej msgsdis  Mailer"
    echo "   4        5       12.3K        7       18.7K        0       0  relay"
    echo

    echo "  Step 5: Show total disk space consumed by systemd journal files."
    read -p "  lab@lab140:~$ " cmd5
    echo
    [[ "$cmd5" != "journalctl --disk-usage" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }
    echo "  Archived and active journals take up 64.0M in the file system."
    echo

    echo "  Step 6: Restart the CUPS service on a systemd-based host."
    read -p "  lab@lab140:~$ " cmd6
    echo
    [[ "$cmd6" != "systemctl restart cups.service" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 7: View only debug-priority messages from the systemd journal."
    read -p "  lab@lab140:~$ " cmd7
    echo
    [[ "$cmd7" != "journalctl -p debug" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }
    echo "  -- Logs begin at Sun 2025-01-12 09:12:01 --"
    echo "  Jan 12 10:51:02 host kernel: debug: sample debug message"
    echo

    echo "  Step 8: Provide the cupsd.conf directive to listen on all interfaces on the IPP port."
    read -p "  lab@lab140:~$ " cmd8
    echo
    [[ "$cmd8" != "Port 631" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }
    # (No output for this answer)

    echo "  Step 9: Remove a message from the Postfix mail queue (generic command form)."
    read -p "  lab@lab140:~$ " cmd9
    echo
    [[ "$cmd9" != "postsuper -d" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }
    # (No output for this answer)

    echo "  Step 10: Purge archived journal files older than five days."
    read -p "  lab@lab140:~$ " cmd10
    echo
    [[ "$cmd10" != "journalctl --vacuum-time=5d" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }
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
