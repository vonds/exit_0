#!/bin/bash

# Lab 143: System Services

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab System Services: Fundamentals 8"
LAB_ID="lab143"
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
    center_text "Practice with journald, printing, Postfix, and syslog behavior. (set 8)"
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Reduce total journal size on this host to 200M immediately."
    read -p "  lab@lab143:~$ " cmd1
    echo
    [[ "$cmd1" != "journalctl --vacuum-size=200M" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }
    echo "  Vacuuming done, freed 42.3M of archived journals."
    echo

    echo "  Step 2: Show only journal entries from 09:00 today onward."
    read -p "  lab@lab143:~$ " cmd2
    echo
    [[ "$cmd2" != "journalctl --since 09:00" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }
    echo "  Aug 30 09:01 srv1 kernel: eth0: link up"
    echo "  Aug 30 09:05 srv1 sshd[1324]: Accepted publickey for admin"
    echo

    echo "  Step 3: In classic syslog configs, a '-' before a logfile path means what? (answer in a few words)"
    read -p "  lab@lab143:~$ " cmd3
    echo
    [[ "$cmd3" != "omit fsync per write" && "$cmd3" != "no fsync per write" && "$cmd3" != "disable fsync per write" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }

    echo "  Step 4: Submit report.txt to the printer named 'office'."
    read -p "  lab@lab143:~$ " cmd4
    echo
    [[ "$cmd4" != "lpr -P office report.txt" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }
    # (No standard output on success)

    echo "  Step 5: Summarize Postfix queues by age buckets."
    read -p "  lab@lab143:~$ " cmd5
    echo
    [[ "$cmd5" != "qshape" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }
    echo "                T  5 10 20 40 80 160 320 640 1280 1280+"
    echo "          incoming  0  0  1  0  0   0   0   0    0     0"
    echo "            active  1  0  0  0  0   0   0   0    0     0"
    echo

    echo "  Step 6: Name the journald.conf key that caps total disk usage for persistent journals."
    read -p "  lab@lab143:~$ " cmd6
    echo
    [[ "$cmd6" != "SystemMaxUse" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }
    # (No output for this answer)

    echo "  Step 7: Print the absolute path to the Postfix spool/queue directory."
    read -p "  lab@lab143:~$ " cmd7
    echo
    [[ "$cmd7" != "/var/spool/postfix" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }
    # (No output for this answer)

    echo "  Step 8: Read journals from an alternate root at /mnt/rescue/var/log/journal."
    read -p "  lab@lab143:~$ " cmd8
    echo
    [[ "$cmd8" != "journalctl --directory=/mnt/rescue/var/log/journal" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }
    echo "  Hint: showing entries from alternate journal directory."
    echo

    echo "  Step 9: State the conventional directory for text log files on Linux."
    read -p "  lab@lab143:~$ " cmd9
    echo
    [[ "$cmd9" != "/var/log/" && "$cmd9" != "/var/log" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }
    # (No output for this answer)

    echo "  Step 10: Provide the Exim alias target that discards mail (answer with the keyword exactly)."
    read -p "  lab@lab143:~$ " cmd10
    echo
    [[ "$cmd10" != ":blackhole:" ]] && {
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
