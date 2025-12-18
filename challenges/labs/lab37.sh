#!/bin/bash

# Lab 37: Investigating Processes with ps

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 37: Investigating Processes with ps"
LAB_ID="lab37"
LAB_XP=10401
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
    center_text "A developer reports that the system is running slowly."
    center_text "Your job is to investigate which processes are consuming resources."
    echo
    center_text "Use the ps command in various ways to monitor and report on activity."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Show all running processes in full-format listing."
    read -p "  lab@lpic-lab37:~\$ " cmd1
    echo
    [[ "$cmd1" != "ps -ef" ]] && {
        print_error "Incorrect. Use: ps -ef"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  UID        PID  PPID  C STIME TTY          TIME CMD"
    echo "  root         1     0  0 Jul18 ?        00:00:05 /sbin/init"
    echo "  syslog     313     1  0 Jul18 ?        00:00:02 /usr/sbin/rsyslogd"
    echo "  user1     1783  1234  1 11:10 pts/0    00:00:00 top"
    echo

    echo "  Step 2: View all processes running under your current terminal session."
    read -p "  lab@lpic-lab37:~\$ " cmd2
    echo
    [[ "$cmd2" != "ps" && "$cmd2" != "ps -a" && "$cmd2" != "ps -x" && "$cmd2" != "ps -ax" ]] && {
        print_error "Incorrect. Try using: ps"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "    PID TTY          TIME CMD"
    echo "   1783 pts/0    00:00:00 bash"
    echo "   1802 pts/0    00:00:00 ps"
    echo

    echo "  Step 3: Display processes using BSD-style output format."
    read -p "  lab@lpic-lab37:~\$ " cmd3
    echo
    [[ "$cmd3" != "ps aux" ]] && {
        print_error "Incorrect. Use: ps aux"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND"
    echo "  root         1  0.0  0.1  22520  3364 ?        Ss   Jul18   0:05 /sbin/init"
    echo "  daemon     912  0.1  0.2  42636  4820 ?        Ss   11:05   0:00 /usr/sbin/cron"
    echo "  user1     1801  0.5  1.5 102344 15432 pts/0    S    11:15   0:02 ./build.sh"
    echo

    echo "  Step 4: Filter the output to show only processes related to 'sshd'."
    read -p "  lab@lpic-lab37:~\$ " cmd4
    echo
    [[ "$cmd4" != "ps aux | grep sshd" && "$cmd4" != "ps -ef | grep sshd" ]] && {
        print_error "Incorrect. Use: ps aux | grep sshd or ps -ef | grep sshd"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  root      1437     1  0 Jul18 ?        00:00:06 /usr/sbin/sshd -D"
    echo "  user1     1805  1437  0 11:16 ?        00:00:00 sshd: user1@pts/0"
    echo

    echo "  Step 5: Display the tree hierarchy of processes (bonus)."
    read -p "  lab@lpic-lab37:~\$ " cmd5
    echo
    [[ "$cmd5" != "ps -ejH" && "$cmd5" != "ps f" ]] && {
        print_error "Incorrect. Use: ps -ejH or ps f"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  PID  PGID   SID TTY      TPGID STAT   UID   TIME COMMAND"
    echo "    1     1     1 ?           -1 Ss       0   0:05 /sbin/init"
    echo "   91    91    91 ?           -1 Ss       0   0:00  \\_ /lib/systemd/systemd-journald"
    echo " 1437  1437  1437 ?           -1 Ss       0   0:06  \\_ /usr/sbin/sshd -D"
    echo " 1805  1805  1805 pts/0    1805 Ss    1000   lj0:00      \\_ sshd: user1@pts/0"
    echo

    print_success "Well done!"
    print_info "You earned $LAB_XP XP for completing this lab!"
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
