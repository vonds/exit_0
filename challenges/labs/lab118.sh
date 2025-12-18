#!/bin/bash

# Lab 118: Reconfiguring Installed Packages with dpkg-reconfigure
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 118: Reconfiguring Installed Packages with dpkg-reconfigure"
LAB_ID="lab118"
LAB_XP=3000
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
    center_text "Scenario: You need to change configuration of already-installed packages."
    center_text "Use dpkg-reconfigure in interactive and noninteractive modes, and verify results."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Reconfigure the system time zone interactively."
    echo "          Use dpkg-reconfigure on the tzdata package."
    read -p "  lab@lpic-lab118:~$ " cmd1
    echo
    [[ "$cmd1" != "sudo dpkg-reconfigure tzdata" ]] && {
        print_error "Incorrect. Use: sudo dpkg-reconfigure tzdata"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "Current default time zone: 'America/New_York'"
    echo "Local time is now:  Tue Aug 19 12:34:00 EDT 2025."
    echo "Universal Time is now:  Tue Aug 19 16:34:00 UTC 2025."
    echo

    echo "  Step 2: Show debconf selections for tzdata to verify the configured region/city."
    read -p "  lab@lpic-lab118:~$ " cmd2
    echo
    [[ "$cmd2" != "sudo debconf-show tzdata | grep -E 'Areas|Cities'" && "$cmd2" != "sudo debconf-show tzdata | egrep 'Areas|Cities'" ]] && {
        print_error "Incorrect. Example: sudo debconf-show tzdata | grep -E 'Areas|Cities'"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  tzdata/Areas: America"
    echo "  tzdata/Cities: New_York"
    echo

    echo "  Step 3: Regenerate OpenSSH server host keys safely via dpkg-reconfigure."
    echo "          Use dpkg-reconfigure on openssh-server."
    read -p "  lab@lpic-lab118:~$ " cmd3
    echo
    [[ "$cmd3" != "sudo dpkg-reconfigure openssh-server" ]] && {
        print_error "Incorrect. Use: sudo dpkg-reconfigure openssh-server"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "Creating SSH2 RSA key; this may take some time ..."
    echo "Creating SSH2 ECDSA key; this may take some time ..."
    echo "Creating SSH2 ED25519 key; this may take some time ..."
    echo "Restarting OpenSSH server: sshd."
    echo

    echo "  Step 4: Reconfigure the /bin/sh alternative using dpkg-reconfigure dash."
    echo "          Run the tool; this controls whether /bin/sh points to dash or bash."
    read -p "  lab@lpic-lab118:~$ " cmd4
    echo
    [[ "$cmd4" != "sudo dpkg-reconfigure dash" ]] && {
        print_error "Incorrect. Use: sudo dpkg-reconfigure dash"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "Removing 'diversion of /bin/sh to /bin/sh.distrib by dash'"
    echo "Adding 'diversion of /bin/sh to /bin/sh.distrib by dash'"
    echo "Using /bin/bash as the system shell (/bin/sh) (selection may vary by choice)."
    echo

    echo "  Step 5: Use noninteractive mode to reconfigure tzdata without prompts."
    echo "          Use DEBIAN_FRONTEND=noninteractive with -f noninteractive."
    read -p "  lab@lpic-lab118:~$ " cmd5
    echo
    [[ "$cmd5" != "sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure -f noninteractive tzdata" ]] && {
        print_error "Incorrect. Use: sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure -f noninteractive tzdata"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "Reconfiguring tzdata in noninteractive mode."
    echo "Current default time zone: 'America/New_York'"
    echo

    echo "  Step 6: Force low-priority questions to be shown during reconfigure."
    echo "          Use --priority=low with dpkg-reconfigure for tzdata."
    read -p "  lab@lpic-lab118:~$ " cmd6
    echo
    [[ "$cmd6" != "sudo dpkg-reconfigure --priority=low tzdata" ]] && {
        print_error "Incorrect. Use: sudo dpkg-reconfigure --priority=low tzdata"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "Displaying all configuration questions (priority: low)."
    echo "Current default time zone remains: 'America/New_York'"
    echo

    echo "  Step 7: Verify that /etc/localtime is a valid link into zoneinfo."
    read -p "  lab@lpic-lab118:~$ " cmd7
    echo
    [[ "$cmd7" != "ls -l /etc/localtime" ]] && {
        print_error "Incorrect. Use: ls -l /etc/localtime"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "lrwxrwxrwx 1 root root 33 Aug 19 12:34 /etc/localtime -> /usr/share/zoneinfo/America/New_York"
    echo

    echo "  Step 8: If any packages were left unconfigured, configure them now."
    echo "          Use dpkg to configure all unpacked but unconfigured packages."
    read -p "  lab@lpic-lab118:~$ " cmd8
    echo
    [[ "$cmd8" != "sudo dpkg --configure -a" ]] && {
        print_error "Incorrect. Use: sudo dpkg --configure -a"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "Setting up pending packages (if any)."
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
    print_info "You've completed this lab $completion_count time(s)."
    echo
    center_text "Would you like to:"
    center_text "1) Retry this lab"
    center_text "2) Return to Sysadmin Lab Menu"
    echo
    read -p "  > " post_choice

    [[ "$post_choice" == "2" ]] && exit 0
done
