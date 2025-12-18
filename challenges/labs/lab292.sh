#!/bin/bash

# Lab 192: Developing and Managing Library Caches – Objective 102.3

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 292"
LAB_ID="lab292"
LAB_XP=23900
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
    center_text "Objective 102.3 — Developing and Managing Library Caches"
    center_text "Use ldconfig, view caches, and set LD_LIBRARY_PATH."
    echo
    center_text "Press Enter to begin the lab..."
    read _
    draw_lab_ui

    echo "  Step 1: View the current library cache with ldconfig (combined flags, no rebuild)."
    read -p "  lab@lpic-lab192:~\$ > " cmd1
    echo

    if [[ "$cmd1" != "sudo ldconfig -vN" ]]; then
        print_error "Incorrect. Use combined flags with capital N: sudo ldconfig -vN"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  /lib/x86_64-linux-gnu:"
    echo "    libdl.so.2 -> libdl-2.35.so"
    echo "    libm.so.6 -> libm-2.35.so"
    echo "  /usr/lib/x86_64-linux-gnu:"
    echo "    libX11.so.6 -> libX11.so.6.4.0"
    echo "    libz.so.1 -> libz.so.1.2.13"
    echo

    echo "  Step 2: The output scrolls fast. View it one page at a time."
    read -p "  lab@lpic-lab192:~\$ > " cmd2
    echo

    if [[ "$cmd2" != "sudo ldconfig -vN | less" ]]; then
        print_error "Incorrect. Pipe to less with combined flags: sudo ldconfig -vN | less"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  /lib/x86_64-linux-gnu:"
    echo "    ld-linux-x86-64.so.2 -> ld-2.35.so"
    echo "    libdl.so.2 -> libdl-2.35.so"
    echo "    libm.so.6 -> libm-2.35.so"
    echo "    libc.so.6 -> libc-2.35.so"
    echo "    libpthread.so.0 -> libpthread-2.35.so"
    echo "  /usr/lib/x86_64-linux-gnu:"
    echo "    libX11.so.6 -> libX11.so.6.4.0"
    echo "    libXext.so.6 -> libXext.so.6.4.0"
    echo "    libz.so.1 -> libz.so.1.2.13"
    echo "    libsystemd.so.0 -> libsystemd.so.0.34.0"
    echo "    libgcc_s.so.1 -> libgcc_s.so.1"
    echo "  /usr/local/lib:"
    echo "    (no symlinks to update)"
    echo -n "  : "
    # Mimic the user pressing 'q' to quit less
    sleep 1
    echo "q"
    echo


    echo "  Step 3: Display LD_LIBRARY_PATH."
    read -p "  lab@lpic-lab192:~\$ > " cmd3
    echo

    if [[ "$cmd3" != "echo \$LD_LIBRARY_PATH" ]]; then
        print_error "Incorrect. Use echo with the \$ prefix: echo \$LD_LIBRARY_PATH"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Step 4: Pretend you're developing libs and export a new path."
    read -p "  lab@lpic-lab192:~\$ > " cmd4
    echo

    if [[ "$cmd4" != "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/home/app_project" ]]; then
        print_error "Incorrect. Exact syntax: export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/home/app_project"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  LD_LIBRARY_PATH now includes /home/app_project"
    echo

    echo "  Step 5: Verify LD_LIBRARY_PATH."
    read -p "  lab@lpic-lab192:~\$ > " cmd5
    echo

    if [[ "$cmd5" != "echo \$LD_LIBRARY_PATH" ]]; then
        print_error "Incorrect. Verify with: echo \$LD_LIBRARY_PATH"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  /home/app_project"
    echo

    echo "  Step 6: Rebuild the library cache after adding new libraries."
    read -p "  lab@lpic-lab192:~\$ > " cmd6
    echo

    if [[ "$cmd6" != "sudo ldconfig" ]]; then
        print_error "Incorrect. Rebuild cache with: sudo ldconfig"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Library cache rebuilt from configured paths."
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
