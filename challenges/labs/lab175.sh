#!/bin/bash

# Lab 175: RHEL GRUB Recovery — Reset Root Password (rd.break) [Sanitized Outputs]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 175: RHEL GRUB Recovery — Reset Root Password (rd.break)"
LAB_ID="lab175"
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
    center_text "Goal: Edit GRUB temporarily, reset root password, trigger SELinux relabel, verify."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    # --- Enter GRUB edit mode ---
    draw_lab_ui
    echo "  Step 1: At the GRUB menu, enter edit mode for the selected boot entry."
    read -p "  lab@lab175:~$ " cmd1
    echo
    if [[ "$cmd1" != "e" && "$cmd1" != "E" ]]; then
        print_error "Incorrect. Try again. (Press: e)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  GRUB editor opened. The 'linux' line is now editable."
    echo "  Example (truncated):"
    echo "    linux /vmlinuz-<KERNEL-VERSION> root=UUID=<ROOT-UUID> ro rhgb quiet"
    echo

    echo "  Step 2: Append the kernel argument that breaks into the initramfs shell before switch_root."
    read -p "  lab@lab175:~$ " cmd2
    echo
    if [[ "$cmd2" != "rd.break" ]]; then
        print_error "Incorrect. Try again. (Use: rd.break)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  linux ... ro rhgb quiet rd.break"
    echo

    echo "  Step 3: Boot the modified entry."
    read -p "  lab@lab175:~$ " cmd3
    echo
    if [[ "$cmd3" != "Ctrl+x" && "$cmd3" != "ctrl+x" && "$cmd3" != "F10" && "$cmd3" != "f10" ]]; then
        print_error "Incorrect. Try again. (Use: Ctrl+x or F10)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  dracut: rd.break requested — entering emergency shell (simulated)"
    echo "  Type 'journalctl' to view system logs."
    echo "  dracut:/#"
    echo

    echo "  Step 4: Confirm the kernel command line includes 'rd.break'."
    read -p "  dracut:/# " cmd4
    echo
    if [[ "$cmd4" != "cat /proc/cmdline" ]]; then
        print_error "Incorrect. Try again. (Use: cat /proc/cmdline)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  BOOT_IMAGE=/vmlinuz-<KERNEL-VERSION> root=UUID=<ROOT-UUID> ro rhgb quiet rd.break"
    echo

    # --- Remount and chroot into real root ---
    echo "  Step 5: Remount the real root (mounted at /sysroot) as read-write."
    read -p "  dracut:/# " cmd5
    echo
    if [[ "$cmd5" != "mount -o remount,rw /sysroot" && "$cmd5" != "mount -o rw,remount /sysroot" ]]; then
        print_error "Incorrect. Try again. (Use: mount -o remount,rw /sysroot)"
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Step 6: Chroot into the real root filesystem."
    read -p "  dracut:/# " cmd6
    echo
    if [[ "$cmd6" != "chroot /sysroot" ]]; then
        print_error "Incorrect. Try again. (Use: chroot /sysroot)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  sh-<MAJOR.MINOR>#"
    echo

    # --- Reset root password ---
    echo "  Step 7: Reset the root password."
    read -p "  sh-<MAJOR.MINOR># " cmd7
    echo
    if [[ "$cmd7" != "passwd" && "$cmd7" != "passwd root" ]]; then
        print_error "Incorrect. Try again. (Use: passwd)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Changing password for user root."
    echo "  New password: "
    echo "  Retype new password: "
    echo "  passwd: all authentication tokens updated successfully."
    echo

    # --- Ensure SELinux relabel ---
    echo "  Step 8: Ensure SELinux will relabel files on next boot."
    read -p "  sh-<MAJOR.MINOR># " cmd8
    echo
    if [[ "$cmd8" != "touch /.autorelabel" ]]; then
        print_error "Incorrect. Try again. (Use: touch /.autorelabel)"
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Step 9: Exit the chroot to return to the dracut shell."
    read -p "  sh-<MAJOR.MINOR># " cmd9
    echo
    if [[ "$cmd9" != "exit" ]]; then
        print_error "Incorrect. Try again. (Use: exit)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  dracut:/#"
    echo

    echo "  Step 10: Reboot the system."
    read -p "  dracut:/# " cmd10
    echo
    if [[ "$cmd10" != "reboot -f" && "$cmd10" != "reboot" && "$cmd10" != "systemctl reboot" ]]; then
        print_error "Incorrect. Try again. (Use: reboot -f)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Rebooting (simulated)."
    echo

    # --- First boot after reset: SELinux relabel simulation ---
    echo "  Step 11: (Boot) SELinux is relabeling the filesystem. No action required."
    echo "  SELinux: Relabeling filesystem..."
    echo "  Relabeling complete."
    echo "  System will reboot automatically."
    echo

    # --- Post-boot verification ---
    echo "  Step 12: After reboot, verify that SELinux relabel occurred."
    read -p "  lab@lab175:~$ " cmd12
    echo
    if [[ "$cmd12" != "journalctl -b | grep -i relabel" ]]; then
        print_error "Incorrect. Try again. (Use: journalctl -b | grep -i relabel)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  systemd: Filesystem relabel complete"
    echo

    echo "  Step 13: Confirm the relabel marker file was consumed."
    read -p "  lab@lab175:~$ " cmd13
    echo
    if [[ "$cmd13" != "ls -l /.autorelabel" ]]; then
        print_error "Incorrect. Try again. (Use: ls -l /.autorelabel)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  ls: cannot access '/.autorelabel': No such file or directory"
    echo

    echo "  Step 14: Show the shadow file timestamp changed."
    read -p "  lab@lab175:~$ " cmd14
    echo
    if [[ "$cmd14" != "ls -l /etc/shadow" ]]; then
        print_error "Incorrect. Try again. (Use: ls -l /etc/shadow)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  -rw-------. 1 root root <BYTES> <DATE> /etc/shadow"
    echo

    echo "  Step 15: (Optional) Verify current boot target is normal."
    read -p "  lab@lab175:~$ " cmd15
    echo
    if [[ "$cmd15" != "systemctl get-default" ]]; then
        print_error "Incorrect. Try again. (Use: systemctl get-default)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  multi-user.target"
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
