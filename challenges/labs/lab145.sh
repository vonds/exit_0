#!/bin/bash

# Lab 145: RHCSA Administrative Tasks — Permissions + Scheduled Jobs + Time Zone + Account Aging Workflow
# Workflow: set up a shared web content directory safely with group ownership + setgid,
# add a recurring cron job (user must type the crontab line themselves),
# schedule a one-time at job, verify timezone config, and remove account expiration.
# RHCSA Focus: chmod/chgrp, setgid dirs, ls -ld, crontab -e/-l, at/atq, ls -l /etc/localtime, chage.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 145: RHCSA Admin Tasks — Permissions + Cron + at + Time + Accounts"
LAB_ID="lab145"
LAB_XP=29500
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@lab145:~$ "

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
    echo
    echo
}

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Scenario:"
    center_text "A web content directory must be writable by the web team group, safely and consistently."
    center_text "Ops needs a recurring cron run, a one-time at job,"
    center_text "a timezone verification, and an account-expiration fix for a user who got locked out."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui

    # STEP 1: Create directory
    echo "  Step 1: Create the directory /home/webfiles (if it doesn't exist)."
    read -p "$PROMPT" cmd1
    echo
    if [[ "$cmd1" != "sudo mkdir -p /home/webfiles" && "$cmd1" != "mkdir -p /home/webfiles" ]]; then
        print_error "Incorrect. Use mkdir -p."
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 2: Set group ownership to apache (RHCSA/RHEL typical)
    echo "  Step 2: Set the group owner of /home/webfiles to apache."
    read -p "$PROMPT" cmd2
    echo
    if [[ "$cmd2" != "sudo chgrp apache /home/webfiles" && "$cmd2" != "chgrp apache /home/webfiles" ]]; then
        print_error "Incorrect. Use chgrp apache."
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 3: Set permissions + setgid so new files inherit group
    echo "  Step 3: Set permissions so owner/group can read/write/enter, and force group inheritance (setgid)."
    echo "          Use a single chmod command."
    read -p "$PROMPT" cmd3
    echo
    if [[ "$cmd3" != "sudo chmod 2775 /home/webfiles" && "$cmd3" != "chmod 2775 /home/webfiles" ]]; then
        print_error "Incorrect. Use chmod 2775 to set setgid + rwx for owner/group."
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 4: Verify ownership and perms
    echo "  Step 4: Verify the directory permissions and group ownership."
    read -p "$PROMPT" cmd4
    echo
    if [[ "$cmd4" != "ls -ld /home/webfiles" ]]; then
        print_error "Incorrect. Use ls -ld."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  drwxrwsr-x. 2 root apache 4096 Jan 25 07:42 /home/webfiles"
    echo

    # STEP 5: Open root crontab editor
    echo "  Step 5: Open root's crontab editor."
    read -p "$PROMPT" cmd5
    echo
    if [[ "$cmd5" != "sudo crontab -e" && "$cmd5" != "crontab -e" ]]; then
        print_error "Incorrect. Use sudo crontab -e."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  (crontab editor opened)"
    echo

    # STEP 6: Type the crontab line (user must input the exact line)
    echo "  Step 6: In the editor, add the line that runs /usr/local/bin/webfiles-audit.sh at 00:15 and 12:15 daily."
    echo "          Type the exact crontab line now:"
    read -p "$PROMPT" cmd6
    echo
    if [[ "$cmd6" != "15 0,12 * * * /usr/local/bin/webfiles-audit.sh" ]]; then
        print_error "Incorrect. Use the exact schedule and script path."
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 7: Verify cron entry exists
    echo "  Step 7: Verify the cron entry is installed."
    read -p "$PROMPT" cmd7
    echo
    if [[ "$cmd7" != "sudo crontab -l" && "$cmd7" != "crontab -l" ]]; then
        print_error "Incorrect. Use crontab -l."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  15 0,12 * * * /usr/local/bin/webfiles-audit.sh"
    echo

    # STEP 8: Schedule a one-time job with at (1 hour from now)
    echo "  Step 8: Schedule a one-time job to run 1 hour from now using at."
    read -p "$PROMPT" cmd8
    echo
    if [[ "$cmd8" != "at now + 1 hour" ]]; then
        print_error "Incorrect. Use: at now + 1 hour"
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  warning: commands will be executed using /bin/sh"
    echo "  at> "
    echo

    # STEP 9: List queued at jobs
    echo "  Step 9: List the queued at jobs."
    read -p "$PROMPT" cmd9
    echo
    if [[ "$cmd9" != "atq" ]]; then
        print_error "Incorrect. Use atq."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  3\tSun Jan 25 08:44:00 2026 a lab"
    echo

    # STEP 10: Verify timezone configuration via /etc/localtime symlink target
    echo "  Step 10: Verify what timezone /etc/localtime points to."
    read -p "$PROMPT" cmd10
    echo
    if [[ "$cmd10" != "ls -l /etc/localtime" ]]; then
        print_error "Incorrect. Use ls -l /etc/localtime"
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  lrwxrwxrwx. 1 root root 33 Jan 25 06:58 /etc/localtime -> ../usr/share/zoneinfo/America/New_York"
    echo

    # STEP 11: Remove account expiration for a user (literal username)
    echo "  Step 11: Remove account expiration for the user 'username' (set no expiration)."
    read -p "$PROMPT" cmd11
    echo
    if [[ "$cmd11" != "sudo chage -E -1 username" && "$cmd11" != "chage -E -1 username" ]]; then
        print_error "Incorrect. Use chage -E -1 username."
        read -p "Press Enter to retry..." _
        continue
    fi

    print_success "Nice work!"
    print_info "Workflow completed:"
    print_info "- Secured a shared directory using group ownership + setgid (2775) and verified with ls -ld"
    print_info "- Opened crontab and entered the schedule line yourself, then verified with crontab -l"
    print_info "- Scheduled and verified a one-time job with at/atq"
    print_info "- Verified timezone link target with ls -l /etc/localtime"
    print_info "- Removed account expiration using chage"
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
