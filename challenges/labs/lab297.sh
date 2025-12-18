#!/bin/bash

# Lab 297: Managing Red Hat Packages with rpm – Objective 102.5

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 297"
LAB_ID="lab297"
LAB_XP=47500
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
    center_text "Objective 102.5 — Manage Red Hat packages with rpm"
    center_text "Practice queries, verification, installs, upgrades, removals, and extraction."
    echo
    center_text "Press Enter to begin the lab..."
    read _
    draw_lab_ui

    echo "  Step 1: Check whether Firefox is installed."
    read -p "  lab@rhel-lab297:~\$ > " cmd1
    echo

    if [[ "$cmd1" != "rpm -q firefox" ]]; then
        print_error "Incorrect. Use: rpm -q firefox"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  firefox-102.15.0-1.el8.x86_64"
    echo

    echo "  Step 2: Show general information about the bash package."
    read -p "  lab@rhel-lab297:~\$ > " cmd2
    echo

    if [[ "$cmd2" != "rpm -qi bash" ]]; then
        print_error "Incorrect. Use: rpm -qi bash"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Name        : bash"
    echo "  Version     : 4.4.20"
    echo "  Release     : 2.el8"
    echo "  Architecture: x86_64"
    echo "  Install Date: Mon 01 Jan 2024 12:00:00 AM UTC"
    echo "  Summary     : The GNU Bourne Again shell"
    echo

    echo "  Step 3: List dependencies required by the bash package."
    read -p "  lab@rhel-lab297:~\$ > " cmd3
    echo

    if [[ "$cmd3" != "rpm -qR bash" ]]; then
        print_error "Incorrect. Use: rpm -qR bash"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  rtld(GNU_HASH)"
    echo "  libc.so.6(GLIBC_2.2.5)"
    echo "  libtinfo.so.6"
    echo "  /bin/sh"
    echo

    echo "  Step 4: Find which installed package owns /bin/top."
    read -p "  lab@rhel-lab297:~\$ > " cmd4
    echo

    if [[ "$cmd4" != "rpm -qf /bin/top" ]]; then
        print_error "Incorrect. Use: rpm -qf /bin/top"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  procps-ng-3.3.15-13.el8.x86_64"
    echo

    echo "  Step 5: Verify the integrity of the bash package files."
    read -p "  lab@rhel-lab297:~\$ > " cmd5
    echo

    if [[ "$cmd5" != "rpm -V bash" ]]; then
        print_error "Incorrect. Use: rpm -V bash"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo
    echo "  (no output means all tracked files verify correctly)"
    echo

    echo "  Step 6: Install a local RPM file (pretend install)."
    read -p "  lab@rhel-lab297:~\$ > " cmd6
    echo

    if [[ "$cmd6" != "sudo rpm -ivh example-1.0-1.el8.x86_64.rpm" ]]; then
        print_error "Incorrect. Use: sudo rpm -ivh example-1.0-1.el8.x86_64.rpm"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Preparing...                          ################################# [100%]"
    echo "  Updating / installing..."
    echo "  example-1.0-1.el8.x86_64              ################################# [100%]"
    echo

    echo "  Step 7: Upgrade a local RPM (installs if not present)."
    read -p "  lab@rhel-lab297:~\$ > " cmd7
    echo

    if [[ "$cmd7" != "sudo rpm -Uvh example-1.1-1.el8.x86_64.rpm" ]]; then
        print_error "Incorrect. Use: sudo rpm -Uvh example-1.1-1.el8.x86_64.rpm"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Preparing...                          ################################# [100%]"
    echo "  Upgrading/Installing..."
    echo "  example-1.1-1.el8.x86_64              ################################# [100%]"
    echo

    echo "  Step 8: Remove (erase) the example package by name."
    read -p "  lab@rhel-lab297:~\$ > " cmd8
    echo

    if [[ "$cmd8" != "sudo rpm -e example" ]]; then
        print_error "Incorrect. Use: sudo rpm -e example"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Preparing... done"
    echo "  Erasing     : example-1.1-1.el8.x86_64"
    echo "  Verifying   : example-1.1-1.el8.x86_64"
    echo

    echo "  Step 9: Extract files from an RPM without installing."
    read -p "  lab@rhel-lab297:~\$ > " cmd9
    echo

    if [[ "$cmd9" != "rpm2cpio example-1.1-1.el8.x86_64.rpm | cpio -idmv" ]]; then
        print_error "Incorrect. Use: rpm2cpio example-1.1-1.el8.x86_64.rpm | cpio -idmv"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  example/usr/bin/example"
    echo "  example/usr/share/doc/example/README"
    echo "  2 blocks"
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
