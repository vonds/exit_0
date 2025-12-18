#!/bin/bash

# Lab 94: Configuring the Linux Firewall (UFW and Firewalld)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 94: Configuring the Linux Firewall"
LAB_ID="lab94"
LAB_XP=4000
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
    center_text "Scenario: Configure the Linux firewall to restrict and allow specific services."
    center_text "You will use either ufw (Ubuntu/Debian) or firewalld (CentOS/Fedora)."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Install the appropriate firewall package."
    read -p "  lab@lpic-lab94:~$ " cmd1
    echo
    [[ "$cmd1" != "sudo apt install ufw -y" && "$cmd1" != "sudo dnf install firewalld -y" && "$cmd1" != "sudo pacman -S ufw" ]] && {
        print_error "Incorrect. Use: sudo apt install ufw -y or sudo dnf install firewalld -y"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Firewall package installed."
    echo

    echo "  Step 2: Enable the firewall service."
    read -p "  lab@lpic-lab94:~$ " cmd2
    echo
    [[ "$cmd2" != "sudo ufw enable" && "$cmd2" != "sudo systemctl enable --now firewalld" ]] && {
        print_error "Incorrect. Use: sudo ufw enable or sudo systemctl enable --now firewalld"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Firewall enabled and active."
    echo

    echo "  Step 3: Allow incoming SSH traffic."
    read -p "  lab@lpic-lab94:~$ " cmd3
    echo
    [[ "$cmd3" != "sudo ufw allow OpenSSH" && "$cmd3" != "sudo firewall-cmd --permanent --add-service=ssh" ]] && {
        print_error "Incorrect. Use: sudo ufw allow OpenSSH or firewall-cmd with --add-service=ssh"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  SSH rule applied."
    echo

    echo "  Step 4: Allow HTTP traffic."
    read -p "  lab@lpic-lab94:~$ " cmd4
    echo
    [[ "$cmd4" != "sudo ufw allow http" && "$cmd4" != "sudo firewall-cmd --permanent --add-service=http" ]] && {
        print_error "Incorrect. Use: sudo ufw allow http or firewall-cmd --add-service=http"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  HTTP rule applied."
    echo

    echo "  Step 5: Deny all incoming connections by default."
    read -p "  lab@lpic-lab94:~$ " cmd5
    echo
    [[ "$cmd5" != "sudo ufw default deny incoming" && "$cmd5" != "sudo firewall-cmd --set-default-zone=drop" ]] && {
        print_error "Incorrect. Use: sudo ufw default deny incoming or firewall-cmd --set-default-zone=drop"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Default deny rule set."
    echo

    echo "  Step 6: Reload the firewall to apply all changes."
    read -p "  lab@lpic-lab94:~$ " cmd6
    echo
    [[ "$cmd6" != "sudo ufw reload" && "$cmd6" != "sudo firewall-cmd --reload" ]] && {
        print_error "Incorrect. Use: sudo ufw reload or firewall-cmd --reload"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Rules reloaded and applied."
    echo

    echo "  Step 7: View current firewall rules."
    read -p "  lab@lpic-lab94:~$ " cmd7
    echo
    [[ "$cmd7" != "sudo ufw status verbose" && "$cmd7" != "sudo firewall-cmd --list-all" ]] && {
        print_error "Incorrect. Use: sudo ufw status verbose or firewall-cmd --list-all"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Firewall rule set displayed."
    echo

    echo "  Step 8: Block 203.0.113.10."
    read -p "  lab@lpic-lab94:~$ " cmd8
    echo
    [[ "$cmd8" != "sudo ufw deny from 203.0.113.10" && "$cmd8" != "sudo firewall-cmd --permanent --add-rich-rule='rule family=ipv4 source address=203.0.113.10 reject'" ]] && {
        print_error "Incorrect. Use: sudo ufw deny from IP or add-rich-rule for firewalld"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  IP blocked successfully."
    echo

    echo "  Step 9: Remove a previously added rule."
    read -p "  lab@lpic-lab94:~$ " cmd9
    echo
    [[ "$cmd9" != "sudo ufw delete allow http" && "$cmd9" != "sudo firewall-cmd --permanent --remove-service=http" ]] && {
        print_error "Incorrect. Use: sudo ufw delete allow http or firewall-cmd --remove-service=http"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Rule removed."
    echo

    echo "  Step 10: Verify firewall is enabled and active at boot."
    read -p "  lab@lpic-lab94:~$ " cmd10
    echo
    [[ "$cmd10" != "sudo systemctl is-enabled ufw" && "$cmd10" != "sudo systemctl is-enabled firewalld" ]] && {
        print_error "Incorrect. Use: sudo systemctl is-enabled ufw or firewalld"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Firewall service is enabled at boot."
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
    print_info "You have completed this lab $completion_count time(s)."
    echo
    center_text "Would you like to:"
    center_text "1) Retry this lab"
    center_text "2) Return to Sysadmin Lab Menu"
    echo
    read -p "  > " post_choice

    [[ "$post_choice" == "2" ]] && exit 0
done
