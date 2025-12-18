#!/bin/bash

# Lab 90: Configuring Account Lockout with faillock (Authentication Hardening)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 90: Configuring Account Lockout with faillock"
LAB_ID="lab90"
LAB_XP=5250
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
    center_text "Scenario: Security has reported repeated failed logins against the appuser account."
    center_text "You will review system-wide lockout settings, adjust faillock defaults, and practice"
    center_text "checking and resetting failed login counters for appuser."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Check the current system-wide faillock settings."
    echo "          Use faillock to display the default deny/unlock policy."
    read -p "  lab@lpic-lab90:~$ " cmd1
    echo
    if [[ "$cmd1" != "sudo faillock --system" ]]; then
        print_error "Incorrect. Use: sudo faillock --system"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  sudo faillock --system"
    echo "  deny = 0"
    echo "  fail_interval = 900"
    echo "  unlock_time = 600"
    echo

    echo "  Step 2: Open the faillock configuration file to set a stricter policy"
    echo "          (for example deny=5, unlock_time=900). Use sudo with your editor."
    read -p "  lab@lpic-lab90:~$ " cmd2
    echo
    if [[ "$cmd2" != "sudo nano /etc/security/faillock.conf" && "$cmd2" != "sudo vim /etc/security/faillock.conf" ]]; then
        print_error "Incorrect. Example: sudo nano /etc/security/faillock.conf"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  (editor opened; you add or adjust lines similar to)"
    echo "    deny = 5"
    echo "    fail_interval = 900"
    echo "    unlock_time = 900"
    echo "  (file saved and closed)"
    echo

    echo "  Step 3: Check the current failed login counter for appuser."
    echo "          Assume security has seen several bad password attempts already."
    read -p "  lab@lpic-lab90:~$ " cmd3
    echo
    if [[ "$cmd3" != "sudo faillock --user appuser" ]]; then
        print_error "Incorrect. Use: sudo faillock --user appuser"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  sudo faillock --user appuser"
    echo "  appuser:"
    echo "      When                Type  Source             Valid"
    echo "      2025-01-01 10:15:32 R    192.168.10.50      V"
    echo "      2025-01-01 10:16:05 R    192.168.10.50      V"
    echo "      2025-01-01 10:16:40 R    192.168.10.50      V"
    echo

    echo "  Step 4: After confirming the attempts were legitimate but due to a typo,"
    echo "          reset the failed login counter for appuser so they can log in normally."
    read -p "  lab@lpic-lab90:~$ " cmd4
    echo
    if [[ "$cmd4" != "sudo faillock --user appuser --reset" ]]; then
        print_error "Incorrect. Use: sudo faillock --user appuser --reset"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Failed login counter for appuser has been reset (simulated)."
    echo

    echo "  Step 5: Confirm that there are no remaining failed login records for appuser."
    read -p "  lab@lpic-lab90:~$ " cmd5
    echo
    if [[ "$cmd5" != "sudo faillock --user appuser" ]]; then
        print_error "Incorrect. Use: sudo faillock --user appuser"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  sudo faillock --user appuser"
    echo "  appuser:"
    echo "      No login failures."
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
