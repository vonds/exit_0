#!/bin/bash

# Lab 173: dnf Package Management

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 173: dnf Package Management"
LAB_ID="lab173"
LAB_XP=20000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

record_lab_completion() {
    tmpfile=$(mktemp)
    jq --arg lab "$LAB_ID" '.[$lab] += 1 // 1' "$LAB_TRACK_FILE" > "$tmpfile" && mv "$tmpfile" "$LAB_TRACK_FILE"
}
get_lab_completion_count() {
    jq -r --arg lab "$LAB_ID" '.[$lab] // 0' "$LAB_TRACK_FILE"
}
draw_lab_ui() {
    clear
    center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
    center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
    echo; echo; echo
}

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Practice common DNF queries, installs, removals, groups, and history."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Show enabled repositories."
    read -p "  lab@lab173:~$ " cmd1
    echo
    if [[ "$cmd1" != "dnf repolist" && "$cmd1" != "dnf repolist --enabled" ]]; then
        print_error "Incorrect. Try again. (Use dnf repolist or dnf repolist --enabled)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  repo id                           repo name                                   status"
    echo "  fedora                            Fedora 40 - x86_64                          71,234"
    echo "  updates                           Fedora 40 - x86_64 - Updates                12,987"
    echo "  repolist: 84,221"
    echo

    echo "  Step 2: Check for available package updates."
    read -p "  lab@lab173:~$ " cmd2
    echo
    if [[ "$cmd2" != "dnf check-update" ]]; then
        print_error "Incorrect. Try again. (Use dnf check-update)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Last metadata expiration check: 0:05:12 ago on Sun Sep 14 12:30:00 2025."
    echo "  kernel.x86_64                 6.10.7-200.fc40                    updates"
    echo "  openssl-libs.x86_64           3.2.2-4.fc40                       updates"
    echo "  vim-enhanced.x86_64           2:9.0.XXXX-1.fc40                  updates"
    echo

    echo "  Step 3: Install the package 'htop'."
    read -p "  lab@lab173:~$ " cmd3
    echo
    if [[ "$cmd3" != "dnf install htop" && "$cmd3" != "dnf install -y htop" ]]; then
        print_error "Incorrect. Try again. (Use dnf install htop)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Last metadata expiration check: 0:06:01 ago on Sun Sep 14 12:30:00 2025."
    echo "  Dependencies resolved."
    echo "  =============================================================================="
    echo "   Package      Arch     Version            Repository                      Size"
    echo "  =============================================================================="
    echo "  Installing:"
    echo "   htop         x86_64   3.3.0-1.fc40      fedora                          120 k"
    echo "  Transaction Summary"
    echo "  =============================================================================="
    echo "  Install  1 Package"
    echo
    echo "  Total download size: 120 k"
    echo "  Installed size: 320 k"
    echo "  Is this ok [y/N]: y"
    echo "  Downloading Packages:"
    echo "  htop-3.3.0-1.fc40.x86_64.rpm                               120 kB/s | 120 kB  00:01"
    echo "  Running transaction check"
    echo "  Running transaction test"
    echo "  Transaction test succeeded."
    echo "  Running transaction"
    echo "    Preparing        :                                                        1/1"
    echo "    Installing       : htop-3.3.0-1.fc40.x86_64                               1/1"
    echo "    Verifying        : htop-3.3.0-1.fc40.x86_64                               1/1"
    echo
    echo "  Installed:"
    echo "    htop-3.3.0-1.fc40.x86_64"
    echo

    echo "  Step 4: Show detailed package info for 'bash'."
    read -p "  lab@lab173:~$ " cmd4
    echo
    if [[ "$cmd4" != "dnf info bash" ]]; then
        print_error "Incorrect. Try again. (Use dnf info bash)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Last metadata expiration check: 0:06:30 ago on Sun Sep 14 12:30:00 2025."
    echo "  Installed Packages"
    echo "  Name         : bash"
    echo "  Version      : 5.2.26"
    echo "  Release      : 1.fc40"
    echo "  Architecture : x86_64"
    echo "  Size         : 4.0 M"
    echo "  Source       : bash-5.2.26-1.fc40.src.rpm"
    echo "  Repository   : @System"
    echo "  From repo    : fedora"
    echo "  Summary      : The GNU Bourne Again shell"
    echo "  License      : GPLv3+"
    echo "  Description  : Bash is the GNU Project's shell—an sh-compatible shell with useful improvements."
    echo

    echo "  Step 5: Search for packages related to 'zsh'."
    read -p "  lab@lab173:~$ " cmd5
    echo
    if [[ "$cmd5" != "dnf search zsh" ]]; then
        print_error "Incorrect. Try again. (Use dnf search zsh)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Last metadata expiration check: 0:07:01 ago on Sun Sep 14 12:30:00 2025."
    echo "  ========================= Name Exactly Matched: zsh ========================="
    echo "  zsh.x86_64 : Powerful shell for interactive use"
    echo "  =============================== Name Matched ================================"
    echo "  zsh-html.noarch : HTML documentation for Zsh"
    echo "  zsh-autosuggestions.noarch : Fish-like autosuggestions for Zsh"
    echo

    echo "  Step 6: List whether 'httpd' is installed."
    read -p "  lab@lab173:~$ " cmd6
    echo
    if [[ "$cmd6" != "dnf list installed httpd" ]]; then
        print_error "Incorrect. Try again. (Use dnf list installed httpd)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Installed Packages"
    echo "  httpd.x86_64                      2.4.59-1.fc40                    @updates"
    echo

    echo "  Step 7: List available packages matching 'openssl*'."
    read -p "  lab@lab173:~$ " cmd7
    echo
    if [[ "$cmd7" != "dnf list available 'openssl*'" && "$cmd7" != "dnf list available openssl*" ]]; then
        print_error "Incorrect. Try again. (Use dnf list available 'openssl*')"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Available Packages"
    echo "  openssl.x86_64                    3.2.2-4.fc40                     updates"
    echo "  openssl-libs.x86_64               3.2.2-4.fc40                     updates"
    echo

    echo "  Step 8: Identify which package provides '/bin/ls'."
    read -p "  lab@lab173:~$ " cmd8
    echo
    if [[ "$cmd8" != "dnf provides /bin/ls" && "$cmd8" != "dnf whatprovides /bin/ls" ]]; then
        print_error "Incorrect. Try again. (Use dnf provides /bin/ls)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Last metadata expiration check: 0:07:45 ago on Sun Sep 14 12:30:00 2025."
    echo "  coreutils-9.4-2.fc40.x86_64 : A set of basic GNU tools including ls"
    echo "  Repo        : fedora"
    echo "  Matched from:"
    echo "  Filename    : /bin/ls"
    echo

    echo "  Step 9: Show runtime dependencies for 'httpd'."
    read -p "  lab@lab173:~$ " cmd9
    echo
    if [[ "$cmd9" != "dnf repoquery --requires httpd" && "$cmd9" != "dnf repoquery --qf '%{name} %{requires}' --requires httpd" ]]; then
        print_error "Incorrect. Try again. (Use dnf repoquery --requires httpd)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  httpd-mmn = 20120211x8664"
    echo "  httpd-filesystem"
    echo "  systemd"
    echo "  libapr-1.so.0()(64bit)"
    echo "  libaprutil-1.so.0()(64bit)"
    echo "  libpcre.so.1()(64bit)"
    echo

    echo "  Step 10: Remove the package 'htop'."
    read -p "  lab@lab173:~$ " cmd10
    echo
    if [[ "$cmd10" != "dnf remove htop" && "$cmd10" != "dnf remove -y htop" ]]; then
        print_error "Incorrect. Try again. (Use dnf remove htop)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Dependencies resolved."
    echo "  =============================================================================="
    echo "   Package  Arch   Version         Repository                               Size"
    echo "  =============================================================================="
    echo "  Removing:"
    echo "   htop     x86_64 3.3.0-1.fc40   @System                                  320 k"
    echo "  Transaction Summary"
    echo "  =============================================================================="
    echo "  Remove  1 Package"
    echo
    echo "  Is this ok [y/N]: y"
    echo "  Running transaction"
    echo "    Preparing        :                                                        1/1"
    echo "    Erasing          : htop-3.3.0-1.fc40.x86_64                               1/1"
    echo "    Verifying        : htop-3.3.0-1.fc40.x86_64                               1/1"
    echo
    echo "  Removed:"
    echo "    htop-3.3.0-1.fc40.x86_64"
    echo

    echo "  Step 11: Show DNF transaction history."
    read -p "  lab@lab173:~$ " cmd11
    echo
    if [[ "$cmd11" != "dnf history" ]]; then
        print_error "Incorrect. Try again. (Use dnf history)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  ID     | Command line        | Date and time         | Action(s)    | Altered"
    echo "  --------------------------------------------------------------------------------"
    echo "     7   | remove htop         | 2025-09-14 12:45      | Removed      |       1"
    echo "     6   | install htop        | 2025-09-14 12:40      | Install      |       1"
    echo "     5   | upgrade             | 2025-09-10 09:02      | Upgrade      |       4"
    echo

    echo "  Step 12: Show details for transaction ID 6."
    read -p "  lab@lab173:~$ " cmd12
    echo
    if [[ "$cmd12" != "dnf history info 6" ]]; then
        print_error "Incorrect. Try again. (Use dnf history info 6)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Transaction ID : 6"
    echo "  Begin time     : Sun Sep 14 12:40:05 2025"
    echo "  Command line   : install htop"
    echo "  Packages Altered: 1"
    echo "      Install htop-3.3.0-1.fc40.x86_64 @fedora"
    echo "  Return-Code    : Success"
    echo

    echo "  Step 13: Clean all cached metadata and packages."
    read -p "  lab@lab173:~$ " cmd13
    echo
    if [[ "$cmd13" != "dnf clean all" ]]; then
        print_error "Incorrect. Try again. (Use dnf clean all)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  0 files removed"
    echo "  Cache cleared."
    echo

    echo "  Step 14: List package groups."
    read -p "  lab@lab173:~$ " cmd14
    echo
    if [[ "$cmd14" != "dnf group list" ]]; then
        print_error "Incorrect. Try again. (Use dnf group list)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Available Environment Groups:"
    echo "     Minimal Install"
    echo "     Workstation"
    echo "  Installed Groups:"
    echo "     Base"
    echo "  Available Groups:"
    echo "     Development Tools"
    echo "     Administration Tools"
    echo

    echo "  Step 15: Show info for the 'Development Tools' group."
    read -p "  lab@lab173:~$ " cmd15
    echo
    if [[ "$cmd15" != "dnf group info 'Development Tools'" && "$cmd15" != 'dnf group info "Development Tools"' && "$cmd15" != "dnf groupinfo 'Development Tools'" && "$cmd15" != 'dnf groupinfo "Development Tools"' ]]; then
        print_error "Incorrect. Try again. (Use dnf group info 'Development Tools')"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Group: Development Tools"
    echo "   Description: A basic development environment."
    echo "   Mandatory Packages:"
    echo "     = gcc"
    echo "     = make"
    echo "     = automake"
    echo "     = autoconf"
    echo "     = kernel-headers"
    echo

    print_success "Nice work!"
    print_info "You earned $LAB_XP XP for completing this lab."
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON"); export XP; export LEVEL
    record_lab_completion

    completion_count=$(get_lab_completion_count)
    echo
    print_info "You've successfully completed this lab $completion_count time(s)."
    echo
    center_text "Would you like to:"
    center_text "1) Retry this lab"
    center_text "2) Return to Sysadmin Lab Menu"
    echo
    read -p "  > " post_choice
    [[ "$post_choice" == "2" ]] && exit 0
done
