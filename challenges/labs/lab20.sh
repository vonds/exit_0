#!/bin/bash

# Lab 20: Manage Environment Variables and Shell Startup Scripts

# Dynamically locate root directory and source core scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 20: Manage Environment Variables and Shell Startup Scripts"
LAB_ID="lab20"
LAB_XP=3300
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
    # Robust increment even if key is missing
    jq --arg lab "$LAB_ID" '.[$lab] = ((.[$lab] // 0) + 1)' "$LAB_TRACK_FILE" > "$tmpfile" && mv "$tmpfile" "$LAB_TRACK_FILE"
}

get_lab_completion_count() {
    jq -r --arg lab "$LAB_ID" '.[$lab] // 0' "$LAB_TRACK_FILE"
}

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "You're tasked with reviewing and modifying shell environment"
    center_text "variables, including PATH changes and persistent exports across login shells."
    echo
    center_text "Press Enter to begin the lab..."
    read _
    draw_lab_ui

    echo "  Step 1: What command shows all environment variables for the current shell?"
    read -p "  lab@lpic-lab20:~$ > " cmd1
    echo

    if [[ "$cmd1" != "printenv" && "$cmd1" != "env" ]]; then
        print_error "Incorrect. Try 'printenv' or 'env'."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    echo "  HOME=/home/lab"
    echo "  SHELL=/bin/bash"
    echo

    echo "  Step 2: What command sets a temporary environment variable FOO to 'bar'?"
    read -p "  lab@lpic-lab20:~$ > " cmd2
    echo

    if [[ "$cmd2" != "export FOO=bar" ]]; then
        print_error "Incorrect. Use export to create or modify variables."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Variable FOO set to 'bar'."
    echo

    echo "  Step 3: What file should you edit to make this variable permanent for bash login shells?"
    read -p "  lab@lpic-lab20:~$ > " cmd3
    echo

    if [[ "$cmd3" != "~/.bash_profile" && "$cmd3" != "~/.profile" && "$cmd3" != "~/.bash_login" ]]; then
        print_error "Incorrect. Use ~/.bash_profile, ~/.bash_login, or ~/.profile (depending on system config)."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Correct. You’d add: export FOO=bar"
    echo

    echo "  Step 4: What command temporarily appends /opt/scripts to the PATH?"
    read -p "  lab@lpic-lab20:~$ > " cmd4
    echo

    if [[ "$cmd4" != "export PATH=\$PATH:/opt/scripts" ]]; then
        print_error "Incorrect. You must preserve the existing PATH with \$PATH expansion."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  PATH updated for this session."
    echo

    echo "  Step 5: What file system-wide sets environment variables for all users?"
    read -p "  lab@lpic-lab20:~$ > " cmd5
    echo

    if [[ "$cmd5" != "/etc/environment" ]]; then
        print_error "Incorrect. /etc/environment is used for global env vars at login."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  /etc/environment is used for global env vars."
    echo

    print_success "Excellent!"
    print_info "You examined current environment variables, set and exported new ones,"
    print_info "modified the PATH, and identified the correct startup files."
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
    else
        # any other input repeats the lab
        continue
    fi
done
.