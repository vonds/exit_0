#!/bin/bash

# Lab 138: System Services

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab System Services: Fundamentals 3"
LAB_ID="lab138"
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
    center_text "Work with printing, mail, clocks, and journaling. (set 3)"
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Submit a document to the system's default print queue (command only)."
    read -p "  lab@lab138:~$ " cmd1
    echo
    [[ "$cmd1" != "lpr" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 2: Show current mail queue details using the MTA's classic interface."
    read -p "  lab@lab138:~$ " cmd2
    echo
    [[ "$cmd2" != "sendmail -bp" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }
    echo "  Mail Queue (1 request)"
    echo "    A1B2C3D4      2 KB  Mon 10:14  user@example.com"
    echo "                     (host mx.example.com said: 450 try again later)"

    echo "  Step 3: Write the current system time to the hardware clock."
    read -p "  lab@lab138:~$ " cmd3
    echo
    if [[ "$cmd3" == "hwclock -w" || "$cmd3" == "hwclock --systohc" ]]; then
        :
    else
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    # (No standard output on success)

    echo "  Step 4: State the default TCP port for the CUPS administrative web interface."
    read -p "  lab@lab138:~$ " cmd4
    echo
    [[ "$cmd4" != "tcp/631" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }
    # (No output for this answer)

    echo "  Step 5: Force immediate delivery attempts for messages currently queued by sendmail."
    read -p "  lab@lab138:~$ " cmd5
    echo
    [[ "$cmd5" != "sendmail -q" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 6: Create a system-wide alias that forwards abuse@example.com to two recipients."
    echo "          Enter the exact /etc/aliases line."
    read -p "  lab@lab138:~$ " cmd6
    echo
    if [[ "$cmd6" == "abuse: admin@example.com, security@example.com" || "$cmd6" == "abuse: admin@example.com,security@example.com" ]]; then
        :
    else
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    # (No output for this answer)

    echo "  Step 7: Record that the hardware clock is in UTC by syncing it from the current system time."
    read -p "  lab@lab138:~$ " cmd7
    echo
    if [[ "$cmd7" == "hwclock --systohc --utc" || "$cmd7" == "hwclock --utc --systohc" ]]; then
        :
    else
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    # (No standard output on success)

    echo "  Step 8: Purge all messages from the Postfix mail queue."
    read -p "  lab@lab138:~$ " cmd8
    echo
    [[ "$cmd8" != "postsuper -d ALL" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }
    echo "  postsuper: Deleted: 42 messages"

    echo "  Step 9: Provide the URL that lists completed print jobs in the local CUPS web UI."
    read -p "  lab@lab138:~$ " cmd9
    echo
    [[ "$cmd9" != "http://localhost:631/jobs?which_jobs=completed" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }
    # (No output for this answer)

    echo "  Step 10: Follow new log entries as they arrive in the systemd journal."
    read -p "  lab@lab138:~$ " cmd10
    echo
    [[ "$cmd10" != "journalctl -f" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }
    echo "  -- Logs begin at Mon 2025-08-25 09:12:04, end at Mon 2025-08-25 10:22:41. --"
    echo "  Aug 25 10:22:41 host systemd[1]: Started Rotate log files."

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
