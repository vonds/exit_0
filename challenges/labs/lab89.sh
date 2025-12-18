#!/bin/bash

# Lab 89: Managing User Passwords and Aging Policies

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 89: Managing User Passwords and Aging Policies"
LAB_ID="lab89"
LAB_XP=2250
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
    center_text "Scenario: A new user account has been created on a production system."
    center_text "You need to set an initial password, enforce a password change at next login,"
    center_text "and configure password aging."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Create the user account appuser (if it does not already exist)."
    read -p "  lab@lpic-lab89:~$ " cmd1
    echo
    if [[ "$cmd1" != "sudo useradd -m appuser" ]]; then
        print_error "Incorrect. Use: sudo useradd -m appuser"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  User appuser created."
    echo

    echo "  Step 2: Set an initial password for appuser."
    read -p "  lab@lpic-lab89:~$ " cmd2
    echo
    if [[ "$cmd2" != "sudo passwd appuser" ]]; then
        print_error "Incorrect. Use: sudo passwd appuser"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Changing password for user appuser."
    echo "  New password: ********"
    echo "  Retype new password: ********"
    echo "  passwd: password updated successfully"
    echo

    echo "  Step 3: Force appuser to change the password at next login."
    read -p "  lab@lpic-lab89:~$ " cmd3
    echo
    if [[ "$cmd3" != "sudo passwd -e appuser" ]]; then
        print_error "Incorrect. Use: sudo passwd -e appuser"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  passwd: password expiry information changed."
    echo "  appuser will be forced to reset their password on next login."
    echo

    echo "  Step 4: Display current password aging information for appuser."
    read -p "  lab@lpic-lab89:~$ " cmd4
    echo
    if [[ "$cmd4" != "sudo chage -l appuser" ]]; then
        print_error "Incorrect. Use: sudo chage -l appuser"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Last password change                                    : Jan 01, 2025"
    echo "  Password expires                                        : Jan 01, 1970"
    echo "  Password inactive                                       : never"
    echo "  Account expires                                         : never"
    echo "  Minimum number of days between password change          : 0"
    echo "  Maximum number of days between password change          : 99999"
    echo "  Number of days of warning before password expires       : 7"
    echo

    echo "  Step 5: Set a stricter password aging policy for appuser:"
    echo "          - Minimum days: 7"
    echo "          - Maximum days: 90"
    echo "          - Warning days: 7"
    read -p "  lab@lpic-lab89:~$ " cmd5
    echo
    if [[ "$cmd5" != "sudo chage -m 7 -M 90 -W 7 appuser" ]]; then
        print_error "Incorrect. Use: sudo chage -m 7 -M 90 -W 7 appuser"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Password aging policy updated for appuser."
    echo

    print_success "Lab complete."
    print_info "You earned $LAB_XP XP for completing this lab."
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON")
    LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
    export XP
    export LEVEL
    record_lab_completion

    completion_count=$(get_lab_completion_count)
    echo
    print_info "You have completed this lab $completion_count time(s)."
    echo
    center_text "Would you like to:"
    center_text "1) Retry this lab"
    center_text "2) Return to Sysadmin Lab Menu"
    echo
    read -p "  > " post_choice

    [[ "$post_choice" == "2" ]] && exit 0
done
