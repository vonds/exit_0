#!/bin/bash

# Lab 178: Boot Target Recovery With systemd
# Goal: Recover a system that boots to the wrong target by switching the default target back to multi-user.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 178: Recover Wrong Default systemd Target"
LAB_ID="lab178"
LAB_XP=50000
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
    echo
    echo
    echo
}

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Scenario: A system is booting into rescue mode because the wrong default target is set."
    center_text "Goal: Inspect the current target, switch to multi-user.target, verify it, and reboot."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  You are logged into a rescue shell on a RHEL-based system."
    echo

    echo "  Step 1: Check the current default target."
    read -p "  rescue# " cmd1
    echo
    if [[ "$cmd1" != "systemctl get-default" ]]; then
        print_error "Incorrect. Try again. (Use: systemctl get-default)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  rescue.target"
    echo

    echo "  Step 2: View the symlink for the default target."
    read -p "  rescue# " cmd2
    echo
    if [[ "$cmd2" != "ls -l /etc/systemd/system/default.target" ]]; then
        print_error "Incorrect. Try again. (Use: ls -l /etc/systemd/system/default.target)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  lrwxrwxrwx 1 root root 37 Mar 08 12:00 /etc/systemd/system/default.target -> /usr/lib/systemd/system/rescue.target"
    echo

    echo "  Step 3: Set the default target to multi-user.target."
    read -p "  rescue# " cmd3
    echo
    if [[ "$cmd3" != "systemctl set-default multi-user.target" ]]; then
        print_error "Incorrect. Try again. (Use: systemctl set-default multi-user.target)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Removed \"/etc/systemd/system/default.target\"."
    echo "  Created symlink /etc/systemd/system/default.target → /usr/lib/systemd/system/multi-user.target."
    echo

    echo "  Step 4: Confirm the new default target."
    read -p "  rescue# " cmd4
    echo
    if [[ "$cmd4" != "systemctl get-default" ]]; then
        print_error "Incorrect. Try again. (Use: systemctl get-default)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  multi-user.target"
    echo

    echo "  Step 5: Inspect the target unit status."
    read -p "  rescue# " cmd5
    echo
    if [[ "$cmd5" != "systemctl status multi-user.target" ]]; then
        print_error "Incorrect. Try again. (Use: systemctl status multi-user.target)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  ● multi-user.target - Multi-User System"
    echo "     Loaded: loaded (/usr/lib/systemd/system/multi-user.target; static)"
    echo "     Active: active"
    echo

    echo "  Step 6: Reboot to test the corrected boot target."
    read -p "  rescue# " cmd6
    echo
    if [[ "$cmd6" != "reboot" && "$cmd6" != "systemctl reboot" ]]; then
        print_error "Incorrect. Try again. (Use: reboot)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Rebooting (simulated)."
    echo "  System boots normally into multi-user.target (simulated)."
    echo

    print_success "Nice work!"
    print_info "You earned $LAB_XP XP for completing this lab."
    award_xp "$LAB_XP"
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
    read -p "  > " post_choice
    [[ "$post_choice" == "2" ]] && exit 0
done