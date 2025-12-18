#!/bin/bash

# Lab 22: Linux Printing with CUPS – Service, Queues, and Jobs

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 22: Linux Printing with CUPS – Service, Queues, and Jobs"
LAB_ID="lab22"
LAB_XP=40000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"

[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

draw_lab_ui() {
    clear
    center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
    center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
    echo
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
    center_text "Scenario: You’ve been asked to bring printing online on a new Rocky Linux host."
    center_text "You will start/enable CUPS, inspect queues, enable a printer, set a default,"
    center_text "submit and cancel a job, and identify key configuration files."
    echo
    center_text "Press Enter to begin the lab..."
    read _
    draw_lab_ui

    echo "  Step 1: Start and enable the CUPS service so it persists across reboots."
    read -p "  lab@cups-lab22:~\$ > " cmd1
    echo

    if [[ "$cmd1" != "sudo systemctl enable --now cups" ]]; then
        print_error "Incorrect. Use systemctl to both enable and start: 'sudo systemctl enable --now cups'."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  ● cups.service - CUPS Scheduler
     Loaded: loaded (/usr/lib/systemd/system/cups.service; enabled; vendor preset: disabled)
     Active: active (running) since Thu 2025-07-17 13:14:02 EDT; 2s ago"
    echo

    echo "  Step 2: Show the current CUPS status including printers, classes, and server settings in one view."
    read -p "  lab@cups-lab22:~\$ > " cmd2
    echo

    if [[ "$cmd2" != "lpstat -t" ]]; then
        print_error "Incorrect. Use 'lpstat -t' for a full status summary."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  scheduler is running
  system default destination: (none)
  no system default destination
  device for Demo_Printer: ipp://printer.demo.local/ipp/print
  Demo_Printer accepting requests since Thu 17 Jul 2025 01:14:06 PM EDT
  printer Demo_Printer is idle.  enabled since Thu 17 Jul 2025 01:14:06 PM EDT"
    echo

    echo "  Step 3: Enable a specific printer queue and allow it to accept jobs."
    echo "          Provide a single line that enables the queue named 'Demo_Printer' and accepts jobs."
    read -p "  lab@cups-lab22:~\$ > " cmd3
    echo

    if [[ "$cmd3" != "sudo cupsenable Demo_Printer && sudo cupsaccept Demo_Printer" ]]; then
        print_error "Incorrect. Use 'cupsenable' and 'cupsaccept' together with the printer name."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  printer Demo_Printer now enabled and accepting jobs."
    echo

    echo "  Step 4: Set 'Demo_Printer' as the system default printer for all users."
    read -p "  lab@cups-lab22:~\$ > " cmd4
    echo

    if [[ "$cmd4" != "sudo lpadmin -d Demo_Printer" ]]; then
        print_error "Incorrect. Use 'lpadmin -d <queue>' to set the default destination."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Default destination set to Demo_Printer."
    echo

    echo "  Step 5: Submit a simple test job to the default printer by printing /etc/hosts."
    read -p "  lab@cups-lab22:~\$ > " cmd5
    echo

    if [[ "$cmd5" != "lp /etc/hosts" ]]; then
        print_error "Incorrect. Use 'lp <file>' to submit a print job to the default queue."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  request id is Demo_Printer-42 (1 file(s))"
    echo

    echo "  Step 6: Show the current job queue for 'Demo_Printer' only."
    echo "          Provide a command that lists pending jobs for that destination."
    read -p "  lab@cups-lab22:~\$ > " cmd6
    echo

    if [[ "$cmd6" != "lpq -P Demo_Printer" ]]; then
        print_error "Incorrect. Use 'lpq -P <queue>' to see jobs for a specific printer."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Demo_Printer is ready
  Rank   Owner        Job  File(s)                         Total Size
  active lab          42   hosts                           1024 bytes"
    echo

    echo "  Step 7: Cancel the job you just submitted (job ID 42) on 'Demo_Printer'."
    echo "          Provide a single command that targets that specific job."
    read -p "  lab@cups-lab22:~\$ > " cmd7
    echo

    if [[ "$cmd7" != "cancel Demo_Printer-42" ]]; then
        print_error "Incorrect. Use 'cancel <destination>-<jobid>' to cancel a specific job."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Job Demo_Printer-42 canceled."
    echo

    echo "  Step 8: You need to allow remote administration and browsing temporarily."
    echo "          Provide a single cupsctl command to enable both."
    read -p "  lab@cups-lab22:~\$ > " cmd8
    echo

    if [[ "$cmd8" != "sudo cupsctl --remote-admin --remote-any" ]]; then
        print_error "Incorrect. Use 'cupsctl --remote-admin --remote-any' (with sudo) to enable both."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Remote admin and remote access enabled (remember to lock this down later)."
    echo

    echo "  Step 9: Where are the two key configuration files for CUPS daemon and printers? (answer must be exact paths)"
    echo "          Provide a single line with both paths separated by a space."
    read -p "  lab@cups-lab22:~\$ > " cmd9
    echo

    if [[ "$cmd9" != "/etc/cups/cupsd.conf /etc/cups/printers.conf" ]]; then
        print_error "Incorrect. The expected answer is: /etc/cups/cupsd.conf /etc/cups/printers.conf"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct. cupsd.conf governs the daemon; printers.conf defines queues."
    echo

    echo "  Step 10: Finally, print a CUPS test page via the built-in web UI. Which URL would you open locally?"
    read -p "  lab@cups-lab22:~\$ > " cmd10
    echo

    if [[ "$cmd10" != "http://localhost:631" ]]; then
        print_error "Incorrect. Use the local CUPS web interface at 'http://localhost:631'."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  CUPS Web Interface reachable at http://localhost:631"
    echo

    print_success "Excellent work!"
    print_info "You brought CUPS online, managed queues, submitted/canceled jobs, and identified core configs."
    print_info "You earned $LAB_XP XP for completing this lab!"
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
    read -p "  > " choice

    if [[ "$choice" == "2" ]]; then
        exit 0
    fi
done
