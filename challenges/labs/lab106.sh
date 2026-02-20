#!/bin/bash

# Lab 101: Managing Users, Groups, and Permissions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 106: Managing Users, Groups, and Permissions"
LAB_ID="lab101"
LAB_XP=5200
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
}

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Scenario: Your team is setting up a new secure development environment."
    center_text "You're tasked with creating two user accounts for new developers,"
    center_text "grouping them under 'devteam', setting secure access permissions"
    center_text "to a shared project directory, and verifying the correct setup."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui

    echo "  Step 1: Create user accounts for dev1 and dev2"
    read -p "  lab@lpic-lab101:~\$ " input1
    [[ "$input1" == "sudo useradd -m dev1 && sudo useradd -m dev2" ]] || { print_error "Expected: sudo useradd -m dev1 && sudo useradd -m dev2"; read -p "Press Enter to try again..."; continue; }

    echo
    echo "  Step 2: Set passwords for dev1 and dev2"
    
    read -p "  lab@lpic-lab101:~\$ " input_pass1
    [[ "$input_pass1" == "sudo passwd dev1 && sudo passwd dev2" ]] || { print_error "Expected: sudo passwd dev1 && sudo passwd dev2"; read -p "Press Enter to try again..."; continue; }
    echo

    echo
    echo "  Step 3: Create the devteam group and add both users"
    read -p "  lab@lpic-lab101:~\$ " input3
    [[ "$input3" == "sudo groupadd devteam && sudo usermod -aG devteam dev1 && sudo usermod -aG devteam dev2" ]] || { print_error "Expected: sudo groupadd devteam && sudo usermod -aG devteam dev1 && sudo usermod -aG devteam dev2"; read -p "Press Enter to try again..."; continue; }

    echo
    echo "  Step 4: Verify entries in /etc/passwd, /etc/shadow, and /etc/group"

    read -p "  lab@lpic-lab101:~\$ " input6
    [[ "$input6" == "grep -E '^(dev1|dev2):' /etc/passwd" ]] || { print_error "Expected: grep -E '^(dev1|dev2):' /etc/passwd"; read -p "Press Enter to try again..."; continue; }
    
    echo
    echo "  dev1:x:1002:1002::/home/dev1:/bin/bash"
    echo "  dev2:x:1003:1003::/home/dev2:/bin/bash"
    echo

    read -p "  lab@lpic-lab101:~\$ " input7
    [[ "$input7" == "sudo grep -E '^(dev1|dev2):' /etc/shadow" ]] || { print_error "Expected: sudo grep -E '^(dev1|dev2):' /etc/shadow"; read -p "Press Enter to try again..."; continue; }
    echo
    echo "  dev1:\$6\$oDc1f9nF\$somehashedstring:19384:0:99999:7:::"
    echo "  dev2:\$6\$Qp31ab2X\$somehashedstring:19384:0:99999:7:::"
    echo

    read -p "  lab@lpic-lab101:~\$ " input8
    [[ "$input8" == "grep '^devteam:' /etc/group" ]] || { print_error "Expected: grep '^devteam:' /etc/group"; read -p "Press Enter to try again..."; continue; }
    
    echo
    echo "  devteam:x:1005:dev1,dev2"
    echo

    echo "  Step 5: Create and secure the shared directory /srv/devdata"
    read -p "  lab@lpic-lab101:~\$ " input9
    [[ "$input9" == "sudo mkdir -p /srv/devdata && sudo chgrp devteam /srv/devdata && sudo chmod 2770 /srv/devdata" ]] || { print_error "Expected: sudo mkdir -p /srv/devdata && sudo chgrp devteam /srv/devdata && sudo chmod 2770 /srv/devdata"; read -p "Press Enter to try again..."; continue; }

    read -p "  lab@lpic-lab101:~\$ " input12
    [[ "$input12" == "ls -ld /srv/devdata" ]] || { print_error "Expected: ls -ld /srv/devdata"; read -p "Press Enter to try again..."; continue; }

    echo
    echo "  drwxrws--- 2 root devteam 4096 Aug  2 02:42 /srv/devdata"
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
