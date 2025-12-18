#!/bin/bash

# Lab 54: Recover Root Password (Simulation)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 54: Recover Root Password"
LAB_ID="lab54"
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
    center_text "You receive a call: the root password is forgotten."
    center_text "This server uses GRUB. You're asked to simulate the recovery."
    echo
    center_text "Press Enter to begin the recovery procedure..."
    read _

    draw_lab_ui
    echo "  Step 1: Reboot and interrupt GRUB menu."
    read -p "  What key should you press? > " key
    echo
    [[ "$key" != "e" ]] && {
        print_error "Incorrect. You should press 'e' to edit the GRUB entry."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 2: Append 'init=/bin/bash' to the kernel line."
    read -p "  grub> " grubline
    echo
    [[ "$grubline" != *"init=/bin/bash"* ]] && {
        print_error "You must append 'init=/bin/bash' to boot into single-user mode."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 3: Boot the system."
    read -p "  grub> " bootcmd
    echo
    [[ "$bootcmd" != "Ctrl+x" && "$bootcmd" != "F10" ]] && {
        print_error "Incorrect. Press Ctrl+x or F10 to boot."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 4: Remount root as read-write."
    read -p "  root@localhost:/# " remount
    echo
    [[ "$remount" != "mount -o remount,rw /" ]] && {
        print_error "Incorrect. Use: mount -o remount,rw /"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 5: Change the root password."
    read -p "  root@localhost:/# " passwdcmd
    echo
    [[ "$passwdcmd" != "passwd" ]] && {
        print_error "Incorrect. Just type: passwd"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Enter new UNIX password:"
    echo "  Retype new UNIX password:"
    echo "  Password updated successfully."
    echo

    echo "  Step 6: Reboot the system."
    read -p "  root@localhost:/# " rebootcmd
    echo
    [[ "$rebootcmd" != "exec /sbin/init" && "$rebootcmd" != "reboot" ]] && {
        print_error "Incorrect. Use either 'exec /sbin/init' or 'reboot'."
        read -p "Press Enter to try again..." _
        continue
    }

    print_success "Root password recovery simulation complete!"
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
