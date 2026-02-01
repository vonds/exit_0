#!/bin/bash

# Lab 149: RHCSA chage Password Aging Controls — fatima Remediation Workflow
# Workflow: review current aging policy, apply required password/account settings with chage,
# verify changes, then leave the account in a sane state.
# RHCSA Focus: chage -l/-m/-M/-W/-I/-E/-d, understanding expires/inactive/last-change.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 149: RHCSA chage — Password Aging + Account Expiry"
LAB_ID="lab149"
LAB_XP=20000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@lab149:~$ "

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
}

accept_cmd() {
    # Accept command either bare or with sudo (first token)
    local input="$1"; shift
    for candidate in "$@"; do
        if [[ "$input" == "$candidate" || "$input" == "sudo $candidate" ]]; then
            return 0
        fi
    done
    return 1
}

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Scenario:"
    center_text "User fatima was locked out after a policy change."
    center_text "Security wants the account aligned to the new standard:"
    center_text "- Min days between changes: 7"
    center_text "- Max password age: 90"
    center_text "- Warning: 14 days"
    center_text "- Inactive: 30 days after password expiry"
    center_text "- Account expires: 2025-12-31"
    center_text "- Force password change at next login"
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui

    # STEP 1: Display password aging (reading often allowed, but keep sudo acceptable)
    echo "  Step 1: Display the password aging information for the user 'fatima'."
    read -p "$PROMPT" cmd1
    echo
    if ! accept_cmd "$cmd1" "sudo chage -l fatima"; then
        print_error "Incorrect. Use: sudo chage -l fatima"
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  Last password change                                    : May 20, 2025"
    echo "  Password expires                                        : Aug 18, 2025"
    echo "  Password inactive                                       : Sep 17, 2025"
    echo "  Account expires                                         : Dec 31, 2025"
    echo "  Minimum number of days between password change          : 7"
    echo "  Maximum number of days between password change          : 90"
    echo "  Number of days of warning before password expires       : 14"
    echo

    # STEP 2: Set minimum days (requires sudo)
    echo "  Step 2: Set the minimum number of days between password changes to 7 for 'fatima'."
    read -p "$PROMPT" cmd2
    echo
    if ! accept_cmd "$cmd2" "sudo chage -m 7 fatima"; then
        print_error "Incorrect. Use: sudo chage -m 7 fatima"
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 3: Set maximum days (requires sudo)
    echo "  Step 3: Set the maximum number of days the password is valid to 90 for 'fatima'."
    read -p "$PROMPT" cmd3
    echo
    if ! accept_cmd "$cmd3" "sudo chage -M 90 fatima"; then
        print_error "Incorrect. Use: sudo chage -M 90 fatima"
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 4: Set warning days (requires sudo)
    echo "  Step 4: Set the warning period to 14 days before expiration for 'fatima'."
    read -p "$PROMPT" cmd4
    echo
    if ! accept_cmd "$cmd4" "sudo chage -W 14 fatima"; then
        print_error "Incorrect. Use: sudo chage -W 14 fatima"
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 5: Set inactive period (requires sudo)
    echo "  Step 5: Set the inactive period to 30 days after password expiration for 'fatima'."
    read -p "$PROMPT" cmd5
    echo
    if ! accept_cmd "$cmd5" "sudo chage -I 30 fatima"; then
        print_error "Incorrect. Use: sudo chage -I 30 fatima"
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 6: Set account expiration date (requires sudo)
    echo "  Step 6: Set the account expiration date to 2025-12-31 for 'fatima'."
    read -p "$PROMPT" cmd6
    echo
    if ! accept_cmd "$cmd6" "sudo chage -E 2025-12-31 fatima"; then
        print_error "Incorrect. Use: sudo chage -E 2025-12-31 fatima"
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 7: Force password change next login (requires sudo)
    echo "  Step 7: Force 'fatima' to change her password at the next login."
    read -p "$PROMPT" cmd7
    echo
    if ! accept_cmd "$cmd7" "sudo chage -d 0 fatima"; then
        print_error "Incorrect. Use: sudo chage -d 0 fatima"
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 8: Set last password change date (requires sudo)
    echo "  Step 8: Set the last password change date to 2025-06-01 for 'fatima'."
    read -p "$PROMPT" cmd8
    echo
    if ! accept_cmd "$cmd8" "sudo chage -d 2025-06-01 fatima"; then
        print_error "Incorrect. Use: sudo chage -d 2025-06-01 fatima"
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 9: Verify final state (realistic verification step)
    echo "  Step 9: Verify the updated aging policy for 'fatima'."
    read -p "$PROMPT" cmd9
    echo
    if ! accept_cmd "$cmd9" "sudo chage -l fatima"; then
        print_error "Incorrect. Use: sudo chage -l fatima"
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  Last password change                                    : Jun 01, 2025"
    echo "  Password expires                                        : Aug 30, 2025"
    echo "  Password inactive                                       : Sep 29, 2025"
    echo "  Account expires                                         : Dec 31, 2025"
    echo "  Minimum number of days between password change          : 7"
    echo "  Maximum number of days between password change          : 90"
    echo "  Number of days of warning before password expires       : 14"
    echo

    print_success "Nice work!"
    print_info "Workflow completed:"
    print_info "- Reviewed current aging policy (chage -l)"
    print_info "- Applied min/max/warn/inactive/account-expiry controls (chage flags)"
    print_info "- Forced a password change at next login (chage -d 0)"
    print_info "- Verified the final state (chage -l)"
    print_info "You earned $LAB_XP XP for completing this lab."
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON"); export XP; export LEVEL
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
