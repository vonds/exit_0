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
    center_text "- Custom skeleton: /etc/skel-custom (must include README.WELCOME)"
    echo
    center_text "Your job: confirm defaults, prep prerequisites, create the account ONCE, verify, then clean up."
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
    echo

    # STEP 3: Prepare a custom skeleton directory
    echo "  Step 3: Create /etc/skel-custom/README.WELCOME with a short welcome message."
    read -p "$PROMPT" cmd3
    echo
    if [[ "$cmd3" != "sudo mkdir -p /etc/skel-custom && printf 'Welcome. Read the change-window notes in this home directory.\n' | sudo tee /etc/skel-custom/README.WELCOME >/dev/null" && \
          "$cmd3" != "mkdir -p /etc/skel-custom && printf 'Welcome. Read the change-window notes in this home directory.\n' | tee /etc/skel-custom/README.WELCOME >/dev/null" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo

    # STEP 4: Create the account once with all ticket requirements
    echo "  Step 4: Create user 'satoshi' meeting the ticket requirements in ONE useradd command."
    read -p "$PROMPT" cmd4
    echo
    if [[ "$cmd4" != "sudo useradd -m -u 1055 -g developers -G wheel,docker -c 'Satoshi Nakamoto' -s /bin/bash -d /home/satoshi -e 2025-12-31 -f 30 -k /etc/skel-custom satoshi" && \
          "$cmd4" != "sudo useradd -m -u 1055 -g developers -G docker,wheel -c 'Satoshi Nakamoto' -s /bin/bash -d /home/satoshi -e 2025-12-31 -f 30 -k /etc/skel-custom satoshi" && \
          "$cmd4" != "useradd -m -u 1055 -g developers -G wheel,docker -c 'Satoshi Nakamoto' -s /bin/bash -d /home/satoshi -e 2025-12-31 -f 30 -k /etc/skel-custom satoshi" && \
          "$cmd4" != "useradd -m -u 1055 -g developers -G docker,wheel -c 'Satoshi Nakamoto' -s /bin/bash -d /home/satoshi -e 2025-12-31 -f 30 -k /etc/skel-custom satoshi" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo

    # STEP 5: Verify passwd database entry (NSS)
    echo "  Step 5: Verify the passwd database entry for satoshi."
    read -p "$PROMPT" cmd5
    echo
    if [[ "$cmd5" != "getent passwd satoshi" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  satoshi:x:1055:1001:Satoshi Nakamoto:/home/satoshi:/bin/bash"
    echo "  (GID number may vary; primary group must be developers)"
    echo

    # STEP 6: Verify group memberships
    echo "  Step 6: Verify satoshi's primary group and supplementary groups."
    read -p "$PROMPT" cmd6
    echo
    if [[ "$cmd6" != "id satoshi" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  uid=1055(satoshi) gid=1001(developers) groups=1001(developers),10(wheel),993(docker)"
    echo "  (group IDs may vary; group NAMES must include developers, wheel, docker)"
    echo

    # STEP 7: Verify account expiration and inactive policy fields
    echo "  Step 7: Verify account expiration date and password aging fields using chage."
    read -p "$PROMPT" cmd7
    echo
    if [[ "$cmd7" != "sudo chage -l satoshi" && "$cmd7" != "chage -l satoshi" ]]; then
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

    # STEP 8: Verify skeleton file deployment
    echo "  Step 8: Verify satoshi's home directory contains README.WELCOME."
    read -p "$PROMPT" cmd8
    echo
    if [[ "$cmd8" != "ls -la /home/satoshi" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  total 20"
    echo "  drwx------. 2 satoshi developers  96 Feb  1 08:12 ."
    echo "  drwxr-xr-x. 1 root    root        34 Feb  1 08:12 .."
    echo "  -rw-r--r--. 1 satoshi developers  18 Apr 18  2023 .bash_logout"
    echo "  -rw-r--r--. 1 satoshi developers 141 Apr 18  2023 .bash_profile"
    echo "  -rw-r--r--. 1 satoshi developers 492 Apr 18  2023 .bashrc"
    echo "  -rw-r--r--. 1 satoshi developers  66 Feb  1 08:12 README.WELCOME"
    echo

    # STEP 9: Cleanup
    echo "  Step 9: Cleanup after verification (remove user and home directory)."
    read -p "$PROMPT" cmd9
    echo
    if [[ "$cmd9" != "sudo userdel -r satoshi" && "$cmd9" != "userdel -r satoshi" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo

    print_success "Nice work!"
    print_info "Workflow completed:"
    print_info "- Confirmed defaults with useradd -D"
    print_info "- Ensured prerequisite groups exist (groupadd -f)"
    print_info "- Built a custom skeleton file under /etc (mkdir + tee)"
    print_info "- Provisioned the account in one useradd command (ticket-style)"
    print_info "- Verified with getent/id/chage/ls like a real admin"
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
