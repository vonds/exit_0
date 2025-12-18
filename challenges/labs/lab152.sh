#!/bin/bash

# Lab 152: userdel User Account Deletion

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 152: userdel User Account Deletion"
LAB_ID="lab152"
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
    center_text "Work with user deletion and cleanup using userdel."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Delete the user 'amina' but keep the home directory."
    read -p "  lab@lab152:~$ " cmd1
    echo
    [[ "$cmd1" != "userdel amina" ]] && { print_error "Incorrect. Try again."; read _; continue; }

    echo "  Step 2: Delete 'amina' and remove their home directory and mail spool."
    read -p "  lab@lab152:~$ " cmd2
    echo
    [[ "$cmd2" != "userdel -r amina" ]] && { print_error "Incorrect. Try again."; read _; continue; }

    echo "  Step 3: Delete 'amina' and force removal even if logged in."
    read -p "  lab@lab152:~$ " cmd3
    echo
    [[ "$cmd3" != "userdel -f amina" ]] && { print_error "Incorrect. Try again."; read _; continue; }

    echo "  Step 4: Delete 'amina' and remove the home directory forcibly."
    read -p "  lab@lab152:~$ " cmd4
    echo
    [[ "$cmd4" != "userdel -r -f amina" ]] && { print_error "Incorrect. Try again."; read _; continue; }

    echo "  Step 5: Delete a user with UID 1055 (assume mapped)."
    read -p "  lab@lab152:~$ " cmd5
    echo
    [[ "$cmd5" != "userdel 1055" ]] && { print_error "Incorrect. Try again."; read _; continue; }

    echo "  Step 6: Which option forces userdel if logged in?"
    read -p "  lab@lab152:~$ " cmd6
    echo
    [[ "$cmd6" != "-f" ]] && { print_error "Incorrect. Try again."; read _; continue; }

    echo "  Step 7: Which file is always updated when userdel removes a user?"
    read -p "  lab@lab152:~$ " cmd7
    echo
    [[ "$cmd7" != "/etc/passwd" ]] && { print_error "Incorrect. Try again."; read _; continue; }

    echo "  Step 8: Which other critical files are updated?"
    read -p "  lab@lab152:~$ " cmd8
    echo
    [[ "$cmd8" != "/etc/shadow /etc/group /etc/gshadow" ]] && { print_error "Incorrect. Try again."; read _; continue; }

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
