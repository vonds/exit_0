#!/bin/bash

# Lab 304: Shell Options with 'set' – Objective 105.1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 304"
LAB_ID="lab304"
LAB_XP=26400
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"

[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

draw_lab_ui() {
    clear
    center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
    center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
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

PROMPT="student@lab304:~$ > "

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Objective 105.1 — Focus: Bash 'set' switches/options only"
    center_text "Practice viewing and toggling key options: -b -e -n -t -C -a"
    echo
    center_text "Press Enter to begin."
    read _
    draw_lab_ui

    echo "  Step 1: Display current shell options in concise format."
    read -p "  $PROMPT" cmd1
    echo
    if [[ "$cmd1" != "set -o" && "$cmd1" != "set -o | less" ]]; then
        print_error "Incorrect. Use: set -o"
        read -p "Press Enter to continue..." _
        continue
    fi
    echo "  allexport        off"
    echo "  errexit          off"
    echo "  noclobber        off"
    echo "  noexec           off"
    echo "  notify           off"
    echo "  onecmd           off"
    echo

    echo "  Step 2: Turn on immediate background job notifications."
    read -p "  $PROMPT" cmd2
    echo
    if [[ "$cmd2" != "set -b" ]]; then
        print_error "Incorrect. Use: set -b"
        read -p "Press Enter to continue..." _
        continue
    fi
    echo "  notify           on"
    echo

    echo "  Step 3: Turn notifications back off."
    read -p "  $PROMPT" cmd3
    echo
    if [[ "$cmd3" != "set +b" ]]; then
        print_error "Incorrect. Use: set +b"
        read -p "Press Enter to continue..." _
        continue
    fi
    echo "  notify           off"
    echo

    echo "  Step 4: Enable error-exit behavior."
    read -p "  $PROMPT" cmd4
    echo
    if [[ "$cmd4" != "set -e" ]]; then
        print_error "Incorrect. Use: set -e"
        read -p "Press Enter to continue..." _
        continue
    fi
    echo "  errexit          on"
    echo

    echo "  Step 5: Disable error-exit behavior."
    read -p "  $PROMPT" cmd5
    echo
    if [[ "$cmd5" != "set +e" ]]; then
        print_error "Incorrect. Use: set +e"
        read -p "Press Enter to continue..." _
        continue
    fi
    echo "  errexit          off"
    echo

    echo "  Step 6: Enable no-exec (syntax check only)."
    read -p "  $PROMPT" cmd6
    echo
    if [[ "$cmd6" != "set -n" ]]; then
        print_error "Incorrect. Use: set -n"
        read -p "Press Enter to continue..." _
        continue
    fi
    echo "  noexec           on"
    echo

    echo "  Step 7: Disable no-exec."
    read -p "  $PROMPT" cmd7
    echo
    if [[ "$cmd7" != "set +n" ]]; then
        print_error "Incorrect. Use: set +n"
        read -p "Press Enter to continue..." _
        continue
    fi
    echo "  noexec           off"
    echo

    echo "  Step 8: Enable one-command mode."
    read -p "  $PROMPT" cmd8
    echo
    if [[ "$cmd8" != "set -t" ]]; then
        print_error "Incorrect. Use: set -t"
        read -p "Press Enter to continue..." _
        continue
    fi
    echo "  onecmd           on"
    echo

    echo "  Step 9: Disable one-command mode."
    read -p "  $PROMPT" cmd9
    echo
    if [[ "$cmd9" != "set +t" ]]; then
        print_error "Incorrect. Use: set +t"
        read -p "Press Enter to continue..." _
        continue
    fi
    echo "  onecmd           off"
    echo

    echo "  Step 10: Enable noclobber to prevent overwriting with > redirection."
    read -p "  $PROMPT" cmd10
    echo
    if [[ "$cmd10" != "set -C" ]]; then
        print_error "Incorrect. Use: set -C"
        read -p "Press Enter to continue..." _
        continue
    fi
    echo "  noclobber        on"
    echo

    echo "  Step 11: Disable noclobber."
    read -p "  $PROMPT" cmd11
    echo
    if [[ "$cmd11" != "set +C" ]]; then
        print_error "Incorrect. Use: set +C"
        read -p "Press Enter to continue..." _
        continue
    fi
    echo "  noclobber        off"
    echo

    echo "  Step 12: Turn on allexport so new variables are exported by default."
    read -p "  $PROMPT" cmd12
    echo
    if [[ "$cmd12" != "set -a" ]]; then
        print_error "Incorrect. Use: set -a"
        read -p "Press Enter to continue..." _
        continue
    fi
    echo "  allexport        on"
    echo

    echo "  Step 13: Turn allexport back off."
    read -p "  $PROMPT" cmd13
    echo
    if [[ "$cmd13" != "set +a" ]]; then
        print_error "Incorrect. Use: set +a"
        read -p "Press Enter to continue..." _
        continue
    fi
    echo "  allexport        off"
    echo

    echo "  Step 14: Show options again to confirm final states."
    read -p "  $PROMPT" cmd14
    echo
    if [[ "$cmd14" != "set -o" && "$cmd14" != "set -o | less" ]]; then
        print_error "Incorrect. Use: set -o"
        read -p "Press Enter to continue..." _
        continue
    fi
    echo "  allexport        off"
    echo "  errexit          off"
    echo "  noclobber        off"
    echo "  noexec           off"
    echo "  notify           off"
    echo "  onecmd           off"
    echo

    print_success "Excellent work!"
    print_info "You earned $LAB_XP XP for completing this lab!"
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON")
    LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
    export XP
    export LEVEL
    record_lab_completion

    completion_count=$(get_lab_completion_count)
    echo
    print_info "You've successfully completed this lab $completion_count time(s)."
    echo
    center_text "Would you like to:"
    center_text "1) Retry this lab"
    center_text "2) Return to Sysadmin Lab Menu"
    echo
    read -p "  > " choice

    if [[ "$choice" == "2" ]]; then
        exit 0
    fi
done
