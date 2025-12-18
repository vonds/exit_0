#!/bin/bash

# Lab 6: Blacklisting a Problematic Kernel Module

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 6: Blacklisting a Problematic Kernel Module"
LAB_ID="lab6"
LAB_XP=2420
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

draw_lab_ui() {
    clear
    center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
    center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
    echo; echo
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
    center_text "Scenario: Your system keeps beeping on every alert."
    center_text "You’ve been asked to identify and disable the 'pcspkr' kernel module."
    echo
    center_text "Press Enter to begin the lab..."
    read _
    draw_lab_ui

    echo "  Step 1: Check if the 'pcspkr' module is currently loaded."
    read -p "  lab@lpic-lab6:~$ " cmd1
    echo
    [[ "$cmd1" != "lsmod | grep pcspkr" ]] && {
        print_error "Incorrect. Use: lsmod | grep pcspkr"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  pcspkr                 20480  0"
    echo

    echo "  Step 2: Unload the module to stop the immediate beeping."
    read -p "  lab@lpic-lab6:~$ " cmd2
    echo
    [[ "$cmd2" != "sudo rmmod pcspkr" ]] && {
        print_error "Incorrect. Use: sudo rmmod pcspkr"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 3: Create a blacklist configuration file to block this module permanently."
    read -p "  lab@lpic-lab6:~$ " cmd3
    echo
    [[ "$cmd3" != "echo 'blacklist pcspkr' | sudo tee /etc/modprobe.d/nobeep.conf" ]] && {
        print_error "Incorrect. Use: echo 'blacklist pcspkr' | sudo tee /etc/modprobe.d/nobeep.conf"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 4: Verify that the blacklist entry is now active in the config."
    read -p "  lab@lpic-lab6:~$ " cmd4
    echo
    [[ "$cmd4" != "grep pcspkr /etc/modprobe.d/nobeep.conf" ]] && {
        print_error "Incorrect. Use: grep pcspkr /etc/modprobe.d/nobeep.conf"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  blacklist pcspkr"
    echo

    print_success "Module 'pcspkr' has been blacklisted successfully!"
    print_info "You earned $LAB_XP XP for completing this lab."
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
