#!/bin/bash

# Lab 55: Environment Variables

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 55: Environment Variables"
LAB_ID="lab55"
LAB_XP=22100
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
    center_text "You're troubleshooting a user issue related to PATH and custom environment variables."
    center_text "You'll inspect and modify environment variables, then export changes."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: View the current value of the PATH environment variable."
    read -p "  lab@env-lab:~$ " cmd1
    echo
    [[ "$cmd1" != "echo \$PATH" ]] && {
        print_error "Incorrect. Use echo \$PATH to print the PATH variable."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    echo

    echo "  Step 2: View all currently defined environment variables."
    read -p "  lab@env-lab:~$ " cmd2
    echo
    [[ "$cmd2" != "printenv" && "$cmd2" != "env" ]] && {
        print_error "Incorrect. Use env or printenv to list all environment variables."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  SHELL=/bin/bash"
    echo "  USER=lab"
    echo "  LOGNAME=lab"
    echo "  HOME=/home/lab"
    echo "  PWD=/home/lab"
    echo "  OLDPWD=/home/lab"
    echo "  HOSTNAME=env-lab"
    echo "  PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    echo "  LANG=en_US.UTF-8"
    echo "  LANGUAGE=en_US:en"
    echo "  TERM=xterm-256color"
    echo "  SHLVL=1"
    echo "  MAIL=/var/mail/lab"
    echo "  HISTSIZE=1000"
    echo "  HISTFILE=/home/lab/.bash_history"
    echo "  HISTCONTROL=ignoredups:ignorespace"
    echo "  EDITOR=vim"
    echo "  VISUAL=vim"
    echo "  PAGER=less"
    echo "  LESS=-R"
    echo "  TMPDIR=/tmp"
    echo "  XDG_RUNTIME_DIR=/run/user/1000"
    echo "  XDG_SESSION_ID=2"
    echo "  XDG_SESSION_TYPE=tty"
    echo "  XDG_CONFIG_HOME=/home/lab/.config"
    echo "  XDG_CACHE_HOME=/home/lab/.cache"
    echo "  XDG_DATA_HOME=/home/lab/.local/share"
    echo "  XDG_STATE_HOME=/home/lab/.local/state"
    echo "  MANPATH=/usr/local/man:/usr/local/share/man:/usr/share/man"
    echo "  GNUPGHOME=/home/lab/.gnupg"
    echo "  SSH_AGENT_PID="
    echo "  SSH_AUTH_SOCK="
    echo "  SUDO_USER="
    echo "  UID=1000"
    echo "  _=/usr/bin/printenv"
    echo

    echo "  Step 3: Create a new environment variable called PROJECT_DIR with the value /srv/app."
    read -p "  lab@env-lab:~$ " cmd3
    echo
    [[ "$cmd3" != "export PROJECT_DIR=/srv/app" ]] && {
        print_error "Incorrect. Use export PROJECT_DIR=/srv/app."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 4: Confirm PROJECT_DIR is now set."
    read -p "  lab@env-lab:~$ " cmd4
    echo
    [[ "$cmd4" != "echo \$PROJECT_DIR" ]] && {
        print_error "Incorrect. Use echo \$PROJECT_DIR to verify the value."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  /srv/app"
    echo

    echo "  Step 5: Make this variable persist across sessions."
    read -p "  lab@env-lab:~$ " cmd5
    echo
    [[ "$cmd5" != "echo 'export PROJECT_DIR=/srv/app' >> ~/.bashrc" ]] && {
        print_error "Incorrect. Append the export command to ~/.bashrc"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 6: Remove the PROJECT_DIR variable."
    read -p "  lab@env-lab:~$ " cmd6
    echo
    [[ "$cmd6" != "unset PROJECT_DIR" ]] && {
        print_error "Incorrect. Use unset PROJECT_DIR to remove the variable."
        read -p "Press Enter to try again..." _
        continue
    }

    print_success "Nice work!"
    print_info "You earned $LAB_XP XP for completing this lab."
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
    read -p "  > " post_choice
    [[ "$post_choice" == "2" ]] && exit 0

done
