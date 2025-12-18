#!/bin/bash

# Lab 8: Identify and Change Default Runlevel (SysV Systems)

# Dynamically locate root directory and source core scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 8: Identify and Change Default Runlevel (SysV Systems)"
LAB_ID="lab8"
LAB_XP=2470
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"

[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

draw_lab_ui() {
    clear
    center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
    center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
    echo
    echo
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
    center_text "You're working on an older Debian system using SysV init."
    center_text "The system boots into a graphical environment, but your team"
    center_text "needs it to boot into multi-user mode without GUI (runlevel 3)."
    echo
    center_text "Press Enter to begin the lab..."
    read _
    draw_lab_ui

    # Step 1: Runlevel command (interactive)
    echo "  Step 1: What command shows the current runlevel?"
    read -p "  lab@lpic-lab8:~$ " cmd1
    echo

    if [[ "$cmd1" != "runlevel" ]]; then
        print_error "Incorrect. Hint: Use the runlevel command."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  N 5"
    echo

    # Step 2: Alternate command to show runlevel
    echo "  Step 2: What command also shows the current runlevel?"
    read -p "  lab@lpic-lab8:~$ " cmd2
    echo

    if [[ "$cmd2" != "who -r" ]]; then
        print_error "Incorrect. Hint: Use 'who' with a specific option for runlevel."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "   run-level 5  2025-07-18 13:14"
    echo

    # Step 3: Services at runlevel 3
    echo "  Step 3: What command shows services that start at runlevel 3?"
    read -p "  lab@lpic-lab8:~$ " cmd3
    echo

    if [[ "$cmd3" != "ls /etc/rc3.d/" ]]; then
        print_error "Incorrect. Hint: The /etc/rcX.d/ directories hold symlinks to services."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  S01rsyslog  S02networking  S03cron  K01gdm3"
    echo

    # Step 4: Switch to runlevel 3
    echo "  Step 4: What command switches the system to runlevel 3 immediately?"
    read -p "  lab@lpic-lab8:~$ " cmd4
    echo

    if [[ "$cmd4" != "init 3" && "$cmd4" != "telinit 3" ]]; then
        print_error "Incorrect. Hint: Use init or telinit to switch runlevels."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Switching to runlevel 3..."
    echo "  [ OK ] Stopping graphical interface manager"
    echo "  [ OK ] Starting multi-user services"
    echo

    # Step 5: Config file for default runlevel
    echo "  Step 5: What config file would you edit to make runlevel 3 the default on boot?"
    read -p "  lab@lpic-lab8:~$ " cmd5
    echo

    if [[ "$cmd5" != "/etc/inittab" ]]; then
        print_error "Incorrect. Hint: This file sets the default runlevel in SysV init."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  # The default runlevel."
    echo "  id:3:initdefault:"
    echo

    # Step 6: Return to runlevel 5
    echo "  Step 6: What command would bring the system back to graphical mode (runlevel 5)?"
    read -p "  lab@lpic-lab8:~$ " cmd6
    echo

    if [[ "$cmd6" != "init 5" && "$cmd6" != "telinit 5" ]]; then
        print_error "Incorrect. Hint: Use init or telinit to return to GUI mode."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Switching to runlevel 5..."
    echo "  [ OK ] Starting graphical interface manager"
    echo

    print_success "Nice work!"
    print_info "You successfully identified and changed the current runlevel,"
    print_info "verified runlevel-specific services, and made changes persistent."
    print_info "You earned $LAB_XP XP for completing this lab!"
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
    read -p "  > " choice

    if [[ "$choice" == "2" ]]; then
        exit 0
    fi
done
