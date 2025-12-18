#!/bin/bash

# Lab 295: Managing Debian Packages with dpkg – Objectives 102.4 & 102.5

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 295"
LAB_ID="lab295"
LAB_XP=47300
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
    center_text "Objectives 102.4 & 102.5 — Managing Debian Packages with dpkg"
    center_text "Learn how to inspect, install, verify, audit, and reconfigure Debian packages."
    echo
    center_text "Press Enter to begin the lab..."
    read _
    draw_lab_ui

    echo "  Step 1: Display the contents of a Debian package file using dpkg."
    read -p "  lab@ubuntu-lab295:~\$ > " cmd1
    echo

    if [[ "$cmd1" != "dpkg -c example_1.0-1_amd64.deb" ]]; then
        print_error "Incorrect. Use dpkg -c followed by the package file name."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  drwxr-xr-x root/root         0 2025-10-14 10:00 ./usr/bin/"
    echo "  -rwxr-xr-x root/root     15360 2025-10-14 10:00 ./usr/bin/example"
    echo "  -rw-r--r-- root/root      1024 2025-10-14 10:00 ./usr/share/doc/example/README"
    echo

    echo "  Step 2: View package version and dependency information."
    read -p "  lab@ubuntu-lab295:~\$ > " cmd2
    echo

    if [[ "$cmd2" != "dpkg -I example_1.0-1_amd64.deb" ]]; then
        print_error "Incorrect. Use dpkg -I (uppercase i) to view version and dependency info."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  new debian package, version 2.0."
    echo "  Package: example"
    echo "  Version: 1.0-1"
    echo "  Architecture: amd64"
    echo "  Maintainer: John Doe <john@example.com>"
    echo "  Depends: libc6 (>= 2.31)"
    echo "  Installed-Size: 512"
    echo

    echo "  Step 3: Check if the package 'example' is currently installed."
    read -p "  lab@ubuntu-lab295:~\$ > " cmd3
    echo

    if [[ "$cmd3" != "dpkg -s example" ]]; then
        print_error "Incorrect. Use dpkg -s package_name to check installation status."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  package 'example' is not installed"
    echo

    echo "  Step 4: Install the Debian package file using dpkg."
    read -p "  lab@ubuntu-lab295:~\$ > " cmd4
    echo

    if [[ "$cmd4" != "sudo dpkg -i example_1.0-1_amd64.deb" ]]; then
        print_error "Incorrect. Use sudo dpkg -i followed by the full package file name."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Selecting previously unselected package example."
    echo "  Preparing to unpack example_1.0-1_amd64.deb ..."
    echo "  Unpacking example (1.0-1) ..."
    echo "  Setting up example (1.0-1) ..."
    echo "  Processing triggers for man-db (2.9.1-1) ..."
    echo

    echo "  Step 5: Verify that the package is now installed."
    read -p "  lab@ubuntu-lab295:~\$ > " cmd5
    echo

    if [[ "$cmd5" != "dpkg -s example | less" ]]; then
        print_error "Incorrect. Pipe dpkg -s example to less for readability."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Package: example"
    echo "  Status: install ok installed"
    echo "  Priority: optional"
    echo "  Section: utils"
    echo "  Installed-Size: 512"
    echo "  Maintainer: John Doe <john@example.com>"
    echo "  Version: 1.0-1"
    echo

    echo "  Step 6: Verify the installed package’s integrity."
    read -p "  lab@ubuntu-lab295:~\$ > " cmd6
    echo

    if [[ "$cmd6" != "sudo dpkg -V example" ]]; then
        print_error "Incorrect. Use sudo dpkg -V package_name to verify integrity."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  (no output — verification passed successfully)"
    echo

    echo "  Step 7: Perform a package audit to detect any broken packages."
    read -p "  lab@ubuntu-lab295:~\$ > " cmd7
    echo

    if [[ "$cmd7" != "sudo dpkg -C" ]]; then
        print_error "Incorrect. Use sudo dpkg -C to audit for broken or incomplete installs."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  (no output — no broken packages detected)"
    echo

    echo "  Step 8: Remove the example package (but not its dependencies)."
    read -p "  lab@ubuntu-lab295:~\$ > " cmd8
    echo

    if [[ "$cmd8" != "sudo dpkg -r example" ]]; then
        print_error "Incorrect. Use sudo dpkg -r package_name to remove it."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  (Reading database ...)"
    echo "  Removing example (1.0-1) ..."
    echo

    echo "  Step 9: Reconfigure an installed package (pretend example is still installed)."
    read -p "  lab@ubuntu-lab295:~\$ > " cmd9
    echo

    if [[ "$cmd9" != "sudo dpkg-reconfigure example" ]]; then
        print_error "Incorrect. Use sudo dpkg-reconfigure package_name to adjust its configuration."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Configuring example..."
    echo "  ┌────────────────────────────┤ Configuring example ├────────────────────────────┐"
    echo "  │ Would you like to enable example service on startup?                          │"
    echo "  │                                                                               │"
    echo "  │       <Yes>                                                <No>               │"
    echo "  └───────────────────────────────────────────────────────────────────────────────┘"
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
