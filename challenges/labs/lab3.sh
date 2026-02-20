#!/bin/bash

# Lab 3: Basic sed Substitution

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 3: Basic sed Substitution"
LAB_ID="lab3"
LAB_XP=1350
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"

[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

draw_lab_ui() {
    clear
    center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
    center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
    echo
    echo
    echo
    echo
}

record_lab_completion() {
    tmpfile=$(mktemp)
    jq --arg lab "$LAB_ID" '.[$lab] += 1 // 1' "$LAB_TRACK_FILE" > "$tmpfile" && mv "$tmpfile" "$LAB_TRACK_FILE"
}

get_lab_completion_count() {
    jq -r --arg lab "$LAB_ID" '.[$lab] // 0' "$LAB_TRACK_FILE"
}

# Begin Lab
while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "You’ve been handed a config file called 'webserver.conf' with a typo."
    center_text "All instances of 'protcol' need to be corrected to 'protocol'."
    center_text "You're expected to use 'sed' to fix it across the entire file in-place."
    echo
    center_text "Press Enter to begin the lab..."
    read _
    draw_lab_ui

    echo "  Step 1: Preview the contents of 'webserver.conf'."
    read -p "  lab@lpic-lab3:~$ " cmd1
    echo

    if [[ "$cmd1" != "cat webserver.conf" ]]; then
        print_error "Incorrect. Hint: Use the 'cat' command to view the contents of the file."
        read -p "  Press Enter to try again..." _
        continue
    fi

    echo "  server_name localhost;"
    echo "  protcol http;"
    echo "  listen 80;"
    echo "  protcol must be set correctly."
    echo

    echo "  Step 2: What 'sed' command would you run to replace 'protcol' with 'protocol' in-place?"
    read -p "  lab@lpic-lab3:~$ " cmd2
    echo

    if [[ "$cmd2" != "sed -i 's/protcol/protocol/g' webserver.conf" ]]; then
        print_error "Incorrect. Hint: Use -i for in-place edit, and the correct substitution syntax."
        echo
        read -p "  Press Enter to try again..." _
        continue
    fi

    echo "  Step 3: Verify that the typo has been corrected by viewing the file again."
    read -p "  lab@lpic-lab3:~$ " cmd3
    echo

    if [[ "$cmd3" != "cat webserver.conf" ]]; then
        print_error "Incorrect. You should use 'cat webserver.conf' to verify the change."
        read -p "  Press Enter to try again..." _
        continue
    fi

    echo "  server_name localhost;"
    echo "  protocol http;"
    echo "  listen 80;"
    echo "  protocol must be set correctly."
    echo

    print_success "Great work!"
    print_info "You used sed to correct a recurring typo across a config file."
    print_info "You earned $LAB_XP XP for completing this lab!"
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON")
    LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
    export XP
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

    if [[ "$post_choice" == "2" ]]; then
        exit 0
    fi
done
