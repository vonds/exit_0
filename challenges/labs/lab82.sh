#!/bin/bash

# Lab 82: Installing, Validating, and Managing Nginx

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 82: Installing, Validating, and Managing Nginx"
LAB_ID="lab82"
LAB_XP=2250
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
    center_text "Scenario: Nginx is going to sit in front of an internal app as a"
    center_text "reverse proxy. You’ve already planned your config changes and now"
    center_text "you need to install Nginx, validate its configuration, reload it"
    center_text "safely, and confirm that it’s actually serving traffic."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Install the Nginx web server package using your distro's package manager."
    read -p "  lab@lpic-lab82:~$ " cmd1
    echo
    if [[ "$cmd1" != "sudo pacman -S nginx" && \
          "$cmd1" != "sudo apt install nginx -y" && \
          "$cmd1" != "sudo yum install nginx -y" ]]; then
        print_error "Incorrect. Install the nginx package with pacman, apt, or yum."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Nginx package installed successfully."
    echo

    echo "  Step 2: Enable and start the Nginx service so it persists across reboots."
    read -p "  lab@lpic-lab82:~$ " cmd2
    echo
    if [[ "$cmd2" != "sudo systemctl enable --now nginx" ]]; then
        print_error "Incorrect. Use systemctl to enable and start the nginx service."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Nginx service is now enabled and running."
    echo

    echo "  Step 3: Validate the Nginx configuration for syntax errors."
    read -p "  lab@lpic-lab82:~$ " cmd3
    echo
    if [[ "$cmd3" != "sudo nginx -t" ]]; then
        print_error "Incorrect. Use the nginx config test command."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  nginx: the configuration file /etc/nginx/nginx.conf syntax is ok"
    echo "  nginx: configuration file /etc/nginx/nginx.conf test is successful"
    echo

    echo "  Step 4: Reload Nginx to apply configuration changes, then confirm it is"
    echo "          listening on port 80 by inspecting active TCP listeners."
    read -p "  lab@lpic-lab82:~$ " cmd4
    echo
    if [[ "$cmd4" != "sudo systemctl reload nginx && ss -tuln | grep ':80'" ]]; then
        print_error "Incorrect. Reload nginx, then verify it is listening on port 80."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Reloading nginx configuration..."
    echo "  Nginx reloaded successfully."
    echo "  Active listeners:"
    echo "  LISTEN 0      511          0.0.0.0:80           0.0.0.0:*"
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
