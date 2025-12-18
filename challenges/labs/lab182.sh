#!/bin/bash

# Lab 182: LVM Root Issues — Find, Fix, and Persist (pvscan/vgscan/vgchange, LV rename, fstab/GRUB)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 182: LVM Root Issues — Find, Fix, and Persist"
LAB_ID="lab182"
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
    center_text "Scenario: System can’t find the LVM root at boot. The root LV was renamed from 'root' → 'sysroot'."
    center_text "Goal: Discover and activate LVM, boot, then persistently fix by renaming LV and updating configs."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    # --- You are at the dracut emergency shell due to wrong/missing LVM root mapping ---
    draw_lab_ui
    echo "  The system dropped to the initramfs emergency shell (simulated)."
    echo "  dracut:/#"
    echo

    echo "  Step 1: Show the kernel command line to confirm the expected LV name."
    read -p "  dracut:/# " cmd1
    echo
    if [[ "$cmd1" != "cat /proc/cmdline" ]]; then
        print_error "Incorrect. Try again. (Use: cat /proc/cmdline)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  BOOT_IMAGE=/vmlinuz-<KERNEL> root=/dev/mapper/rhel-root rd.lvm.lv=rhel/root ro rhgb quiet"
    echo "  (Note: cmdline expects LV 'rhel/root')"
    echo

    echo "  Step 2: Scan for physical volumes."
    read -p "  dracut:/# " cmd2
    echo
    if [[ "$cmd2" != "pvscan" ]]; then
        print_error "Incorrect. Try again. (Use: pvscan)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  PV /dev/sda2   VG rhel   lvm2 [39.50 GiB / 0    free]"
    echo

    echo "  Step 3: Scan for volume groups."
    read -p "  dracut:/# " cmd3
    echo
    if [[ "$cmd3" != "vgscan" ]]; then
        print_error "Incorrect. Try again. (Use: vgscan)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Found volume group \"rhel\" using metadata type lvm2"
    echo

    echo "  Step 4: Activate the volume group so logical volumes appear."
    read -p "  dracut:/# " cmd4
    echo
    if [[ "$cmd4" != "vgchange -ay" ]]; then
        print_error "Incorrect. Try again. (Use: vgchange -ay)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  2 logical volume(s) in volume group \"rhel\" now active"
    echo

    echo "  Step 5: List logical volumes to identify the root LV name."
    read -p "  dracut:/# " cmd5
    echo
    if [[ "$cmd5" != "lvs" ]]; then
        print_error "Incorrect. Try again. (Use: lvs)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  LV       VG   Attr       LSize"
    echo "  sysroot  rhel -wi-ao----  20.0g"
    echo "  swap     rhel -wi-ao----   2.0g"
    echo "  (Mismatch: LV is 'sysroot' but kernel expects 'root')"
    echo

    echo "  Step 6: Mount the real root at /sysroot to allow boot to proceed."
    read -p "  dracut:/# " cmd6
    echo
    if [[ "$cmd6" != "mount /dev/mapper/rhel-sysroot /sysroot" ]]; then
        print_error "Incorrect. Try again. (Use: mount /dev/mapper/rhel-sysroot /sysroot)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    echo "  Step 7: Exit the emergency shell to continue boot with /sysroot mounted."
    read -p "  dracut:/# " cmd7
    echo
    if [[ "$cmd7" != "exit" ]]; then
        print_error "Incorrect. Try again. (Use: exit)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  dracut: Switching root to /sysroot"
    echo "  systemd: Continuing boot (simulated)..."
    echo

    # --- Now we're in the running system; persistently fix the mismatch ---
    echo "  Step 8: Verify the root filesystem is mounted from the 'sysroot' LV."
    read -p "  lab@lab182:~$ " cmd8
    echo
    if [[ "$cmd8" != "findmnt /" ]]; then
        print_error "Incorrect. Try again. (Use: findmnt /)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  TARGET SOURCE                   FSTYPE OPTIONS"
    echo "  /      /dev/mapper/rhel-sysroot xfs    rw,relatime"
    echo

    echo "  Step 9: Rename the LV back to 'root' so it matches the kernel args."
    read -p "  lab@lab182:~$ " cmd9
    echo
    if [[ "$cmd9" != "lvrename rhel sysroot root" ]]; then
        print_error "Incorrect. Try again. (Use: lvrename rhel sysroot root)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Renamed \"sysroot\" to \"root\" in volume group \"rhel\""
    echo

    echo "  Step 10: Confirm the LV has the expected name."
    read -p "  lab@lab182:~$ " cmd10
    echo
    if [[ "$cmd10" != "lvs rhel" && "$cmd10" != "lvs" ]]; then
        print_error "Incorrect. Try again. (Use: lvs rhel)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  LV    VG   Attr       LSize"
    echo "  root  rhel -wi-ao----  20.0g"
    echo "  swap  rhel -wi-ao----   2.0g"
    echo

    echo "  Step 11: Check if /etc/fstab references the old name and update if needed."
    read -p "  lab@lab182:~$ " cmd11
    echo
    if [[ "$cmd11" != "grep -E '(/dev/mapper/rhel-sysroot|/dev/rhel/sysroot)' /etc/fstab" ]]; then
        print_error "Incorrect. Try again. (Use: grep -E '(/dev/mapper/rhel-sysroot|/dev/rhel/sysroot)' /etc/fstab)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  /dev/mapper/rhel-sysroot  /  xfs  defaults  0  1"
    echo

    echo "  Step 12: Replace the old mapper path with the new one."
    read -p "  lab@lab182:~$ " cmd12
    echo
    if [[ "$cmd12" != "sed -i 's/rhel-sysroot/rhel-root/' /etc/fstab" ]]; then
        print_error "Incorrect. Try again. (Use: sed -i 's/rhel-sysroot/rhel-root/' /etc/fstab)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    echo "  Step 13: Verify the corrected fstab root line."
    read -p "  lab@lab182:~$ " cmd13
    echo
    if [[ "$cmd13" != "grep -E '\\s/\\s' /etc/fstab" ]]; then
        print_error "Incorrect. Try again. (Use: grep -E '\\s/\\s' /etc/fstab )"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  /dev/mapper/rhel-root  /  xfs  defaults  0  1"
    echo

    echo "  Step 14: (Good practice) Regenerate the GRUB configuration."
    read -p "  lab@lab182:~$ " cmd14
    echo
    if [[ "$cmd14" != "grub2-mkconfig -o /boot/grub2/grub.cfg" ]]; then
        print_error "Incorrect. Try again. (Use: grub2-mkconfig -o /boot/grub2/grub.cfg)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Generating grub configuration file ..."
    echo "  Found linux image: /boot/vmlinuz-<KERNEL-VERSION>"
    echo "  Found initrd image: /boot/initramfs-<KERNEL-VERSION>.img"
    echo "  done"
    echo

    echo "  Note: Alternatively, instead of renaming the LV, you could persistently change"
    echo "        the kernel args to 'rd.lvm.lv=rhel/sysroot' using 'grubby --update-kernel ALL'."
    echo

    echo "  Step 15: Reboot to validate clean boot without emergency shell."
    read -p "  lab@lab182:~$ " cmd15
    echo
    if [[ "$cmd15" != "reboot" && "$cmd15" != "reboot -f" ]]; then
        print_error "Incorrect. Try again. (Use: reboot)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Rebooting (simulated)..."
    echo "  System boots normally. Kernel finds 'rhel/root' without manual intervention (simulated)."
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
