#!/bin/bash

# Lab 301: Setting and Managing Aliases – Objective 105.1 (Interactive, Simulated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 301"
LAB_ID="lab301"
LAB_XP=54400
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

PROMPT="student@lab301:~$ > "

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Objective 105.1 — Manage Aliases in Bash"
    center_text "Topics: Creating, viewing, removing aliases, and setting persistent aliases in environment files."
    echo
    center_text "Press Enter to begin."
    read _
    draw_lab_ui

    echo "  Step 1: Display all currently defined aliases in the shell environment."
    read -p "  $PROMPT" cmd1
    echo
    if [[ "$cmd1" != "alias" && "$cmd1" != "alias -p" ]]; then
        print_error "Incorrect. Use the command that displays all active aliases."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  alias vi='vim'"
    echo

    echo "  Step 2: Create a new alias named 'cls' that clears the terminal screen."
    read -p "  $PROMPT" cmd2
    echo
    if [[ "$cmd2" != "alias cls='clear'" ]]; then
        print_error "Incorrect. Use the alias command to create a shortcut that runs 'clear'."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Alias 'cls' created (simulated)."
    echo

    echo "  Step 3: Display only the definition of the alias you just created."
    read -p "  $PROMPT" cmd3
    echo
    if [[ "$cmd3" != "alias cls" ]]; then
        print_error "Incorrect. Use the alias command followed by the alias name."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  alias cls='clear'"
    echo

    echo "  Step 4: Remove the alias you just created."
    read -p "  $PROMPT" cmd4
    echo
    if [[ "$cmd4" != "unalias cls" ]]; then
        print_error "Incorrect. Use the command that removes an alias definition."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Alias 'cls' removed."
    echo

    echo "  Step 5: Show how to remove all aliases currently set in the shell environment."
    read -p "  $PROMPT" cmd5
    echo
    if [[ "$cmd5" != "unalias -a" ]]; then
        print_error "Incorrect. Use the command that removes all aliases at once."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  All aliases removed."
    echo

    echo "  Step 6: Create an alias that modifies the default behavior of 'ls' to show colorized output with long listing."
    read -p "  $PROMPT" cmd6
    echo
    if [[ "$cmd6" != "alias ls='ls -la --color=auto'" ]]; then
        print_error "Incorrect. Create an alias that automatically adds long listing and colorized output options to 'ls'."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Alias for 'ls' created."
    echo

    echo "  Step 7: Make sure that aliases persist across sessions. Identify the user-specific configuration file where aliases are typically stored."
    read -p "  $PROMPT" cmd7
    echo
    if [[ "$cmd7" != "~/.bashrc" && "$cmd7" != "$HOME/.bashrc" ]]; then
        print_error "Incorrect. Identify the file commonly used to store persistent aliases for individual users."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  ~/.bashrc"
    echo

    echo "  Step 8: Add a persistent alias definition for 'grep' that enables color highlighting of search matches."
    read -p "  $PROMPT" cmd8
    echo
    if [[ "$cmd8" != "echo \"alias grep='grep --color=auto'\" >> ~/.bashrc" ]]; then
        print_error "Incorrect. Use a redirection command to append the alias definition to your Bash configuration file."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  (Simulated) Alias for 'grep' added to ~/.bashrc"
    echo

    echo "  Step 9: Load your updated Bash configuration file so that new aliases become active immediately."
    read -p "  $PROMPT" cmd9
    echo
    if [[ "$cmd9" != "source ~/.bashrc" ]]; then
        print_error "Incorrect. Use the command that re-reads and applies Bash configuration changes."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  (Simulated) Configuration reloaded."
    echo

    echo "  Step 10: Check whether the 'grep' alias is now active."
    read -p "  $PROMPT" cmd10
    echo
    if [[ "$cmd10" != "alias grep" ]]; then
        print_error "Incorrect. Use the alias command to display the definition of a specific alias."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  alias grep='grep --color=auto'"
    echo

    echo "  Step 11: Some aliases come preconfigured globally for all users. Identify the directory that may contain global alias settings."
    read -p "  $PROMPT" cmd11
    echo
    if [[ "$cmd11" != "/etc/profile.d" ]]; then
        print_error "Incorrect. Identify the directory commonly containing global initialization scripts."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  /etc/profile.d"
    echo

    echo "  Step 12: Display all currently active aliases again to review the environment."
    read -p "  $PROMPT" cmd12
    echo
    if [[ "$cmd12" != "alias" && "$cmd12" != "alias -p" ]]; then
        print_error "Incorrect. Use the command that lists all defined aliases."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  alias ls='ls -la --color=auto'"
    echo "  alias grep='grep --color=auto'"
    echo "  alias vi='vim'"
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
