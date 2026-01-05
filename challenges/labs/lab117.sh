#!/bin/bash

# Lab 117: Debian Package Management with dpkg
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 117: Debian Package Management with dpkg"
LAB_ID="lab117"
LAB_XP=3400
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

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Scenario: You must manage Debian packages directly with dpkg."
    center_text "Query package info, list installed packages, install a .deb, and remove/purge it."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Show the status of the 'bash' package."
    read -p "  lab@lpic-lab117:~$ " cmd1
    echo
    [[ "$cmd1" != "dpkg -s bash" ]] && {
        print_error "Incorrect. Use: dpkg -s bash"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Package: bash"
    echo "  Status: install ok installed"
    echo "  Priority: required"
    echo "  Version: 5.1-2ubuntu3"
    echo

    echo "  Step 2: List the first 10 installed packages."
    read -p "  lab@lpic-lab117:~$ " cmd2
    echo
    [[ "$cmd2" != "dpkg -l | head -n 10" ]] && {
        print_error "Incorrect. Use: dpkg -l | head -n 10"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Desired=Unknown/Install/Remove/Purge/Hold"
    echo "  ||/ Name           Version       Architecture Description"
    echo "  ii  adduser        3.118         all          add and remove users and groups"
    echo "  ii  apt            2.4.5         amd64        commandline package manager"
    echo "  ii  base-files     12ubuntu4     amd64        Debian base system miscellaneous files"
    echo "  ii  bash           5.1-2ubuntu3  amd64        GNU Bourne Again SHell"
    echo "  ii  bsdutils       1:2.37.2-4    amd64        basic utilities from 2.37"
    echo "  ii  coreutils      8.32-4.1      amd64        GNU core utilities"
    echo "  ii  dash           0.5.11+git    amd64        POSIX-compliant shell"
    echo

    echo "  Step 3: List all files installed by the 'bash' package."
    read -p "  lab@lpic-lab117:~$ " cmd3
    echo
    [[ "$cmd3" != "dpkg -L bash" ]] && {
        print_error "Incorrect. Use: dpkg -L bash"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  /."
    echo "  /bin/bash"
    echo "  /usr/share/doc/bash/README.gz"
    echo "  /usr/share/man/man1/bash.1.gz"
    echo

    echo "  Step 4: Identify which package owns /bin/bash."
    read -p "  lab@lpic-lab117:~$ " cmd4
    echo
    [[ "$cmd4" != "dpkg -S /bin/bash" ]] && {
        print_error "Incorrect. Use: dpkg -S /bin/bash"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  bash: /bin/bash"
    echo

    echo "  Step 5: Install a local .deb file with dpkg."
    echo "          Assume the file is htop_3.0.5-1_amd64.deb in the current directory."
    read -p "  lab@lpic-lab117:~$ " cmd5
    echo
    [[ "$cmd5" != "sudo dpkg -i htop_3.0.5-1_amd64.deb" ]] && {
        print_error "Incorrect. Use: sudo dpkg -i htop_3.0.5-1_amd64.deb"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Selecting previously unselected package htop."
    echo "  (Reading database ... 123456 files and directories currently installed.)"
    echo "  Preparing to unpack htop_3.0.5-1_amd64.deb ..."
    echo "  Unpacking htop (3.0.5-1) ..."
    echo "  dpkg: dependency problems prevent configuration of htop:"
    echo "   htop depends on libc6 (>= 2.34); however:"
    echo "    Package libc6 is not configured yet."
    echo "  dpkg: error processing package htop (--install):"
    echo "   dependency problems - leaving unconfigured"
    echo

    echo "  Step 6: Fix missing dependencies after a dpkg install."
    read -p "  lab@lpic-lab117:~$ " cmd6
    echo
    [[ "$cmd6" != "sudo apt -f install" ]] && {
        print_error "Incorrect. Use: sudo apt -f install"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Reading package lists... Done"
    echo "  Building dependency tree"
    echo "  Correcting dependencies... Done"
    echo "  The following additional packages will be installed:"
    echo "    libc6"
    echo "  Setting up libc6 ..."
    echo "  Setting up htop (3.0.5-1) ..."
    echo

    echo "  Step 7: Remove the package but keep configuration files."
    read -p "  lab@lpic-lab117:~$ " cmd7
    echo
    [[ "$cmd7" != "sudo dpkg -r htop" ]] && {
        print_error "Incorrect. Use: sudo dpkg -r htop"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (Reading database ... 123460 files and directories currently installed.)"
    echo "  Removing htop (3.0.5-1) ..."
    echo "  Processing triggers for man-db ..."
    echo

    echo "  Step 8: Purge the package including configuration files."
    read -p "  lab@lpic-lab117:~$ " cmd8
    echo
    [[ "$cmd8" != "sudo dpkg -P htop" ]] && {
        print_error "Incorrect. Use: sudo dpkg -P htop"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (Reading database ... 123450 files and directories currently installed.)"
    echo "  Purging configuration files for htop (3.0.5-1) ..."
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
