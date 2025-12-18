#!/bin/bash

# Lab 80: Installing and Configuring a Mail Transfer Agent (Postfix)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 80: Installing and Configuring Postfix (MTA)"
LAB_ID="lab80"
LAB_XP=2500
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
    center_text "Scenario: You are tasked with setting up an MTA using Postfix to send system mail."
    center_text "You will install Postfix, configure basic settings, and send a test message."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Install Postfix using your package manager."
    read -p "  lab@lpic-lab80:~$ " cmd1
    echo
    if [[ "$cmd1" != "sudo apt install postfix" && "$cmd1" != "sudo pacman -S postfix" && "$cmd1" != "sudo yum install postfix" ]]; then
        print_error "Incorrect. Use: sudo apt install postfix OR sudo pacman -S postfix OR sudo yum install postfix"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Installing Postfix... Done."
    echo

    echo "  Step 2: Enable and start the Postfix service."
    read -p "  lab@lpic-lab80:~$ " cmd2
    echo
    [[ "$cmd2" != "sudo systemctl enable --now postfix" ]] && {
        print_error "Incorrect. Use: sudo systemctl enable --now postfix"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Postfix enabled and started."
    echo

    echo "  Step 3: Check the Postfix service status."
    read -p "  lab@lpic-lab80:~$ " cmd3
    echo
    [[ "$cmd3" != "systemctl status postfix" ]] && {
        print_error "Incorrect. Use: systemctl status postfix"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  ● postfix.service - Postfix Mail Transport Agent"
    echo "       Loaded: loaded (/usr/lib/systemd/system/postfix.service; enabled; vendor preset: disabled)"
    echo "       Active: active (running) since Fri 2025-11-28 10:23:45 EST; 5min ago"
    echo "         Docs: man:postfix(1)"
    echo "     Main PID: 2143 (master)"
    echo "        Tasks: 5 (limit: 1123)"
    echo "       Memory: 8.5M"
    echo "          CPU: 220ms"
    echo "       CGroup: /system.slice/postfix.service"
    echo "               ├─2143 /usr/libexec/postfix/master -w"
    echo "               ├─2144 pickup -l -t unix -u"
    echo "               └─2145 qmgr -l -t unix -u"
    echo

    echo "  Step 4: Set the system's mail name (mail domain)."
    read -p "  lab@lpic-lab80:~$ " cmd4
    echo
    [[ "$cmd4" != "echo 'example.local' | sudo tee /etc/mailname" ]] && {
        print_error "Incorrect. Use: echo 'example.local' | sudo tee /etc/mailname"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Mail name set to 'example.local'."
    echo

    echo "  Step 5: Send a test message using the mail command."
    read -p "  lab@lpic-lab80:~$ " cmd5
    echo
    [[ "$cmd5" != "echo 'Test message' | mail -s 'Hello' root" ]] && {
        print_error "Incorrect. Use: echo 'Test message' | mail -s 'Hello' root"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Message sent to local root user."
    echo

    print_success "Lab complete."
    print_info "You earned $LAB_XP XP for completing this lab."
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
