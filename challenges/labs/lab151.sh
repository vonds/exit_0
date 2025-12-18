#!/bin/bash

# Lab 151: usermod User Account Modification

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 151: usermod User Account Modification"
LAB_ID="lab151"
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
    center_text "Modify existing accounts with usermod."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Set the primary group of 'satoshi' to 'developers'."
    read -p "  lab@lab151:~$ " cmd1
    echo
    [[ "$cmd1" != "usermod -g developers satoshi" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output)

    echo "  Step 2: Add 'satoshi' to the supplementary groups 'docker' and 'wheel' (without removing existing groups)."
    read -p "  lab@lab151:~$ " cmd2
    echo
    [[ "$cmd2" != "usermod -aG docker,wheel satoshi" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output)

    echo "  Step 3: Change the login shell of 'satoshi' to /bin/zsh."
    read -p "  lab@lab151:~$ " cmd3
    echo
    [[ "$cmd3" != "usermod -s /bin/zsh satoshi" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output)

    echo "  Step 4: Change the home directory of 'satoshi' to /srv/satoshi and MOVE the current contents."
    read -p "  lab@lab151:~$ " cmd4
    echo
    [[ "$cmd4" != "usermod -d /srv/satoshi -m satoshi" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output)

    echo "  Step 5: Set the account expiration date for 'satoshi' to 2025-12-31."
    read -p "  lab@lab151:~$ " cmd5
    echo
    [[ "$cmd5" != "usermod -e 2025-12-31 satoshi" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output)

    echo "  Step 6: Lock the account of 'satoshi'."
    read -p "  lab@lab151:~$ " cmd6
    echo
    [[ "$cmd6" != "usermod -L satoshi" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output)

    echo "  Step 7: Unlock the account of 'satoshi'."
    read -p "  lab@lab151:~$ " cmd7
    echo
    [[ "$cmd7" != "usermod -U satoshi" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output)

    echo "  Step 8: Change the UID of 'satoshi' to 1055."
    read -p "  lab@lab151:~$ " cmd8
    echo
    [[ "$cmd8" != "usermod -u 1055 satoshi" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output)

    echo "  Step 9: Set the GECOS/comment field of 'satoshi' to 'Satoshi Nakamoto'."
    read -p "  lab@lab151:~$ " cmd9
    echo
    [[ "$cmd9" != 'usermod -c "Satoshi Nakamoto" satoshi' ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output)

    echo "  Step 10: Rename the login name from 'satoshi' to 'satoshi-renamed'."
    read -p "  lab@lab151:~$ " cmd10
    echo
    [[ "$cmd10" != "usermod -l satoshi-renamed satoshi" ]] && {
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
