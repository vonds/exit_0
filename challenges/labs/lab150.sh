#!/bin/bash

# Lab 150: RHCSA useradd — Defaults + Realistic Provisioning Workflow

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 150: RHCSA useradd — Defaults + Realistic Provisioning Workflow"
LAB_ID="lab150"
LAB_XP=20000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@lab150:~$ "

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

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Scenario:"
    center_text "Ticket INC-150: Onboard a contractor account (satoshi) for a short change window."
    center_text "Requirements:"
    center_text "- UID 1055, home /home/satoshi, shell /bin/bash"
    center_text "- Primary group developers, supplementary groups wheel,docker"
    center_text "- Comment: Satoshi Nakamoto"
    center_text "- Account expires 2025-12-31"
    center_text "- Inactive lockout: 30 days after password expiry (policy setting)"
    echo
    center_text "Your job: confirm defaults, ensure prerequisites, create the account ONCE, verify, then clean up."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui

    # STEP 1: Show system-wide defaults (read-only)
    echo "  Step 1: Show system-wide default settings for useradd."
    read -p "$PROMPT" cmd1
    echo
    if [[ "$cmd1" != "useradd -D" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  GROUP=100"
    echo "  HOME=/home"
    echo "  INACTIVE=-1"
    echo "  EXPIRE="
    echo "  SHELL=/bin/bash"
    echo "  SKEL=/etc/skel"
    echo "  CREATE_MAIL_SPOOL=yes"
    echo

    # STEP 2: Ensure required groups exist
    echo "  Step 2: Ensure the required groups exist: developers, docker, wheel."
    read -p "$PROMPT" cmd2
    echo
    if [[ "$cmd2" != "sudo groupadd -f developers && sudo groupadd -f docker && sudo groupadd -f wheel" && \
          "$cmd2" != "groupadd -f developers && groupadd -f docker && groupadd -f wheel" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 3: Create the account once with all ticket requirements
    echo "  Step 3: Create user 'satoshi' meeting the ticket requirements in ONE useradd command."
    read -p "$PROMPT" cmd3
    echo
    if [[ "$cmd3" != "sudo useradd -m -u 1055 -g developers -G wheel,docker -c 'Satoshi Nakamoto' -s /bin/bash -d /home/satoshi -e 2025-12-31 -f 30 satoshi" && \
          "$cmd3" != "sudo useradd -m -u 1055 -g developers -G docker,wheel -c 'Satoshi Nakamoto' -s /bin/bash -d /home/satoshi -e 2025-12-31 -f 30 satoshi" && \
          "$cmd3" != "useradd -m -u 1055 -g developers -G wheel,docker -c 'Satoshi Nakamoto' -s /bin/bash -d /home/satoshi -e 2025-12-31 -f 30 satoshi" && \
          "$cmd3" != "useradd -m -u 1055 -g developers -G docker,wheel -c 'Satoshi Nakamoto' -s /bin/bash -d /home/satoshi -e 2025-12-31 -f 30 satoshi" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 4: Verify passwd database entry (NSS)
    echo "  Step 4: Verify the passwd database entry for satoshi."
    read -p "$PROMPT" cmd4
    echo
    if [[ "$cmd4" != "getent passwd satoshi" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  satoshi:x:1055:1001:Satoshi Nakamoto:/home/satoshi:/bin/bash"
    echo "  (GID number may vary; primary group must be developers)"
    echo

    # STEP 5: Verify group memberships
    echo "  Step 5: Verify satoshi's primary group and supplementary groups."
    read -p "$PROMPT" cmd5
    echo
    if [[ "$cmd5" != "id satoshi" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  uid=1055(satoshi) gid=1001(developers) groups=1001(developers),10(wheel),993(docker)"
    echo "  (group IDs may vary; group NAMES must include developers, wheel, docker)"
    echo

    # STEP 6: Verify account expiration and aging fields
    echo "  Step 6: Verify account expiration date and password aging fields using chage."
    read -p "$PROMPT" cmd6
    echo
    if [[ "$cmd6" != "sudo chage -l satoshi" && "$cmd6" != "chage -l satoshi" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  Last password change                                    : Feb 01, 2026"
    echo "  Password expires                                        : never"
    echo "  Password inactive                                       : never"
    echo "  Account expires                                         : Dec 31, 2025"
    echo "  Minimum number of days between password change          : 0"
    echo "  Maximum number of days between password change          : 99999"
    echo "  Number of days of warning before password expires       : 7"
    echo

    # STEP 7: Cleanup
    echo "  Step 7: Cleanup after verification (remove user and home directory)."
    read -p "$PROMPT" cmd7
    echo
    if [[ "$cmd7" != "sudo userdel -r satoshi" && "$cmd7" != "userdel -r satoshi" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi

    print_success "Nice work!"
    print_info "Workflow completed:"
    print_info "- Confirmed defaults with useradd -D"
    print_info "- Ensured prerequisite groups exist (groupadd -f)"
    print_info "- Provisioned the account in one useradd command (ticket-style)"
    print_info "- Verified with getent/id/chage like a real admin"
    print_info "- Cleaned up with userdel -r"
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
