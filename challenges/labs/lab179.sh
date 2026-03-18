#!/bin/bash

# Lab 179: Restore Service Access by Opening Firewall

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 179: Restore Service Access by Opening Firewall"
LAB_ID="lab179"
LAB_XP=50000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

record_lab_completion() {
    tmpfile=$(mktemp)
    jq --arg lab "$LAB_ID" '.[$lab] += 1 // 1' "$LAB_TRACK_FILE" > "$tmpfile" && mv "$tmpfile" "$LAB_TRACK_FILE"
}

get_lab_completion_count() {
    jq -r --arg lab "$LAB_ID" '.[$lab] // 0' "$LAB_TRACK_FILE"
}

draw_lab_ui() {
    clear
    center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
    center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
    echo
    echo
    echo
}

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Scenario: A web server is running but users cannot reach the website."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Verify the web server service is running."
    read -p "  root@server:~# " cmd1
    echo
    if [[ "$cmd1" != "systemctl status httpd" ]]; then
        print_error "Incorrect. Try again. (Use: systemctl status httpd)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  ● httpd.service - The Apache HTTP Server"
    echo "       Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; preset: disabled)"
    echo "       Active: active (running) since Tue 2026-03-10 09:14:22 EDT; 12min ago"
    echo "         Docs: man:httpd.service(8)"
    echo "     Main PID: 1432 (httpd)"
    echo "       Status: \"Started, listening on: port 80\""
    echo "        Tasks: 177 (limit: 23176)"
    echo "       Memory: 29.4M"
    echo "          CPU: 412ms"
    echo "       CGroup: /system.slice/httpd.service"
    echo "               ├─1432 /usr/sbin/httpd -DFOREGROUND"
    echo "               ├─1433 /usr/sbin/httpd -DFOREGROUND"
    echo "               ├─1434 /usr/sbin/httpd -DFOREGROUND"
    echo "               ├─1435 /usr/sbin/httpd -DFOREGROUND"
    echo "               └─1436 /usr/sbin/httpd -DFOREGROUND"
    echo

    echo "  Step 2: Verify the server is listening on port 80."
    read -p "  root@server:~# " cmd2
    echo
    if [[ "$cmd2" != "ss -tuln | grep :80" ]]; then
        print_error "Incorrect. Try again. (Use: ss -tuln | grep :80)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  tcp   LISTEN 0      511                 *:80               *:*"
    echo "  tcp   LISTEN 0      511              [::]:80            [::]:*"
    echo

    echo "  Step 3: Inspect the current firewall configuration."
    read -p "  root@server:~# " cmd3
    echo
    if [[ "$cmd3" != "firewall-cmd --list-all" ]]; then
        print_error "Incorrect. Try again. (Use: firewall-cmd --list-all)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  public (active)"
    echo "    target: default"
    echo "    icmp-block-inversion: no"
    echo "    interfaces: ens160"
    echo "    sources:"
    echo "    services: cockpit dhcpv6-client ssh"
    echo "    ports:"
    echo "    protocols:"
    echo "    forward: yes"
    echo "    masquerade: no"
    echo "    forward-ports:"
    echo "    source-ports:"
    echo "    icmp-blocks:"
    echo "    rich rules:"
    echo
    echo "  http is not currently allowed through the active zone."
    echo

    echo "  Step 4: Allow HTTP traffic through the firewall."
    read -p "  root@server:~# " cmd4
    echo
    if [[ "$cmd4" != "firewall-cmd --add-service=http" ]]; then
        print_error "Incorrect. Try again. (Use: firewall-cmd --add-service=http)"
        read -p "Press Enter to try again..." _
        continue
    fi


    echo "  Step 5: Make the firewall rule persistent."
    read -p "  root@server:~# " cmd5
    echo
    if [[ "$cmd5" != "firewall-cmd --runtime-to-permanent" ]]; then
        print_error "Incorrect. Try again. (Use: firewall-cmd --runtime-to-permanent)"
        read -p "Press Enter to try again..." _
        continue
    fi


    echo "  Step 6: Verify the website is now reachable locally."
    read -p "  root@server:~# " cmd6
    echo
    if [[ "$cmd6" != "curl http://localhost" ]]; then
        print_error "Incorrect. Try again. (Use: curl http://localhost)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  <!DOCTYPE html>"
    echo "  <html lang=\"en\">"
    echo "  <head>"
    echo "    <meta charset=\"UTF-8\">"
    echo "    <title>Test Page</title>"
    echo "  </head>"
    echo "  <body>"
    echo "    <h1>It works!</h1>"
    echo "    <p>Apache HTTP Server is serving content on port 80.</p>"
    echo "  </body>"
    echo "  </html>"
    echo

    print_success "Nice work!"
    print_info "You earned $LAB_XP XP for completing this lab."
    award_xp "$LAB_XP"

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