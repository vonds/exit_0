#!/bin/bash

# Lab 38: Monitoring System with top

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 38: Monitoring System with top"
LAB_ID="lab38"
LAB_XP=11850
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
    center_text "You are monitoring performance on a Linux system with high load."
    center_text "Use the 'top' command to analyze system processes and resources."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Launch the real-time process viewer."
    read -p "  lab@lpic-lab38:~\$ " cmd1
    echo
    [[ "$cmd1" != "top" ]] && {
        print_error "Incorrect. Use: top"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  top - 10:15:01 up  1:23,  2 users,  load average: 0.25, 0.30, 0.28"
    echo "  Tasks: 150 total,   1 running, 149 sleeping,   0 stopped,   0 zombie"
    echo "  %Cpu(s):  3.2 us,  1.5 sy,  0.0 ni, 94.8 id,  0.4 wa,  0.0 hi,  0.1 si,  0.0 st"
    echo "  MiB Mem :   7820.9 total,   2988.2 free,   1075.4 used,   3757.3 buff/cache"
    echo "  MiB Swap:   2048.0 total,   2048.0 free,      0.0 used.   6366.4 avail Mem"
    echo "  "
    echo "  PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND"
    echo "  2387 alice     20   0 2412340  74200  40200 S   5.3  0.9   0:12.34 code"
    echo "  2194 alice     20   0 1911224  98200  53000 S   3.1  1.2   2:01.12 firefox"
    echo "  2381 dev       20   0 1120332  40320  14000 S   2.4  0.5   0:45.67 python3"
    echo "  1324 root      20   0  169084  13872   8732 S   0.3  0.2   0:04.12 systemd"
    echo "  1502 root      20   0  315600   8420   6020 S   0.1  0.1   0:00.98 sshd"
    echo "  1650 dev       20   0  987456  25400  12000 S   0.1  0.3   0:03.01 bash"
    echo

    echo "  Step 2: Sort processes by memory usage (while inside 'top'). What key do you press?"
    read -p "  Key to press: " key1
    echo
    [[ "$key1" != "M" && "$key1" != "m" ]] && {
        print_error "Incorrect. Press 'M' inside top to sort by memory usage."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Sorted by memory usage inside top."
    echo

    echo "  Step 3: Exit the 'top' viewer."
    read -p "  Key to press: " key2
    echo
    [[ "$key2" != "q" ]] && {
        print_error "Incorrect. Press 'q' to quit top."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Exited the top utility."
    echo

    echo "  Step 4: Display help options for the top command (outside of top)."
    read -p "  lab@lpic-lab38:~\$ " cmd3
    echo
    [[ "$cmd3" != "top --help" && "$cmd3" != "man top" ]] && {
        print_error "Incorrect. Use: top --help or man top"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  top command help displayed."
    echo

    print_success "Excellent work!"
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
