#!/bin/bash

# Lab 147: RHCSA User + Group Administration — tsuli Account Workflow
# Workflow: create a contractor account, audit identity + NSS records, add to team groups,
# validate key auth file permissions, then clean up.
# RHCSA Focus: useradd/usermod/groupadd/getent/id/ls -l, core /etc/*shadow* permissions.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 147: RHCSA User + Group Admin — tsuli Account"
LAB_ID="lab147"
LAB_XP=20000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@lab147:~$ "

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
    center_text "Create a contractor account (tsuli) for documentation updates."
    center_text "They must be added to the editor and devops teams. After provisioning,"
    center_text "Ops wants a quick audit of NSS user/group records and core auth file permissions."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui

    # STEP 1: Ensure required groups exist (realistic prerequisite)
    echo "  Step 1: Ensure the groups 'editor' and 'devops' exist (create if missing)."
    read -p "$PROMPT" cmd1
    echo
    if [[ "$cmd1" != "sudo groupadd -f editor && sudo groupadd -f devops" && \
          "$cmd1" != "groupadd -f editor && groupadd -f devops" ]]; then
        print_error "Incorrect. Example: sudo groupadd -f editor && sudo groupadd -f devops"
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 2: Create user with home directory (requires sudo)
    echo "  Step 2: Create a new user account named tsuli and ensure it has a home directory."
    read -p "$PROMPT" cmd2
    echo
    if ! accept_cmd "$cmd2" "sudo useradd -m tsuli"; then
        print_error "Incorrect. Use: sudo useradd -m tsuli"
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 3: Verify passwd database entry (NSS)
    echo "  Step 3: Verify tsuli exists in the passwd database (NSS)."
    read -p "$PROMPT" cmd3
    echo
    if [[ "$cmd3" != "getent passwd tsuli" ]]; then
        print_error "Incorrect. Use: getent passwd tsuli"
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  tsuli:x:1002:1002:tsuli:/home/tsuli:/bin/bash"
    echo

    # STEP 4: Verify identity, primary group name, and group list
    echo "  Step 4a: Display UID, primary GID, and supplementary groups for tsuli."
    read -p "$PROMPT" cmd4a
    echo
    if [[ "$cmd4a" != "id tsuli" ]]; then
        print_error "Incorrect. Use: id tsuli"
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  uid=1002(tsuli) gid=1002(tsuli) groups=1002(tsuli)"
    echo

    echo "  Step 4b: Show the PRIMARY group name for tsuli."
    read -p "$PROMPT" cmd4b
    echo
    if [[ "$cmd4b" != "id -gn tsuli" ]]; then
        print_error "Incorrect. Use: id -gn tsuli"
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  tsuli"
    echo

    # STEP 5: Review shadow data via NSS (requires sudo to read shadow via getent on most systems)
    echo "  Step 5: Review tsuli's shadow entry via NSS (getent shadow)."
    read -p "$PROMPT" cmd5
    echo
    if ! accept_cmd "$cmd5" "sudo getent shadow tsuli"; then
        print_error "Incorrect. Use: sudo getent shadow tsuli"
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  tsuli:!!:19700:0:99999:7:::"
    echo

    # STEP 6: Add secondary groups (requires sudo)
    echo "  Step 6: Add tsuli to the secondary groups editor and devops."
    read -p "$PROMPT" cmd6
    echo
    if ! accept_cmd "$cmd6" "sudo usermod -aG editor,devops tsuli"; then
        print_error "Incorrect. Use: sudo usermod -aG editor,devops tsuli"
        read -p "Press Enter to retry..." _
        continue
    fi


    echo "  Step 6b: Verify tsuli is now a member of editor and devops."
    read -p "$PROMPT" cmd6b
    echo
    if [[ "$cmd6b" != "id tsuli" ]]; then
        print_error "Incorrect. Use: id tsuli"
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  uid=1002(tsuli) gid=1002(tsuli) groups=1002(tsuli),1005(editor),1006(devops)"
    echo "  (group IDs may vary; names must include editor and devops)"
    echo

    # STEP 7: Verify group database records (NSS)
    echo "  Step 7: Verify membership details for the group 'editor' using getent."
    read -p "$PROMPT" cmd7
    echo
    if [[ "$cmd7" != "getent group editor" ]]; then
        print_error "Incorrect. Use: getent group editor"
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  editor:x:1005:tsuli"
    echo

    # STEP 8: Inspect permissions on key auth files (ls is unprivileged; files may be root-owned)
    echo "  Step 8: List passwd/group/shadow/gshadow and review permissions."
    read -p "$PROMPT" cmd8
    echo
    if [[ "$cmd8" != "ls -l /etc/passwd /etc/group /etc/shadow /etc/gshadow" ]]; then
        print_error "Incorrect. Use: ls -l /etc/passwd /etc/group /etc/shadow /etc/gshadow"
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  -rw-r--r--. 1 root root   2450 Sep 10 10:30 /etc/passwd"
    echo "  -rw-r--r--. 1 root root   1200 Sep 10 10:30 /etc/group"
    echo "  -rw-------. 1 root root   1700 Sep 10 10:30 /etc/shadow"
    echo "  -rw-------. 1 root root    600 Sep 10 10:30 /etc/gshadow"
    echo

    # STEP 9: Cleanup (realistic lab hygiene)
    echo "  Step 9: Remove the contractor account and home directory (cleanup)."
    read -p "$PROMPT" cmd9
    echo
    if ! accept_cmd "$cmd9" "sudo userdel -r tsuli"; then
        print_error "Incorrect. Use: sudo userdel -r tsuli"
        read -p "Press Enter to retry..." _
        continue
    fi

    print_success "Excellent work!"
    print_info "Workflow completed:"
    print_info "- Ensured required groups exist (groupadd -f)"
    print_info "- Created a user with a home directory (useradd -m)"
    print_info "- Verified NSS user/group/shadow records (getent, id)"
    print_info "- Added team memberships safely (usermod -aG)"
    print_info "- Checked permissions on critical auth databases (ls -l /etc/*shadow*)"
    print_info "- Cleaned up test account (userdel -r)"
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
