#!/bin/bash

# Lab 303: Setting Environment and User Variables – Objective 105.1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 303"
LAB_ID="lab303"
LAB_XP=56000
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

PROMPT="student@lab303:~$ > "

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Objective 105.1 — Setting Environment and User Variables"
    center_text "Topics: Viewing variables, creating/modifying/unsetting, PATH updates, persistent settings, shell options."
    echo
    center_text "Press Enter to begin."
    read _
    draw_lab_ui

    echo "  Step 1: Display all currently defined shell variables (environment and user-defined)."
    read -p "  $PROMPT" cmd1
    echo
    if [[ "$cmd1" != "set" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to continue..." _
        continue
    fi
    echo "  BASH=/bin/bash"
    echo "  BASHOPTS=cmdhist:expand_aliases:interactive_comments:monitor"
    echo "  BASH_VERSION=5.1.16(1)-release"
    echo "  COLUMNS=120"
    echo "  EUID=1000"
    echo "  HISTCONTROL=ignoredups"
    echo "  HOME=/home/student"
    echo "  IFS=\$' \t\n'"
    echo "  LANG=en_US.UTF-8"
    echo "  PATH=/usr/local/bin:/usr/bin:/bin"
    echo "  PPID=12345"
    echo "  PS1='\\u@\\h:\\w\\$ '"
    echo "  PWD=/home/student"
    echo "  SHELL=/bin/bash"
    echo "  SHLVL=1"
    echo

    echo "  Step 2: Display only environment variables."
    read -p "  $PROMPT" cmd2
    echo
    if [[ "$cmd2" != "env" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to continue..." _
        continue
    fi
    echo "  SHELL=/bin/bash"
    echo "  USER=student"
    echo "  LOGNAME=student"
    echo "  HOME=/home/student"
    echo "  PWD=/home/student"
    echo "  LANG=en_US.UTF-8"
    echo "  TERM=xterm-256color"
    echo "  PATH=/usr/local/bin:/usr/bin:/bin"
    echo "  SHLVL=1"
    echo "  _=/usr/bin/env"
    echo

    echo "  Step 3: Display the PATH variable using a command designed for that purpose."
    read -p "  $PROMPT" cmd3
    echo
    if [[ "$cmd3" != "printenv PATH" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to continue..." _
        continue
    fi
    echo "  /usr/local/bin:/usr/bin:/bin"
    echo

    echo "  Step 4: Create a user-defined variable (MYVAR) with the value 'hello'."
    read -p "  $PROMPT" cmd4
    echo
    if [[ "$cmd4" != "MYVAR=hello" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to continue..." _
        continue
    fi

    echo "  Step 5: Display the value of the variable you just created."
    read -p "  $PROMPT" cmd5
    echo
    if [[ "$cmd5" != "echo \$MYVAR" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to continue..." _
        continue
    fi
    echo "  hello"
    echo

    echo "  Step 6: Remove the variable from the current shell session."
    read -p "  $PROMPT" cmd6
    echo
    if [[ "$cmd6" != "unset MYVAR" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to continue..." _
        continue
    fi

    echo "  Step 7: Extend your PATH variable to include this directory /home/student/big_project while keeping existing entries."
    read -p "  $PROMPT" cmd7
    echo
    if [[ "$cmd7" != "export PATH=\$PATH:/home/student/big_project" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to continue..." _
        continue
    fi


    echo "  Step 8: Display the current PATH variable."
    read -p "  $PROMPT" cmd8
    echo
    if [[ "$cmd8" != "echo \$PATH" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to continue..." _
        continue
    fi
    echo "  /usr/local/bin:/usr/bin:/bin:/home/student/big_project"
    echo

    echo "  Step 9: Identify the user startup file where variable settings are made persistent."
    read -p "  $PROMPT" cmd9
    echo
    if [[ "$cmd9" != "~/.bashrc" && "$cmd9" != "$HOME/.bashrc" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to continue..." _
        continue
    fi


    echo "  Step 10: Modify the shell prompt to '$ '."
    read -p "  $PROMPT" cmd10
    echo
    if [[ "$cmd10" != "PS1='\$ '" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to continue..." _
        continue
    fi
    PROMPT="\$ > "
    echo


    echo "  Step 11: Reload your shell configuration file."
    read -p "  $PROMPT" cmd11
    echo
    if [[ "$cmd11" != "source ~/.bashrc" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to continue..." _
        continue
    fi
    PROMPT="student@lab303:~$ > "
    echo

    echo "  Step 12: Display current shell options (flags)."
    read -p "  $PROMPT" cmd12
    echo
    if [[ "$cmd12" != "set -o" && "$cmd12" != "set -o | less" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to continue..." _
        continue
    fi
    echo "  allexport        off"
    echo "  braceexpand      on"
    echo "  emacs            on"
    echo "  errexit          off"
    echo "  errtrace         off"
    echo "  functrace        off"
    echo "  hashall          on"
    echo "  histexpand       on"
    echo "  history          on"
    echo "  ignoreeof        off"
    echo "  interactive-comments on"
    echo "  monitor          on"
    echo "  noclobber        off"
    echo "  noexec           off"
    echo "  noglob           off"
    echo "  nolog            off"
    echo "  notify           off"
    echo "  nounset          off"
    echo "  onecmd           off"
    echo "  physical         off"
    echo "  pipefail         off"
    echo "  posix            off"
    echo "  privileged       off"
    echo "  verbose          off"
    echo "  vi               off"
    echo "  xtrace           off"
    echo

    echo "  Step 13: Turn on the allexport shell option using the correct syntax."
    read -p "  $PROMPT" cmd13
    echo
    if [[ "$cmd13" != "set -a" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to continue..." _
        continue
    fi

    echo "  Step 14: Turn the shell allexport option back off."
    read -p "  $PROMPT" cmd14
    echo
    if [[ "$cmd14" != "set +a" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to continue..." _
        continue
    fi

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
