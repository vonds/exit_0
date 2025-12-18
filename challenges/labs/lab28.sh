#!/bin/bash

# Lab 28: Switching Users and Sudo Access (Realistic Responses)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 28: Switching Users and Sudo Access"
LAB_ID="lab28"
LAB_XP=2748
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

TEMP_USER="tempsudo"

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
    center_text "You're training a junior admin on switching users and using sudo privileges properly."
    center_text "Your task is to demonstrate sudo usage, a root shell, and privilege escalation best practices."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui

    # ---- Step 1: Run a privileged command with sudo (from regular user) ----
    echo "  Step 1: Run a privileged command with sudo to list /root."
    read -p "  lab@lpic-lab28:~$ " cmd1
    echo
    if [[ "$cmd1" != "sudo ls /root" ]]; then
        print_error "  Incorrect. Use: sudo ls /root"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo -e "  [sudo] password for lab:\n  file1.txt  backup.tar.gz"
    echo

    # ---- Step 2: Gain a root shell (portable way) ----
    echo "  Step 2: Start a root shell to perform administrative tasks."
    read -p "  lab@lpic-lab28:~$ " cmd2
    echo
    if [[ "$cmd2" != "sudo -i" ]]; then
        print_error "  Incorrect. Use: sudo -i"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo

    # ---- Step 3: Add a new user '$TEMP_USER' (as root) ----
    echo "  Step 3: Add a new user '$TEMP_USER'."
    read -p "  root@lpic-lab28:~# " cmd3
    echo
    if [[ "$cmd3" != "useradd $TEMP_USER" ]]; then
        print_error "  Incorrect. Use: useradd $TEMP_USER"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo

    # ---- Step 4: Set a password for '$TEMP_USER' (as root) ----
    echo "  Step 4: Set a password for '$TEMP_USER'."
    read -p "  root@lpic-lab28:~# " cmd4
    echo
    if [[ "$cmd4" != "passwd $TEMP_USER" ]]; then
        print_error "  Incorrect. Use: passwd $TEMP_USER"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo

    # ---- Step 5: Grant sudo via group (Debian/Ubuntu: 'sudo'; RHEL family uses 'wheel') ----
    echo "  Step 5: Grant sudo privileges by adding '$TEMP_USER' to the 'sudo' group."
    echo "          (Note: On RHEL-family systems, use the 'wheel' group instead.)"
    read -p "  root@lpic-lab28:~# " cmd5
    echo
    if [[ "$cmd5" != "usermod -aG sudo $TEMP_USER" && "$cmd5" != "usermod -aG wheel $TEMP_USER" ]]; then
        print_error "  Incorrect. Use: usermod -aG sudo $TEMP_USER   (or wheel on RHEL-family)"
        read -p "  Press Enter to try again..." _
        continue
    fi
    if [[ "$cmd5" == *"wheel"* ]]; then
        echo "  User '$TEMP_USER' added to 'wheel' group."
    else
        echo "  User '$TEMP_USER' added to 'sudo' group."
    fi
    echo

    # ---- Step 6: Exit root shell back to regular user ----
    echo "  Step 6: Exit the root shell."
    read -p "  root@lpic-lab28:~# " cmd6
    echo
    if [[ "$cmd6" != "exit" ]]; then
        print_error "  Incorrect. Type: exit"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  lab@lpic-lab28:~$"
    echo

    # ---- Step 7: Switch to '$TEMP_USER' ----
    echo "  Step 7: Switch to '$TEMP_USER' with a login shell."
    read -p "  lab@lpic-lab28:~$ " cmd7
    echo
    if [[ "$cmd7" != "su - $TEMP_USER" ]]; then
        print_error "  Incorrect. Use: su - $TEMP_USER"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo "  Password:"
    echo "  $TEMP_USER@lpic-lab28:~$"
    echo

    # ---- Step 8: Use sudo as '$TEMP_USER' (expect password prompt; no NOPASSWD rule) ----
    echo "  Step 8: Verify sudo works by printing the effective user."
    read -p "  $TEMP_USER@lpic-lab28:~$ " cmd8
    echo
    if [[ "$cmd8" != "sudo whoami" ]]; then
        print_error "  Incorrect. Use: sudo whoami"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo

    # ---- Step 9: Cleanup (remove the test user and home directory) ----
    echo "  Step 9: Clean up by removing '$TEMP_USER' and their home."
    read -p "  lab@lpic-lab28:~$ " cmd9
    echo
    if [[ "$cmd9" != "sudo userdel -r $TEMP_USER" ]]; then
        print_error "  Incorrect. Use: sudo userdel -r $TEMP_USER"
        read -p "  Press Enter to try again..." _
        continue
    fi
    echo

    print_success "Lab complete!"
    print_info "You earned $LAB_XP XP for completing this sudo/su training lab."
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
