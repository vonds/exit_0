#!/bin/bash

# Lab 294: Understanding Package Management – Objectives 102.4 & 102.5

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 294"
LAB_ID="lab294"
LAB_XP=45900
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
    center_text "Objectives 102.4 & 102.5 — Understanding Package Management"
    center_text "Learn the structure of packages, formats (DEB/RPM), and key package tools."
    echo
    center_text "Press Enter to begin the lab..."
    read _
    draw_lab_ui

    echo "  Step 1: Check the package that provides the 'bash' program."
    read -p "  lab@centos-lab294:~\$ > " cmd1
    echo

    if [[ "$cmd1" != "rpm -qf /bin/bash" ]]; then
        print_error "Incorrect. Use rpm -qf /bin/bash to query which package owns that file."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  bash-4.4.20-2.el8.x86_64"
    echo

    echo "  Step 2: Find the absolute path of the rpm and yum package managers."
    read -p "  lab@centos-lab294:~\$ > " cmd2
    echo

    if [[ "$cmd2" != "which rpm && which yum" ]]; then
        print_error "Incorrect. Combine which rpm && which yum to view both paths."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  /usr/bin/rpm"
    echo "  /usr/bin/yum"
    echo

    echo "  Step 3: What file extensions do Debian and Red Hat binary packages use?"
    read -p "  lab@centos-lab294:~\$ > " cmd3
    echo

    if [[ "$cmd3" != ".deb and .rpm" ]]; then
        print_error "Incorrect. Answer with: .deb and .rpm"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  .deb and .rpm"
    echo

    echo "  Step 4: Use a command to query general information about the bash package."
    read -p "  lab@centos-lab294:~\$ > " cmd4
    echo

    if [[ "$cmd4" != "rpm -qi bash" ]]; then
        print_error "Incorrect. Use rpm -qi bash to display package information."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Name        : bash"
    echo "  Version     : 4.4.20"
    echo "  Release     : 2.el8"
    echo "  Architecture: x86_64"
    echo "  Summary     : The GNU Bourne Again shell"
    echo "  Description : Bash is the default command processor for most Linux systems."
    echo

    echo "  Step 5: Install a package directly from an RPM file."
    read -p "  lab@centos-lab294:~\$ > " cmd5
    echo

    if [[ "$cmd5" != "sudo rpm -ivh example.rpm" ]]; then
        print_error "Incorrect. Use rpm -ivh filename.rpm for direct installations."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Preparing...                          ################################# [100%]"
    echo "  Updating / installing..."
    echo "  example-1.0-1.el8.x86_64              ################################# [100%]"
    echo

    echo "  Step 6: Which higher-level package manager automatically resolves dependencies?"
    read -p "  lab@centos-lab294:~\$ > " cmd6
    echo

    if [[ "$cmd6" != "yum" ]]; then
        print_error "Incorrect. High-level Red Hat package manager: yum"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Correct — yum automatically downloads dependencies and installs them."
    echo

    echo "  Step 7: Use yum to install the 'tree' package (pretend installation)."
    read -p "  lab@centos-lab294:~\$ > " cmd7
    echo

    if [[ "$cmd7" != "sudo yum install tree" ]]; then
        print_error "Incorrect. Use sudo yum install tree"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Resolving Dependencies"
    echo "  --> Running transaction check"
    echo "  Installing : tree-1.7.0-15.el8.x86_64"
    echo "  Installed: tree.x86_64 1.7.0-15.el8"
    echo

    echo "  Step 8: List the modern equivalents of yum for RHEL-based systems (not on exam)."
    read -p "  lab@centos-lab294:~\$ > " cmd8
    echo

    if [[ "$cmd8" != "dnf snap flatpak" ]]; then
        print_error "Incorrect. Answer with: dnf snap flatpak"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Step 9: Which Debian utilities perform similar high-level management?"
    read -p "  lab@centos-lab294:~\$ > " cmd9
    echo

    if [[ "$cmd9" != "apt-get and apt-cache" ]]; then
        print_error "Incorrect. Type: apt-get and apt-cache"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi


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
