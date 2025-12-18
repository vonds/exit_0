#!/bin/bash

# Lab 149: chage Password Aging Controls

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 149: chage Password Aging Controls"
LAB_ID="lab149"
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
    center_text "Practice password aging and account expiry management with chage."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Display the password aging information for the user 'fatima'."
    read -p "  lab@lab149:~$ " cmd1
    echo
    [[ "$cmd1" != "chage -l fatima" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Last password change                                    : May 20, 2025"
    echo "  Password expires                                        : Aug 18, 2025"
    echo "  Password inactive                                       : Sep 17, 2025"
    echo "  Account expires                                         : Dec 31, 2025"
    echo "  Minimum number of days between password change          : 7"
    echo "  Maximum number of days between password change          : 90"
    echo "  Number of days of warning before password expires       : 14"
    echo

    echo "  Step 2: Set the minimum number of days between password changes to 7 for 'fatima'."
    read -p "  lab@lab149:~$ " cmd2
    echo
    [[ "$cmd2" != "chage -m 7 fatima" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output)

    echo "  Step 3: Set the maximum number of days the password is valid to 90 for 'fatima'."
    read -p "  lab@lab149:~$ " cmd3
    echo
    [[ "$cmd3" != "chage -M 90 fatima" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output)

    echo "  Step 4: Set the warning period to 14 days before expiration for 'fatima'."
    read -p "  lab@lab149:~$ " cmd4
    echo
    [[ "$cmd4" != "chage -W 14 fatima" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output)

    echo "  Step 5: Set the inactive period to 30 days after password expiration for 'fatima'."
    read -p "  lab@lab149:~$ " cmd5
    echo
    [[ "$cmd5" != "chage -I 30 fatima" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output)

    echo "  Step 6: Set the account expiration date to 2025-12-31 for 'fatima'."
    read -p "  lab@lab149:~$ " cmd6
    echo
    [[ "$cmd6" != "chage -E 2025-12-31 fatima" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output)

    echo "  Step 7: Force 'fatima' to change her password at the next login."
    read -p "  lab@lab149:~$ " cmd7
    echo
    [[ "$cmd7" != "chage -d 0 fatima" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output)

    echo "  Step 8: Set the last password change date to 2025-06-01 for 'fatima'."
    read -p "  lab@lab149:~$ " cmd8
    echo
    [[ "$cmd8" != "chage -d 2025-06-01 fatima" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output)

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
