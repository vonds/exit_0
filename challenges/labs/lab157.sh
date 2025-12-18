#!/bin/bash

# Lab 157: groupmod Group Modification

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 157: groupmod Group Modification"
LAB_ID="lab157"
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
    center_text "Modify existing groups using groupmod."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Show the current /etc/group entry for 'developers'."
    read -p "  root@lab157:~# " cmd1
    echo
    [[ "$cmd1" != "getent group developers" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  developers:x:1002:satoshi"
    echo

    echo "  Step 2: Rename group 'developers' to 'devs'."
    read -p "  root@lab157:~# " cmd2
    echo
    [[ "$cmd2" != "groupmod -n devs developers" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Group 'developers' renamed to 'devs'."
    echo "  Verifying:"
    echo "  devs:x:1002:satoshi"
    echo

    echo "  Step 3: Attempt to rename 'devs' to existing group name 'docker'."
    read -p "  root@lab157:~# " cmd3
    echo
    [[ "$cmd3" != "groupmod -n docker devs" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  groupmod: group 'docker' already exists"
    echo

    echo "  Step 4: Change GID of 'devs' to 1300."
    read -p "  root@lab157:~# " cmd4
    echo
    [[ "$cmd4" != "groupmod -g 1300 devs" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  GID for 'devs' changed to 1300."
    echo "  Verifying:"
    echo "  devs:x:1300:satoshi"
    echo

    echo "  Step 5: Attempt to change GID of 'devs' to 1050 (already in use by 'docker')."
    read -p "  root@lab157:~# " cmd5
    echo
    [[ "$cmd5" != "groupmod -g 1050 devs" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  groupmod: GID '1050' already exists"
    echo

    echo "  Step 6: Allow a non-unique GID and set 'devs' to 1050 anyway."
    read -p "  root@lab157:~# " cmd6
    echo
    [[ "$cmd6" != "groupmod -o -g 1050 devs" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  GID for 'devs' set to 1050 (non-unique)."
    echo "  Verifying:"
    echo "  devs:x:1050:satoshi"
    echo

    echo "  Step 7: Set an encrypted password placeholder for group 'devs'."
    echo "          (Simulate placing a disabled password '!' in gshadow.)"
    read -p "  root@lab157:~# " cmd7
    echo
    if [[ "$cmd7" != "groupmod -p '!' devs" && "$cmd7" != "groupmod -p ! devs" ]]; then
        print_error "Incorrect. Try again. (Use: groupmod -p '!' devs)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Group password updated."
    echo

    echo "  Step 8: Verify the gshadow entry for 'devs'."
    read -p "  root@lab157:~# " cmd8
    echo
    [[ "$cmd8" != "getent gshadow devs" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  devs:!::satoshi"
    echo

    echo "  Step 9: Rename group 'devs' back to 'developers'."
    read -p "  root@lab157:~# " cmd9
    echo
    [[ "$cmd9" != "groupmod -n developers devs" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Group 'devs' renamed to 'developers'."
    echo "  Verifying:"
    echo "  developers:x:1050:satoshi"
    echo

    echo "  Step 10: Attempt to modify a non-existent group."
    echo "          Use the groupmod command with a new GID (e.g., 2001) and the group name 'ghosts'."
    read -p "  root@lab157:~# " cmd10
    echo
    [[ "$cmd10" != "groupmod -g 2001 ghosts" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  groupmod: group 'ghosts' does not exist"
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
