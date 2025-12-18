#!/bin/bash

# Lab 141: System Services

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab System Services: Fundamentals 6"
LAB_ID="lab141"
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
    center_text "Practice with mail, time, journald, and printing essentials. (set 6)"
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Specify the per-user Procmail configuration file path used to control forwarding rules."
    read -p "  lab@lab141:~$ " cmd1
    echo
    [[ "$cmd1" != "~/.procmailrc" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }

    echo
    echo "  Step 2: Define an alias to forward mail for 'root' to admin@example.com and webmaster@example.com."
    echo "          Enter the exact line as it should appear in /etc/aliases."
    read -p "  lab@lab141:~$ " cmd2
    echo
    [[ "$cmd2" != "root: admin@example.com, webmaster@example.com" ]] && {
        print_error "Incorrect. Use canonical /etc/aliases syntax with full addresses."
        read -p "Press Enter to retry..." _
        continue
    }

    echo
    echo "  Step 3: View the full contents of a specific message in the Postfix queue (command only)."
    read -p "  lab@lab141:~$ " cmd3
    echo
    [[ "$cmd3" != "postcat" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    }
    echo "  *** MESSAGE FILE BEGIN ***"
    echo "  From: root@example.local"
    echo "  To: admin@example.com"
    echo "  Subject: Test"
    echo "  Date: Sun, 12 Jan 2025 10:57:12 -0600"
    echo
    echo "  This is a queued test message."
    echo "  *** MESSAGE FILE END ***"
    echo

    echo "  Step 4: Identify the log file where Postfix delivery errors are recorded on many rsyslog-based systems."
    read -p "  lab@lab141:~$ " cmd4
    echo
    [[ "$cmd4" != "/var/log/mail.err" ]] && {
        print_error "Incorrect. Try the mail facility's common error log path."
        read -p "Press Enter to retry..." _
        continue
    }

    echo
    echo "  Step 5: Begin an SMTP session using Extended Hello from host 'mail.example.com'."
    read -p "  lab@lab141:~$ " cmd5
    echo
    [[ "$cmd5" != "EHLO mail.example.com" ]] && {
        print_error "Incorrect. Use the ESMTP greeting with the local hostname."
        read -p "Press Enter to retry..." _
        continue
    }
    echo "  250-mail.example.com Hello"
    echo "  250-SIZE 52428800"
    echo "  250-PIPELINING"
    echo "  250-STARTTLS"
    echo "  250 AUTH PLAIN LOGIN"
    echo

    echo "  Step 6: List all supported time zones available on this system."
    read -p "  lab@lab141:~$ " cmd6
    echo
    [[ "$cmd6" != "timedatectl list-timezones" ]] && {
        print_error "Incorrect. Use the system time management tool to enumerate zones."
        read -p "Press Enter to retry..." _
        continue
    }
    echo "  Africa/Abidjan"
    echo "  America/Chicago"
    echo "  Asia/Tokyo"
    echo "  Europe/Berlin"
    echo "  UTC"
    echo

    echo "  Step 7: Interpret this link: /etc/localtime -> /usr/share/zoneinfo/America/Chicago."
    echo "          State what this means in one line."
    read -p "  lab@lab141:~$ " cmd7
    echo
    [[ "$cmd7" != "The file is a symlink to a timezone in /usr/share/zoneinfo." ]] && {
        print_error "Incorrect. Describe the relationship succinctly."
        read -p "Press Enter to retry..." _
        continue
    }

    echo
    echo "  Step 8: Show the current local time and time zone using a single command."
    read -p "  lab@lab141:~$ " cmd8
    echo
    [[ "$cmd8" != "date" ]] && {
        print_error "Incorrect. Use the standard command that prints local time."
        read -p "Press Enter to retry..." _
        continue
    }
    echo "  Sun Jan 12 10:59:03 CST 2025"
    echo

    echo "  Step 9: Provide the absolute path to Chrony's main configuration file."
    read -p "  lab@lab141:~$ " cmd9
    echo
    [[ "$cmd9" != "/etc/chrony.conf" ]] && {
        print_error "Incorrect. Provide the primary Chrony config path."
        read -p "Press Enter to retry..." _
        continue
    }

    echo
    echo "  Step 10: Display only kernel messages from the systemd journal."
    read -p "  lab@lab141:~$ " cmd10
    echo
    [[ "$cmd10" != "journalctl -k" ]] && {
        print_error "Incorrect. Use the journal query option for kernel transport."
        read -p "Press Enter to retry..." _
        continue
    }
    echo "  -- Logs begin at Sun 2025-01-12 09:12:01 --"
    echo "  Jan 12 10:59:10 host kernel: Linux version 6.6.7 (builder@ci) ..."
    echo "  Jan 12 10:59:12 host kernel: eth0: Link is Up - 1Gbps/Full ..."
    echo

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
