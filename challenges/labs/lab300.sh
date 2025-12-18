#!/bin/bash

# Lab 300: Exploring Environment Files – Objective 105.1 (Interactive, Simulated)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 300"
LAB_ID="lab300"
LAB_XP=51200
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

# Fully simulated: no real commands are executed or files modified.
PROMPT="student@lab300:~$ > "

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Objective 105.1 — Explore global & local Bash environment files"
    center_text "Coverage: /etc/profile, /etc/bashrc or /etc/bash.bashrc, ~/.bash_profile, ~/.bash_login,"
    center_text "~/.profile, ~/.bashrc, ~/.bash_logout, precedence, /etc/skel, PS1, EDITOR, aliases."
    echo
    center_text "Press Enter to begin."
    read _
    draw_lab_ui

    echo "  Step 1: Show the primary global environment files on RHEL-like systems (paths only)."
    read -p "  $PROMPT" cmd1
    echo
    if [[ "$cmd1" != "ls -ld /etc/profile /etc/bashrc" ]]; then
        print_error "Incorrect. Use: ls -ld /etc/profile /etc/bashrc"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  -rw-r--r-- root root /etc/profile"
    echo "  -rw-r--r-- root root /etc/bashrc"
    echo

    echo "  Step 2: On Debian/Ubuntu, what is the global interactive Bash config file path?"
    read -p "  $PROMPT" cmd2
    echo
    if [[ "$cmd2" != "/etc/bash.bashrc" ]]; then
        print_error "Incorrect. Answer with: /etc/bash.bashrc"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  /etc/bash.bashrc"
    echo

    echo "  Step 3: For a Bash LOGIN shell, which user file is checked and run first if it exists?"
    read -p "  $PROMPT" cmd3
    echo
    if [[ "$cmd3" != "~/.bash_profile" ]]; then
        print_error "Incorrect. Answer with: ~/.bash_profile"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  ~/.bash_profile"
    echo

    echo "  Step 4: If ~/.bash_profile is not present, what are the next two files in order?"
    read -p "  $PROMPT" cmd4
    echo
    if [[ "$cmd4" != "~/.bash_login then ~/.profile" && "$cmd5" != "$HOME/.bash_login then $HOME/.profile" ]]; then
        print_error "Incorrect. Answer exactly: ~/.bash_login then ~/.profile"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  ~/.bash_login then ~/.profile"
    echo

    echo "  Step 5: For an interactive NON-LOGIN Bash shell, which user file is typically read?"
    read -p "  $PROMPT" cmd5
    echo
    if [[ "$cmd5" != "~/.bashrc" && "$cmd6" != "$HOME/.bashrc" ]]; then
        print_error "Incorrect. Answer with: ~/.bashrc"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  ~/.bashrc"
    echo

    echo "  Step 6: Where are default skeleton dotfiles for new users located? (directory path)"
    read -p "  $PROMPT" cmd6
    echo
    if [[ "$cmd6" != "/etc/skel" ]]; then
        print_error "Incorrect. Answer with: /etc/skel"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  /etc/skel"
    echo

    echo "  Step 7: Append a new alias to clear the screen (alias name: cls) to ~/.bashrc."
    read -p "  $PROMPT" cmd7
    echo
    if [[ "$cmd7" != "echo \"alias cls='clear'\" >> ~/.bashrc" ]]; then
        print_error "Incorrect. Use: echo \"alias cls='clear'\" >> ~/.bashrc"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi


    echo "  Step 8: Load your ~/.bashrc changes now."
    read -p "  $PROMPT" cmd8
    echo
    if [[ "$cmd8" != "source ~/.bashrc" ]]; then
        print_error "Incorrect. Use: source ~/.bashrc"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi


    echo "  Step 9: Verify the alias by listing aliases and grepping for cls."
    read -p "  $PROMPT" cmd9
    echo
    if [[ "$cmd9" != "alias | grep '^alias cls='" ]]; then
        print_error "Incorrect. Use: alias | grep '^alias cls='"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  alias cls='clear'"
    echo

    echo "  Step 10: Set your default editor to vim for THIS SESSION ONLY and verify (two commands)."
    read -p "  $PROMPT" cmd10a
    read -p "  $PROMPT" cmd10b
    echo
    if [[ "$cmd10a" != "export EDITOR=vim" || "$cmd10b" != "echo \$EDITOR" ]]; then
        print_error "Incorrect. Use:"
        echo "  export EDITOR=vim"
        echo "  echo \$EDITOR"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  vim"
    echo

    echo "  Step 11: Set a minimal prompt for this session only. Set PS1 exactly to a dollar-sign and space."
    read -p "  $PROMPT" cmd11
    echo
    if [[ "$cmd11" != "PS1='$ '" ]]; then
        print_error "Incorrect. Use: PS1='\\$ '"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi


    echo "  Step 12: Which ONE user file is safest to centralize personal tweaks so all shells can inherit"
    echo "           them via sourcing from login files? Answer with the file path."
    read -p "  $PROMPT" cmd12
    echo
    if [[ "$cmd12" != "~/.bashrc" ]]; then
        print_error "Incorrect. Answer with: ~/.bashrc"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  ~/.bashrc"
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
