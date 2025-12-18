#!/bin/bash

# Lab 145: Administrative Tasks (Set 1)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab Administrative Tasks: Set 1"
LAB_ID="lab145"
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
    center_text "Practice core admin tasks: permissions, cron, time zones, LDAP, accounts. (Set 1)"
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Enable a web server (www-data user/group) to write to /home/webfiles in a secure manner."
    echo "          Provide the exact command sequence."
    read -p "  lab@lab145:~$ " cmd1
    echo
    [[ "$cmd1" != "sudo chgrp www-data /home/webfiles && sudo chmod 775 /home/webfiles" ]] && {
        print_error "Incorrect. Use: chgrp www-data /home/webfiles && chmod 775 /home/webfiles"
        read -p "Press Enter to retry..." _
        continue
    }

    echo
    echo "  Step 2: Write the cron expression to run a job at 12:15 a.m. and 12:15 p.m. every day."
    read -p "  lab@lab145:~$ " cmd2
    echo
    [[ "$cmd2" != "15 0,12 * * *" ]] && {
        print_error "Incorrect. Use: 15 0,12 * * *"
        read -p "Press Enter to retry..." _
        continue
    }

    echo
    echo "  Step 3: Provide the file used to indicate the local time zone on a Linux server."
    read -p "  lab@lab145:~$ " cmd3
    echo
    [[ "$cmd3" != "/etc/localtime" ]] && {
        print_error "Incorrect. Use: /etc/localtime"
        read -p "Press Enter to retry..." _
        continue
    }

    echo
    echo "  Step 4: When using 'ldapadd -f <filename>', specify the required file format (acronym)."
    read -p "  lab@lab145:~$ " cmd4
    echo
    [[ "$cmd4" != "LDIF" ]] && {
        print_error "Incorrect. Use: LDIF"
        read -p "Press Enter to retry..." _
        continue
    }

    echo
    echo "  Step 5: Provide the command to remove an account expiration (use literal 'username')."
    read -p "  lab@lab145:~$ " cmd5
    echo
    [[ "$cmd5" != "sudo chage -E -1 username" ]] && {
        print_error "Incorrect. Use: sudo chage -E -1 username"
        read -p "Press Enter to retry..." _
        continue
    }

    echo
    echo "  Step 6: Provide the directory that contains time zone data for various regions."
    read -p "  lab@lab145:~$ " cmd6
    echo
    [[ "$cmd6" != "/usr/share/zoneinfo" ]] && {
        print_error "Incorrect. Use: /usr/share/zoneinfo"
        read -p "Press Enter to retry..." _
        continue
    }

    echo
    echo "  Step 7: Provide the exact command to schedule a series of commands to execute 1 hour from now."
    read -p "  lab@lab145:~$ " cmd7
    echo
    [[ "$cmd7" != "at now + 1 hour" ]] && {
        print_error "Incorrect. Use: at now + 1 hour"
        read -p "Press Enter to retry..." _
        continue
    }

    echo
    echo "  Step 8: Provide the command that deletes a user and their home directory."
    read -p "  lab@lab145:~$ " cmd8
    echo
    [[ "$cmd8" != "sudo userdel -r username" ]] && {
        print_error "Incorrect. Use: userdel -r"
        read -p "Press Enter to retry..." _
        continue
    }

    echo
    echo "  Step 9: Provide the file that contains hashed (encrypted) passwords on modern Linux systems."
    read -p "  lab@lab145:~$ " cmd9
    echo
    [[ "$cmd9" != "/etc/shadow" ]] && {
        print_error "Incorrect. Use: /etc/shadow"
        read -p "Press Enter to retry..." _
        continue
    }

    echo
    echo "  Step 10: Name the job scheduler used if the system may be powered down at various times."
    read -p "  lab@lab145:~$ " cmd10
    echo
    [[ "$cmd10" != "anacron" ]] && {
        print_error "Incorrect. Use: anacron"
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
