#!/bin/bash

# Lab 144: System Services

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab System Services: Fundamentals 9"
LAB_ID="lab144"
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
    center_text "Practice with CUPS, journald, Postfix, chrony, and rsyslog. (set 9)"
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: In CUPS printers.conf, specify the stanza used to configure the default local printer."
    read -p "  lab@lab144:~$ " cmd1
    echo
    [[ "$cmd1" != "<DefaultPrinter printerName>" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }

    echo
    echo "  Step 2: Remove all jobs queued for printing for the current user on the default destination."
    read -p "  lab@lab144:~$ " cmd2
    echo
    [[ "$cmd2" != "lprm -" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }

    echo
    echo "  Step 3: With the BSD mail utility, provide the option that sets the From (envelope sender) address."
    read -p "  lab@lab144:~$ " cmd3
    echo
    [[ "$cmd3" != "-r" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }

    echo
    echo "  Step 4: In rsyslog, indicate the prefix used to select TCP for a remote destination."
    read -p "  lab@lab144:~$ " cmd4
    echo
    [[ "$cmd4" != "@@" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }

    echo
    echo "  Step 5: In /etc/systemd/journald.conf, provide the key/value that makes journals persistent."
    read -p "  lab@lab144:~$ " cmd5
    echo
    [[ "$cmd5" != "Storage=persistent" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }

    echo
    echo "  Step 6: Name the client utility used to query the chronyd service."
    read -p "  lab@lab144:~$ " cmd6
    echo
    [[ "$cmd6" != "chronyc" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }

    echo
    echo "  Step 7: State the directory that holds per-log rotation snippets used by logrotate."
    read -p "  lab@lab144:~$ " cmd7
    echo
    [[ "$cmd7" != "/etc/logrotate.d" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }

    echo
    echo "  Step 8: Show the command that lists the pending Postfix mail queue."
    read -p "  lab@lab144:~$ " cmd8
    echo
    [[ "$cmd8" != "postqueue -p" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }

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
