#!/bin/bash

# Lab 43: Additional Cron Job Intervals – hourly, daily, weekly, monthly

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 43: Scheduled Task Intervals"
LAB_ID="lab43"
LAB_XP=23650
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
    center_text "Your team needs you to configure system-wide recurring tasks."
    center_text "These include hourly log cleanups, daily backups, weekly reports,"
    center_text "and monthly archive syncs. These must use the proper cron interval directories."
    echo
    center_text "Press Enter to begin..."
    read _

    draw_lab_ui
    echo "  Step 1: Navigate to the system-wide cron directories."
    read -p "  lab@lpic-lab43:~\$ " cmd1
    echo
    [[ "$cmd1" != "cd /etc/cron.*" && "$cmd1" != "cd /etc/cron.daily" && "$cmd1" != "cd /etc/cron.hourly" ]] && {
        print_error "Try: cd /etc/cron.daily or another cron interval directory."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 2: Create a script to be run hourly named cleanup_logs."
    read -p "  lab@lpic-lab43:/etc/cron.hourly\$ " cmd2
    echo
    [[ "$cmd2" != "sudo vim cleanup_logs" && "$cmd2" != "vim cleanup_logs" ]] && {
        print_error "Use vim to create the file cleanup_logs."
        read -p "Press Enter to try again..." _
        continue
    }
    echo -e "  #!/bin/bash\n  find /var/log -type f -name '*.log' -mtime +3 -delete"
    echo

    echo "  Step 3: Make the script executable."
    read -p "  lab@lpic-lab43:/etc/cron.hourly\$ " cmd3
    echo
    [[ "$cmd3" != "chmod +x cleanup_logs" ]] && {
        print_error "Use chmod +x to make the script executable."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 4: Create a script for daily backups in /etc/cron.daily."
    read -p "  lab@lpic-lab43:~\$ " cmd4
    echo
    [[ "$cmd4" != "sudo vim /etc/cron.daily/backup_home" ]] && {
        print_error "Use vim to create /etc/cron.daily/backup_home"
        read -p "Press Enter to try again..." _
        continue
    }

    echo -e "  #!/bin/bash\n  tar -czf /backup/home_\$(date +%F).tar.gz /home"
    echo

    echo "  Step 5: Ensure the daily backup script is executable."
    read -p "  lab@lpic-lab43:~\$ " cmd5
    echo
    [[ "$cmd5" != "chmod +x /etc/cron.daily/backup_home" ]] && {
        print_error "Use chmod +x to make backup script executable."
        read -p "Press Enter to try again..." _
        continue
    }
 

    echo "  Step 6: List the contents of all cron interval directories."
    read -p "  lab@lpic-lab43:~\$ " cmd6
    echo
    [[ "$cmd6" != "ls /etc/cron.*" ]] && {
        print_error "Use: ls /etc/cron.*"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  /etc/cron.daily/backup_home"
    echo "  /etc/cron.hourly/cleanup_logs"
    echo "  /etc/cron.weekly/"
    echo "  /etc/cron.monthly/"
    echo

    echo "  Step 7: Create a monthly sync script."
    read -p "  lab@lpic-lab43:~\$ " cmd7
    echo
    [[ "$cmd7" != "sudo vim /etc/cron.monthly/monthly_sync" ]] && {
        print_error "Use vim to create the script in /etc/cron.monthly."
        read -p "Press Enter to try again..." _
        continue
    }
    echo -e "  #!/bin/bash\n  rsync -av /backup/ /mnt/nas/monthly_archive"
    echo

    echo "  Step 8: Make sure it's executable too."
    read -p "  lab@lpic-lab43:~\$ " cmd8
    echo
    [[ "$cmd8" != "chmod +x /etc/cron.monthly/monthly_sync" ]] && {
        print_error "Don't forget to make the script executable!"
        read -p "Press Enter to try again..." _
        continue
    }


    print_success "Outstanding!"
    print_info "You've completed full setup of hourly, daily, and monthly cron jobs."
    print_info "You earned $LAB_XP XP for this lab!"
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON")
    LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
    export XP
    export LEVEL
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
