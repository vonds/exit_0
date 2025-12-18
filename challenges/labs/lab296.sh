#!/bin/bash

# Lab 296: Managing Debian Packages with apt-get and apt-cache – Objectives 102.4 & 102.5

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 296"
LAB_ID="lab296"
LAB_XP=47600
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
    center_text "Objectives 102.4 & 102.5 — Managing Debian Packages with apt-get and apt-cache"
    center_text "Learn how to install, update, remove, and inspect Debian packages using APT utilities."
    echo
    center_text "Press Enter to begin the lab..."
    read _
    draw_lab_ui

    echo "  Step 1: View repository configuration files."
    read -p "  lab@ubuntu-lab296:~\$ > " cmd1
    echo

    if [[ "$cmd1" != "cat /etc/apt/sources.list" ]]; then
        print_error "Incorrect. Use cat /etc/apt/sources.list to display repository sources."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  deb http://archive.ubuntu.com/ubuntu/ focal main restricted"
    echo "  deb http://archive.ubuntu.com/ubuntu/ focal-updates main restricted"
    echo "  deb http://archive.ubuntu.com/ubuntu/ focal universe"
    echo

    echo "  Step 2: Update repository information."
    read -p "  lab@ubuntu-lab296:~\$ > " cmd2
    echo

    if [[ "$cmd2" != "sudo apt-get update" ]]; then
        print_error "Incorrect. Use sudo apt-get update to refresh repository package lists."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Get:1 http://archive.ubuntu.com/ubuntu focal InRelease [265 kB]"
    echo "  Get:2 http://archive.ubuntu.com/ubuntu focal-updates InRelease [114 kB]"
    echo "  Fetched 379 kB in 3s (127 kB/s)"
    echo "  Reading package lists... Done"
    echo

    echo "  Step 3: Install a package from a repository."
    read -p "  lab@ubuntu-lab296:~\$ > " cmd3
    echo

    if [[ "$cmd3" != "sudo apt-get install procinfo" ]]; then
        print_error "Incorrect. Use sudo apt-get install package_name to install from repositories."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Reading package lists... Done"
    echo "  Building dependency tree... Done"
    echo "  Reading state information... Done"
    echo "  The following NEW packages will be installed:"
    echo "    procinfo"
    echo "  After this operation, 150 kB of additional disk space will be used."
    echo "  Do you want to continue? [Y/n] y"
    echo "  Setting up procinfo (2.0.304) ..."
    echo

    echo "  Step 4: Verify that the package is installed."
    read -p "  lab@ubuntu-lab296:~\$ > " cmd4
    echo

    if [[ "$cmd4" != "apt-cache policy procinfo" ]]; then
        print_error "Incorrect. Use apt-cache policy package_name to verify installation status."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  procinfo:"
    echo "    Installed: 2.0.304-1"
    echo "    Candidate: 2.0.304-1"
    echo "    Version table:"
    echo "       *** 2.0.304-1 500"
    echo "              500 http://archive.ubuntu.com/ubuntu focal/universe amd64 Packages"
    echo "              100 /var/lib/dpkg/status"
    echo

    echo "  Step 5: Update a package to its latest version."
    read -p "  lab@ubuntu-lab296:~\$ > " cmd5
    echo

    if [[ "$cmd5" != "sudo apt-get upgrade procinfo" ]]; then
        print_error "Incorrect. Use sudo apt-get upgrade package_name to update an installed package."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Reading package lists... Done"
    echo "  Building dependency tree... Done"
    echo "  Reading state information... Done"
    echo "  procinfo is already the newest version (2.0.304-1)."
    echo

    echo "  Step 6: Remove a package without its configuration files."
    read -p "  lab@ubuntu-lab296:~\$ > " cmd6
    echo

    if [[ "$cmd6" != "sudo apt-get remove procinfo" ]]; then
        print_error "Incorrect. Use sudo apt-get remove package_name to uninstall the package."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Reading package lists... Done"
    echo "  Building dependency tree... Done"
    echo "  Reading state information... Done"
    echo "  The following packages will be REMOVED:"
    echo "    procinfo"
    echo "  After this operation, 150 kB disk space will be freed."
    echo "  Do you want to continue? [Y/n] y"
    echo "  Removing procinfo (2.0.304-1) ..."
    echo

    echo "  Step 7: Display package dependencies using apt-cache."
    read -p "  lab@ubuntu-lab296:~\$ > " cmd7
    echo

    if [[ "$cmd7" != "apt-cache depends procinfo" ]]; then
        print_error "Incorrect. Use apt-cache depends package_name to view dependencies."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  procinfo"
    echo "    Depends: libc6"
    echo "    Depends: libncurses5"
    echo

    echo "  Step 8: Display detailed package information."
    read -p "  lab@ubuntu-lab296:~\$ > " cmd8
    echo

    if [[ "$cmd8" != "apt-cache show procinfo" ]]; then
        print_error "Incorrect. Use apt-cache show package_name to display package metadata."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Package: procinfo"
    echo "  Version: 2.0.304-1"
    echo "  Maintainer: Ubuntu Developers <ubuntu-devel-discuss@lists.ubuntu.com>"
    echo "  Description: Display system information from /proc"
    echo "  Homepage: https://packages.ubuntu.com/procinfo"
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
