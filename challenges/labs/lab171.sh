#!/bin/bash

# Lab 171: rpm Package Management

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 171: rpm Package Management"
LAB_ID="lab171"
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
    center_text "Practice core RPM queries, verification, and package lifecycle."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Query if 'bash' is installed (show the NEVRA)."
    read -p "  lab@lab171:~$ " cmd1
    echo
    if [[ "$cmd1" != "rpm -q bash" ]]; then
        print_error "Incorrect. Try again. (Use rpm -q bash)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  bash-5.2.26-1.fc40.x86_64"
    echo

    echo "  Step 2: Show detailed package info for 'bash'."
    read -p "  lab@lab171:~$ " cmd2
    echo
    if [[ "$cmd2" != "rpm -qi bash" ]]; then
        print_error "Incorrect. Try again. (Use rpm -qi bash)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Name        : bash"
    echo "  Version     : 5.2.26"
    echo "  Release     : 1.fc40"
    echo "  Architecture: x86_64"
    echo "  Install Date: Sun 14 Sep 2025 12:10:42 PM UTC"
    echo "  Group       : System Environment/Shells"
    echo "  Size        : 4021345"
    echo "  License     : GPLv3+"
    echo "  Source RPM  : bash-5.2.26-1.fc40.src.rpm"
    echo "  URL         : https://www.gnu.org/software/bash/"
    echo "  Summary     : The GNU Bourne Again shell"
    echo "  Description : Bash is the GNU Project's shell—an sh-compatible shell with useful"
    echo "                improvements."
    echo

    echo "  Step 3: List files installed by 'bash'."
    read -p "  lab@lab171:~$ " cmd3
    echo
    if [[ "$cmd3" != "rpm -ql bash" ]]; then
        print_error "Incorrect. Try again. (Use rpm -ql bash)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  /bin/bash"
    echo "  /etc/skel/.bash_profile"
    echo "  /etc/skel/.bashrc"
    echo "  /usr/share/doc/bash/README"
    echo "  /usr/share/man/man1/bash.1.gz"
    echo

    echo "  Step 4: Identify which package owns '/bin/ls'."
    read -p "  lab@lab171:~$ " cmd4
    echo
    if [[ "$cmd4" != "rpm -qf /bin/ls" ]]; then
        print_error "Incorrect. Try again. (Use rpm -qf /bin/ls)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  coreutils-9.4-2.fc40.x86_64"
    echo

    echo "  Step 5: Find which package provides 'libssl.so.3'."
    read -p "  lab@lab171:~$ " cmd5
    echo
    if [[ "$cmd5" != "rpm -q --whatprovides libssl.so.3" ]]; then
        print_error "Incorrect. Try again. (Use rpm -q --whatprovides libssl.so.3)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  openssl-libs-3.2.2-1.fc40.x86_64"
    echo

    echo "  Step 6: Verify 'bash' package files against the RPM database."
    read -p "  lab@lab171:~$ " cmd6
    echo
    if [[ "$cmd6" != "rpm -V bash" ]]; then
        print_error "Incorrect. Try again. (Use rpm -V bash)"
        read -p "Press Enter to try again..." _
        continue
    fi
    # rpm -V outputs nothing if all files match; leave output intentionally blank.
    echo

    echo "  Step 7: Install or upgrade a local RPM '/tmp/sample-1.0-1.x86_64.rpm' with progress."
    read -p "  lab@lab171:~$ " cmd7
    echo
    if [[ "$cmd7" != "rpm -Uvh /tmp/sample-1.0-1.x86_64.rpm" ]]; then
        print_error "Incorrect. Try again. (Use rpm -Uvh /tmp/sample-1.0-1.x86_64.rpm)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Preparing...                          ################################# [100%]"
    echo "  Updating / Installing..."
    echo "     1: sample-1.0-1.x86_64             ################################# [100%]"
    echo

    echo "  Step 8: List installed packages matching '^httpd'."
    read -p "  lab@lab171:~$ " cmd8
    echo
    if [[ "$cmd8" != "rpm -qa | grep ^httpd" ]]; then
        print_error "Incorrect. Try again. (Use rpm -qa | grep ^httpd)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  httpd-2.4.59-1.fc40.x86_64"
    echo

    echo "  Step 9: Show recent changelog entries for 'bash' (top lines only)."
    read -p "  lab@lab171:~$ " cmd9
    echo
    if [[ "$cmd9" != "rpm -q --changelog bash | head" ]]; then
        print_error "Incorrect. Try again. (Use rpm -q --changelog bash | head)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  * Mon Aug 12 2025 Fedora Maintainer <user@fedoraproject.org> - 5.2.26-1"
    echo "  - Rebuild for toolchain update"
    echo "  * Tue May 06 2025 Fedora Maintainer <user@fedoraproject.org> - 5.2.21-2"
    echo "  - Security fixes and minor improvements"
    echo

    echo "  Step 10: Show package scripts (pre/post) for 'bash'."
    read -p "  lab@lab171:~$ " cmd10
    echo
    if [[ "$cmd10" != "rpm -q --scripts bash" ]]; then
        print_error "Incorrect. Try again. (Use rpm -q --scripts bash)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  postinstall scriptlet (using /bin/sh):"
    echo "  /usr/bin/update-alternatives --install /bin/sh sh /bin/bash 100"
    echo "  postuninstall scriptlet (using /bin/sh):"
    echo "  /usr/bin/update-alternatives --remove sh /bin/bash"
    echo

    echo "  Step 11: Identify the package owning '/etc/os-release'."
    read -p "  lab@lab171:~$ " cmd11
    echo
    if [[ "$cmd11" != "rpm -qf /etc/os-release" ]]; then
        print_error "Incorrect. Try again. (Use rpm -qf /etc/os-release)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  systemd-255.6-2.fc40.x86_64"
    echo

    echo "  Step 12: Erase the 'sample' package."
    read -p "  lab@lab171:~$ " cmd12
    echo
    if [[ "$cmd12" != "rpm -e sample" ]]; then
        print_error "Incorrect. Try again. (Use rpm -e sample)"
        read -p "Press Enter to try again..." _
        continue
    fi
    # rpm -e is typically silent on success; leave output intentionally blank.
    echo

    echo "  Step 13: Extract files from '/tmp/sample-1.0-1.x86_64.rpm' into the current directory."
    read -p "  lab@lab171:~$ " cmd13
    echo
    if [[ "$cmd13" != "rpm2cpio /tmp/sample-1.0-1.x86_64.rpm | cpio -idmv" ]]; then
        print_error "Incorrect. Try again. (Use rpm2cpio /tmp/sample-1.0-1.x86_64.rpm | cpio -idmv)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  ./usr/bin/sample"
    echo "  ./usr/share/doc/sample/README"
    echo "  2 blocks"
    echo

    echo "  Step 14: List files contained in the RPM archive (without installing)."
    read -p "  lab@lab171:~$ " cmd14
    echo
    if [[ "$cmd14" != "rpm -qlp /tmp/sample-1.0-1.x86_64.rpm" ]]; then
        print_error "Incorrect. Try again. (Use rpm -qlp /tmp/sample-1.0-1.x86_64.rpm)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  /usr/bin/sample"
    echo "  /usr/share/doc/sample/README"
    echo

    echo "  Step 15: Verify a single file against the owning package (coreutils for /bin/ls)."
    read -p "  lab@lab171:~$ " cmd15
    echo
    if [[ "$cmd15" != "rpm -Vf /bin/ls" ]]; then
        print_error "Incorrect. Try again. (Use rpm -Vf /bin/ls)"
        read -p "Press Enter to try again..." _
        continue
    fi
    # rpm -Vf outputs nothing if the file passes verification; leave output intentionally blank.
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
