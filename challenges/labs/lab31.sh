#!/bin/bash

# Lab 31: Special File Permissions - SetUID, SetGID, and Sticky Bit

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 31: Special Permissions"
LAB_ID="lab31"
LAB_XP=13125
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
    center_text "Scenario: You are preparing a multi-user environment on a development server."
    center_text "Your tasks involve configuring special permissions to ensure security and proper access control."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui

    echo "  Step 1: Ensure the 'devs' group exists."
    read -p "  lab@lpic-lab31:~$ " cmd1
    echo
    [[ "$cmd1" != "sudo groupadd -f devs" && "$cmd1" != "groupadd -f devs" ]] && {
        print_error "Incorrect. Use: groupadd -f devs"
        read -p "Press Enter to try again..." _
        continue
    }


    echo "  Step 2: Create a shared directory called /opt/devshare."
    read -p "  lab@lpic-lab31:~$ " cmd2
    echo
    [[ "$cmd2" != "sudo mkdir -p /opt/devshare" && "$cmd2" != "mkdir -p /opt/devshare" ]] && {
        print_error "Incorrect. Use mkdir -p with sudo if needed."
        read -p "Press Enter to try again..." _
        continue
    }


    echo "  Step 3: Assign group ownership to 'devs' group."
    read -p "  lab@lpic-lab31:~$ " cmd3
    echo
    [[ "$cmd3" != "sudo chgrp devs /opt/devshare" && "$cmd3" != "chgrp devs /opt/devshare" ]] && {
        print_error "Incorrect. Use chgrp to change group ownership."
        read -p "Press Enter to try again..." _
        continue
    } 


    echo "  Step 4: Set the setgid bit so new files inherit the group."
    read -p "  lab@lpic-lab31:~$ " cmd4
    echo
    [[ "$cmd4" != "sudo chmod 2775 /opt/devshare" && "$cmd4" != "chmod 2775 /opt/devshare" ]] && {
        print_error "Incorrect. Use chmod with 2XXX to apply setgid."
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 5: Verify the setgid bit on the directory."
    read -p "  lab@lpic-lab31:~$ " cmd5
    echo
    [[ "$cmd5" != "ls -ld /opt/devshare" ]] && {
        print_error "Incorrect. Use: ls -ld /opt/devshare"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  drwxrwsr-x 2 root devs 4096 Jul 19 00:00 /opt/devshare"
    echo

    echo "  Step 6: Create a root-owned helper with setuid (single command)."
    read -p "  lab@lpic-lab31:~$ " cmd6
    echo
    [[ "$cmd6" != "sudo install -o root -g root -m 4755 /bin/true /usr/local/bin/helper" ]] && {
        print_error "Incorrect. Example: sudo install -o root -g root -m 4755 /bin/true /usr/local/bin/helper"
        read -p "Press Enter to try again..." _
        continue
    }


    echo "  Step 7: Confirm the setuid bit on the helper."
    read -p "  lab@lpic-lab31:~$ " cmd7
    echo
    [[ "$cmd7" != "ls -l /usr/local/bin/helper" ]] && {
        print_error "Incorrect. Use: ls -l /usr/local/bin/helper"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  -rwsr-xr-x 1 root root 0 Jul 19 00:00 /usr/local/bin/helper"
    echo

    echo "  Step 8: Create a world-writable directory and apply the sticky bit."
    read -p "  lab@lpic-lab31:~$ " cmd8
    echo
    if [[ "$cmd8" != "sudo mkdir -p /tmp/shared && sudo chmod 1777 /tmp/shared" && "$cmd8" != "mkdir -p /tmp/shared && chmod 1777 /tmp/shared" ]]; then
        print_error "Incorrect. Use: mkdir -p /tmp/shared && chmod 1777 /tmp/shared"
        read -p "Press Enter to try again..." _
        continue
    fi


    echo "  Step 9: Confirm sticky bit is set correctly."
    read -p "  lab@lpic-lab31:~$ " cmd9
    echo
    [[ "$cmd9" != "ls -ld /tmp/shared" ]] && {
        print_error "Incorrect. Use: ls -ld /tmp/shared"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  drwxrwxrwt 2 root root 4096 Jul 19 00:00 /tmp/shared"
    echo

    print_success "Great work!"
    print_info "You earned $LAB_XP XP for completing this real-world lab!"
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
