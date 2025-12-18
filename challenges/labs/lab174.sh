#!/bin/bash

# Lab 174: GRUB Menu Edits — Temporary Kernel Args (rescue/emergency/rw)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 174: GRUB Menu Edits — Temporary Kernel Args"
LAB_ID="lab174"
LAB_XP=50000
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
    center_text "Practice editing GRUB entries temporarily: rescue.target, emergency.target, and rw/ro."
    center_text "Edits are one-boot only. Use the exact inputs requested."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    # --- Sequence A: Boot into rescue.target ---
    draw_lab_ui
    echo "  Step 1: At the GRUB menu, enter edit mode for the selected entry."
    read -p "  lab@lab174:~$ " cmd1
    echo
    if [[ "$cmd1" != "e" && "$cmd1" != "E" ]]; then
        print_error "Incorrect. Try again. (Press: e)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  GRUB editor opened. The 'linux' line is now editable."
    echo "  Example (truncated):"
    echo "    linux /vmlinuz-<version> root=UUID=<...> ro rhgb quiet"
    echo

    echo "  Step 2: Append the kernel argument to boot into rescue mode."
    read -p "  lab@lab174:~$ " cmd2
    echo
    if [[ "$cmd2" != "systemd.unit=rescue.target" ]]; then
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  linux ... systemd.unit=rescue.target     # (argument appended)"
    echo

    echo "  Step 3: Boot with the modified entry."
    read -p "  lab@lab174:~$ " cmd3
    echo
    if [[ "$cmd3" != "Ctrl+x" && "$cmd3" != "ctrl+x" && "$cmd3" != "F10" && "$cmd3" != "f10" ]]; then
        print_error "Incorrect. Try again. (Use: Ctrl+x or F10)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  [  OK  ] Reached target Rescue Mode."
    echo "  You are in rescue mode. After logging in, type 'journalctl -xb' to view system logs,"
    echo "  'systemctl reboot' to reboot, 'systemctl default' or ^D to boot into default mode."
    echo "  Give root password for maintenance"
    echo "  (or press Control-D to continue):"
    echo

    echo "  Step 4: From rescue shell, reboot back to the GRUB menu."
    read -p "  lab@lab174:~$ " cmd4
    echo
    if [[ "$cmd4" != "reboot" && "$cmd4" != "systemctl reboot" ]]; then
        print_error "Incorrect. Try again. (Use: reboot)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Rebooting."
    echo "  Unmounting file systems."
    echo "  [  OK  ] Reached target Shutdown."
    echo

    # --- Sequence B: Boot into emergency.target ---
    echo "  Step 5: At the GRUB menu again, enter edit mode."
    read -p "  lab@lab174:~$ " cmd5
    echo
    if [[ "$cmd5" != "e" && "$cmd5" != "E" ]]; then
        print_error "Incorrect. Try again. (Press: e)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  GRUB editor opened."
    echo

    echo "  Step 6: Append the kernel argument to boot into emergency mode."
    read -p "  lab@lab174:~$ " cmd6
    echo
    if [[ "$cmd6" != "systemd.unit=emergency.target" ]]; then
        print_error "Incorrect. Try again. (Use: systemd.unit=emergency.target)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  linux ... systemd.unit=emergency.target  # (argument appended)"
    echo

    echo "  Step 7: Boot with the modified entry."
    read -p "  lab@lab174:~$ " cmd7
    echo
    if [[ "$cmd7" != "Ctrl+x" && "$cmd7" != "ctrl+x" && "$cmd7" != "F10" && "$cmd7" != "f10" ]]; then
        print_error "Incorrect. Try again. (Use: Ctrl+x or F10)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Welcome to emergency mode! After logging in, type 'journalctl -xb' to view system logs,"
    echo "  'systemctl reboot' to reboot, 'systemctl default' or ^D to boot into default mode."
    echo "  Give root password for maintenance"
    echo "  (or press Control-D to continue):"
    echo

    echo "  Step 8: From emergency shell, reboot back to the GRUB menu."
    read -p "  lab@lab174:~$ " cmd8
    echo
    if [[ "$cmd8" != "reboot -f" && "$cmd8" != "reboot" && "$cmd8" != "systemctl reboot" ]]; then
        print_error "Incorrect. Try again. (Use: reboot -f or reboot)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Rebooting."
    echo "  Syncing filesystems. Powering off and on."
    echo

    # --- Sequence C: Switch root to rw and boot to bash via init=/bin/bash ---
    echo "  Step 9: At the GRUB menu, enter edit mode once more."
    read -p "  lab@lab174:~$ " cmd9
    echo
    if [[ "$cmd9" != "e" && "$cmd9" != "E" ]]; then
        print_error "Incorrect. Try again. (Press: e)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  GRUB editor opened."
    echo "  Find the 'linux' line containing 'root=... ro rhgb quiet'."
    echo

    echo "  Step 10: Change the root filesystem mount from read-only to read-write."
    read -p "  lab@lab174:~$ " cmd10
    echo
    if [[ "$cmd10" != "rw" ]]; then
        print_error "Incorrect. Try again. (Use: rw)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  linux ... root=UUID=<...> rw quiet     # (ro -> rw)"
    echo

    echo "  Step 11: Add a kernel argument to boot straight into a shell for repairs."
    read -p "  lab@lab174:~$ " cmd11
    echo
    if [[ "$cmd11" != "init=/bin/bash" ]]; then
        print_error "Incorrect. Try again. (Use: init=/bin/bash)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  linux ... rw init=/bin/bash            # (argument appended)"
    echo

    echo "  Step 12: Boot with the modified entry."
    read -p "  lab@lab174:~$ " cmd12
    echo
    if [[ "$cmd12" != "Ctrl+x" && "$cmd12" != "ctrl+x" && "$cmd12" != "F10" && "$cmd12" != "f10" ]]; then
        print_error "Incorrect. Try again. (Use: Ctrl+x or F10)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Kernel command line: ... rw init=/bin/bash"
    echo "  bash: no job control in this shell"
    echo "  (repair shell) #"
    echo

    echo "  Step 13: Confirm the kernel command line reflects your temporary edits."
    read -p "  lab@lab174:~$ " cmd13
    echo
    if [[ "$cmd13" != "cat /proc/cmdline" ]]; then
        print_error "Incorrect. Try again. (Use: cat /proc/cmdline)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  BOOT_IMAGE=(hd0,gpt2)/vmlinuz-<version> root=UUID=<...> rw init=/bin/bash"
    echo

    echo "  Step 14: Exit the repair session and reboot normally."
    read -p "  lab@lab174:~$ " cmd14
    echo
    if [[ "$cmd14" != "reboot -f" && "$cmd14" != "exec /sbin/init" && "$cmd14" != "exec /usr/lib/systemd/systemd" && "$cmd14" != "systemctl reboot" ]]; then
        print_error "Incorrect. Try again. (Use: reboot -f)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Rebooting."
    echo "  Temporary kernel arguments will be discarded on next boot."
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
