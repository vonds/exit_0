#!/bin/bash

# Lab 293: Troubleshooting Library Issues – Objective 102.3

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 293"
LAB_ID="lab293"
LAB_XP=44750
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
    center_text "Objective 102.3 — Troubleshooting Shared Libraries"
    center_text "Diagnose missing libraries using which, ldd, ldconfig -p, grep, and ls."
    echo
    center_text "Press Enter to begin the lab..."
    read _
    draw_lab_ui

    echo "  Step 1: Get the absolute directory reference for the 'man' command."
    read -p "  lab@lpic-lab293:~\$ > " cmd1
    echo

    if [[ "$cmd1" != "which man" ]]; then
        print_error "Incorrect. Use: which man"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  /usr/bin/man"
    echo

    echo "  Step 2: View the libraries required by /usr/bin/man."
    read -p "  lab@lpic-lab293:~\$ > " cmd2
    echo

    if [[ "$cmd2" != "ldd /usr/bin/man" ]]; then
        print_error "Incorrect. Use: ldd /usr/bin/man"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  linux-vdso.so.1 (0x00007ffc00000000)"
    echo "  libman.so.0 => /usr/lib/x86_64-linux-gnu/libman.so.0 (0x00007f1a22b00000)"
    echo "  libz.so.1 => /usr/lib/x86_64-linux-gnu/libz.so.1 (0x00007f1a22700000)"
    echo "  libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f1a22300000)"
    echo "  /lib64/ld-linux-x86-64.so.2 (0x00007f1a23000000)"
    echo

    echo "  Step 3: If the list is long, page through it."
    read -p "  lab@lpic-lab293:~\$ > " cmd3
    echo

    if [[ "$cmd3" != "ldd /usr/bin/man | less" ]]; then
        print_error "Incorrect. Pipe to the pager: ldd /usr/bin/man | less"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  linux-vdso.so.1 (0x00007ffc00000000)"
    echo "  libman.so.0 => /usr/lib/x86_64-linux-gnu/libman.so.0 (0x00007f1a22b00000)"
    echo "  libz.so.1 => /usr/lib/x86_64-linux-gnu/libz.so.1 (0x00007f1a22700000)"
    echo "  libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f1a22300000)"
    echo "  /lib64/ld-linux-x86-64.so.2 (0x00007f1a23000000)"
    echo "  "
    echo "  (less) Use ↑/↓ or PgUp/PgDn to scroll, / to search, q to quit."
    echo

    echo "  Step 4: Print directories and libraries in the cache."
    read -p "  lab@lpic-lab293:~\$ > " cmd4
    echo

    if [[ "$cmd4" != "sudo ldconfig -p" ]]; then
        print_error "Incorrect. Use: sudo ldconfig -p"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  2000 libs found in cache `/etc/ld.so.cache`"
    echo "  libz.so.1 (libc6,x86-64) => /usr/lib/x86_64-linux-gnu/libz.so.1"
    echo "  libc.so.6 (libc6,x86-64) => /lib/x86_64-linux-gnu/libc.so.6"
    echo "  libdl.so.2 (libc6,x86-64) => /lib/x86_64-linux-gnu/libdl.so.2"
    echo "  libpthread.so.0 (libc6,x86-64) => /lib/x86_64-linux-gnu/libpthread.so.0"
    echo

    echo "  Step 5: Search the cache for a specific library — libz.so.1."
    read -p "  lab@lpic-lab293:~\$ > " cmd5
    echo

    if [[ "$cmd5" != "sudo ldconfig -p | grep libz.so.1" ]]; then
        print_error "Incorrect. Use grep with ldconfig -p: sudo ldconfig -p | grep libz.so.1"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  libz.so.1 (libc6,x86-64) => /usr/lib/x86_64-linux-gnu/libz.so.1"
    echo

    echo "  Step 6: Verify libz.so.1 physically exists at that path."
    read -p "  lab@lpic-lab293:~\$ > " cmd6
    echo

    if [[ "$cmd6" != "ls /usr/lib/x86_64-linux-gnu/libz.so.1" ]]; then
        print_error "Incorrect. Use ls on the exact path shown by the cache."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  libz.so.1"
    echo "  (present at the specified path)"
    echo "  Typical long listing would show the target if it's a symlink:"
    echo "  lrwxrwxrwx 1 root root 14 Jan 12 10:15 libz.so.1 -> libz.so.1.2.13"
    echo

    echo "  Step 7: If the library wasn't found, rebuild the cache."
    read -p "  lab@lpic-lab293:~\$ > " cmd7
    echo

    if [[ "$cmd7" != "sudo ldconfig" ]]; then
        print_error "Incorrect. Rebuild with: sudo ldconfig"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Library cache rebuilt successfully. Shared libraries reindexed."
    echo

    print_success "Excellent troubleshooting!"
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
