#!/bin/bash

# Lab 288: systemd Units & Override Strategy (Safe overrides & precedence)
# Scenario: A vendor-supplied unit needs a configuration change to meet site policy.
#           Create a safe drop-in override in /etc, observe precedence with /lib and /run,
#           and confirm the active configuration without disrupting service unexpectedly.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 288: systemd Units & Override Strategy"
LAB_ID="lab288"
LAB_XP=1700
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"

[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

draw_lab_ui() {
    clear
    center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
    center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
    echo
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
    center_text "You must safely override a vendor unit, verify override precedence, and test the change."
    center_text "This lab demonstrates creating drop-ins in /etc, creating a runtime override in /run, and confirming which file is in effect."
    echo
    center_text "Press Enter to begin the lab..."
    read _
    draw_lab_ui

    # ---- Step 1 ----
    echo "  Step 1: Show the vendor-provided unit file for sshd.service."
    read -p "  lab@lab288:~$ " cmd1
    echo
    if [[ "$cmd1" != "systemctl cat sshd.service" && "$cmd1" != "sudo systemctl cat sshd.service" ]]; then
        print_error "Incorrect. Expected: systemctl cat sshd.service"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  # /lib/systemd/system/sshd.service"
    echo "  [Unit]"
    echo "  Description=OpenSSH server daemon"
    echo "  After=network.target"
    echo
    echo "  [Service]"
    echo "  ExecStart=/usr/sbin/sshd -D"
    echo
    echo "  [Install]"
    echo "  WantedBy=multi-user.target"
    echo

    # ---- Step 2 ----
    echo "  Step 2: Create an /etc drop-in override that sets Environment=MAINT=1 and reload systemd."
    echo "          Run a chained command that creates the directory, writes override.conf, and runs daemon-reload."
    echo "          Example: sudo mkdir -p /etc/systemd/system/sshd.service.d && printf '[Service]\\nEnvironment=MAINT=1\\n' | sudo tee /etc/systemd/system/sshd.service.d/override.conf && sudo systemctl daemon-reload"
    read -p "  lab@lab288:~$ " cmd2
    echo
    if [[ ( "$cmd2" == *"/etc/systemd/system/sshd.service.d"* && "$cmd2" == *"override.conf"* && "$cmd2" == *"daemon-reload"* ) || \
          ( "$cmd2" == *"systemctl daemon-reload"* && "$cmd2" == *"tee /etc/systemd/system/sshd.service.d/override.conf"* ) ]]; then
        # Simulated effect
        echo "  Created: /etc/systemd/system/sshd.service.d/override.conf"
        echo "  systemctl: daemon-reload completed"
        echo
        # show the subsequent verification command output expectation
        echo "  (Next) Run: systemctl show -p Environment sshd.service"
    else
        print_error "Incorrect. Use a command that writes override.conf under /etc/systemd/system/sshd.service.d and runs systemctl daemon-reload."
        echo "  Example: sudo mkdir -p /etc/systemd/system/sshd.service.d && printf '[Service]\\nEnvironment=MAINT=1\\n' | sudo tee /etc/systemd/system/sshd.service.d/override.conf && sudo systemctl daemon-reload"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    # ---- Step 3 ----
    echo "  Step 3: Show the unit's effective Environment value to confirm the /etc drop-in is active."
    read -p "  lab@lab288:~$ " cmd3
    echo
    if [[ "$cmd3" != "systemctl show -p Environment sshd.service" && "$cmd3" != "sudo systemctl show -p Environment sshd.service" ]]; then
        print_error "Incorrect. Expected: systemctl show -p Environment sshd.service"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Environment=MAINT=1"
    echo

    # ---- Step 4 ----
    echo "  Step 4: Create a runtime override in /run/systemd/system to simulate a temporary change that should take precedence over /etc."
    echo "          Use a command to create the runtime drop-in and reload daemon. Example:"
    echo "          sudo mkdir -p /run/systemd/system/sshd.service.d && printf '[Service]\\nEnvironment=RUNTIME=1\\n' | sudo tee /run/systemd/system/sshd.service.d/override.conf && sudo systemctl daemon-reload"
    read -p "  lab@lab288:~$ " cmd4
    echo
    if [[ ( "$cmd4" == *"/run/systemd/system/sshd.service.d"* && "$cmd4" == *"override.conf"* && "$cmd4" == *"daemon-reload"* ) || \
          ( "$cmd4" == *"tee /run/systemd/system/sshd.service.d/override.conf"* && "$cmd4" == *"systemctl daemon-reload"* ) ]]; then
        echo "  Created: /run/systemd/system/sshd.service.d/override.conf"
        echo "  systemctl: daemon-reload completed"
    else
        print_error "Incorrect. Use a command that writes override.conf under /run/systemd/system/sshd.service.d and runs systemctl daemon-reload."
        echo "  Example: sudo mkdir -p /run/systemd/system/sshd.service.d && printf '[Service]\\nEnvironment=RUNTIME=1\\n' | sudo tee /run/systemd/system/sshd.service.d/override.conf && sudo systemctl daemon-reload"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    # ---- Step 5 ----
    echo "  Step 5: Show the full unit content (systemctl cat) and confirm that the runtime override from /run is listed before /etc and /lib."
    read -p "  lab@lab288:~$ " cmd5
    echo
    if [[ "$cmd5" != "systemctl cat sshd.service" && "$cmd5" != "sudo systemctl cat sshd.service" ]]; then
        print_error "Incorrect. Expected: systemctl cat sshd.service"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  # /run/systemd/system/sshd.service.d/override.conf"
    echo "  [Service]"
    echo "  Environment=RUNTIME=1"
    echo
    echo "  # /etc/systemd/system/sshd.service.d/override.conf"
    echo "  [Service]"
    echo "  Environment=MAINT=1"
    echo
    echo "  # /lib/systemd/system/sshd.service"
    echo "  [Unit]"
    echo "  Description=OpenSSH server daemon"
    echo "  [Service]"
    echo "  ExecStart=/usr/sbin/sshd -D"
    echo

    # ---- Step 6 ----
    echo "  Step 6: Restart sshd and show a short status output to confirm the service is active and the runtime environment is in effect."
    read -p "  lab@lab288:~$ " cmd6
    echo
    if [[ "$cmd6" == *"systemctl restart sshd"* && ( "$cmd6" == *"systemctl status sshd"* || "$cmd6" == *"systemctl status sshd -n"* || "$cmd6" == *"systemctl status sshd -n 5"* ) ]]; then
        echo "  ● sshd.service - OpenSSH server daemon"
        echo "     Loaded: loaded (/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)"
        echo "     Active: active (running) since Fri 2025-07-19 09:00:00 UTC; 2s ago"
        echo "    Process: 1234 ExecStart=/usr/sbin/sshd -D (code=exited, status=0/SUCCESS)"
        echo "   Main PID: 1236 (sshd)"
        echo "    Tasks: 1 (limit: 4915)"
        echo "     Memory: 1.4M"
        echo "     CGroup: /system.slice/sshd.service"
        echo
        echo "  Jul 19 09:00:00 host sshd[1236]: Server listening on 0.0.0.0 port 22."
        echo "  Jul 19 09:00:00 host sshd[1236]: Environment: RUNTIME=1"
    else
        print_error "Incorrect. Use a command that restarts sshd and displays its status (e.g., sudo systemctl restart sshd && sudo systemctl status sshd -n 5)."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    # ---- Step 7 ----
    echo "  Step 7: Clean up: remove /run override and /etc drop-in you created, reload daemon, and show the unit's Environment to confirm cleanup."
    echo "          Example: sudo rm -f /run/systemd/system/sshd.service.d/override.conf /etc/systemd/system/sshd.service.d/override.conf && sudo systemctl daemon-reload"
    read -p "  lab@lab288:~$ " cmd7
    echo
    if [[ ( "$cmd7" == *"rm -f"* && "$cmd7" == *"/run/systemd/system/sshd.service.d/override.conf"* && "$cmd7" == *"/etc/systemd/system/sshd.service.d/override.conf"* && "$cmd7" == *"daemon-reload"* ) || \
          ( "$cmd7" == *"rm /run/systemd/system/sshd.service.d/override.conf"* && "$cmd7" == *"rm /etc/systemd/system/sshd.service.d/override.conf"* && "$cmd7" == *"systemctl daemon-reload"* ) ]]; then
        echo "  Removed: /run/systemd/system/sshd.service.d/override.conf"
        echo "  Removed: /etc/systemd/system/sshd.service.d/override.conf"
        echo "  systemctl: daemon-reload completed"
        echo
        echo "  Now checking: systemctl show -p Environment sshd.service"
        echo "  Environment="
    else
        print_error "Incorrect. Use commands that remove both override files and run systemctl daemon-reload."
        echo "  Example: sudo rm -f /run/systemd/system/sshd.service.d/override.conf /etc/systemd/system/sshd.service.d/override.conf && sudo systemctl daemon-reload"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    # ---- Completion ----
    print_success "Lab complete: you created an /etc drop-in, created a runtime override in /run, observed precedence, restarted the unit, and cleaned up."
    print_info "You earned $LAB_XP XP for completing this lab!"
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON")
    LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
    export XP
    export LEVEL
    record_lab_completion

    completion_count=$(get_lab_completion_count)
    echo
    echo "Completed: $completion_count time(s)"
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
