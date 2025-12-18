#!/bin/bash

# Lab 29: Monitor User Activity - Realistic Scenario

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 29: Monitor User Activity"
LAB_ID="lab29"
LAB_XP=3145
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
    center_text "  Security Alert: An overnight access review flagged an unapproved login."
    center_text "  Suspicious activity was recorded from a user account that should have"
    center_text "  been inactive. Your task: determine who accessed the system and decide"
    center_text "  whether the account should be disabled immediately."
    echo
    center_text "Press Enter to begin..."
    read _

    draw_lab_ui
    echo "  Step 1: Display current users logged into the system."
    read -p "  root@server01:~# " cmd1
    echo
    [[ "$cmd1" != "who" ]] && {
        print_error "Incorrect. Use the 'who' command."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  devstudent  pts/0        2025-07-18 08:13 (192.168.1.25)"
    echo "  sysmon      pts/1        2025-07-18 08:15 (192.168.1.23)"
    echo "  analyst     pts/2        2025-07-18 08:21 (192.168.1.12)"
    echo

    echo "  Step 2: View what those users are doing right now."
    read -p "  root@server01:~# " cmd2
    echo
    [[ "$cmd2" != "w" ]] && {
        print_error "Incorrect. Use the 'w' command."
        read -p "Press Enter to try again..." _
        continue
    }
    echo -e "  08:30:01 up 2 days,  4:56,  3 users,  load average: 0.45, 0.42, 0.36"
    echo -e "  USER       TTY      FROM              LOGIN@   IDLE   JCPU   PCPU WHAT"
    echo -e "  devstudent pts/0    192.168.1.25      08:13    3.00s  0.10s  0.00s bash"
    echo -e "  sysmon     pts/1    192.168.1.23      08:15    7.00s  0.20s  0.01s top"
    echo -e "  analyst    pts/2    192.168.1.12      08:21    1:15   0.30s  0.03s vim"
    echo

    echo "  Step 3: Review the login history to see late-night activity."
    read -p "  root@server01:~# " cmd3
    echo
    [[ "$cmd3" != "last" ]] && {
        print_error "Incorrect. Use: last"
        read -p "Press Enter to try again..." _
        continue
    }
    echo -e "  analyst   pts/2        192.168.1.12    Fri Jul 19 08:21   still logged in"
    echo -e "  sysmon    pts/1        192.168.1.23    Fri Jul 19 08:15   still logged in"
    echo -e "  devstudent pts/0       192.168.1.25    Fri Jul 19 08:13   still logged in"
    echo -e "  intern    pts/3        192.168.1.30    Thu Jul 18 23:59 - 00:15  (00:16)"
    echo -e "  tester    pts/4        192.168.1.55    Thu Jul 18 23:00 - 23:55  (00:55)"
    echo -e "  backup    pts/6        127.0.0.1       Thu Jul 18 02:00 - 02:30  (00:30)"
    echo -e "  root      pts/7        192.168.1.10    Thu Jul 18 01:00 - 01:45  (00:45)"
    echo
    center_text "  Notice: 'tester' logged in from an unfamiliar IP at 11 PM — well outside work hours."

    echo
    echo "  Step 4: Check whether 'tester' has any assigned permissions or elevated roles."
    read -p "  root@server01:~# " cmd4
    echo
    [[ "$cmd4" != "id tester" ]] && {
        print_error "Incorrect. Use: id tester"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  uid=1012(tester) gid=1012(tester) groups=1012(tester)"
    echo
    center_text "  'tester' is not part of any privileged groups."

    echo
    echo "  Step 5: View the sudo group to confirm authorized users."
    read -p "  root@server01:~# " cmd5
    echo
    [[ "$cmd5" != "getent group sudo" ]] && {
        print_error "Incorrect. Use: getent group sudo"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  sudo:x:27:admin,analyst"
    echo
    center_text "  'tester' is not authorized for administrative access, yet was active at night."

    echo
    echo "  Step 6: Filter activity from the 'tester' account."
    read -p "  root@server01:~# " cmd6
    echo
    [[ "$cmd6" != "last | grep tester" ]] && {
        print_error "Incorrect. Use: last | grep tester"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  tester    pts/4        192.168.1.55    Thu Jul 18 23:00 - 23:55  (00:55)"
    echo

    echo "  Step 7: Check for failed logins involving 'tester'."
    read -p "  root@server01:~# " cmd7
    echo
    [[ "$cmd7" != "grep 'Failed password' /var/log/auth.log" ]] && {
        print_error "Incorrect. Try: grep 'Failed password' /var/log/auth.log"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Jul 18 23:02:11 server01 sshd[19112]: Failed password for tester from 192.168.1.55 port 44662"
    echo "  Jul 18 23:02:15 server01 sshd[19113]: Failed password for tester from 192.168.1.55 port 44663"
    echo
    center_text "  Multiple failed login attempts from 'tester' followed by a successful session."

    echo
    echo "  Step 8: Lock the 'tester' account to prevent future login."
    read -p "  root@server01:~# " cmd8
    echo
    [[ "$cmd8" != "passwd -l tester" && "$cmd8" != "sudo passwd -l tester" ]] && {
        print_error "Incorrect. Use: passwd -l tester"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "passwd: password expiry information changed."
    echo

    print_success "Security response complete."
    print_info "You correctly identified unauthorized access and locked the tester account."
    print_info "You earned $LAB_XP XP for completing the investigation and mitigation."
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON")
    LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
    export XP
    export LEVEL
    record_lab_completion

    completion_count=$(get_lab_completion_count)
    echo
    print_info "You've completed this lab $completion_count time(s)."
    echo
    center_text "Would you like to:"
    center_text "1) Retry this lab"
    center_text "2) Return to Sysadmin Lab Menu"
    echo
    read -p "  > " post_choice

    [[ "$post_choice" == "2" ]] && exit 0
done
