#!/bin/bash

# Lab 178: Reinstall GRUB (UEFI) from Rescue Chroot

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 178: Reinstall GRUB (UEFI) from Rescue Chroot"
LAB_ID="lab178"
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
    center_text "Scenario: GRUB is broken on a UEFI system."
    center_text "Goal: Mount root and the EFI System Partition (ESP), chroot, reinstall GRUB (UEFI),"
    center_text "      regenerate grub.cfg, verify NVRAM entry, and reboot."
    echo
    center_text "Assumptions: root is /dev/sda2; ESP is /dev/sda1 and will be mounted at /boot/efi."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    # --- In rescue/live environment ---
    draw_lab_ui
    echo "  You are in a rescue shell with the installed system's disks attached."
    echo

    echo "  Step 1: List block devices to identify root and the EFI System Partition."
    read -p "  rescue# " cmd1
    echo
    if [[ "$cmd1" != "lsblk" ]]; then
        print_error "Incorrect. Try again. (Use: lsblk)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS"
    echo "  sda      8:0    0   <SIZE> 0 disk"
    echo "  ├─sda1   8:1    0   512M  0 part"
    echo "  └─sda2   8:2    0   <SIZE> 0 part"
    echo

    echo "  Step 2: Mount the root filesystem at /mnt/sysroot."
    read -p "  rescue# " cmd2
    echo
    if [[ "$cmd2" != "mount /dev/sda2 /mnt/sysroot" ]]; then
        print_error "Incorrect. Try again. (Use: mount /dev/sda2 /mnt/sysroot)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    echo "  Step 3: Ensure the ESP mountpoint exists and mount the ESP at /mnt/sysroot/boot/efi."
    read -p "  rescue# " cmd3
    echo
    if [[ "$cmd3" != "mkdir -p /mnt/sysroot/boot/efi && mount /dev/sda1 /mnt/sysroot/boot/efi" ]]; then
        print_error "Incorrect. Try again. (Use: mkdir -p /mnt/sysroot/boot/efi && mount /dev/sda1 /mnt/sysroot/boot/efi)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    echo "  Step 4: Bind-mount /dev, /proc, /sys, and /run into the chroot."
    read -p "  rescue# " cmd4
    echo
    if [[ "$cmd4" != "mount --bind /dev /mnt/sysroot/dev && mount --bind /proc /mnt/sysroot/proc && mount --bind /sys /mnt/sysroot/sys && mount --bind /run /mnt/sysroot/run" ]]; then
        print_error "Incorrect. Try again. (Use: mount --bind /dev /mnt/sysroot/dev && mount --bind /proc /mnt/sysroot/proc && mount --bind /sys /mnt/sysroot/sys && mount --bind /run /mnt/sysroot/run)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    echo "  Step 5: Chroot into the installed system."
    read -p "  rescue# " cmd5
    echo
    if [[ "$cmd5" != "chroot /mnt/sysroot" ]]; then
        print_error "Incorrect. Try again. (Use: chroot /mnt/sysroot)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  chroot#"
    echo

    echo "  Step 6: Reinstall GRUB for UEFI to the ESP."
    echo "          (Use --target x86_64-efi, --efi-directory /boot/efi, and a bootloader-id.)"
    read -p "  chroot# " cmd6
    echo
    if [[ "$cmd6" != "grub2-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=RHEL" && "$cmd6" != "grub2-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=redhat" ]]; then
        print_error "Incorrect. Try again. (Example: grub2-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=RHEL)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Installing for x86_64-efi platform."
    echo "  Installation finished. No error reported."
    echo

    echo "  Step 7: Regenerate the GRUB configuration file."
    read -p "  chroot# " cmd7
    echo
    if [[ "$cmd7" != "grub2-mkconfig -o /boot/grub2/grub.cfg" ]]; then
        print_error "Incorrect. Try again. (Use: grub2-mkconfig -o /boot/grub2/grub.cfg)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Generating grub configuration file ..."
    echo "  Found linux image: /boot/vmlinuz-<KERNEL-VERSION>"
    echo "  Found initrd image: /boot/initramfs-<KERNEL-VERSION>.img"
    echo "  done"
    echo

    echo "  Step 8: Verify the EFI binaries now exist on the ESP."
    read -p "  chroot# " cmd8
    echo
    if [[ "$cmd8" != "ls -l /boot/efi/EFI" ]]; then
        print_error "Incorrect. Try again. (Use: ls -l /boot/efi/EFI)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  total <N>"
    echo "  drwxr-xr-x 2 root root <BYTES> <DATE> RHEL"
    echo

    echo "  Step 9: Inspect the vendor directory for GRUB/shim binaries."
    read -p "  chroot# " cmd9
    echo
    if [[ "$cmd9" != "ls -l /boot/efi/EFI/RHEL" && "$cmd9" != "ls -l /boot/efi/EFI/redhat" ]]; then
        print_error "Incorrect. Try again. (Use: ls -l /boot/efi/EFI/RHEL)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  -rw-r--r-- 1 root root <BYTES> <DATE> grubx64.efi"
    echo "  -rw-r--r-- 1 root root <BYTES> <DATE> shimx64.efi"
    echo

    echo "  Step 10: Create/verify an NVRAM boot entry pointing to the loader."
    read -p "  chroot# " cmd10
    echo
    if [[ "$cmd10" != "efibootmgr -v" ]]; then
        print_error "Incorrect. Try again. (Use: efibootmgr -v)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Boot0001* RHEL    HD(1,GPT,<UUID>,0x800,0x100000)  File(\\EFI\\RHEL\\shimx64.efi)"
    echo

    echo "  Step 11: (Optional) Install a UEFI fallback loader."
    read -p "  chroot# " cmd11
    echo
    if [[ "$cmd11" != "cp /boot/efi/EFI/RHEL/shimx64.efi /boot/efi/EFI/BOOT/BOOTX64.EFI" && "$cmd11" != "cp /boot/efi/EFI/redhat/shimx64.efi /boot/efi/EFI/BOOT/BOOTX64.EFI" ]]; then
        print_error "Incorrect. Try again. (Use: cp /boot/efi/EFI/RHEL/shimx64.efi /boot/efi/EFI/BOOT/BOOTX64.EFI)"
        read -p "Press Enter to try again..." _
        continue
    fi
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

    echo "  Step 13: Unmount bind mounts (/run, /sys, /proc, /dev)."
    read -p "  rescue# " cmd13
    echo
    if [[ "$cmd13" != "umount /mnt/sysroot/run /mnt/sysroot/sys /mnt/sysroot/proc /mnt/sysroot/dev" && "$cmd13" != "umount /mnt/sysroot/run && umount /mnt/sysroot/sys && umount /mnt/sysroot/proc && umount /mnt/sysroot/dev" ]]; then
        print_error "Incorrect. Try again. (Use: umount /mnt/sysroot/run /mnt/sysroot/sys /mnt/sysroot/proc /mnt/sysroot/dev)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    echo "  Step 14: Unmount the ESP and the root mountpoint."
    read -p "  rescue# " cmd14
    echo
    if [[ "$cmd14" != "umount /mnt/sysroot/boot/efi && umount /mnt/sysroot" ]]; then
        print_error "Incorrect. Try again. (Use: umount /mnt/sysroot/boot/efi && umount /mnt/sysroot)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    echo "  Step 15: Reboot to test the repaired UEFI bootloader."
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
