#!/bin/bash

# Lab 95: Tuning System Performance with tuned, nice, and renice
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 95: Tuning System Performance (tuned, nice, renice)"
LAB_ID="lab95"
LAB_XP=5000
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
    center_text "Scenario: Optimize system performance using tuned for profiles,"
    center_text "and manage process priorities with nice and renice."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Install tuned if not installed."
    read -p "  lab@lpic-lab95:~$ " cmd1
    echo
    [[ "$cmd1" != "sudo apt install tuned -y" && "$cmd1" != "sudo dnf install tuned -y" && "$cmd1" != "sudo pacman -S tuned" ]] && {
        print_error "Incorrect. Use: sudo apt install tuned -y (or dnf/pacman equivalent)"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  tuned installed successfully."
    echo

    echo "  Step 2: Enable and start the tuned service."
    read -p "  lab@lpic-lab95:~$ " cmd2
    echo
    [[ "$cmd2" != "sudo systemctl enable --now tuned" ]] && {
        print_error "Incorrect. Use: sudo systemctl enable --now tuned"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  tuned service started and enabled at boot."
    echo

    echo "  Step 3: List available tuned performance profiles."
    read -p "  lab@lpic-lab95:~$ " cmd3
    echo
    [[ "$cmd3" != "tuned-adm list" ]] && {
        print_error "Incorrect. Use: tuned-adm list"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  All available performance profiles displayed."
    echo

    echo "  Step 4: Apply the 'throughput-performance' profile."
    read -p "  lab@lpic-lab95:~$ " cmd4
    echo
    [[ "$cmd4" != "sudo tuned-adm profile throughput-performance" ]] && {
        print_error "Incorrect. Use: sudo tuned-adm profile throughput-performance"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  throughput-performance profile applied."
    echo

    echo "  Step 5: Confirm the current active profile."
    read -p "  lab@lpic-lab95:~$ " cmd5
    echo
    [[ "$cmd5" != "tuned-adm active" ]] && {
        print_error "Incorrect. Use: tuned-adm active"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Current profile verified."
    echo

    echo "  Step 6: Start a background CPU-intensive process."
    read -p "  lab@lpic-lab95:~$ " cmd6
    echo
    [[ "$cmd6" != "yes > /dev/null &" ]] && {
        print_error "Incorrect. Use: yes > /dev/null &"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  CPU-intensive process started."
    echo

    echo "  Step 7: Lower the process priority using nice."
    read -p "  lab@lpic-lab95:~$ " cmd7
    echo
    [[ "$cmd7" != "nice -n 10 yes > /dev/null &" ]] && {
        print_error "Incorrect. Use: nice -n 10 yes > /dev/null &"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Process started with lower priority (nice value 10)."
    echo

    echo "  Step 8: List all 'yes' processes and their PIDs."
    read -p "  lab@lpic-lab95:~$ " cmd8
    echo
    [[ "$cmd8" != "pgrep yes" && "$cmd8" != "ps aux | grep yes" ]] && {
        print_error "Incorrect. Use: pgrep yes or ps aux | grep yes"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  PIDs of 'yes' processes retrieved."
    echo

    echo "  Step 9: Adjust the nice value of a running process using renice."
    read -p "  lab@lpic-lab95:~$ " cmd9
    echo
    [[ "$cmd9" != "sudo renice -5 -p 1234" ]] && {
        print_error "Incorrect. Use: sudo renice <nice_value> -p <pid>"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Process priority changed using renice."
    echo

    echo "  Step 10: Kill the background 'yes' processes to clean up."
    read -p "  lab@lpic-lab95:~$ " cmd10
    echo
    [[ "$cmd10" != "killall yes" && "$cmd10" != "pkill yes" ]] && {
        print_error "Incorrect. Use: killall yes or pkill yes"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  All background processes terminated."
    echo

    print_success "Lab complete."
    print_info "You earned $LAB_XP XP for completing this lab."
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON")
    LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
    export XP
    export LEVEL
    record_lab_completion

    completion_count=$(get_lab_completion_count)
    echo
    print_info "You have completed this lab $completion_count time(s)."
    echo
    center_text "Would you like to:"
    center_text "1) Retry this lab"
    center_text "2) Return to Sysadmin Lab Menu"
    echo
    read -p "  > " post_choice

    [[ "$post_choice" == "2" ]] && exit 0
done
