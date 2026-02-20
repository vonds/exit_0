#!/bin/bash

# Lab 40: Mastering Process Signals in Linux

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 40: Mastering Process Signals in Linux"
LAB_ID="lab40"
LAB_XP=23402
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
    center_text "A background process started by your teammate is using excessive memory."
    center_text "You're tasked with identifying the process and using the appropriate signal"
    center_text "to gracefully or forcefully terminate it depending on the situation."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: View all running processes related to 'memhog'."
    read -p "  lab@lpic-lab40:~\$ " cmd1
    echo
    [[ "$cmd1" != "ps aux | grep memhog" ]] && {
        print_error "Hint: Use ps aux piped into grep to filter for the name."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  user123   5268  98.1 45.3 1612932 924392 pts/0  R    13:22   2:11 memhog"
    echo "  user123   5269   0.0  0.1   9044   872 pts/0    S+   13:22   0:00 grep --color=auto memhog"
    echo

    echo "  Step 2: Send the SIGTERM signal to PID 5268."
    read -p "  lab@lpic-lab40:~\$ " cmd2
    echo
    [[ "$cmd2" != "kill -SIGTERM 5268" && "$cmd2" != "kill -15 5268" ]] && {
        print_error "Use kill with either -SIGTERM or -15 followed by the PID."
        read -p "Press Enter to try again..." _
        continue
    }
 
    echo "  Step 3: Wait a moment and verify if the process is gone."
    read -p "  lab@lpic-lab40:~\$ " cmd3
    echo
    [[ "$cmd3" != "ps -p 5268" && "$cmd3" != "pgrep memhog" ]] && {
        print_error "Try ps -p <pid> or pgrep <name> to confirm termination."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  PID TTY      TIME     CMD"
    echo "  5268 ?       00:02:11 memhog"
    echo

    echo "  Step 4: The process did not terminate. Use SIGKILL instead."
    read -p "  lab@lpic-lab40:~\$ " cmd4
    echo
    [[ "$cmd4" != "kill -9 5268" && "$cmd4" != "kill -SIGKILL 5268" ]] && {
        print_error "Send signal 9 (SIGKILL) to terminate it forcefully."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 5: Confirm that it's no longer running."
    read -p "  lab@lpic-lab40:~\$ " cmd5
    echo
    [[ "$cmd5" != "ps -p 5268" && "$cmd5" != "pgrep memhog" ]] && {
        print_error "Check if the process was successfully killed."
        read -p "Press Enter to try again..." _
        continue
    }

        echo "  Step 6: List all available signals on your system."
    read -p "  lab@lpic-lab40:~\$ " cmd6
    echo
    [[ "$cmd6" != "kill -l" ]] && {
        print_error "Use kill -l to list all signal names and numbers."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  1) SIGHUP     2) SIGINT     3) SIGQUIT    4) SIGILL     5) SIGTRAP     6) SIGABRT     7) SIGBUS"
    echo "  8) SIGFPE     9) SIGKILL   10) SIGUSR1   11) SIGSEGV   12) SIGUSR2    13) SIGPIPE    14) SIGALRM"
    echo "  15) SIGTERM  16) SIGSTKFLT 17) SIGCHLD   18) SIGCONT   19) SIGSTOP    20) SIGTSTP    21) SIGTTIN"
    echo "  22) SIGTTOU  23) SIGURG    24) SIGXCPU   25) SIGXFSZ   26) SIGVTALRM  27) SIGPROF    28) SIGWINCH"
    echo "  29) SIGIO    30) SIGPWR    31) SIGSYS"

    echo "Step 7: Configure the shell so that pressing Ctrl+C prints: Signal caught!"
    read -p "  lab@lpic-lab40:~\$ " cmd7
    echo
    [[ "$cmd7" != "trap 'echo Signal caught!' SIGINT" ]] && {
        print_error "Hint: Use trap 'commands' SIGNAL"
        read -p "Press Enter to try again..." _
        continue
    }

    print_success "Great job!"
    print_info "You earned $LAB_XP XP for mastering process signals."
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
