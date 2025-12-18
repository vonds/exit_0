#!/bin/bash

# Lab Security 4: Scanning, Sockets, Logs & Users

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab Security 4: Scanning, Sockets, Logs & Users"
LAB_ID="lab_sec_4"
LAB_XP=8600
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
    center_text "Use nmap, lsof, fuser, netstat; inspect logs and users."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: SYN scan host 192.168.1.154."
    read -p "  lab@security-4:~$ " cmd1
    echo
    [[ "$cmd1" != "nmap -sS 192.168.1.154" && "$cmd1" != "nmap 192.168.1.154" ]] && {
        print_error "Use: nmap -sS 192.168.1.154 (plain nmap also accepted here)"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Scanning..."
    echo

    echo "  Step 2: TCP connect() scan 192.168.2.3."
    read -p "  lab@security-4:~$ " cmd2
    echo
    [[ "$cmd2" != "nmap -sT 192.168.2.3" ]] && {
        print_error "Use: nmap -sT 192.168.2.3"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Scanning..."
    echo

    echo "  Step 3: Force DNS resolution of targets with nmap."
    read -p "  lab@security-4:~$ " cmd3
    echo
    [[ "$cmd3" != "echo -R" ]] && {
        print_error "Echo the option: -R"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  -R"
    echo

    echo "  Step 4: Treat hosts as up even if ping fails (old flag)."
    read -p "  lab@security-4:~$ " cmd4
    echo
    [[ "$cmd4" != "echo -P0" && "$cmd4" != "echo -Pn" ]] && {
        print_error "Echo -P0 (older) or -Pn (current)"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (accepted)"
    echo

    echo "  Step 5: Show open sockets and owning processes (preferred)."
    read -p "  lab@security-4:~$ " cmd5
    echo
    [[ "$cmd5" != "lsof -i" ]] && {
        print_error "Use: lsof -i"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  COMMAND PID USER FD TYPE DEVICE SIZE/OFF NODE NAME"
    echo

    echo "  Step 6: Use netstat to show sockets with PIDs/program names."
    read -p "  lab@security-4:~$ " cmd6
    echo
    [[ "$cmd6" != "netstat -p" ]] && {
        print_error "Use: netstat -p"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Proto Local Address Foreign Address State PID/Program"
    echo

    echo "  Step 7: Show listening and non-listening sockets."
    read -p "  lab@security-4:~$ " cmd7
    echo
    [[ "$cmd7" != "netstat -a" ]] && {
        print_error "Use: netstat -a"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (listening + established shown)"
    echo

    echo "  Step 8: Find which process holds mount /srv busy."
    read -p "  lab@security-4:~$ " cmd8
    echo
    [[ "$cmd8" != "fuser -m /srv" && "$cmd8" != "fuser /srv" && "$cmd8" != "lsof +f -- /srv" ]] && {
        print_error "Use: fuser -m <mountpoint> (or lsof on mount)"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  /srv: 1234"
    echo

    echo "  Step 9: List open files for all processes except those owned by user 'bind'."
    read -p "  lab@security-4:~$ " cmd9
    echo
    [[ "$cmd9" != "lsof -u ^bind" ]] && {
        print_error "Use: lsof -u ^bind"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (non-bind processes shown)"
    echo

    echo "  Step 10: Show recent logins from an alternate wtmp file."
    read -p "  lab@security-4:~$ " cmd10
    echo
    [[ "$cmd10" != "last -f /var/log/wtmp.1" ]] && {
        print_error "Use: last -f <file>"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (alternate login history)"
    echo

    echo "  Step 11: State the log used by 'last' for recent logins (echo path)."
    read -p "  lab@security-4:~$ " cmd11
    echo
    [[ "$cmd11" != "echo /var/log/wtmp" ]] && {
        print_error "Echo: /var/log/wtmp"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  /var/log/wtmp"
    echo

    echo "  Step 12: Print only usernames from /etc/passwd."
    read -p "  lab@security-4:~$ " cmd12
    echo
    [[ "$cmd12" != "cut -d: -f1 /etc/passwd" && "$cmd12" != "cat /etc/passwd | cut -d: -f1" && "$cmd12" != "getent passwd | cut -d: -f1" ]] && {
        print_error "Use: cut -d: -f1 /etc/passwd  (or getent ...)"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  root"
    echo "  daemon"
    echo "  ..."
    echo

    echo "  Step 13: Show SUID files."
    read -p "  lab@security-4:~$ " cmd13
    echo
    [[ "$cmd13" != "find / -perm -4000" && "$cmd13" != "find / -perm 4000" ]] && {
        print_error "Use: find / -perm -4000"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (SUID files listed)"
    echo

    echo "  Step 14: Show SGID files."
    read -p "  lab@security-4:~$ " cmd14
    echo
    [[ "$cmd14" != "find / -perm -2000" && "$cmd14" != "find / -perm 2000" ]] && {
        print_error "Use: find / -perm -2000"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (SGID files listed)"
    echo

    echo "  Step 15: Show all sockets (both listening & not) quickly (netstat)."
    read -p "  lab@security-4:~$ " cmd15
    echo
    [[ "$cmd15" != "netstat -a" ]] && {
        print_error "Use: netstat -a"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Done."
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
