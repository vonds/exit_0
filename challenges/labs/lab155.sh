#!/bin/bash

# Lab 155: groupadd Group Management

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 155: groupadd Group Management"
LAB_ID="lab155"
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
    center_text "Create and manage groups using groupadd."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Create a group named 'developers'."
    read -p "  root@lab155:~# " cmd1
    echo
    [[ "$cmd1" != "groupadd developers" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Group 'developers' created with GID 1002."
    echo

    echo "  Step 2: Create a group named 'docker' with a specific GID of 1050."
    read -p "  root@lab155:~# " cmd2
    echo
    [[ "$cmd2" != "groupadd -g 1050 docker" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Group 'docker' created with GID 1050."
    echo

    echo "  Step 3: Create a system group named 'sysadmin'."
    read -p "  root@lab155:~# " cmd3
    echo
    [[ "$cmd3" != "groupadd -r sysadmin" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  System group 'sysadmin' created with GID 998."
    echo

    echo "  Step 4: Create a group 'qa' with a password entry placeholder."
    read -p "  root@lab155:~# " cmd4
    echo
    [[ "$cmd4" != "groupadd -p x qa" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Group 'qa' created with an encrypted password placeholder."
    echo

    echo "  Step 5: Create a group 'research' with a non-default group ID 1100."
    read -p "  root@lab155:~# " cmd5
    echo
    [[ "$cmd5" != "groupadd -g 1100 research" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Group 'research' created with GID 1100."
    echo

    echo "  Step 6: Attempt to create a duplicate group named 'developers'."
    read -p "  root@lab155:~# " cmd6
    echo
    [[ "$cmd6" != "groupadd developers" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  groupadd: group 'developers' already exists"
    echo

    echo "  Step 7: Create a group 'finance' with a specific unique GID 1101."
    read -p "  root@lab155:~# " cmd7
    echo
    [[ "$cmd7" != "groupadd -g 1101 finance" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Group 'finance' created with GID 1101."
    echo

    echo "  Step 8: Create a group 'devops' with GID 1200."
    read -p "  root@lab155:~# " cmd8
    echo
    [[ "$cmd8" != "groupadd -g 1200 devops" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Group 'devops' created with GID 1200."
    echo

    echo "  Step 9: Create a group 'testers' as a system group with specific GID 999."
    read -p "  root@lab155:~# " cmd9
    echo
    [[ "$cmd9" != "groupadd -r -g 999 testers" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  System group 'testers' created with GID 999."
    echo

    echo "  Step 10: Verify the group 'developers' entry in /etc/group."
    read -p "  root@lab155:~# " cmd10
    echo
    [[ "$cmd10" != "getent group developers" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  developers:x:1002:satoshi"
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
