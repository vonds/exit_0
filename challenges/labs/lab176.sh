#!/bin/bash

# Lab 176: firewalld — Publish HTTPS and Allow App Port
# SAFETY: This lab is simulated. It only validates typed commands and prints canned outputs.
#         No real firewall changes are made on your system.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 176: firewalld — Publish HTTPS and Allow App Port"
LAB_ID="lab176"
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
    center_text "Scenario: A web application is moving into production."
    center_text "You need to verify firewalld, confirm the active zone,"
    center_text "then allow HTTPS and TCP/8443 for the application."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Confirm that firewalld is running."
    read -p "  lab@lab176:~$ " cmd1
    echo
    if [[ "$cmd1" != "systemctl status firewalld" ]]; then
        print_error "Incorrect. Try again. (Use: systemctl status firewalld)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  ● firewalld.service - firewalld - dynamic firewall daemon"
    echo "       Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; preset: enabled)"
    echo "       Active: active (running) since Tue 2026-03-03 08:14:19 EST; 2h 11min ago"
    echo "         Docs: man:firewalld(1)"
    echo "     Main PID: 812 (firewalld)"
    echo "        Tasks: 2 (limit: 23156)"
    echo "       Memory: 31.4M"
    echo "          CPU: 1.203s"
    echo "       CGroup: /system.slice/firewalld.service"
    echo "               └─812 /usr/bin/python3 -s /usr/sbin/firewalld --nofork --nopid"
    echo

    echo "  Step 2: Identify the active zone."
    read -p "  lab@lab176:~$ " cmd2
    echo
    if [[ "$cmd2" != "firewall-cmd --get-active-zones" ]]; then
        print_error "Incorrect. Try again. (Use: firewall-cmd --get-active-zones)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  public"
    echo "    interfaces: ens160"
    echo

    echo "  Step 3: Review the current rules in the public zone."
    read -p "  lab@lab176:~$ " cmd3
    echo
    if [[ "$cmd3" != "firewall-cmd --zone=public --list-all" ]]; then
        print_error "Incorrect. Try again. (Use: firewall-cmd --zone=public --list-all)"
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
    echo "    forward: no"
    echo "    masquerade: no"
    echo "    forward-ports:"
    echo "    source-ports:"
    echo "    icmp-blocks:"
    echo "    rich rules:"
    echo

    echo "  Step 4: Permanently allow HTTPS in the public zone."
    read -p "  lab@lab176:~$ " cmd4
    echo
    if [[ "$cmd4" != "firewall-cmd --permanent --zone=public --add-service=https" ]]; then
        print_error "Incorrect. Try again. (Use: firewall-cmd --permanent --zone=public --add-service=https)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  success"
    echo

    echo "  Step 5: Permanently allow the application listener on TCP/8443."
    read -p "  lab@lab176:~$ " cmd5
    echo
    if [[ "$cmd5" != "firewall-cmd --permanent --zone=public --add-port=8443/tcp" ]]; then
        print_error "Incorrect. Try again. (Use: firewall-cmd --permanent --zone=public --add-port=8443/tcp)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  success"
    echo

    echo "  Step 6: Reload firewalld so the permanent changes become active."
    read -p "  lab@lab176:~$ " cmd6
    echo
    if [[ "$cmd6" != "firewall-cmd --reload" ]]; then
        print_error "Incorrect. Try again. (Use: firewall-cmd --reload)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  success"
    echo

    echo "  Step 7: Verify the public zone now includes HTTPS and port 8443/tcp."
    read -p "  lab@lab176:~$ " cmd7
    echo
    if [[ "$cmd7" != "firewall-cmd --zone=public --list-all" ]]; then
        print_error "Incorrect. Try again. (Use: firewall-cmd --zone=public --list-all)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  public (active)"
    echo "    target: default"
    echo "    icmp-block-inversion: no"
    echo "    interfaces: ens160"
    echo "    sources:"
    echo "    services: cockpit dhcpv6-client https ssh"
    echo "    ports: 8443/tcp"
    echo "    protocols:"
    echo "    forward: no"
    echo "    masquerade: no"
    echo "    forward-ports:"
    echo "    source-ports:"
    echo "    icmp-blocks:"
    echo "    rich rules:"
    echo

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