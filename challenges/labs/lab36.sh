#!/bin/bash

# Lab 36: Managing Services with systemctl

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 36: Managing Services with systemctl"
LAB_ID="lab36"
LAB_XP=23225
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
    center_text "You're managing a production server running multiple services."
    center_text "Your team lead has asked you to inspect and manage various systemd services."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Check the current runlevel target (default boot target)."
    read -p "  lab@lpic-lab36:~\$ " cmd1
    echo
    [[ "$cmd1" != "systemctl get-default" ]] && {
        print_error "Incorrect. Use: systemctl get-default"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  multi-user.target"
    echo

    echo "  Step 2: View all loaded services."
    read -p "  lab@lpic-lab36:~\$ " cmd2
    echo
    [[ "$cmd2" != "systemctl list-units --type=service" ]] && {
        print_error "Incorrect. Use: systemctl list-units --type=service"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  UNIT                           LOAD   ACTIVE SUB     DESCRIPTION"
    echo "  ssh.service                    loaded active running OpenBSD Secure Shell server"
    echo "  cron.service                   loaded active running Regular background program processing daemon"
    echo "  systemd-journald.service       loaded active running Journal Service"
    echo "  ... (truncated)"
    echo

    echo "  Step 3: Check the status of the 'ssh' service."
    read -p "  lab@lpic-lab36:~\$ " cmd3
    echo
    [[ "$cmd3" != "systemctl status ssh" ]] && {
        print_error "Incorrect. Use: systemctl status ssh"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  ● ssh.service - OpenBSD Secure Shell server"
    echo "     Loaded: loaded (/lib/systemd/system/ssh.service; enabled)"
    echo "     Active: active (running) since Fri 2025-07-18 10:22:13 UTC; 3h 22min ago"
    echo "     Docs: man:sshd(8)"
    echo "           man:sshd_config(5)"
    echo

    echo "  Step 4: Restart the 'ssh' service."
    read -p "  lab@lpic-lab36:~\$ " cmd4
    echo
    [[ "$cmd4" != "sudo systemctl restart ssh" && "$cmd4" != "systemctl restart ssh" ]] && {
        print_error "Incorrect. Use: systemctl restart ssh"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Service 'ssh' restarted successfully."
    echo

    echo "  Step 5: Disable a service from starting on boot. Disable 'apache2'."
    read -p "  lab@lpic-lab36:~\$ " cmd5
    echo
    [[ "$cmd5" != "sudo systemctl disable apache2" && "$cmd5" != "systemctl disable apache2" ]] && {
        print_error "Incorrect. Use: systemctl disable apache2"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Removed /etc/systemd/system/multi-user.target.wants/apache2.service."
    echo

    echo "  Step 6: Mask the apache2 service so it cannot be started manually."
    read -p "  lab@lpic-lab36:~\$ " cmd6
    echo
    [[ "$cmd6" != "sudo systemctl mask apache2" && "$cmd6" != "systemctl mask apache2" ]] && {
        print_error "Incorrect. Use: systemctl mask apache2"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Created symlink /etc/systemd/system/apache2.service → /dev/null."
    echo

    echo "  Step 7: Reload systemd configuration after editing unit files."
    read -p "  lab@lpic-lab36:~\$ " cmd7
    echo
    [[ "$cmd7" != "sudo systemctl daemon-reload" && "$cmd7" != "systemctl daemon-reload" ]] && {
        print_error "Incorrect. Use: systemctl daemon-reload"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Systemd manager configuration reloaded."
    echo

    echo "  Step 8: Re-execute the systemd manager to reflect deeper configuration changes."
    read -p "  lab@lpic-lab36:~\$ " cmd8
    echo
    [[ "$cmd8" != "sudo systemctl daemon-reexec" && "$cmd8" != "systemctl daemon-reexec" ]] && {
        print_error "Incorrect. Use: systemctl daemon-reexec"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Systemd manager re-executed successfully."
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
    print_info "You've completed this lab $completion_count time(s)."
    echo
    center_text "Would you like to:"
    center_text "1) Retry this lab"
    center_text "2) Return to Sysadmin Lab Menu"
    echo
    read -p "  > " post_choice

    [[ "$post_choice" == "2" ]] && exit 0
done
