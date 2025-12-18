#!/bin/bash

# Lab 142: System Services

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab System Services: Fundamentals 7"
LAB_ID="lab142"
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
    center_text "Practice with aliases, journald, printing, mail, and time. (set 7)"
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: After editing /etc/aliases, rebuild the aliases database so changes apply."
    read -p "  lab@lab142:~$ " cmd1
    echo
    [[ "$cmd1" != "newaliases" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }

    echo
    echo "  Step 2: From a script, send standard input to the systemd journal."
    read -p "  lab@lab142:~$ " cmd2
    echo
    [[ "$cmd2" != "systemd-cat" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }

    echo
    echo "  Step 3: Remove one or more pending print jobs from the default queue."
    read -p "  lab@lab142:~$ " cmd3
    echo
    [[ "$cmd3" != "lprm" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }

    echo
    echo "  Step 4: From a shell script, write a message to syslog."
    read -p "  lab@lab142:~$ " cmd4
    echo
    [[ "$cmd4" != "logger" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }

    echo
    echo "  Step 5: Provide the Postfix parameter name that defines the queue directory path."
    read -p "  lab@lab142:~$ " cmd5
    echo
    [[ "$cmd5" != "queue_dir" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }

    echo
    echo "  Step 6: Name the journal field used to filter logs by a specific systemd unit (field only)."
    read -p "  lab@lab142:~$ " cmd6
    echo
    if [[ "$cmd6" != "_SYSTEMD_UNIT" && "$cmd6" != "SYSTEMD_UNIT" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi

    echo
    echo "  Step 7: Submit a document to the print queue using the System V-style command."
    read -p "  lab@lab142:~$ " cmd7
    echo
    [[ "$cmd7" != "lp" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }

    echo
    echo "  Step 8: Specify the per-user file that enables email forwarding."
    read -p "  lab@lab142:~$ " cmd8
    echo
    [[ "$cmd8" != "~/.forward" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }

    echo
    echo "  Step 9: Provide the command-line flag that sets the subject when sending mail."
    read -p "  lab@lab142:~$ " cmd9
    echo
    [[ "$cmd9" != "-s" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }

    echo
    echo "  Step 10: Set the system date and time from the command line (single command with option only)."
    read -p "  lab@lab142:~$ " cmd10
    echo
    [[ "$cmd10" != "date -s" ]] && {
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
