#!/bin/bash

# Lab 177: Reinstall GRUB (BIOS/MBR) from Rescue Chroot

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 177: Reinstall GRUB (BIOS/MBR) from Rescue Chroot"
LAB_ID="lab177"
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
    center_text "Scenario: GRUB is broken on a BIOS/MBR system."
    center_text "Goal: Chroot into the installed system, reinstall GRUB to /dev/sda, regenerate grub.cfg, and reboot."
    echo
    center_text "Assumptions: root is /dev/sda2 and /boot is a separate partition on /dev/sda1."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    # --- In rescue/live environment (not the installed OS) ---
    draw_lab_ui
    echo "  You are in a rescue shell with the installed system's disks attached."
    echo

    echo "  Step 1: List block devices to identify root and boot partitions."
    read -p "  rescue# " cmd1
    echo
    if [[ "$cmd1" != "lsblk" ]]; then
        print_error "Incorrect. Try again. (Use: lsblk)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS"
    echo "  sda      8:0    0   40G  0 disk"
    echo "  ├─sda1   8:1    0  512M  0 part"
    echo "  └─sda2   8:2    0 39.5G  0 part"
    echo

    echo "  Step 2: Mount the root filesystem at /mnt/sysroot."
    read -p "  rescue# " cmd2
    echo
    if [[ "$cmd2" != "mount /dev/sda2 /mnt/sysroot" ]]; then
        print_error "Incorrect. Try again. (Use: mount /dev/sda2 /mnt/sysroot)"
        read -p "Press Enter to try again..." _
        continue
    fi
    # (mount success typically has no output)
    echo

    echo "  Step 3: Mount the separate /boot partition inside the sysroot."
    read -p "  rescue# " cmd3
    echo
    if [[ "$cmd3" != "mount /dev/sda1 /mnt/sysroot/boot" ]]; then
        print_error "Incorrect. Try again. (Use: mount /dev/sda1 /mnt/sysroot/boot)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    echo "  Step 4: Bind-mount /dev into the chroot."
    read -p "  rescue# " cmd4
    echo
    if [[ "$cmd4" != "mount --bind /dev /mnt/sysroot/dev" ]]; then
        print_error "Incorrect. Try again. (Use: mount --bind /dev /mnt/sysroot/dev)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    echo "  Step 5: Bind-mount /proc and /sys into the chroot."
    read -p "  rescue# " cmd5
    echo
    if [[ "$cmd5" != "mount --bind /proc /mnt/sysroot/proc" ]]; then
        print_error "Incorrect. Try again. (Use: mount --bind /proc /mnt/sysroot/proc)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  (proc bound)"
    echo

    echo "  Step 6: Bind-mount /sys and /run into the chroot."
    read -p "  rescue# " cmd6
    echo
    if [[ "$cmd6" != "mount --bind /sys /mnt/sysroot/sys && mount --bind /run /mnt/sysroot/run" ]]; then
        print_error "Incorrect. Try again. (Use: mount --bind /sys /mnt/sysroot/sys && mount --bind /run /mnt/sysroot/run)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  (sys and run bound)"
    echo

    echo "  Step 7: Chroot into the installed system."
    read -p "  rescue# " cmd7
    echo
    if [[ "$cmd7" != "chroot /mnt/sysroot" ]]; then
        print_error "Incorrect. Try again. (Use: chroot /mnt/sysroot)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  chroot#"
    echo

    echo "  Step 8: Install GRUB to the MBR of the first disk (/dev/sda)."
    read -p "  chroot# " cmd8
    echo
    if [[ "$cmd8" != "grub2-install /dev/sda" ]]; then
        print_error "Incorrect. Try again. (Use: grub2-install /dev/sda)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Installing for i386-pc platform."
    echo "  Installation finished. No error reported."
    echo

    echo "  Step 9: Regenerate the GRUB configuration file."
    read -p "  chroot# " cmd9
    echo
    if [[ "$cmd9" != "grub2-mkconfig -o /boot/grub2/grub.cfg" ]]; then
        print_error "Incorrect. Try again. (Use: grub2-mkconfig -o /boot/grub2/grub.cfg)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Generating grub configuration file ..."
    echo "  Found linux image: /boot/vmlinuz-<KERNEL-VERSION>"
    echo "  Found initrd image: /boot/initramfs-<KERNEL-VERSION>.img"
    echo "  done"
    echo

    echo "  Step 10: Verify the GRUB config exists and is non-empty."
    read -p "  chroot# " cmd10
    echo
    if [[ "$cmd10" != "ls -lh /boot/grub2/grub.cfg" ]]; then
        print_error "Incorrect. Try again. (Use: ls -lh /boot/grub2/grub.cfg)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  -rw------- 1 root root <SIZE> <DATE> /boot/grub2/grub.cfg"
    echo

    echo "  Step 11: (Optional) Set the first menu entry as default for next boots."
    read -p "  chroot# " cmd11
    echo
    if [[ "$cmd11" != "grub2-set-default 0" ]]; then
        print_error "Incorrect. Try again. (Use: grub2-set-default 0)"
        read -p "Press Enter to try again..." _
        continue
    fi
    # grub2-set-default has no output on success
    echo

    echo "  Step 12: Exit the chroot."
    read -p "  chroot# " cmd12
    echo
    if [[ "$cmd12" != "exit" ]]; then
        print_error "Incorrect. Try again. (Use: exit)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  rescue#"
    echo

    echo "  Step 13: Unmount the bind mounts (run/sys/proc/dev)."
    read -p "  rescue# " cmd13
    echo
    if [[ "$cmd13" != "umount /mnt/sysroot/run /mnt/sysroot/sys /mnt/sysroot/proc /mnt/sysroot/dev" && "$cmd13" != "umount /mnt/sysroot/run && umount /mnt/sysroot/sys && umount /mnt/sysroot/proc && umount /mnt/sysroot/dev" ]]; then
        print_error "Incorrect. Try again. (Use: umount /mnt/sysroot/run /mnt/sysroot/sys /mnt/sysroot/proc /mnt/sysroot/dev)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    echo "  Step 14: Unmount /boot and the root mountpoint."
    read -p "  rescue# " cmd14
    echo
    if [[ "$cmd14" != "umount /mnt/sysroot/boot && umount /mnt/sysroot" ]]; then
        print_error "Incorrect. Try again. (Use: umount /mnt/sysroot/boot && umount /mnt/sysroot)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    echo "  Step 15: Reboot to test the repaired bootloader."
    read -p "  rescue# " cmd15
    echo
    if [[ "$cmd15" != "reboot" && "$cmd15" != "reboot -f" ]]; then
        print_error "Incorrect. Try again. (Use: reboot)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Rebooting (simulated)."
    echo "  System boots to GRUB menu and loads the default kernel (simulated)."
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
