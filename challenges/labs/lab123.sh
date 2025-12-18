#!/bin/bash

# Lab 123: YUM & DNF Basics (search, info, install, remove, update, history)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 123: YUM & DNF Basics"
LAB_ID="lab123"
LAB_XP=3250
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

# Helper matchers (accept yum or dnf variants)
is_makecache() {
  [[ "$1" == "sudo yum makecache" || "$1" == "yum makecache" || "$1" == "sudo dnf makecache" || "$1" == "dnf makecache" ]]
}
is_search_htop() {
  [[ "$1" == "yum search htop" || "$1" == "dnf search htop" || "$1" == "sudo yum search htop" || "$1" == "sudo dnf search htop" ]]
}
is_info_htop() {
  [[ "$1" == "yum info htop" || "$1" == "dnf info htop" || "$1" == "sudo yum info htop" || "$1" == "sudo dnf info htop" ]]
}
is_install_htop() {
  [[ "$1" == "yum install htop" || "$1" == "dnf install htop" || "$1" == "sudo yum install htop" || "$1" == "sudo dnf install htop" || \
     "$1" == "yum install -y htop" || "$1" == "dnf install -y htop" || "$1" == "sudo yum install -y htop" || "$1" == "sudo dnf install -y htop" ]]
}
is_list_installed_htop() {
  [[ "$1" == "yum list installed htop" || "$1" == "dnf list installed htop" || "$1" == "sudo yum list installed htop" || "$1" == "sudo dnf list installed htop" ]]
}
is_remove_htop() {
  [[ "$1" == "yum remove htop" || "$1" == "dnf remove htop" || "$1" == "sudo yum remove htop" || "$1" == "sudo dnf remove htop" || \
     "$1" == "yum erase htop" || "$1" == "dnf erase htop" || "$1" == "sudo yum erase htop" || "$1" == "sudo dnf erase htop" ]]
}
is_check_update() {
  [[ "$1" == "yum check-update" || "$1" == "dnf check-update" || "$1" == "sudo yum check-update" || "$1" == "sudo dnf check-update" ]]
}
is_upgrade_system() {
  [[ "$1" == "yum update" || "$1" == "sudo yum update" || "$1" == "yum upgrade" || "$1" == "sudo yum upgrade" || \
     "$1" == "dnf upgrade" || "$1" == "sudo dnf upgrade" || "$1" == "dnf update" || "$1" == "sudo dnf update" ]]
}
is_clean_all() {
  [[ "$1" == "yum clean all" || "$1" == "sudo yum clean all" || "$1" == "dnf clean all" || "$1" == "sudo dnf clean all" ]]
}
is_history_undo_last() {
  [[ "$1" == "yum history undo last" || "$1" == "sudo yum history undo last" || "$1" == "dnf history undo last" || "$1" == "sudo dnf history undo last" ]]
}

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Scenario: Manage software on an RPM-based system using YUM/DNF."
    center_text "Update metadata, search/info, install, verify, remove, check updates, upgrade, clean, and undo."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Build or refresh local repo metadata cache."
    read -p "  lab@lpic-lab123:~$ " cmd1
    echo
    if ! is_makecache "$cmd1"; then
        print_error "Incorrect. Use: yum makecache   or   dnf makecache"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Metadata cache created."
    echo

    echo "  Step 2: Search repositories for the 'htop' package."
    read -p "  lab@lpic-lab123:~$ " cmd2
    echo
    if ! is_search_htop "$cmd2"; then
        print_error "Incorrect. Use: yum search htop   or   dnf search htop"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "============================== Name Matched: htop =============================="
    echo "htop.x86_64 : Interactive process viewer"
    echo

    echo "  Step 3: Show package information for 'htop'."
    read -p "  lab@lpic-lab123:~$ " cmd3
    echo
    if ! is_info_htop "$cmd3"; then
        print_error "Incorrect. Use: yum info htop   or   dnf info htop"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Name         : htop"
    echo "Version      : 3.3.0"
    echo "Release      : 1.el9"
    echo "Architecture : x86_64"
    echo "Summary      : Interactive process viewer"
    echo "From repo    : appstream"
    echo

    echo "  Step 4: Install the 'htop' package."
    read -p "  lab@lpic-lab123:~$ " cmd4
    echo
    if ! is_install_htop "$cmd4"; then
        print_error "Incorrect. Use: yum install htop   or   dnf install htop"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Dependencies resolved."
    echo "Installed: htop-3.3.0-1.el9.x86_64"
    echo

    echo "  Step 5: Verify that 'htop' is installed."
    read -p "  lab@lpic-lab123:~$ " cmd5
    echo
    if ! is_list_installed_htop "$cmd5"; then
        print_error "Incorrect. Use: yum list installed htop   or   dnf list installed htop"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Installed Packages"
    echo "htop.x86_64  3.3.0-1.el9    @appstream"
    echo

    echo "  Step 6: Remove the 'htop' package."
    read -p "  lab@lpic-lab123:~$ " cmd6
    echo
    if ! is_remove_htop "$cmd6"; then
        print_error "Incorrect. Use: yum remove htop   or   dnf remove htop"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Removed: htop-3.3.0-1.el9.x86_64"
    echo

    echo "  Step 7: Check for available updates."
    read -p "  lab@lpic-lab123:~$ " cmd7
    echo
    if ! is_check_update "$cmd7"; then
        print_error "Incorrect. Use: yum check-update   or   dnf check-update"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Loaded plugins: fastestmirror"
    echo "openssl.x86_64        1:3.0.7-24.el9_2     appstream"
    echo "kernel.x86_64         6.6.0-100.el9        baseos"
    echo

    echo "  Step 8: Upgrade the system packages."
    read -p "  lab@lpic-lab123:~$ " cmd8
    echo
    if ! is_upgrade_system "$cmd8"; then
        print_error "Incorrect. Use: yum update|upgrade   or   dnf update|upgrade"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Upgrades complete."
    echo

    echo "  Step 9: Clean cached metadata and packages."
    read -p "  lab@lpic-lab123:~$ " cmd9
    echo
    if ! is_clean_all "$cmd9"; then
        print_error "Incorrect. Use: yum clean all   or   dnf clean all"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Cache and metadata removed."
    echo

    echo "  Step 10: Undo the last transaction using history."
    read -p "  lab@lpic-lab123:~$ " cmd10
    echo
    if ! is_history_undo_last "$cmd10"; then
        print_error "Incorrect. Use: yum history undo last   or   dnf history undo last"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Undoing last transaction..."
    echo "Complete."
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
