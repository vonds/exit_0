#!/bin/bash

# Lab 81: Setting Up a Web Server (Apache - HTTP)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 81: Setting Up a Web Server (Apache - HTTP)"
LAB_ID="lab81"
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
    center_text "Scenario: You need to deploy a basic Apache HTTP web server"
    center_text "to serve static content over port 80."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Install the Apache (httpd) web server package."
    read -p "  lab@lpic-lab81:~$ " cmd1
    echo
    [[ "$cmd1" != "sudo pacman -S apache" && "$cmd1" != "sudo apt install apache2 -y" && "$cmd1" != "sudo yum install httpd -y" ]] && {
        print_error "Incorrect. Try: sudo pacman -S apache  (or apt/yum based on distro)"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Apache package installed successfully."
    echo

    echo "  Step 2: Enable and start the Apache web server service."
    read -p "  lab@lpic-lab81:~$ " cmd2
    echo
    [[ "$cmd2" != "sudo systemctl enable --now httpd" && "$cmd2" != "sudo systemctl enable --now apache2" ]] && {
        print_error "Incorrect. Use: sudo systemctl enable --now httpd (or apache2 depending on distro)"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Apache service is now enabled and running."
    echo

    echo "  Step 3: Create a custom index.html file in the web root."
    read -p "  lab@lpic-lab81:~$ " cmd3
    echo
    [[ "$cmd3" != "echo 'Hello from LPIC Lab!' | sudo tee /var/www/html/index.html" ]] && {
        print_error "Incorrect. Use: echo 'Hello from LPIC Lab!' | sudo tee /var/www/html/index.html"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  File created: /var/www/html/index.html"
    echo

    echo "  Step 4: Test the web server with curl."
    read -p "  lab@lpic-lab81:~$ " cmd4
    echo
    [[ "$cmd4" != "curl http://localhost" ]] && {
        print_error "Incorrect. Use: curl http://localhost"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Output:"
    echo "  Hello from LPIC Lab!"
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
