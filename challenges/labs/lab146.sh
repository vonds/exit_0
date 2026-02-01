#!/bin/bash

# Lab 146: RHCSA Administrative Tasks — Users + Groups + Account Aging + Cleanup Workflow

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 146: RHCSA Admin Tasks — Users + Groups + Aging + Cleanup"
LAB_ID="lab146"
LAB_XP=65500
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@lab146:~$ "

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
}

accept_cmd() {
    # Accept command either bare or with sudo (first token)
    local input="$1"; shift
    for candidate in "$@"; do
        if [[ "$input" == "$candidate" || "$input" == "sudo $candidate" ]]; then
            return 0
        fi
    done
    return 1
}

while true; do
    emma_secondary_done=false

    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Scenario:"
    center_text "Ops needs a quick admin run: create groups, provision users, adjust memberships,"
    center_text "set passwords, verify account aging, simulate an expiration issue, then clean up."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui

    # STEP 1: Create groups (requires elevated privileges on RHCSA/RHEL systems)
    echo "  Step 1a: Create the group 'administrators'."
    read -p "$PROMPT" cmd1a
    echo
    if ! accept_cmd "$cmd1a" "sudo groupadd administrators"; then
        print_error "Incorrect. Use: sudo groupadd administrators"
        read -p "Press Enter to retry..." _
        continue
    fi

    echo "  Step 1b: Create the group 'developers'."
    read -p "$PROMPT" cmd1b
    echo
    if ! accept_cmd "$cmd1b" "sudo groupadd developers"; then
        print_error "Incorrect. Use: sudo groupadd developers"
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 2: Create user with secondary groups (requires sudo)
    echo "  Step 2: Create user 'kevin' and add them to the secondary groups administrators and developers."
    read -p "$PROMPT" cmd2
    echo
    if ! accept_cmd "$cmd2" "sudo useradd -G administrators,developers kevin"; then
        print_error "Incorrect. Use: sudo useradd -G administrators,developers kevin"
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 3: Create + rename group, then add user to it (requires sudo)

    echo "  Step 3a: Create a group named 'designers'."
    read -p "$PROMPT" cmd3a
    echo
    if ! accept_cmd "$cmd3a" "sudo groupadd designers"; then
        print_error "Incorrect. Use: sudo groupadd designers"
        read -p "Press Enter to retry..." _
        continue
    fi

    echo "  Step 3b: Rename 'designers' to 'web-designers'."
    read -p "$PROMPT" cmd3b
    echo
    if ! accept_cmd "$cmd3b" "sudo groupmod -n web-designers designers"; then
        print_error "Incorrect. Use: sudo groupmod -n web-designers designers"
        read -p "Press Enter to retry..." _
        continue
    fi

    echo "  Step 3c: Add 'kevin' to the 'web-designers' group (as a secondary group)."
    read -p "$PROMPT" cmd3c
    echo
    if ! accept_cmd "$cmd3c" "sudo usermod -aG web-designers kevin"; then
        print_error "Incorrect. Use: sudo usermod -aG web-designers kevin"
        read -p "Press Enter to retry..." _
        continue
    fi

    echo "  Step 4a: Remove ONLY the 'developers' group from 'kevin'’s secondary groups."
    read -p "$PROMPT" cmd4a
    echo
    if ! accept_cmd "$cmd4a" "sudo gpasswd -d kevin developers"; then
        print_error "Incorrect. Use: sudo gpasswd -d kevin developers"
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  Removing user kevin from group developers"
    echo

    echo "  Step 4b: Which command shows 'kevin'’s current group memberships?"
    read -p "$PROMPT" cmd4b
    echo
    if [[ "$cmd4b" != "id kevin" ]]; then
        print_error "Tip: Use: id kevin"
        read -p "Press Enter to continue..." _
        echo
    else
        echo "  uid=1001(kevin) gid=1001(kevin) groups=1001(kevin),1000(administrators),1003(web-designers)"
        echo
    fi

    # STEP 5: Set password (requires sudo when you are not kevin)
    echo "  Step 5: Set the password for user 'kevin'."
    read -p "$PROMPT" cmd5
    echo
    if ! accept_cmd "$cmd5" "sudo passwd kevin"; then
        print_error "Incorrect. Use: sudo passwd kevin"
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  Changing password for user kevin."
    echo "  New password:"
    echo "  Retype new password:"
    echo "  passwd: all authentication tokens updated successfully."
    echo

    # STEP 6: Account aging (requires sudo)
    echo "  Step 6a: Check the expiry details for the 'kevin' account."
    read -p "$PROMPT" cmd6a
    echo
    if ! accept_cmd "$cmd6a" "sudo chage -l kevin"; then
        print_error "Incorrect. Use: sudo chage -l kevin"
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  Last password change                                    : Aug 20, 2025"
    echo "  Password expires                                        : never"
    echo "  Password inactive                                       : never"
    echo "  Account expires                                         : never"
    echo "  Minimum number of days between password change          : 0"
    echo "  Maximum number of days between password change          : 99999"
    echo "  Number of days of warning before password expires       : 7"
    echo

    echo "  Step 6b: Set the account expiration date to Dec 31, 2022 using chage."
    read -p "$PROMPT" cmd6b
    echo
    if ! accept_cmd "$cmd6b" "sudo chage -E 2022-12-31 kevin" "sudo chage --expiredate 2022-12-31 kevin"; then
        print_error "Incorrect. Use: sudo chage -E 2022-12-31 kevin"
        read -p "Press Enter to retry..." _
        continue
    fi

    echo "  Step 6c: Provide ANOTHER valid command that would set the same expiration date."
    read -p "$PROMPT" cmd6c
    echo
    if [[ "$cmd6c" != "sudo usermod -e 2022-12-31 kevin" && "$cmd6c" != "sudo usermod --expiredate 2022-12-31 kevin" ]]; then
        print_error "Incorrect. For example: sudo usermod -e 2022-12-31 kevin"
        read -p "Press Enter to retry..." _
        continue
    fi
 
    # STEP 7: Create user with UID + primary group (requires sudo)
    echo "  Step 7a: Create a new user 'emma' with UID 1050 and primary group 'administrators'."
    read -p "$PROMPT" cmd7a
    echo
    if accept_cmd "$cmd7a" "sudo useradd -u 1050 -g administrators emma"; then
        created_emma_primary=true
    else
        print_error "Incorrect. Use: sudo useradd -u 1050 -g administrators emma"
        read -p "Press Enter to retry..." _
        continue
    fi
    # useradd: no output on success

    if [[ "$emma_secondary_done" != "true" ]]; then
        echo "  Step 7b: Add 'emma' to the secondary groups 'developers' and 'web-designers'."
        read -p "$PROMPT" cmd7b
        echo
        if ! accept_cmd "$cmd7b" "sudo usermod -aG developers,web-designers emma"; then
            print_error "Incorrect. Use: sudo usermod -aG developers,web-designers emma"
            read -p "Press Enter to retry..." _
            continue
        fi
    fi

    # STEP 8: Change login shell (requires sudo)
    echo "  Step 8: Change 'emma'’s login shell to /bin/sh."
    read -p "$PROMPT" cmd8
    echo
    if ! accept_cmd "$cmd8" "sudo usermod -s /bin/sh emma"; then
        print_error "Incorrect. Use: sudo usermod -s /bin/sh emma"
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 9: Cleanup users and groups (requires sudo)
    echo "  Step 9a: Delete the user 'emma' and their home directory."
    read -p "$PROMPT" cmd9a
    echo
    if ! accept_cmd "$cmd9a" "sudo userdel -r emma"; then
        print_error "Incorrect. Use: sudo userdel -r emma"
        read -p "Press Enter to retry..." _
        continue
    fi


    echo "  Step 9b: Delete the user 'kevin' and their home directory."
    read -p "$PROMPT" cmd9b
    echo
    if ! accept_cmd "$cmd9b" "sudo userdel -r kevin"; then
        print_error "Incorrect. Use: sudo userdel -r kevin"
        read -p "Press Enter to retry..." _
        continue
    fi

    echo "  Step 9c: Delete the groups 'administrators', 'developers', and 'web-designers'."
    read -p "$PROMPT" cmd9c
    echo
    if ! accept_cmd "$cmd9c" "sudo groupdel administrators && sudo groupdel developers && sudo groupdel web-designers"; then
        print_error "Incorrect. Use: sudo groupdel administrators && sudo groupdel developers && sudo groupdel web-designers"
        read -p "Press Enter to retry..." _
        continue
    fi
    # groupdel: no output

    print_success "Excellent! You’ve completed the lab."
    print_info "Workflow completed:"
    print_info "- Created groups and provisioned users with primary/secondary group control"
    print_info "- Verified and modified memberships (gpasswd/id)"
    print_info "- Set a password and inspected/changed account expiration (chage/usermod)"
    print_info "- Cleaned up users and groups"
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
