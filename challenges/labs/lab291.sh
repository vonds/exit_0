#!/bin/bash

# Lab 291: Understanding Libraries – Objective 102.3

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 291"
LAB_ID="lab291"
LAB_XP=57680
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"

[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

draw_lab_ui() {
    clear
    center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
    center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
    echo
    echo
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
    center_text "Objective 102.3 — Shared libraries and the dynamic linker."
    center_text "You'll inspect naming, locations, config, env vars, and dependency resolution."
    echo
    center_text "Press Enter to begin the lab..."
    read _
    draw_lab_ui

    echo "  Step 1: Print the current LD_LIBRARY_PATH (expecting blank on most systems)."
    read -p "  lab@lpic-lab291:~\$ > " cmd1
    echo

    if [[ "$cmd1" != "echo \$LD_LIBRARY_PATH" ]]; then
        print_error "Incorrect. Echo the variable exactly: echo \$LD_LIBRARY_PATH"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi


    echo "  Step 2: Show the master dynamic linker configuration file."
    read -p "  lab@lpic-lab291:~\$ > " cmd2
    echo

    if [[ "$cmd2" != "cat /etc/ld.so.conf" ]]; then
        print_error "Incorrect. View the master config with: cat /etc/ld.so.conf"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  include /etc/ld.so.conf.d/*.conf"
    echo

    echo "  Step 3: List directory with per-package linker configs."
    read -p "  lab@lpic-lab291:~\$ > " cmd3
    echo

    if [[ "$cmd3" != "ls /etc/ld.so.conf.d" ]]; then
        print_error "Incorrect. List the directory: ls /etc/ld.so.conf.d"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  libc.conf"
    echo "  x86_64-linux-gnu.conf"
    echo "  fakeroot-x86_64-linux-gnu.conf"
    echo

    echo "  Step 4: List a standard library directory (quick scan)."
    read -p "  lab@lpic-lab291:~\$ > " cmd4
    echo

    if [[ "$cmd4" != "ls /lib | head" ]]; then
        print_error "Incorrect. Try: ls /lib | head"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  ld-linux-x86-64.so.2"
    echo "  libblkid.so.1"
    echo "  libbz2.so.1.0"
    echo "  libcap.so.2"
    echo "  libcrypt.so.1"
    echo "  libdl.so.2"
    echo "  libgcc_s.so.1"
    echo "  libm.so.6"
    echo "  libmount.so.1"
    echo "  libpthread.so.0"
    echo

    echo "  Step 5: Print the cached shared library list (first few)."
    read -p "  lab@lpic-lab291:~\$ > " cmd5
    echo

    if [[ "$cmd5" != "sudo ldconfig -p | head" ]]; then
        print_error "Incorrect. Use ldconfig -p to view the cache. Example: ldconfig -p | head"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  1000 libs found in cache `/etc/ld.so.cache`"
    echo "  libX11.so.6 (libc6,x86-64) => /usr/lib/x86_64-linux-gnu/libX11.so.6"
    echo "  libm.so.6 (libc6,x86-64)   => /usr/lib/x86_64-linux-gnu/libm.so.6"
    echo "  libc.so.6 (libc6,x86-64)   => /usr/lib/x86_64-linux-gnu/libc.so.6"
    echo "  libdl.so.2 (libc6,x86-64)  => /usr/lib/x86_64-linux-gnu/libdl.so.2"
    echo "  libpthread.so.0 (libc6,x86-64) => /usr/lib/x86_64-linux-gnu/libpthread.so.0"
    echo "  libgcc_s.so.1 (libc6,x86-64) => /lib/x86_64-linux-gnu/libgcc_s.so.1"
    echo "  libsystemd.so.0 (libc6,x86-64) => /lib/x86_64-linux-gnu/libsystemd.so.0"
    echo "  libz.so.1 (libc6,x86-64)   => /usr/lib/x86_64-linux-gnu/libz.so.1"
    echo "  libcap.so.2 (libc6,x86-64) => /lib/x86_64-linux-gnu/libcap.so.2"
    echo

    echo "  Step 6: Find the absolute path of the 'ps' binary."
    read -p "  lab@lpic-lab291:~\$ > " cmd6
    echo

    if [[ "$cmd6" != "which ps" ]]; then
        print_error "Incorrect. Use which to resolve executables: which ps"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  /usr/bin/ps"
    echo

    echo "  Step 7: Show the shared libraries required by /usr/bin/ps."
    read -p "  lab@lpic-lab291:~\$ > " cmd7
    echo

    if [[ "$cmd7" != "ldd /usr/bin/ps" ]]; then
        print_error "Incorrect. Use ldd against the absolute path: ldd /usr/bin/ps"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  linux-vdso.so.1 (0x00007ffc00000000)"
    echo "  libsystemd.so.0 => /lib/x86_64-linux-gnu/libsystemd.so.0 (0x00007f1a22b00000)"
    echo "  libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f1a22700000)"
    echo "  /lib64/ld-linux-x86-64.so.2 (0x00007f1a23000000)"
    echo

    echo "  Step 8: Use the dynamic linker directly to run /usr/bin/ps."
    read -p "  lab@lpic-lab291:~\$ > " cmd8
    echo

    if [[ "$cmd8" != "/lib64/ld-linux-x86-64.so.2 /usr/bin/ps" ]]; then
        print_error "Incorrect. Invoke the loader with the binary: /lib64/ld-linux-x86-64.so.2 /usr/bin/ps"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  PID TTY          TIME CMD"
    echo "  1000 pts/0    00:00:00 bash"
    echo "  1045 pts/0    00:00:00 ps"
    echo

    echo "  Step 9: BONUS — Show two standard library roots often seen on exams."
    read -p "  lab@lpic-lab291:~\$ > " cmd9
    echo

    if [[ "$cmd9" != "/lib /lib64" ]]; then
        print_error "Incorrect. Print exactly these two lines."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  /lib"
    echo "  /lib64"
    echo

    print_success "Excellent work!"
    print_info "You earned $LAB_XP XP for completing this lab!"
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON")
    LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
    export XP
    export LEVEL
    record_lab_completion

    completion_count=$(get_lab_completion_count)
    echo
    print_info "You've successfully completed this lab $completion_count time(s)."
    echo
    center_text "Would you like to:"
    center_text "1) Retry this lab"
    center_text "2) Return to Sysadmin Lab Menu"
    echo
    read -p "  > " choice

    if [[ "$choice" == "2" ]]; then
        exit 0
    fi
done
