#!/bin/bash

# Lab 183: Fix Broken /etc/fstab Entry Causing Boot Failure

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 183: Recover System from Broken /etc/fstab Entry"
LAB_ID="lab183"
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
    echo; echo; echo
}

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Scenario: The system failed to boot"
    center_text "because /etc/fstab contains an invalid mount entry."
    center_text "Goal: Identify the problem, correct the entry,"
    center_text "verify mounts, and return the system to normal boot."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: View recent boot errors."
    read -p "  emergency@lab183:~# " cmd1
    echo
    if [[ "$cmd1" != "journalctl -xb" ]]; then
        print_error "Incorrect. Try again. (Use: journalctl -xb)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Failed to mount /data."
    echo "  Dependency failed for Local File Systems."
    echo

    echo "  Step 2: Inspect the filesystem table."
    read -p "  emergency@lab183:~# " cmd2
    echo
    if [[ "$cmd2" != "cat /etc/fstab" ]]; then
        print_error "Incorrect. Try again. (Use: cat /etc/fstab)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  UUID=xxxx / xfs defaults 0 1"
    echo "  /dev/sdb1 /data xfs defaults 0 0"
    echo "  (Device /dev/sdb1 does not exist)"
    echo

    echo "  Step 3: Comment out the bad entry."
    read -p "  emergency@lab183:~# " cmd3
    echo
    if [[ "$cmd3" != "sed -i 's|/dev/sdb1 /data xfs defaults 0 0|#/dev/sdb1 /data xfs defaults 0 0|' /etc/fstab" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Step 4: Create a corrected mount entry."
    read -p "  emergency@lab183:~# " cmd4
    echo
    if [[ "$cmd4" != "echo '/dev/sdb2 /data xfs defaults 0 0' | tee -a /etc/fstab" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  /dev/sdb2 /data xfs defaults 0 0"
    echo

    echo "  Step 5: Attempt to mount all filesystems."
    read -p "  emergency@lab183:~# " cmd5
    echo
    if [[ "$cmd5" != "mount -a" ]]; then
        print_error "Incorrect. Try again. (Use: mount -a)"
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Step 6: Verify the new mount."
    read -p "  emergency@lab183:~# " cmd6
    echo
    if [[ "$cmd6" != "findmnt /data" ]]; then
        print_error "Incorrect. Try again. (Use: findmnt /data)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  TARGET SOURCE     FSTYPE OPTIONS"
    echo "  /data  /dev/sdb2  xfs    rw,relatime"
    echo

    echo "  Step 7: Exit emergency mode to resume boot."
    read -p "  emergency@lab183:~# " cmd7
    echo
    if [[ "$cmd7" != "exit" ]]; then
        print_error "Incorrect. Try again. (Use: exit)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  systemd: Resuming normal boot (simulated)"
    echo

    echo "  Step 8: Confirm the system reached the default target."
    read -p "  rhel@lab183:~$ " cmd8
    echo
    if [[ "$cmd8" != "systemctl get-default" ]]; then
        print_error "Incorrect. Try again. (Use: systemctl get-default)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  multi-user.target"
    echo

    print_success "Nice work!"
    print_info "You fixed a boot failure caused by a bad /etc/fstab entry."
    print_info "You earned $LAB_XP XP for completing this lab."

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

    read -p "  > " post_choice
    [[ "$post_choice" == "2" ]] && exit 0
done