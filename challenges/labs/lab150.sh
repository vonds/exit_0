#!/bin/bash

# Lab 150: useradd User Creation and Defaults

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 150: useradd User Creation and Defaults"
LAB_ID="lab150"
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
    center_text "Work with user creation options and defaults using useradd."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Show system-wide default settings for useradd."
    read -p "  lab@lab150:~$ " cmd1
    echo
    [[ "$cmd1" != "useradd -D" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output)

    echo "  Step 2: Create user 'satoshi' with a home directory."
    read -p "  lab@lab150:~$ " cmd2
    echo
    [[ "$cmd2" != "useradd -m satoshi" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output)

    echo "  Step 3: Create 'satoshi' with explicit home '/home/satoshi' and shell '/bin/bash'."
    read -p "  lab@lab150:~$ " cmd3
    echo
    [[ "$cmd3" != "useradd -m -d /home/satoshi -s /bin/bash satoshi" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output)

    echo "  Step 4: Create 'satoshi' with primary group 'developers'."
    read -p "  lab@lab150:~$ " cmd4
    echo
    [[ "$cmd4" != "useradd -m -g developers satoshi" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output)

    echo "  Step 5: Add 'satoshi' to supplementary groups 'docker' and 'wheel'."
    read -p "  lab@lab150:~$ " cmd5
    echo
    [[ "$cmd5" != "useradd -m -G docker,wheel satoshi" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output)

    echo "  Step 6: Create 'satoshi' with a specific UID of 1055."
    read -p "  lab@lab150:~$ " cmd6
    echo
    [[ "$cmd6" != "useradd -m -u 1055 satoshi" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output)

    echo "  Step 7: Set the GECOS/comment field to 'Satoshi Nakamoto' when creating 'satoshi'."
    read -p "  lab@lab150:~$ " cmd7
    echo
    [[ "$cmd7" != 'useradd -m -c "Satoshi Nakamoto" satoshi' ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output)

    echo "  Step 8: Set an account expiration date of 2025-12-31 for 'satoshi'."
    read -p "  lab@lab150:~$ " cmd8
    echo
    [[ "$cmd8" != "useradd -m -e 2025-12-31 satoshi" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output)

    echo "  Step 9: Set the password INACTIVE period to 30 days after expiration for 'satoshi'."
    read -p "  lab@lab150:~$ " cmd9
    echo
    [[ "$cmd9" != "useradd -m -f 30 satoshi" ]] && {
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    }
    # (No output)

    echo "  Step 10: Create 'satoshi' using a custom skeleton directory '/etc/skel-custom'."
    read -p "  lab@lab150:~$ " cmd10
    echo
    [[ "$cmd10" != "useradd -m -k /etc/skel-custom satoshi" ]] && {
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
