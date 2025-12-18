#!/bin/bash

# Lab 154: passwd Password Management

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 154: passwd Password Management"
LAB_ID="lab154"
LAB_XP=20000
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
    center_text "Manage user passwords and expiry with passwd."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Change the password of the current user interactively."
    read -p "  lab@lab154:~$ " cmd1
    echo
    [[ "$cmd1" != "passwd" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Changing password for user satoshi."
    echo "  New password: "
    echo "  Retype new password: "
    echo "  passwd: password updated successfully"
    echo

    echo "  Step 2: Change the password of user 'satoshi' as root."
    read -p "  root@lab154:~# " cmd2
    echo
    [[ "$cmd2" != "passwd satoshi" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Enter new UNIX password: "
    echo "  Retype new UNIX password: "
    echo "  passwd: password updated successfully"
    echo

    echo "  Step 3: Lock the account of 'satoshi'."
    read -p "  root@lab154:~# " cmd3
    echo
    [[ "$cmd3" != "passwd -l satoshi" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  passwd: password expiry information changed."
    echo "  Account 'satoshi' locked."
    echo

    echo "  Step 4: Unlock the account of 'satoshi'."
    read -p "  root@lab154:~# " cmd4
    echo
    [[ "$cmd4" != "passwd -u satoshi" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  passwd: password expiry information changed."
    echo "  Account 'satoshi' unlocked."
    echo

    echo "  Step 5: Expire the password of 'satoshi' so it must be changed at next login."
    read -p "  root@lab154:~# " cmd5
    echo
    [[ "$cmd5" != "passwd -e satoshi" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  passwd: password expiry information changed."
    echo "  User 'satoshi' will be forced to change password at next login."
    echo

    echo "  Step 6: Set the minimum number of days between password changes to 7 for 'satoshi'."
    read -p "  root@lab154:~# " cmd6
    echo
    [[ "$cmd6" != "passwd -n 7 satoshi" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  passwd: password expiry information changed."
    echo

    echo "  Step 7: Set the maximum number of days the password is valid to 90 for 'satoshi'."
    read -p "  root@lab154:~# " cmd7
    echo
    [[ "$cmd7" != "passwd -x 90 satoshi" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  passwd: password expiry information changed."
    echo

    echo "  Step 8: Set the warning period to 14 days before password expiration for 'satoshi'."
    read -p "  root@lab154:~# " cmd8
    echo
    [[ "$cmd8" != "passwd -w 14 satoshi" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  passwd: password expiry information changed."
    echo

    echo "  Step 9: Set the inactivity period to 30 days after password expiration for 'satoshi'."
    read -p "  root@lab154:~# " cmd9
    echo
    [[ "$cmd9" != "passwd -i 30 satoshi" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  passwd: password expiry information changed."
    echo

    echo "  Step 10: Display password status information for 'satoshi'."
    read -p "  root@lab154:~# " cmd10
    echo
    [[ "$cmd10" != "passwd -S satoshi" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  satoshi P 05/20/2025 7 90 14 -1 (Password set, SHA512 crypt.)"
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
