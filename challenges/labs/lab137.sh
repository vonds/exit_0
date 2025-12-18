#!/bin/bash

# Lab 137: System Services

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab System Services: Fundamentals 2"
LAB_ID="lab137"
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
    center_text "Work with time, logging, mail, and service tooling. (set 2)"
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Ops needs to re-link /etc/localtime. Identify the directory containing the canonical time zone files (full path)."
    read -p "  lab@lab138:~$ " cmd1
    echo
    [[ "$cmd1" != "/usr/share/zoneinfo" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 2: While tuning syslog filters, provide the single severity name used for informational messages."
    read -p "  lab@lab138:~$ " cmd2
    echo
    [[ "$cmd2" != "info" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 3: NTP drift must be persisted. Enter the exact ntp.conf line to set the drift file to /var/lib/ntp/drift."
    read -p "  lab@lab138:~$ " cmd3
    echo
    [[ "$cmd3" != "driftfile /var/lib/ntp/drift" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 4: Security requests email on rotation. Provide the logrotate directive to email admin@example.com."
    read -p "  lab@lab138:~$ " cmd4
    echo
    [[ "$cmd4" != "mail admin@example.com" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 5: Estimate space used by the systemd journal. Run the command that shows total journal disk usage."
    read -p "  lab@lab138:~$ " cmd5
    echo
    [[ "$cmd5" != "journalctl --disk-usage" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Archived and active journals take up 64.0M in the file system."

    echo "  Step 6: Check the current Postfix mail queue succinctly."
    read -p "  lab@lab138:~$ " cmd6
    echo
    [[ "$cmd6" != "mailq" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Mail queue is empty"

    echo "  Step 7: Interactively query the local NTP daemon."
    read -p "  lab@lab138:~$ " cmd7
    echo
    [[ "$cmd7" != "ntpq" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 8: Redirect all root mail to admin@example.com via /etc/aliases. Enter the alias line."
    read -p "  lab@lab138:~$ " cmd8
    echo
    if [[ "$cmd8" == "root: admin@example.com" || "$cmd8" == "root:admin@example.com" ]]; then
        :
    else
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Step 9: Provide the klogd option that sets the destination log file."
    read -p "  lab@lab138:~$ " cmd9
    echo
    [[ "$cmd9" != "-f" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 10: Name a time-synchronization suite suitable for intermittently connected systems (e.g., laptops)."
    read -p "  lab@lab138:~$ " cmd10
    echo
    [[ "$cmd10" != "chrony" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
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
