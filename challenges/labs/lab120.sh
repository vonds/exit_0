#!/bin/bash

# Lab 119: APT & APT-GET Basics (update, upgrade, install, remove)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 119: APT & APT-GET Basics"
LAB_ID="lab119"
LAB_XP=3200
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

# helpers to accept apt-get or apt variants
is_update_cmd() {
  [[ "$1" == "sudo apt-get update" || "$1" == "apt-get update" || "$1" == "sudo apt update" || "$1" == "apt update" ]]
}
is_upgrade_cmd() {
  [[ "$1" == "sudo apt-get upgrade" || "$1" == "apt-get upgrade" || "$1" == "sudo apt upgrade" || "$1" == "apt upgrade" ]]
}
is_full_upgrade_cmd() {
  [[ "$1" == "sudo apt-get dist-upgrade" || "$1" == "apt-get dist-upgrade" || "$1" == "sudo apt full-upgrade" || "$1" == "apt full-upgrade" ]]
}

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Scenario: Keep a Debian/Ubuntu system current with APT, then install and remove software."
    center_text "Practice apt-get and apt equivalents: update, upgrade, full-upgrade, install, purge, autoremove, clean."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Update the package index."
    read -p "  lab@lpic-lab119:~$ " cmd1
    echo
    if ! is_update_cmd "$cmd1"; then
        print_error "Incorrect. Use: apt-get update   or   apt update (with sudo as needed)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Get:1 http://archive.ubuntu.com/ubuntu jammy InRelease"
    echo "Reading package lists... Done"
    echo

    echo "  Step 2: Perform a standard upgrade (no removals)."
    read -p "  lab@lpic-lab119:~$ " cmd2
    echo
    if ! is_upgrade_cmd "$cmd2"; then
        print_error "Incorrect. Use: apt-get upgrade   or   apt upgrade"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Reading package lists... Done"
    echo "Building dependency tree"
    echo "Calculating upgrade... Done"
    echo "The following packages will be upgraded:"
    echo "  libc6 libssl3"
    echo "0 upgraded, 0 newly installed, 0 to remove, 2 not upgraded."
    echo

    echo "  Step 3: Perform a full upgrade that may install/remove to satisfy dependencies."
    read -p "  lab@lpic-lab119:~$ " cmd3
    echo
    if ! is_full_upgrade_cmd "$cmd3"; then
        print_error "Incorrect. Use: apt-get dist-upgrade   or   apt full-upgrade"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Reading package lists... Done"
    echo "Building dependency tree"
    echo "Calculating upgrade... Done"
    echo "The following packages will be upgraded:"
    echo "  linux-image-generic linux-headers-generic"
    echo "After this operation, 25.6 MB of additional disk space will be used."
    echo

    echo "  Step 4: Install a package (htop) using apt-get."
    read -p "  lab@lpic-lab119:~$ " cmd4
    echo
    if [[ "$cmd4" != "sudo apt-get install htop" && "$cmd4" != "apt-get install htop" && "$cmd4" != "sudo apt install htop" && "$cmd4" != "apt install htop" ]]; then
        print_error "Incorrect. Use: apt-get install htop   or   apt install htop"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Reading package lists... Done"
    echo "Building dependency tree"
    echo "Reading state information... Done"
    echo "The following NEW packages will be installed:"
    echo "  htop"
    echo "After this operation, 1,024 kB of additional disk space will be used."
    echo "Setting up htop (3.0.5-1) ..."
    echo

    echo "  Step 5: Show details about the installed package via apt show."
    read -p "  lab@lpic-lab119:~$ " cmd5
    echo
    if [[ "$cmd5" != "apt show htop" && "$cmd5" != "apt-cache show htop" ]]; then
        print_error "Incorrect. Use: apt show htop   or   apt-cache show htop"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Package: htop"
    echo "Version: 3.0.5-1"
    echo "Priority: optional"
    echo "Description: interactive processes viewer"
    echo

    echo "  Step 6: Remove the package but keep configuration files."
    read -p "  lab@lpic-lab119:~$ " cmd6
    echo
    if [[ "$cmd6" != "sudo apt-get remove htop" && "$cmd6" != "apt-get remove htop" && "$cmd6" != "sudo apt remove htop" && "$cmd6" != "apt remove htop" ]]; then
        print_error "Incorrect. Use: apt-get remove htop   or   apt remove htop"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Reading package lists... Done"
    echo "Reading state information... Done"
    echo "The following packages will be REMOVED:"
    echo "  htop"
    echo "After this operation, 1,024 kB disk space will be freed."
    echo

    echo "  Step 7: Purge the package including configuration files."
    read -p "  lab@lpic-lab119:~$ " cmd7
    echo
    if [[ "$cmd7" != "sudo apt-get purge htop" && "$cmd7" != "apt-get purge htop" && "$cmd7" != "sudo apt purge htop" && "$cmd7" != "apt purge htop" ]]; then
        print_error "Incorrect. Use: apt-get purge htop   or   apt purge htop"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Reading package lists... Done"
    echo "Removing configuration files for htop (3.0.5-1) ..."
    echo

    echo "  Step 8: Remove automatically installed, now-unused dependencies."
    read -p "  lab@lpic-lab119:~$ " cmd8
    echo
    if [[ "$cmd8" != "sudo apt-get autoremove" && "$cmd8" != "apt-get autoremove" && "$cmd8" != "sudo apt autoremove" && "$cmd8" != "apt autoremove" ]]; then
        print_error "Incorrect. Use: apt-get autoremove   or   apt autoremove"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Reading package lists... Done"
    echo "Reading state information... Done"
    echo "0 to remove, 0 not upgraded."
    echo

    echo "  Step 9: Clean local package cache."
    read -p "  lab@lpic-lab119:~$ " cmd9
    echo
    if [[ "$cmd9" != "sudo apt-get clean" && "$cmd9" != "apt-get clean" && "$cmd9" != "sudo apt clean" && "$cmd9" != "apt clean" ]]; then
        print_error "Incorrect. Use: apt-get clean   or   apt clean"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Cache cleared."
    echo

    echo "  Step 10: Simulate installing nginx without making changes."
    read -p "  lab@lpic-lab119:~$ " cmd10
    echo
    if [[ "$cmd10" != "apt-get -s install nginx" && "$cmd10" != "sudo apt-get -s install nginx" && "$cmd10" != "apt -s install nginx" && "$cmd10" != "sudo apt -s install nginx" && "$cmd10" != "apt --simulate install nginx" && "$cmd10" != "sudo apt --simulate install nginx" ]]; then
        print_error "Incorrect. Examples: apt-get -s install nginx   or   apt -s install nginx"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "NOTE: This is only a simulation!"
    echo "Inst nginx (1.18.0-0ubuntu1) [amd64]"
    echo "Conf nginx (1.18.0-0ubuntu1) [amd64]"
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
