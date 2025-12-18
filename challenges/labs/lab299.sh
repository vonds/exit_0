#!/bin/bash

# Lab 299: Managing Red Hat Packages with zypper – Objective 102.5

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 299"
LAB_ID="lab299"
LAB_XP=67700
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
    center_text "Objective 102.5 — Manage Red Hat packages with zypper"
    center_text "Work with repos, refresh, install, update, remove, verify, and info commands."
    echo
    center_text "Press Enter to begin the lab..."
    read _
    draw_lab_ui

    echo "  Step 1: View zypper configuration file and repo directory."
    read -p "  lab@opensuse-lab299:~\$ > " cmd1
    echo

    if [[ "$cmd1" != "ls -ld /etc/zypp/zypp.conf /etc/zypp/repos.d/" ]]; then
        print_error "Incorrect. Use: ls -ld /etc/zypp/zypp.conf /etc/zypp/repos.d/"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  -rw-r--r--. 1 root root  3540 Jan 01 00:00 /etc/zypp/zypp.conf"
    echo "  drwxr-xr-x. 1 root root  4096 Jan 01 00:00 /etc/zypp/repos.d/"
    echo

    echo "  Step 2: Refresh repository metadata."
    read -p "  lab@opensuse-lab299:~\$ > " cmd2
    echo

    if [[ "$cmd2" != "sudo zypper refresh" ]]; then
        print_error "Incorrect. Use: sudo zypper refresh"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Retrieving repository 'Main Repository' metadata ..."
    echo "  Repository 'Main Repository' refreshed."
    echo "  All repositories have been refreshed."
    echo

    echo "  Step 3: Install the iotop package."
    read -p "  lab@opensuse-lab299:~\$ > " cmd3
    echo

    if [[ "$cmd3" != "sudo zypper install iotop" ]]; then
        print_error "Incorrect. Use: sudo zypper install iotop"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Loading repository data..."
    echo "  Reading installed packages..."
    echo "  Resolving package dependencies..."
    echo "  The following NEW package is going to be installed: iotop"
    echo "  Continue? [y/n/v/...? shows all options] (y): y"
    echo "  Installing: iotop-0.6-4.2.noarch [done]"
    echo "  Additional rpm output: Installing package iotop"
    echo "  Installation of iotop succeeded."
    echo

    echo "  Step 4: Verify installation by searching installed packages."
    read -p "  lab@opensuse-lab299:~\$ > " cmd4
    echo

    if [[ "$cmd4" != "zypper search -i iotop" ]]; then
        print_error "Incorrect. Use: zypper search -i iotop"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  S | Name  | Type    | Version | Arch  | Repository"
    echo "  --+-------+---------+---------+-------+------------"
    echo "  i+| iotop | package | 0.6-4.2 | noarch| @System"
    echo

    echo "  Step 5: Display detailed info about the installed package."
    read -p "  lab@opensuse-lab299:~\$ > " cmd5
    echo

    if [[ "$cmd5" != "zypper info iotop" ]]; then
        print_error "Incorrect. Use: zypper info iotop"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Information for package iotop:"
    echo "  -------------------------------"
    echo "  Repository  : @System"
    echo "  Name         : iotop"
    echo "  Version      : 0.6-4.2"
    echo "  Arch         : noarch"
    echo "  Installed    : Yes"
    echo "  Summary      : Top-like I/O monitor"
    echo

    echo "  Step 6: Check which package provides /usr/bin/top."
    read -p "  lab@opensuse-lab299:~\$ > " cmd6
    echo

    if [[ "$cmd6" != "sudo zypper what-provides /usr/bin/top" ]]; then
        print_error "Incorrect. Use: sudo zypper what-provides /usr/bin/top"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  S | Name      | Type    | Version   | Arch  | Repository"
    echo "  --+-----------+---------+-----------+-------+------------"
    echo "  i+| procps    | package | 3.3.15-3.5 | x86_64| Main Repo"
    echo

    echo "  Step 7: Update the iotop package."
    read -p "  lab@opensuse-lab299:~\$ > " cmd7
    echo

    if [[ "$cmd7" != "sudo zypper update iotop" ]]; then
        print_error "Incorrect. Use: sudo zypper update iotop"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Loading repository data..."
    echo "  Reading installed packages..."
    echo "  Nothing to update."
    echo

    echo "  Step 8: Remove the iotop package."
    read -p "  lab@opensuse-lab299:~\$ > " cmd8
    echo

    if [[ "$cmd8" != "sudo zypper remove iotop" ]]; then
        print_error "Incorrect. Use: sudo zypper remove iotop"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Reading installed packages..."
    echo "  Resolving package dependencies..."
    echo "  The following package is going to be REMOVED: iotop"
    echo "  Continue? [y/n/v/...? shows all options] (y): y"
    echo "  Removing: iotop-0.6-4.2.noarch [done]"
    echo

    echo "  Step 9: Verify installed packages have their dependencies met."
    read -p "  lab@opensuse-lab299:~\$ > " cmd9
    echo

    if [[ "$cmd9" != "sudo zypper verify" ]]; then
        print_error "Incorrect. Use: sudo zypper verify"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Reading installed packages..."
    echo "  Checking for dependencies..."
    echo "  Nothing to do."
    echo

    echo "  Step 10: Show available updates for installed packages."
    read -p "  lab@opensuse-lab299:~\$ > " cmd10
    echo

    if [[ "$cmd10" != "zypper list-updates" ]]; then
        print_error "Incorrect. Use: zypper list-updates"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  No updates found."
    echo

    echo "  Step 11: Display zypper command help."
    read -p "  lab@opensuse-lab299:~\$ > " cmd11
    echo

    if [[ "$cmd11" != "zypper | less" ]]; then
        print_error "Incorrect. Use: zypper | less"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Commands:"
    echo "    search, install, remove, update, info, verify, refresh, what-provides, list-updates..."
    echo

    print_success "Excellent work!"
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
