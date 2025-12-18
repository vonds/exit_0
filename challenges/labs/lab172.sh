#!/bin/bash

# Lab 172: yum Package Management

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 172: yum Package Management"
LAB_ID="lab172"
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
    center_text "Practice common yum queries, installs, removals, groups, and history."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Show enabled repositories."
    read -p "  lab@lab172:~$ " cmd1
    echo
    if [[ "$cmd1" != "yum repolist" && "$cmd1" != "yum repolist enabled" ]]; then
        print_error "Incorrect. Try again. (Use yum repolist or yum repolist enabled)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Loaded plugins: fastestmirror"
    echo "  Repo id              Repo name                         Status"
    echo "  base/7/x86_64        CentOS-7 - Base                   10,072"
    echo "  updates/7/x86_64     CentOS-7 - Updates                 1,234"
    echo "  extras/7/x86_64      CentOS-7 - Extras                    512"
    echo "  repolist: 11,818"
    echo

    echo "  Step 2: Check for available package updates."
    read -p "  lab@lab172:~$ " cmd2
    echo
    if [[ "$cmd2" != "yum check-update" ]]; then
        print_error "Incorrect. Try again. (Use yum check-update)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Loaded plugins: fastestmirror"
    echo "  Determining fastest mirrors"
    echo "  kernel.x86_64                3.10.0-1160.123.1.el7          updates"
    echo "  openssl-libs.x86_64          1:1.0.2k-26.el7_9              updates"
    echo "  vim-enhanced.x86_64          2:7.4.629-8.el7_9              base"
    echo "  (3 packages available)"
    echo

    echo "  Step 3: Install the package 'htop' (assume repo contains it)."
    read -p "  lab@lab172:~$ " cmd3
    echo
    if [[ "$cmd3" != "yum install htop" && "$cmd3" != "yum install -y htop" ]]; then
        print_error "Incorrect. Try again. (Use yum install htop)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Loaded plugins: fastestmirror"
    echo "  Resolving Dependencies"
    echo "  --> Running transaction check"
    echo "  ---> Package htop.x86_64 0:2.2.0-3.el7 will be installed"
    echo "  --> Finished Dependency Resolution"
    echo
    echo "  Dependencies Resolved"
    echo
    echo "  =============================================================================="
    echo "   Package         Arch     Version           Repository                  Size"
    echo "  =============================================================================="
    echo "  Installing:"
    echo "   htop            x86_64   2.2.0-3.el7       base                       105 k"
    echo "  =============================================================================="
    echo "  Total download size: 105 k"
    echo "  Installed size: 300 k"
    echo "  Is this ok [y/d/N]: y"
    echo "  Downloading packages:"
    echo "  htop-2.2.0-3.el7.x86_64.rpm                                   | 105 kB  00:00"
    echo "  Running transaction check"
    echo "  Running transaction test"
    echo "  Transaction test succeeded"
    echo "  Running transaction"
    echo "    Installing : htop-2.2.0-3.el7.x86_64                                        1/1"
    echo "    Verifying  : htop-2.2.0-3.el7.x86_64                                        1/1"
    echo
    echo "  Installed:"
    echo "    htop.x86_64 0:2.2.0-3.el7"
    echo

    echo "  Step 4: Show detailed package info for 'bash'."
    read -p "  lab@lab172:~$ " cmd4
    echo
    if [[ "$cmd4" != "yum info bash" ]]; then
        print_error "Incorrect. Try again. (Use yum info bash)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Loaded plugins: fastestmirror"
    echo "  Available Packages"
    echo "  Name        : bash"
    echo "  Arch        : x86_64"
    echo "  Version     : 4.2.46"
    echo "  Release     : 34.el7"
    echo "  Size        : 1.0 M"
    echo "  Repo        : base/7/x86_64"
    echo "  Summary     : The GNU Bourne Again shell"
    echo "  Description : Bash is the GNU Project's shell."
    echo

    echo "  Step 5: Search for packages related to 'zsh'."
    read -p "  lab@lab172:~$ " cmd5
    echo
    if [[ "$cmd5" != "yum search zsh" ]]; then
        print_error "Incorrect. Try again. (Use yum search zsh)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Loaded plugins: fastestmirror"
    echo "  ============================= N/S matched: zsh ============================="
    echo "  zsh.x86_64 : Powerful shell for interactive use"
    echo "  zsh-html.noarch : HTML documentation for Zsh"
    echo

    echo "  Step 6: List whether 'httpd' is installed."
    read -p "  lab@lab172:~$ " cmd6
    echo
    if [[ "$cmd6" != "yum list installed httpd" ]]; then
        print_error "Incorrect. Try again. (Use yum list installed httpd)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Installed Packages"
    echo "  httpd.x86_64            2.4.6-99.el7.centos            @base"
    echo

    echo "  Step 7: List available packages matching 'openssl*'."
    read -p "  lab@lab172:~$ " cmd7
    echo
    if [[ "$cmd7" != "yum list available 'openssl*'" && "$cmd7" != "yum list available openssl*" ]]; then
        print_error "Incorrect. Try again. (Use yum list available 'openssl*')"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Available Packages"
    echo "  openssl.x86_64          1:1.0.2k-26.el7_9              updates"
    echo "  openssl-libs.x86_64     1:1.0.2k-26.el7_9              updates"
    echo

    echo "  Step 8: Identify which package provides '/bin/ls'."
    read -p "  lab@lab172:~$ " cmd8
    echo
    if [[ "$cmd8" != "yum provides /bin/ls" && "$cmd8" != "yum whatprovides /bin/ls" ]]; then
        print_error "Incorrect. Try again. (Use yum provides /bin/ls)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Loaded plugins: fastestmirror"
    echo "  coreutils-8.22-24.el7.x86_64 : A set of basic GNU tools including ls"
    echo "  Repo        : base"
    echo "  Matched from:"
    echo "  Filename    : /bin/ls"
    echo

    echo "  Step 9: Show dependencies for 'httpd'."
    read -p "  lab@lab172:~$ " cmd9
    echo
    if [[ "$cmd9" != "yum deplist httpd" ]]; then
        print_error "Incorrect. Try again. (Use yum deplist httpd)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Loaded plugins: fastestmirror"
    echo "  package: httpd.x86_64 2.4.6-99.el7.centos"
    echo "    dependency: libapr-1.so.0()(64bit)"
    echo "     provider: apr.x86_64 1.4.8-5.el7"
    echo "    dependency: libaprutil-1.so.0()(64bit)"
    echo "     provider: apr-util.x86_64 1.5.2-6.el7"
    echo "    dependency: libpcre.so.1()(64bit)"
    echo "     provider: pcre.x86_64 8.32-17.el7"
    echo

    echo "  Step 10: Remove the package 'htop'."
    read -p "  lab@lab172:~$ " cmd10
    echo
    if [[ "$cmd10" != "yum remove htop" && "$cmd10" != "yum remove -y htop" ]]; then
        print_error "Incorrect. Try again. (Use yum remove htop)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Loaded plugins: fastestmirror"
    echo "  Resolving Dependencies"
    echo "  --> Running transaction check"
    echo "  ---> Package htop.x86_64 0:2.2.0-3.el7 will be erased"
    echo "  --> Finished Dependency Resolution"
    echo
    echo "  Dependencies Resolved"
    echo
    echo "  =============================================================================="
    echo "   Package      Arch     Version         Repository                     Size"
    echo "  =============================================================================="
    echo "  Removing:"
    echo "   htop         x86_64   2.2.0-3.el7     @base                         300 k"
    echo "  =============================================================================="
    echo "  Is this ok [y/N]: y"
    echo "  Running transaction"
    echo "    Erasing    : htop-2.2.0-3.el7.x86_64                                        1/1"
    echo "    Verifying  : htop-2.2.0-3.el7.x86_64                                        1/1"
    echo
    echo "  Removed:"
    echo "    htop.x86_64 0:2.2.0-3.el7"
    echo

    echo "  Step 11: Show yum transaction history."
    read -p "  lab@lab172:~$ " cmd11
    echo
    if [[ "$cmd11" != "yum history" ]]; then
        print_error "Incorrect. Try again. (Use yum history)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Loaded plugins: fastestmirror"
    echo "      ID | Command line             | Date and time    | Action(s)      | Altered"
    echo "  --------------------------------------------------------------------------------"
    echo "       5 | remove htop              | 2025-09-14 13:15 | Erase          |     1  "
    echo "       4 | install htop             | 2025-09-14 13:10 | Install        |     1  "
    echo "       3 | update                   | 2025-09-10 09:02 | Update         |     4  "
    echo

    echo "  Step 12: Show details for transaction ID 4."
    read -p "  lab@lab172:~$ " cmd12
    echo
    if [[ "$cmd12" != "yum history info 4" ]]; then
        print_error "Incorrect. Try again. (Use yum history info 4)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Loaded plugins: fastestmirror"
    echo "  Transaction ID : 4"
    echo "  Begin time     : Sun Sep 14 13:10:05 2025"
    echo "  Command line   : install htop"
    echo "  Packages Altered: 1"
    echo "      Install htop-2.2.0-3.el7.x86_64 @base"
    echo "  Return-Code    : Success"
    echo

    echo "  Step 13: Clean all cached metadata and packages."
    read -p "  lab@lab172:~$ " cmd13
    echo
    if [[ "$cmd13" != "yum clean all" ]]; then
        print_error "Incorrect. Try again. (Use yum clean all)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Loaded plugins: fastestmirror"
    echo "  Cleaning repos: base extras updates"
    echo "  Cleaning up everything"
    echo "  Cleaning up list of fastest mirrors"
    echo

    echo "  Step 14: List package groups."
    read -p "  lab@lab172:~$ " cmd14
    echo
    if [[ "$cmd14" != "yum group list" ]]; then
        print_error "Incorrect. Try again. (Use yum group list)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Loaded plugins: fastestmirror"
    echo "  Available environment groups:"
    echo "     Minimal Install"
    echo "     Server with GUI"
    echo "  Installed groups:"
    echo "     Base"
    echo "  Available groups:"
    echo "     Development Tools"
    echo "     System Administration Tools"
    echo

    echo "  Step 15: Show info for the 'Development Tools' group."
    read -p "  lab@lab172:~$ " cmd15
    echo
    if [[ "$cmd15" != "yum group info 'Development Tools'" && "$cmd15" != "yum groupinfo 'Development Tools'" && "$cmd15" != 'yum group info "Development Tools"' && "$cmd15" != 'yum groupinfo "Development Tools"' ]]; then
        print_error "Incorrect. Try again. (Use yum group info 'Development Tools')"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Loaded plugins: fastestmirror"
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
