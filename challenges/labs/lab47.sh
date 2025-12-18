#!/bin/bash

# Lab 47: System Maintenance Commands (shutdown, init, reboot, halt)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 47: System Maintenance Commands"
LAB_ID="lab47"
LAB_XP=20500
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
    center_text "You are performing late-night maintenance on a production server."
    center_text "The system needs to be safely shut down and restarted after key updates."
    center_text "You will schedule reboots, alert users, and perform clean shutdowns."
    echo
    center_text "Press Enter to begin..."
    read _

    draw_lab_ui
    echo "  Step 1: Alert users that the system will shut down in 15 minutes."
    read -p "  lab@lpic-lab47:~\$ " cmd1
    echo
    [[ "$cmd1" != "sudo shutdown +15" && "$cmd1" != "shutdown +15" ]] && {
        print_error "Incorrect. Use 'shutdown +15' to schedule a shutdown in 15 minutes."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Broadcast message from root@lpic-lab47 (pts/0) (Tue Jul 22 01:15):"
    echo "    The system is going down for maintenance in 15 minutes!"
    echo "  Shutdown scheduled for Tue 2025-07-22 01:15:00 UTC; use 'shutdown -c' to cancel."
    echo

    echo "  Step 2: Cancel the scheduled shutdown."
    read -p "  lab@lpic-lab47:~\$ " cmd2
    echo
    [[ "$cmd2" != "sudo shutdown -c" && "$cmd2" != "shutdown -c" ]] && {
        print_error "Incorrect. Use 'shutdown -c' to cancel a scheduled shutdown."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Broadcast message from root@lpic-lab47 (pts/0) (Tue Jul 22 01:04):"
    echo "    Shutdown cancelled."
    echo "  Planned shutdown has been cancelled."
    echo

    echo "  Step 3: Immediately reboot the system after applying updates."
    read -p "  lab@lpic-lab47:~\$ " cmd3
    echo
    [[ "$cmd3" != "sudo reboot" && "$cmd3" != "reboot" ]] && {
        print_error "Incorrect. Use 'reboot' to restart the system."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Broadcast message from root@lpic-lab47 (pts/0):"
    echo "    The system is going down for reboot NOW!"
    echo

    echo "  Step 4: Simulate using init to change to runlevel 6 (reboot)."
    read -p "  lab@lpic-lab47:~\$ " cmd4
    echo
    [[ "$cmd4" != "sudo init 6" && "$cmd4" != "init 6" ]] && {
        print_error "Incorrect. Use 'init 6' to change to reboot runlevel."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  init: Switching to runlevel: 6"
    echo "  Rebooting..."
    echo

    echo "  Step 5: Halt the system immediately (simulate emergency power down)."
    read -p "  lab@lpic-lab47:~\$ " cmd5
    echo
    [[ "$cmd5" != "sudo halt" && "$cmd5" != "halt" ]] && {
        print_error "Incorrect. Use 'halt' to immediately stop the system."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  The system is going down NOW!"
    echo "  System halted."
    echo

    echo "  Step 6: Power off the system after a 1-minute warning."
    read -p "  lab@lpic-lab47:~\$ " cmd6
    echo
    [[ "$cmd6" != "sudo shutdown -P +1" && "$cmd6" != "shutdown -P +1" ]] && {
        print_error "Incorrect. Use 'shutdown -P +1' to power off the system in 1 minute."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Broadcast message from root@lpic-lab47 (pts/0) (Tue Jul 22 01:16):"
    echo "    The system will power off in 1 minute!"
    echo "  Shutdown scheduled for Tue 2025-07-22 01:17:00 UTC; use 'shutdown -c' to cancel."
    echo

    print_success "Great work!"
    print_info "You earned $LAB_XP XP for completing system maintenance operations."
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
    center_text "What would you like to do next?"
    center_text "1) Retry this lab"
    center_text "2) Return to Sysadmin Lab Menu"
    echo
    read -p "  > " post_choice
    [[ "$post_choice" == "2" ]] && exit 0
done
