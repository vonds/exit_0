#!/bin/bash

# Lab 124: Zypper Basics (refresh, repos, search, info, install, remove)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 124: Zypper Basics"
LAB_ID="lab124"
LAB_XP=3150
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

# Helpers for accepting common aliases
is_zref() { [[ "$1" == "zypper refresh" || "$1" == "sudo zypper refresh" || "$1" == "zypper ref" || "$1" == "sudo zypper ref" ]]; }
is_zsearch_htop() { [[ "$1" == "zypper search htop" || "$1" == "sudo zypper search htop" || "$1" == "zypper se htop" || "$1" == "sudo zypper se htop" ]]; }
is_zinfo_htop() { [[ "$1" == "zypper info htop" || "$1" == "sudo zypper info htop" ]]; }
is_zinstall_htop() { [[ "$1" == "zypper install htop" || "$1" == "sudo zypper install htop" || "$1" == "zypper in htop" || "$1" == "sudo zypper in htop" ]]; }
is_zinstalled_htop() { [[ "$1" == "zypper search -i htop" || "$1" == "sudo zypper search -i htop" || "$1" == "zypper se -i htop" || "$1" == "sudo zypper se -i htop" ]]; }
is_zremove_htop() { [[ "$1" == "zypper remove htop" || "$1" == "sudo zypper remove htop" || "$1" == "zypper rm htop" || "$1" == "sudo zypper rm htop" ]]; }

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Scenario: You are on an openSUSE/SLE system. Manage software and repositories with zypper."
    center_text "Tasks: refresh metadata, inspect repos, add a repo, search/info/install/remove a package, and disable a repo."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Refresh repository metadata."
    read -p "  lab@lpic-lab124:~$ " cmd1
    echo
    if ! is_zref "$cmd1"; then
        print_error "Incorrect. Use: zypper refresh   (alias: zypper ref)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Repository 'main' is up to date."
    echo "All repositories have been refreshed."
    echo

    echo "  Step 2: List repository definition files."
    read -p "  lab@lpic-lab124:~$ " cmd2
    echo
    if [[ "$cmd2" != "ls -1 /etc/zypp/repos.d" ]]; then
        print_error "Incorrect. Use: ls -1 /etc/zypp/repos.d"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "repo-oss.repo"
    echo "repo-non-oss.repo"
    echo "repo-update.repo"
    echo

    echo "  Step 3: Add a new repository named 'custom-utils'."
    echo "          URL: http://example.com/opensuse/repo/oss/"
    read -p "  lab@lpic-lab124:~$ " cmd3
    echo
    if [[ "$cmd3" != "sudo zypper ar http://example.com/opensuse/repo/oss/ custom-utils" ]]; then
        print_error "Incorrect. Use: sudo zypper ar http://example.com/opensuse/repo/oss/ custom-utils"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Adding repository 'custom-utils' ......................................................................[done]"
    echo "Repository 'custom-utils' successfully added."
    echo

    echo "  Step 4: Refresh repositories to load metadata from the new repo."
    read -p "  lab@lpic-lab124:~$ " cmd4
    echo
    if ! is_zref "$cmd4"; then
        print_error "Incorrect. Use: zypper refresh"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Retrieving repository 'custom-utils' metadata ...........................................................[done]"
    echo "All repositories have been refreshed."
    echo

    echo "  Step 5: Search for the 'htop' package."
    read -p "  lab@lpic-lab124:~$ " cmd5
    echo
    if ! is_zsearch_htop "$cmd5"; then
        print_error "Incorrect. Use: zypper search htop   (alias: zypper se htop)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "S  | Name | Summary"
    echo "---+------+------------------------------------------------"
    echo "   | htop | Interactive process viewer"
    echo

    echo "  Step 6: Show detailed information about 'htop'."
    read -p "  lab@lpic-lab124:~$ " cmd6
    echo
    if ! is_zinfo_htop "$cmd6"; then
        print_error "Incorrect. Use: zypper info htop"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Information for package htop:"
    echo "Repository : custom-utils"
    echo "Name       : htop"
    echo "Version    : 3.3.0-1"
    echo "Arch       : x86_64"
    echo "Summary    : Interactive process viewer"
    echo

    echo "  Step 7: Install the 'htop' package."
    read -p "  lab@lpic-lab124:~$ " cmd7
    echo
    if ! is_zinstall_htop "$cmd7"; then
        print_error "Incorrect. Use: zypper install htop   (alias: zypper in htop)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Loading repository data..."
    echo "Reading installed packages..."
    echo "Resolving package dependencies..."
    echo "Installing: htop-3.3.0-1.x86_64 .................................................[done]"
    echo

    echo "  Step 8: Verify that 'htop' is installed."
    read -p "  lab@lpic-lab124:~$ " cmd8
    echo
    if ! is_zinstalled_htop "$cmd8"; then
        print_error "Incorrect. Use: zypper search -i htop   (alias: zypper se -i htop)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "S  | Name | Summary"
    echo "---+------+----------------------------------------------"
    echo "i+ | htop | Interactive process viewer"
    echo

    echo "  Step 9: Remove the 'htop' package."
    read -p "  lab@lpic-lab124:~$ " cmd9
    echo
    if ! is_zremove_htop "$cmd9"; then
        print_error "Incorrect. Use: zypper remove htop   (alias: zypper rm htop)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Resolving package dependencies..."
    echo "Removing: htop-3.3.0-1.x86_64 ...................................................[done]"
    echo

    echo "  Step 10: Disable the 'custom-utils' repository."
    read -p "  lab@lpic-lab124:~$ " cmd10
    echo
    if [[ "$cmd10" != "sudo zypper mr -d custom-utils" ]]; then
        print_error "Incorrect. Use: sudo zypper mr -d custom-utils"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Repository 'custom-utils' has been disabled."
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
