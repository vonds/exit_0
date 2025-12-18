#!/bin/bash

# Lab 298: Managing Red Hat Packages with yum – Objective 102.5

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 298"
LAB_ID="lab298"
LAB_XP=77600
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
    center_text "Objective 102.5 — Manage Red Hat packages with yum"
    center_text "Repos, configuration, installs/updates/removals, cache, info, deps, search."
    echo
    center_text "Press Enter to begin the lab..."
    read _
    draw_lab_ui

    echo "  Step 1: Show the yum configuration file and repo directory (paths only)."
    read -p "  lab@rhel-lab298:~\$ > " cmd1
    echo

    if [[ "$cmd1" != "ls -ld /etc/yum.conf /etc/yum.repos.d/" ]]; then
        print_error "Incorrect. Use: ls -ld /etc/yum.conf /etc/yum.repos.d/"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  -rw-r--r--. 1 root root  1793 Jan 01 00:00 /etc/yum.conf"
    echo "  drwxr-xr-x. 1 root root  4096 Jan 01 00:00 /etc/yum.repos.d/"
    echo

    echo "  Step 2: Which file is the main yum config file? (answer with the absolute path)"
    read -p "  lab@rhel-lab298:~\$ > " cmd2
    echo

    if [[ "$cmd2" != "/etc/yum.conf" ]]; then
        print_error "Incorrect. Answer with: /etc/yum.conf"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  /etc/yum.conf"
    echo

    echo "  Step 3: Where are repo definition files stored? (answer with the directory path)"
    read -p "  lab@rhel-lab298:~\$ > " cmd3
    echo

    if [[ "$cmd3" != "/etc/yum.repos.d/" ]]; then
        print_error "Incorrect. Answer with: /etc/yum.repos.d/"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  /etc/yum.repos.d/"
    echo

    echo "  Step 4: Show whether iptraf-ng is installed or available."
    read -p "  lab@rhel-lab298:~\$ > " cmd4
    echo

    if [[ "$cmd4" != "yum list iptraf-ng" ]]; then
        print_error "Incorrect. Use: yum list iptraf-ng"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Available Packages"
    echo "  iptraf-ng.x86_64  1.2.1-9.el8  appstream"
    echo

    echo "  Step 5: Check if iotop is installed."
    read -p "  lab@rhel-lab298:~\$ > " cmd5
    echo

    if [[ "$cmd5" != "yum list installed iotop" ]]; then
        print_error "Incorrect. Use: yum list installed iotop"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Installed Packages"
    echo "  iotop.noarch  0.6-4.el8  @baseos"
    echo

    echo "  Step 6: Install iptraf-ng (pretend install)."
    read -p "  lab@rhel-lab298:~\$ > " cmd6
    echo

    if [[ "$cmd6" != "sudo yum install iptraf-ng" ]]; then
        print_error "Incorrect. Use: sudo yum install iptraf-ng"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Dependencies resolved."
    echo "  ========================================================================"
    echo "   Package         Arch    Version        Repository    Size"
    echo "  ========================================================================"
    echo "   iptraf-ng       x86_64  1.2.1-9.el8    appstream     200 k"
    echo
    echo "  Is this ok [y/N]: y"
    echo "  Downloading Packages:"
    echo "  Installed: iptraf-ng-1.2.1-9.el8.x86_64"
    echo

    echo "  Step 7: Clean all cached metadata and packages."
    read -p "  lab@rhel-lab298:~\$ > " cmd7
    echo

    if [[ "$cmd7" != "sudo yum clean all" ]]; then
        print_error "Incorrect. Use: sudo yum clean all"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  0 files removed"
    echo "  Cleaning repos: baseos appstream extras"
    echo "  Cleaning up list of fastest mirrors"
    echo

    echo "  Step 8: Update iotop to the latest available version."
    read -p "  lab@rhel-lab298:~\$ > " cmd8
    echo

    if [[ "$cmd8" != "sudo yum update iotop" ]]; then
        print_error "Incorrect. Use: sudo yum update iotop"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Last metadata expiration check: 0:00:00 ago"
    echo "  Dependencies resolved."
    echo "  Nothing to do. Complete!"
    echo

    echo "  Step 9: Remove (erase) iptraf-ng."
    read -p "  lab@rhel-lab298:~\$ > " cmd9
    echo

    if [[ "$cmd9" != "sudo yum remove iptraf-ng" ]]; then
        print_error "Incorrect. Use: sudo yum remove iptraf-ng"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Resolving Dependencies"
    echo "  --> Removing: iptraf-ng.x86_64 1.2.1-9.el8"
    echo "  Removed: iptraf-ng.x86_64 1.2.1-9.el8"
    echo

    echo "  Step 10: Display package details for iotop."
    read -p "  lab@rhel-lab298:~\$ > " cmd10
    echo

    if [[ "$cmd10" != "yum info iotop" ]]; then
        print_error "Incorrect. Use: yum info iotop"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Installed Packages"
    echo "  Name         : iotop"
    echo "  Arch         : noarch"
    echo "  Version      : 0.6"
    echo "  Release      : 4.el8"
    echo "  Repository   : @System"
    echo "  Summary      : Top-like I/O monitor"
    echo

    echo "  Step 11: Show the dependencies required by iotop."
    read -p "  lab@rhel-lab298:~\$ > " cmd11
    echo

    if [[ "$cmd11" != "yum deplist iotop" ]]; then
        print_error "Incorrect. Use: yum deplist iotop"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  package: iotop.noarch 0.6-4.el8"
    echo "   dependency: python3"
    echo "   dependency: /usr/bin/python3"
    echo

    echo "  Step 12: Find which package provides /bin/top."
    read -p "  lab@rhel-lab298:~\$ > " cmd12
    echo

    if [[ "$cmd12" != "yum provides /bin/top" ]]; then
        print_error "Incorrect. Use: yum provides /bin/top"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  procps-ng-3.3.15-13.el8.x86_64 : System and process monitoring utilities"
    echo "  Repo        : baseos"
    echo "  Matched from:"
    echo "   Filename   : /bin/top"
    echo

    echo "  Step 13: Search repos for packages related to iotop."
    read -p "  lab@rhel-lab298:~\$ > " cmd13
    echo

    if [[ "$cmd13" != "yum search iotop" ]]; then
        print_error "Incorrect. Use: yum search iotop"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  ============================ Name Exactly Matched ============================="
    echo "  iotop.noarch : Top-like I/O monitor"
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
