#!/bin/bash

# Lab 126: alien, ldd, and the Dynamic Linker (ldconfig, ld.so.conf, ld.so.cache)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 126: alien, ldd, and the Dynamic Linker"
LAB_ID="lab126"
LAB_XP=3350
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

# helpers (accept minor variants)
is_ldconfig_p() { [[ "$1" == "ldconfig -p | head -n 10" || "$1" == "ldconfig -p | head" ]]; }
is_show_ldso_conf() { [[ "$1" == "grep -E '^[^#]' /etc/ld.so.conf" || "$1" == "awk 'NF && $1!~/^#/' /etc/ld.so.conf" ]]; }
is_ldconfig_verify_opt() { [[ "$1" == "sudo ldconfig -v 2>/dev/null | grep -m1 /opt/mylib" || "$1" == "ldconfig -v 2>/dev/null | grep -m1 /opt/mylib" || "$1" == "sudo ldconfig -N -v 2>/dev/null | grep /opt/mylib" ]]; }

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Scenario: Inspect shared library usage, manage the dynamic linker search paths,"
    center_text "and convert packages between RPM and DEB formats."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Show the shared libraries required by /bin/ls."
    read -p "  lab@lpic-lab126:~$ " cmd1
    echo
    [[ "$cmd1" != "ldd /bin/ls" ]] && {
        print_error "Incorrect. Use: ldd /bin/ls"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "        linux-vdso.so.1 (0x00007ffdfc1f9000)"
    echo "        libselinux.so.1 => /lib/x86_64-linux-gnu/libselinux.so.1 (0x00007f1c...)"
    echo "        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f1c...)"
    echo "        /lib64/ld-linux-x86-64.so.2 (0x00007f1c...)"
    echo

    echo "  Step 2: List the first 10 entries from the dynamic linker cache."
    read -p "  lab@lpic-lab126:~$ " cmd2
    echo
    if ! is_ldconfig_p "$cmd2"; then
        print_error "Incorrect. Example: ldconfig -p | head -n 10"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "    1: libm.so.6 (libc6,x86-64) => /lib/x86_64-linux-gnu/libm.so.6"
    echo "    2: libc.so.6 (libc6,x86-64) => /lib/x86_64-linux-gnu/libc.so.6"
    echo "    3: libdl.so.2 (libc6,x86-64) => /lib/x86_64-linux-gnu/libdl.so.2"
    echo "    4: libpthread.so.0 (libc6,x86-64) => /lib/x86_64-linux-gnu/libpthread.so.0"
    echo "    5: libpcre2-8.so.0 (libc6,x86-64) => /lib/x86_64-linux-gnu/libpcre2-8.so.0"
    echo

    echo "  Step 3: Show active non-comment lines in /etc/ld.so.conf."
    read -p "  lab@lpic-lab126:~$ " cmd3
    echo
    if ! is_show_ldso_conf "$cmd3"; then
        print_error "Incorrect. Example: grep -E '^[^#]' /etc/ld.so.conf"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "/usr/local/lib"
    echo "include /etc/ld.so.conf.d/*.conf"
    echo

    echo "  Step 4: List snippet files in /etc/ld.so.conf.d."
    read -p "  lab@lpic-lab126:~$ " cmd4
    echo
    [[ "$cmd4" != "ls -1 /etc/ld.so.conf.d" ]] && {
        print_error "Incorrect. Use: ls -1 /etc/ld.so.conf.d"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "fakeroot-x86_64-linux-gnu.conf"
    echo "libc.conf"
    echo "x86_64-linux-gnu.conf"
    echo

    echo "  Step 5: Add a custom library path /opt/mylib via a new snippet."
    echo "          Create /etc/ld.so.conf.d/mylib.conf with one line: /opt/mylib"
    read -p "  lab@lpic-lab126:~$ " cmd5
    echo
    EXPECT5="echo /opt/mylib | sudo tee /etc/ld.so.conf.d/mylib.conf"
    [[ "$cmd5" != "$EXPECT5" ]] && {
        print_error "Incorrect. Use: $EXPECT5"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "/opt/mylib"
    echo

    echo "  Step 6: Update the library cache so the new path is recognized."
    read -p "  lab@lpic-lab126:~$ " cmd6
    echo
    [[ "$cmd6" != "sudo ldconfig" && "$cmd6" != "ldconfig" ]] && {
        print_error "Incorrect. Use: sudo ldconfig"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "Cache updated: /etc/ld.so.cache"
    echo

    echo "  Step 7: Verify that ldconfig now scans /opt/mylib."
    read -p "  lab@lpic-lab126:~$ " cmd7
    echo
    if ! is_ldconfig_verify_opt "$cmd7"; then
        print_error "Incorrect. Example: sudo ldconfig -v 2>/dev/null | grep -m1 /opt/mylib"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "/opt/mylib:"
    echo "    libexample.so -> libexample.so.1"
    echo

    echo "  Step 8: Temporarily prepend /opt/mylib to LD_LIBRARY_PATH for the current shell."
    read -p "  lab@lpic-lab126:~$ " cmd8
    echo
    [[ "$cmd8" != "export LD_LIBRARY_PATH=/opt/mylib:$LD_LIBRARY_PATH" ]] && {
        print_error "Incorrect. Use: export LD_LIBRARY_PATH=/opt/mylib:\$LD_LIBRARY_PATH"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "LD_LIBRARY_PATH set for current shell."
    echo

    echo "  Step 9: Convert an RPM to a DEB package using alien."
    echo "          Source file: htop-3.3.0-1.el9.x86_64.rpm"
    read -p "  lab@lpic-lab126:~$ " cmd9
    echo
    [[ "$cmd9" != "sudo alien -d htop-3.3.0-1.el9.x86_64.rpm" && "$cmd9" != "alien -d htop-3.3.0-1.el9.x86_64.rpm" ]] && {
        print_error "Incorrect. Use: sudo alien -d htop-3.3.0-1.el9.x86_64.rpm"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "htop-3.3.0-1.el9.x86_64.rpm converted to htop_3.3.0-2_amd64.deb"
    echo

    echo "  Step 10: Convert a DEB to an RPM package using alien."
    echo "           Source file: htop_3.0.5-1_amd64.deb"
    read -p "  lab@lpic-lab126:~$ " cmd10
    echo
    [[ "$cmd10" != "sudo alien -r htop_3.0.5-1_amd64.deb" && "$cmd10" != "alien -r htop_3.0.5-1_amd64.deb" ]] && {
        print_error "Incorrect. Use: sudo alien -r htop_3.0.5-1_amd64.deb"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "htop_3.0.5-1_amd64.deb converted to htop-3.0.5-2.x86_64.rpm"
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
