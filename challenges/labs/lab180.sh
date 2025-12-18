#!/bin/bash

# Lab 180: Rebuild Broken/Missing initramfs with dracut (+hostonly vs full), then regen GRUB

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 180: Rebuild initramfs with dracut"
LAB_ID="lab180"
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
    center_text "Scenario: Boot failed because the initramfs is missing/broken (dropped to dracut shell)."
    center_text "Goal: Mount, chroot, rebuild initramfs with dracut (hostonly & full), verify, regen GRUB, reboot."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    # --- You are in a rescue/live environment now (not the installed OS) ---
    draw_lab_ui
    echo "  You are in a rescue shell with the installed system's disks attached (simulated)."
    echo

    echo "  Step 1: List block devices to identify the LVM PV and any /boot partition."
    read -p "  rescue# " cmd1
    echo
    if [[ "$cmd1" != "lsblk" ]]; then
        print_error "Incorrect. Try again. (Use: lsblk)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  NAME              MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS"
    echo "  sda                 8:0    0   40G  0 disk"
    echo "  ├─sda1              8:1    0  512M  0 part"
    echo "  └─sda2              8:2    0 39.5G  0 part"
    echo "    └─rhel-root     253:0    0   38G  0 lvm"
    echo

    echo "  Step 2: Activate the volume group so LVs become available."
    read -p "  rescue# " cmd2
    echo
    if [[ "$cmd2" != "vgchange -ay" && "$cmd2" != "lvm vgchange -ay" ]]; then
        print_error "Incorrect. Try again. (Use: vgchange -ay)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  1 logical volume(s) in volume group \"rhel\" now active"
    echo

    echo "  Step 3: Mount the root LV at /mnt/sysroot."
    read -p "  rescue# " cmd3
    echo
    if [[ "$cmd3" != "mount /dev/mapper/rhel-root /mnt/sysroot" ]]; then
        print_error "Incorrect. Try again. (Use: mount /dev/mapper/rhel-root /mnt/sysroot)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    echo "  Step 4: If /boot is separate, mount it inside the sysroot."
    read -p "  rescue# " cmd4
    echo
    if [[ "$cmd4" != "mount /dev/sda1 /mnt/sysroot/boot" ]]; then
        print_error "Incorrect. Try again. (Use: mount /dev/sda1 /mnt/sysroot/boot)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    echo "  Step 5: Bind-mount /dev, /proc, /sys, and /run for a functional chroot."
    read -p "  rescue# " cmd5
    echo
    if [[ "$cmd5" != "mount --bind /dev /mnt/sysroot/dev && mount --bind /proc /mnt/sysroot/proc && mount --bind /sys /mnt/sysroot/sys && mount --bind /run /mnt/sysroot/run" ]]; then
        print_error "Incorrect. Try again. (Use: mount --bind /dev /mnt/sysroot/dev && mount --bind /proc /mnt/sysroot/proc && mount --bind /sys /mnt/sysroot/sys && mount --bind /run /mnt/sysroot/run)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    echo "  Step 6: Chroot into the installed system."
    read -p "  rescue# " cmd6
    echo
    if [[ "$cmd6" != "chroot /mnt/sysroot" ]]; then
        print_error "Incorrect. Try again. (Use: chroot /mnt/sysroot)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  chroot#"
    echo

    echo "  Step 7: Determine the running kernel version of this installation."
    read -p "  chroot# " cmd7
    echo
    if [[ "$cmd7" != "uname -r" ]]; then
        print_error "Incorrect. Try again. (Use: uname -r)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  <KERNEL-VERSION>"
    echo

    echo "  Step 8: Verify if the initramfs for this kernel exists (expect missing/broken)."
    read -p "  chroot# " cmd8
    echo
    if [[ "$cmd8" != "ls -l /boot/initramfs-<KERNEL-VERSION>.img" ]]; then
        print_error "Incorrect. Try again. (Use: ls -l /boot/initramfs-<KERNEL-VERSION>.img)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  ls: cannot access '/boot/initramfs-<KERNEL-VERSION>.img': No such file or directory"
    echo

    echo "  Step 9: Rebuild a hostonly initramfs for the current kernel (hardware-specific)."
    read -p "  chroot# " cmd9
    echo
    if [[ "$cmd9" != "dracut -f -v" && "$cmd9" != "dracut -f -v --kver $(uname -r)" ]]; then
        print_error "Incorrect. Try again. (Use: dracut -f -v)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  dracut: Executing: /usr/bin/dracut -f -v"
    echo "  dracut: dracut module 'lvm' will be installed"
    echo "  dracut: Including drivers: dm-mod sd_mod xfs"
    echo "  dracut: Installing kernel module dependencies"
    echo "  dracut: *** Creating initramfs image file '/boot/initramfs-<KERNEL-VERSION>.img' ***"
    echo "  dracut: *** Creating image file done ***"
    echo

    echo "  Step 10: Inspect the image to ensure required modules/hooks are present."
    read -p "  chroot# " cmd10
    echo
    if [[ "$cmd10" != "lsinitrd /boot/initramfs-<KERNEL-VERSION>.img | head -n 10" && "$cmd10" != "lsinitrd /boot/initramfs-<KERNEL-VERSION>.img | head" ]]; then
        print_error "Incorrect. Try again. (Use: lsinitrd /boot/initramfs-<KERNEL-VERSION>.img | head -n 10)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Image: /boot/initramfs-<KERNEL-VERSION>.img:  (gzip compressed data)"
    echo "  dracut/modules.d/90lvm/"
    echo "  dracut/modules.d/90lvm/lvm.sh"
    echo "  usr/lib/modprobe.d/"
    echo "  lib/modules/<KERNEL-VERSION>/kernel/drivers/md/dm-mod.ko.xz"
    echo

    echo "  Step 11: (Optional) Build a generic/full initramfs (not host-only) for broader hardware."
    read -p "  chroot# " cmd11
    echo
    if [[ "$cmd11" != "dracut -f -v --no-hostonly" && "$cmd11" != "dracut -f -v --no-hostonly --kver $(uname -r)" ]]; then
        print_error "Incorrect. Try again. (Use: dracut -f -v --no-hostonly)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  dracut: Executing: /usr/bin/dracut -f -v --no-hostonly"
    echo "  dracut: Hostonly disabled; including broad driver set"
    echo "  dracut: *** Recreating initramfs '/boot/initramfs-<KERNEL-VERSION>.img' ***"
    echo "  dracut: *** Creating image file done ***"
    echo

    echo "  Step 12: Regenerate the GRUB configuration to ensure entries reference the image."
    read -p "  chroot# " cmd12
    echo
    if [[ "$cmd12" != "grub2-mkconfig -o /boot/grub2/grub.cfg" ]]; then
        print_error "Incorrect. Try again. (Use: grub2-mkconfig -o /boot/grub2/grub.cfg)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Generating grub configuration file ..."
    echo "  Found linux image: /boot/vmlinuz-<KERNEL-VERSION>"
    echo "  Found initrd image: /boot/initramfs-<KERNEL-VERSION>.img"
    echo "  done"
    echo

    echo "  Step 13: Exit the chroot."
    read -p "  chroot# " cmd13
    echo
    if [[ "$cmd13" != "exit" ]]; then
        print_error "Incorrect. Try again. (Use: exit)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  rescue#"
    echo

    echo "  Step 14: Unmount bind mounts and filesystems."
    read -p "  rescue# " cmd14
    echo
    if [[ "$cmd14" != "umount /mnt/sysroot/run /mnt/sysroot/sys /mnt/sysroot/proc /mnt/sysroot/dev" && "$cmd14" != "umount /mnt/sysroot/run && umount /mnt/sysroot/sys && umount /mnt/sysroot/proc && umount /mnt/sysroot/dev" ]]; then
        print_error "Incorrect. Try again. (Use: umount /mnt/sysroot/run /mnt/sysroot/sys /mnt/sysroot/proc /mnt/sysroot/dev)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    echo "  Step 15: Unmount /boot (if mounted) and the root mountpoint."
    read -p "  rescue# " cmd15
    echo
    if [[ "$cmd15" != "umount /mnt/sysroot/boot && umount /mnt/sysroot" ]]; then
        print_error "Incorrect. Try again. (Use: umount /mnt/sysroot/boot && umount /mnt/sysroot)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    echo "  Step 16: Reboot to test the new initramfs."
    read -p "  rescue# " cmd16
    echo
    if [[ "$cmd16" != "reboot" && "$cmd16" != "reboot -f" ]]; then
        print_error "Incorrect. Try again. (Use: reboot)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Rebooting (simulated)."
    echo "  System boots successfully using the rebuilt initramfs (simulated)."
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
