#!/bin/bash

# Lab 122: RPM Package Management (install, remove, query, verify)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 122: RPM Package Management"
LAB_ID="lab122"
LAB_XP=3300
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
    center_text "Scenario: You are on an RPM-based system. Use rpm to query, verify, install, and remove packages."
    center_text "Practice: -qa, -qi, -ql, -qf, -V, -K/--checksig, -qp --info, -Uvh, -e, --rebuilddb."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: List the first 10 installed RPM packages."
    read -p "  lab@lpic-lab122:~$ " cmd1
    echo
    [[ "$cmd1" != "rpm -qa | head -n 10" ]] && {
        print_error "Incorrect. Use: rpm -qa | head -n 10"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  bash-5.1.8-3.el9.x86_64"
    echo "  coreutils-8.32-34.el9.x86_64"
    echo "  filesystem-3.16-2.el9.x86_64"
    echo "  glibc-2.34-100.el9.x86_64"
    echo "  grep-3.6-5.el9.x86_64"
    echo "  gzip-1.10-6.el9.x86_64"
    echo "  rpm-4.16.1.3-31.el9.x86_64"
    echo "  shadow-utils-4.9-8.el9.x86_64"
    echo "  vim-minimal-8.2.2637-20.el9.x86_64"
    echo "  which-2.21-29.el9.x86_64"
    echo

    echo "  Step 2: Show package info for the installed 'bash' package."
    read -p "  lab@lpic-lab122:~$ " cmd2
    echo
    [[ "$cmd2" != "rpm -qi bash" ]] && {
        print_error "Incorrect. Use: rpm -qi bash"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Name        : bash"
    echo "  Version     : 5.1.8"
    echo "  Release     : 3.el9"
    echo "  Architecture: x86_64"
    echo "  Summary     : The GNU Bourne Again shell"
    echo "  License     : GPLv3+"
    echo

    echo "  Step 3: List files installed by the 'bash' package."
    read -p "  lab@lpic-lab122:~$ " cmd3
    echo
    [[ "$cmd3" != "rpm -ql bash" ]] && {
        print_error "Incorrect. Use: rpm -ql bash"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  /bin/bash"
    echo "  /etc/skel/.bashrc"
    echo "  /usr/share/man/man1/bash.1.gz"
    echo

    echo "  Step 4: Identify which package owns /bin/bash."
    read -p "  lab@lpic-lab122:~$ " cmd4
    echo
    [[ "$cmd4" != "rpm -qf /bin/bash" ]] && {
        print_error "Incorrect. Use: rpm -qf /bin/bash"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  bash-5.1.8-3.el9.x86_64"
    echo

    echo "  Step 5: Verify the integrity of the installed 'bash' package."
    read -p "  lab@lpic-lab122:~$ " cmd5
    echo
    [[ "$cmd5" != "rpm -V bash" ]] && {
        print_error "Incorrect. Use: rpm -V bash"
        read -p "Press Enter to try again..." _
        continue
    }
    echo

    echo "  Step 6: Check the GPG signature of a local RPM file."
    echo "          Assume file: htop-3.3.0-1.el9.x86_64.rpm"
    read -p "  lab@lpic-lab122:~$ " cmd6
    echo
    [[ "$cmd6" != "rpm -K htop-3.3.0-1.el9.x86_64.rpm" && "$cmd6" != "rpm --checksig htop-3.3.0-1.el9.x86_64.rpm" ]] && {
        print_error "Incorrect. Use: rpm -K htop-3.3.0-1.el9.x86_64.rpm"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  htop-3.3.0-1.el9.x86_64.rpm: digests signatures OK"
    echo

    echo "  Step 7: Query info from a local RPM file (not yet installed)."
    read -p "  lab@lpic-lab122:~$ " cmd7
    echo
    [[ "$cmd7" != "rpm -qp --info htop-3.3.0-1.el9.x86_64.rpm" ]] && {
        print_error "Incorrect. Use: rpm -qp --info htop-3.3.0-1.el9.x86_64.rpm"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Name        : htop"
    echo "  Version     : 3.3.0"
    echo "  Release     : 1.el9"
    echo "  Architecture: x86_64"
    echo "  Summary     : Interactive process viewer"
    echo

    echo "  Step 8: Install or upgrade the local RPM with verbose progress."
    read -p "  lab@lpic-lab122:~$ " cmd8
    echo
    [[ "$cmd8" != "sudo rpm -Uvh htop-3.3.0-1.el9.x86_64.rpm" && "$cmd8" != "rpm -Uvh htop-3.3.0-1.el9.x86_64.rpm" ]] && {
        print_error "Incorrect. Use: rpm -Uvh htop-3.3.0-1.el9.x86_64.rpm"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Preparing...                          ################################# [100%]"
    echo "  Updating / installing..."
    echo "     1:htop-3.3.0-1.el9                 ################################# [100%]"
    echo

    echo "  Step 9: Remove the htop package."
    read -p "  lab@lpic-lab122:~$ " cmd9
    echo
    [[ "$cmd9" != "sudo rpm -e htop" && "$cmd9" != "rpm -e htop" ]] && {
        print_error "Incorrect. Use: rpm -e htop"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Preparing packages..."
    echo "  Erasing     : htop-3.3.0-1.el9.x86_64"
    echo "  Verifying   : htop-3.3.0-1.el9.x86_64"
    echo

    echo "  Step 10: Rebuild the RPM database (maintenance)."
    read -p "  lab@lpic-lab122:~$ " cmd10
    echo
    [[ "$cmd10" != "sudo rpm --rebuilddb" && "$cmd10" != "rpm --rebuilddb" ]] && {
        print_error "Incorrect. Use: rpm --rebuilddb"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Rebuilding RPM database..."
    echo "  Done."
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
