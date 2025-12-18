#!/bin/bash

# Lab 87: Network Troubleshooting with netcat (nc)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 87: Network Troubleshooting with netcat (nc)"
LAB_ID="lab87"
LAB_XP=5500
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
    center_text "Scenario: A branch office reports that the internal web app at"
    center_text "10.10.20.15:8080 is down. You will use netcat (nc) to verify"
    center_text "connectivity, test HTTP responses, and validate UDP log delivery."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    ###########################################################################
    # Step 1: TCP connectivity check with timeout
    ###########################################################################
    draw_lab_ui
    echo "  Step 1: From the branch workstation, do a TCP connectivity check"
    echo "          to 10.10.20.15 on port 8080 using netcat scan mode with"
    echo "          verbose output and a 3-second timeout."
    echo
    read -p "  lab@branch-ws:~$ " cmd1
    echo
    if [[ "$cmd1" != "nc -vz -w 3 10.10.20.15 8080" && "$cmd1" != "nc -zv -w 3 10.10.20.15 8080" ]]; then
        print_error "Incorrect. Use netcat scan mode with a 3-second timeout, for example:"
        print_error "  nc -vz -w 3 10.10.20.15 8080"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  TCP connectivity check to 10.10.20.15:8080 completed."
    echo

    ###########################################################################
    # Step 2: Start a listener on the app server
    ###########################################################################
    echo "  Step 2: After SSHing into the app server, start a TCP listener on"
    echo "          port 8080 with netcat so you can see if traffic from the"
    echo "          branch actually reaches the host. Use verbose and numeric"
    echo "          output options."
    echo
    read -p "  lab@app-server:~$ " cmd2
    echo
    if [[ "$cmd2" != "sudo nc -lvnp 8080" && "$cmd2" != "sudo nc -lvp 8080" ]]; then
        print_error "Incorrect. Start a verbose listener on TCP port 8080, numeric only, for example:"
        print_error "  sudo nc -lvnp 8080"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  TCP listener on 8080 started on the app server (simulated)."
    echo

    ###########################################################################
    # Step 3: Send a simple test payload from the branch
    ###########################################################################
    echo "  Step 3: Back on the branch workstation, send a simple test string to"
    echo "          the listener on 10.10.20.15:8080 so you can confirm end-to-end"
    echo "          delivery from the branch to the server."
    echo
    read -p "  lab@branch-ws:~$ " cmd3
    echo
    if [[ "$cmd3" != "echo \"health-check\" | nc 10.10.20.15 8080" ]]; then
        print_error "Incorrect. Pipe a test string into nc targeting 10.10.20.15:8080, for example:"
        print_error "  echo \"health-check\" | nc 10.10.20.15 8080"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Test payload sent through netcat to the listener (simulated)."
    echo

   

    ###########################################################################
    # Completion
    ###########################################################################
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
