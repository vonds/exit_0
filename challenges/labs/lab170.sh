#!/bin/bash

# Lab 170: APT & dpkg Open-Ended Commands

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 170: APT & dpkg Open-Ended Commands"
LAB_ID="lab170"
LAB_XP=42000
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
    center_text "Practice core APT and dpkg commands (one-line, open-ended inputs)."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Update the local APT package index from configured repositories."
    read -p "  lab@lab170:~$ " cmd1
    echo
    if [[ "$cmd1" != "apt-get update" && "$cmd1" != "apt update" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Hit:1 http://deb.debian.org/debian bookworm InRelease"
    echo "  Get:2 http://security.debian.org/debian-security bookworm-security InRelease [48.0 kB]"
    echo "  Fetched 48.0 kB in 1s (52.3 kB/s)"
    echo "  Reading package lists... Done"
    echo

    echo "  Step 2: Install the package 'htop' from repositories (dependency-resolving)."
    read -p "  lab@lab170:~$ " cmd2
    echo
    if [[ "$cmd2" != "apt-get install htop" && "$cmd2" != "apt install htop" && "$cmd2" != "apt-get install -y htop" && "$cmd2" != "apt install -y htop" ]]; then
        print_error "Incorrect. Try again. (Use apt-get install htop or apt install htop)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Reading package lists... Done"
    echo "  Building dependency tree... Done"
    echo "  Reading state information... Done"
    echo "  The following NEW packages will be installed:"
    echo "    htop"
    echo "  0 upgraded, 1 newly installed, 0 to remove and 0 not upgraded."
    echo "  Need to get 100 kB of archives."
    echo "  After this operation, 300 kB of additional disk space will be used."
    echo "  Do you want to continue? [Y/n] y"
    echo "  Get:1 http://deb.debian.org/debian bookworm/main amd64 htop amd64 3.2.2-1 [100 kB]"
    echo "  Fetched 100 kB in 0s (420 kB/s)"
    echo "  Selecting previously unselected package htop."
    echo "  (Reading database ... 120000 files and directories currently installed.)"
    echo "  Preparing to unpack .../archives/htop_3.2.2-1_amd64.deb ..."
    echo "  Unpacking htop (3.2.2-1) ..."
    echo "  Setting up htop (3.2.2-1) ..."
    echo "  Processing triggers for man-db (2.11.2-2) ..."
    echo

    echo "  Step 3: Remove the package 'htop' using APT."
    read -p "  lab@lab170:~$ " cmd3
    echo
    if [[ "$cmd3" != "apt-get remove htop" && "$cmd3" != "apt remove htop" && "$cmd3" != "apt-get remove -y htop" && "$cmd3" != "apt remove -y htop" ]]; then
        print_error "Incorrect. Try again. (Use apt-get remove htop or apt remove htop)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Reading package lists... Done"
    echo "  Building dependency tree... Done"
    echo "  Reading state information... Done"
    echo "  The following packages will be REMOVED:"
    echo "    htop"
    echo "  0 upgraded, 0 newly installed, 1 to remove and 0 not upgraded."
    echo "  After this operation, 300 kB disk space will be freed."
    echo "  Do you want to continue? [Y/n] y"
    echo "  (Reading database ... 120050 files and directories currently installed.)"
    echo "  Removing htop (3.2.2-1) ..."
    echo "  Processing triggers for man-db (2.11.2-2) ..."
    echo

    echo "  Step 4: Show metadata/details for the package 'htop' using APT."
    read -p "  lab@lab170:~$ " cmd4
    echo
    if [[ "$cmd4" != "apt-cache show htop" && "$cmd4" != "apt show htop" ]]; then
        print_error "Incorrect. Try again. (Use apt-cache show htop or apt show htop)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Package: htop"
    echo "  Version: 3.2.2-1"
    echo "  Architecture: amd64"
    echo "  Maintainer: Debian QA Group <packages@qa.debian.org>"
    echo "  Depends: libc6 (>= 2.34), libncursesw6 (>= 6), libtinfo6 (>= 6)"
    echo "  Description: interactive processes viewer"
    echo "   htop is an ncurses-based process viewer for Linux. It aims to be a better 'top'."
    echo

    echo "  Step 5: Search the APT cache for packages related to 'zsh'."
    read -p "  lab@lab170:~$ " cmd5
    echo
    if [[ "$cmd5" != "apt-cache search zsh" && "$cmd5" != "apt search zsh" ]]; then
        print_error "Incorrect. Try again. (Use apt-cache search zsh or apt search zsh)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  zsh - shell with lots of features"
    echo "  zsh-common - architecture independent files for Zsh"
    echo "  zsh-doc - Zsh documentation"
    echo "  zsh-autosuggestions - Fish-like autosuggestions for Zsh"
    echo

    echo "  Step 6: Update the apt-file contents index (for file→package lookups)."
    read -p "  lab@lab170:~$ " cmd6
    echo
    if [[ "$cmd6" != "apt-file update" ]]; then
        print_error "Incorrect. Try again. (Use apt-file update)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Updating apt-file cache..."
    echo "  Downloading indexes: done."
    echo

    echo "  Step 7: Find which package provides the path '/bin/ls' using apt-file."
    read -p "  lab@lab170:~$ " cmd7
    echo
    if [[ "$cmd7" != "apt-file search /bin/ls" ]]; then
        print_error "Incorrect. Try again. (Use apt-file search /bin/ls)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  coreutils: /bin/ls"
    echo

    echo "  Step 8: List the contents of the package 'bash' (works even if not installed)."
    read -p "  lab@lab170:~$ " cmd8
    echo
    if [[ "$cmd8" != "apt-file list bash" ]]; then
        print_error "Incorrect. Try again. (Use apt-file list bash)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  bash: /bin/bash"
    echo "  bash: /etc/skel/.bashrc"
    echo "  bash: /usr/share/doc/bash/changelog.Debian.gz"
    echo "  bash: /usr/share/man/man1/bash.1.gz"
    echo

    echo "  Step 9: Install a local Debian package at '/tmp/sample.deb' with the low-level tool."
    read -p "  lab@lab170:~$ " cmd9
    echo
    if [[ "$cmd9" != "dpkg -i /tmp/sample.deb" ]]; then
        print_error "Incorrect. Try again. (Use dpkg -i /tmp/sample.deb)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  (Reading database ... 120100 files and directories currently installed.)"
    echo "  Preparing to unpack /tmp/sample.deb ..."
    echo "  Unpacking sample (1.0-1) over (none) ..."
    echo "  Setting up sample (1.0-1) ..."
    echo "  Processing triggers for man-db (2.11.2-2) ..."
    echo

    echo "  Step 10: Remove the package 'htop' with the low-level tool."
    read -p "  lab@lab170:~$ " cmd10
    echo
    if [[ "$cmd10" != "dpkg -r htop" ]]; then
        print_error "Incorrect. Try again. (Use dpkg -r htop)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  (Reading database ... 120120 files and directories currently installed.)"
    echo "  Removing htop (3.2.2-1) ..."
    echo "  Processing triggers for man-db (2.11.2-2) ..."
    echo

    echo "  Step 11: Inspect the local archive '/tmp/sample.deb' to view metadata and dependencies."
    read -p "  lab@lab170:~$ " cmd11
    echo
    if [[ "$cmd11" != "dpkg -I /tmp/sample.deb" ]]; then
        print_error "Incorrect. Try again. (Use dpkg -I /tmp/sample.deb)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "   new Debian package, version 2.0."
    echo "   size 12345 bytes: control archive=tar.xz."
    echo "  Package: sample"
    echo "  Version: 1.0-1"
    echo "  Architecture: amd64"
    echo "  Depends: libc6 (>= 2.34)"
    echo "  Maintainer: Example Maintainer <maint@example.com>"
    echo "  Description: Sample package for lab"
    echo "   A simple package used for demonstration and testing in Lab 170."
    echo

    echo "  Step 12: List all packages and their selection states on this system with the low-level tool."
    read -p "  lab@lab170:~$ " cmd12
    echo
    if [[ "$cmd12" != "dpkg --get-selections" ]]; then
        print_error "Incorrect. Try again. (Use dpkg --get-selections)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  adduser                                   install"
    echo "  apt                                       install"
    echo "  bash                                      install"
    echo "  coreutils                                 install"
    echo "  htop                                      deinstall"
    echo

    echo "  Step 13: List every file installed by the package 'bash' (installed package → files)."
    read -p "  lab@lab170:~$ " cmd13
    echo
    if [[ "$cmd13" != "dpkg -L bash" ]]; then
        print_error "Incorrect. Try again. (Use dpkg -L bash)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  /."
    echo "  /bin"
    echo "  /bin/bash"
    echo "  /etc/skel/.bashrc"
    echo "  /usr/share/doc/bash/changelog.Debian.gz"
    echo "  /usr/share/man/man1/bash.1.gz"
    echo

    echo "  Step 14: Given the path '/bin/ls', show which installed package owns that file."
    read -p "  lab@lab170:~$ " cmd14
    echo
    if [[ "$cmd14" != "dpkg -S /bin/ls" && "$cmd14" != "dpkg-query -S /bin/ls" ]]; then
        print_error "Incorrect. Try again. (Use dpkg -S /bin/ls or dpkg-query -S /bin/ls)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  coreutils: /bin/ls"
    echo

    echo "  Step 15: Re-run configuration for the package 'tzdata'."
    read -p "  lab@lab170:~$ " cmd15
    echo
    if [[ "$cmd15" != "dpkg-reconfigure tzdata" ]]; then
        print_error "Incorrect. Try again. (Use dpkg-reconfigure tzdata)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Current default time zone: 'Etc/UTC'"
    echo "  Local time is now:      Sun Sep 14 12:34:56 UTC 2025."
    echo "  Universal Time is now:  Sun Sep 14 12:34:56 UTC 2025."
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
