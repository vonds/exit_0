#!/bin/bash

# Lab 156: groupdel Group Deletion

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 156: groupdel Group Deletion"
LAB_ID="lab156"
LAB_XP=20000
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
    center_text "Delete and verify groups using groupdel."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Delete the group 'developers'."
    read -p "  root@lab156:~# " cmd1
    echo
    [[ "$cmd1" != "groupdel developers" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Group 'developers' removed."
    echo

    echo "  Step 2: Delete the group 'docker'."
    read -p "  root@lab156:~# " cmd2
    echo
    [[ "$cmd2" != "groupdel docker" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Group 'docker' removed."
    echo

    echo "  Step 3: Attempt to delete group 'wheel' while user 'satoshi' is still a member."
    read -p "  root@lab156:~# " cmd3
    echo
    [[ "$cmd3" != "groupdel wheel" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  groupdel: cannot remove the primary group of user 'satoshi'"
    echo

    echo "  Step 4: Delete the group 'qa'."
    read -p "  root@lab156:~# " cmd4
    echo
    [[ "$cmd4" != "groupdel qa" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Group 'qa' removed."
    echo

    echo "  Step 5: Attempt to delete a non-existent group 'ghosts'."
    read -p "  root@lab156:~# " cmd5
    echo
    [[ "$cmd5" != "groupdel ghosts" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  groupdel: group 'ghosts' does not exist"
    echo

    echo "  Step 6: Delete the group with GID 1100 (research)."
    read -p "  root@lab156:~# " cmd6
    echo
    [[ "$cmd6" != "groupdel research" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Group 'research' removed."
    echo

    echo "  Step 7: Delete the group 'finance'."
    read -p "  root@lab156:~# " cmd7
    echo
    [[ "$cmd7" != "groupdel finance" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Group 'finance' removed."
    echo

    echo "  Step 8: Delete the group 'devops'."
    read -p "  root@lab156:~# " cmd8
    echo
    [[ "$cmd8" != "groupdel devops" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Group 'devops' removed."
    echo

    echo "  Step 9: Attempt to delete the primary group of user 'root'."
    read -p "  root@lab156:~# " cmd9
    echo
    [[ "$cmd9" != "groupdel root" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  groupdel: cannot remove the primary group of user 'root'"
    echo

    echo "  Step 10: Verify that 'developers' group has been removed."
    read -p "  root@lab156:~# " cmd10
    echo
    [[ "$cmd10" != "getent group developers" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output when the group no longer exists)
    echo

    print_success "Nice work!"
    print_info "You earned $LAB_XP XP for completing this lab."
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON"); export XP; export LEVEL
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
