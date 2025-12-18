#!/bin/bash

# Lab 30: Communicating with Users - users, wall, and write

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 30: Communicating with Users"
LAB_ID="lab30"
LAB_XP=1450
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
    center_text "Scenario: A scheduled maintenance window is about to begin."
    center_text "Alert all logged-in users and notify a specific user about their open session."
    echo
    center_text "Press Enter to begin..."
    read _

    draw_lab_ui

    # Step 1: Enumerate users with TTYs (prefer who; accept users)
    echo "  Step 1: View currently logged-in users and their TTYs."
    read -p "  root@server01:~# " cmd1
    echo
    if [[ "$cmd1" == "who" ]]; then
        echo "  devstudent pts/0  2025-07-19 08:31 (:0)"
        echo "  sysmon     pts/1  2025-07-19 08:33 (10.0.0.15)"
        echo "  analyst    pts/2  2025-07-19 08:34 (10.0.0.42)"
    elif [[ "$cmd1" == "users" ]]; then
        echo "  devstudent sysmon analyst"
        echo "  (Tip: use 'who' to see TTYs for targeted messages)"
    else
        print_error "  Incorrect. Use 'who' (preferred) or 'users'."
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo

    # Step 2: Broadcast a one-line system-wide message with wall
    echo "  Step 2: Broadcast a system-wide message to all users."
    echo "          Use a single line command with the message text."
    read -p "  root@server01:~# " cmd2
    echo
    if [[ "$cmd2" != "wall \"System maintenance starts in 10 minutes. Please save your work.\"" \
          && "$cmd2" != "wall 'System maintenance starts in 10 minutes. Please save your work.'" ]]; then
        print_error "  Incorrect. Example: wall \"System maintenance starts in 10 minutes. Please save your work.\""
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  Broadcast message from root@server01 (tty1) (Fri Jul 19 08:35:12):"
    echo "  System maintenance starts in 10 minutes. Please save your work."
    echo

    # Step 3: Send a private message to 'analyst' on their TTY
    echo "  Step 3: Send a private message to 'analyst' on their session."
    read -p "  root@server01:~# " cmd3
    echo
    if [[ "$cmd3" != "write analyst pts/2" ]]; then
        print_error "  Incorrect. Use: write analyst pts/2   (match the TTY you saw in Step 1)"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  [write session open - type your message and press Ctrl+D to send]"
    echo "  Hi analyst, please log off before 08:45 for scheduled maintenance."
    echo "  [Message sent]"
    echo

    print_success "User communication complete."
    print_info "You earned $LAB_XP XP for correctly using who/users, wall, and write."
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON")
    LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
    export XP
    export LEVEL
    record_lab_completion

    completion_count=$(get_lab_completion_count)
    echo
    print_info "You've completed this lab $completion_count time(s)."
    echo
    center_text "Would you like to:"
    center_text "1) Retry this lab"
    center_text "2) Return to Sysadmin Lab Menu"
    echo
    read -p "  > " post_choice

    [[ "$post_choice" == "2" ]] && exit 0
done
