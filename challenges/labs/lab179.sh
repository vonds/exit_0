#!/bin/bash

# Lab 179: Fix Wrong Root Mapping (root=/ rd.lvm.lv=, /etc/fstab UUID)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 179: Fix Wrong Root Mapping"
LAB_ID="lab179"
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
    center_text "Scenario: System fails to boot because the kernel cmdline points to the wrong root device."
    center_text "Goal: Discover the correct LVM root, boot by fixing GRUB args (rd.lvm.lv & root=), then fix /etc/fstab."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    # --- Boot failure lands in dracut emergency shell ---
    draw_lab_ui
    echo "  The system has dropped to the initramfs emergency shell (simulated)."
    echo "  dracut:/#"
    echo

    echo "  Step 1: Show the current kernel command line to confirm the wrong root mapping."
    read -p "  dracut:/# " cmd1
    echo
    if [[ "$cmd1" != "cat /proc/cmdline" ]]; then
        print_error "Incorrect. Try again. (Use: cat /proc/cmdline)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  BOOT_IMAGE=/vmlinuz-<KERNEL> root=/dev/sda2 ro rhgb quiet"
    echo "  (Problem: root points to /dev/sda2 but this system uses LVM.)"
    echo

    echo "  Step 2: Activate LVM volumes."
    read -p "  dracut:/# " cmd2
    echo
    if [[ "$cmd2" != "vgchange -ay" ]]; then
        print_error "Incorrect. Try again. (Use: vgchange -ay)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  2 logical volume(s) in volume group \"rhel\" now active"
    echo

    echo "  Step 3: List logical volumes to identify the root LV."
    read -p "  dracut:/# " cmd3
    echo
    if [[ "$cmd3" != "lvs" ]]; then
        print_error "Incorrect. Try again. (Use: lvs)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  LV    VG   Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert"
    echo "  root  rhel -wi-ao----  20.0g"
    echo "  swap  rhel -wi-ao----   2.0g"
    echo

    echo "  Step 4: Mount the suspected root LV to verify it contains the OS."
    read -p "  dracut:/# " cmd4
    echo
    if [[ "$cmd4" != "mount /dev/mapper/rhel-root /mnt" ]]; then
        print_error "Incorrect. Try again. (Use: mount /dev/mapper/rhel-root /mnt)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    echo "  Step 5: Confirm standard directories exist on the mounted root."
    read -p "  dracut:/# " cmd5
    echo
    if [[ "$cmd5" != "ls /mnt" ]]; then
        print_error "Incorrect. Try again. (Use: ls /mnt)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  bin  boot  etc  home  lib  lib64  root  sbin  usr  var"
    echo

    echo "  Step 6: Reboot to the GRUB menu so we can fix kernel args (temporary)."
    read -p "  dracut:/# " cmd6
    echo
    if [[ "$cmd6" != "reboot -f" && "$cmd6" != "reboot" ]]; then
        print_error "Incorrect. Try again. (Use: reboot -f)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Rebooting (simulated) to GRUB menu..."
    echo

    # --- GRUB menu edit to boot successfully ---
    echo "  Step 7: At the GRUB menu, enter edit mode for the selected entry."
    read -p "  grub menu> " cmd7
    echo
    if [[ "$cmd7" != "e" && "$cmd7" != "E" ]]; then
        print_error "Incorrect. Try again. (Press: e)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  GRUB editor opened. Locate the 'linux' line."
    echo "    linux /vmlinuz-<KERNEL> root=/dev/sda2 ro rhgb quiet"
    echo

    echo "  Step 8: Add the LVM hint so initramfs can find the root LV."
    echo "          (Type exactly the argument to add.)"
    read -p "  grub edit> " cmd8
    echo
    if [[ "$cmd8" != "rd.lvm.lv=rhel/root" ]]; then
        print_error "Incorrect. Try again. (Use: rd.lvm.lv=rhel/root)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  linux ... root=/dev/sda2 ro rhgb quiet rd.lvm.lv=rhel/root"
    echo

    echo "  Step 9: Replace the incorrect root device with the LVM mapper path."
    echo "          (Type exactly the new root= value.)"
    read -p "  grub edit> " cmd9
    echo
    if [[ "$cmd9" != "root=/dev/mapper/rhel-root" ]]; then
        print_error "Incorrect. Try again. (Use: root=/dev/mapper/rhel-root)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  linux ... root=/dev/mapper/rhel-root ro rhgb quiet rd.lvm.lv=rhel/root"
    echo

    echo "  Step 10: Boot the edited entry."
    read -p "  grub edit> " cmd10
    echo
    if [[ "$cmd10" != "Ctrl+x" && "$cmd10" != "ctrl+x" && "$cmd10" != "F10" && "$cmd10" != "f10" ]]; then
        print_error "Incorrect. Try again. (Use: Ctrl+x or F10)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Loading Linux kernel ..."
    echo "  Loading initial ramdisk ..."
    echo "  System booted successfully (simulated)."
    echo

    # --- Persistently fix /etc/fstab so future boots work without edits ---
    echo "  Step 11: Get the UUID of the root LV to use in /etc/fstab."
    read -p "  lab@lab179:~$ " cmd11
    echo
    if [[ "$cmd11" != "blkid -s UUID -o value /dev/mapper/rhel-root" ]]; then
        print_error "Incorrect. Try again. (Use: blkid -s UUID -o value /dev/mapper/rhel-root)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  UUID-ROOT-PLACEHOLDER"
    echo

    echo "  Step 12: Back up the current /etc/fstab."
    read -p "  lab@lab179:~$ " cmd12
    echo
    if [[ "$cmd12" != "cp /etc/fstab /etc/fstab.bak" ]]; then
        print_error "Incorrect. Try again. (Use: cp /etc/fstab /etc/fstab.bak)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    echo "  Step 13: Replace the wrong root UUID in /etc/fstab with the correct one."
    echo "           (Simulated wrong ID: WRONG-UUID; correct: UUID-ROOT-PLACEHOLDER)"
    read -p "  lab@lab179:~$ " cmd13
    echo
    if [[ "$cmd13" != "sed -i 's/WRONG-UUID/UUID-ROOT-PLACEHOLDER/' /etc/fstab" ]]; then
        print_error "Incorrect. Try again. (Use: sed -i 's/WRONG-UUID/UUID-ROOT-PLACEHOLDER/' /etc/fstab)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    echo "  Step 14: Show the root (/) line in /etc/fstab to confirm it uses the new UUID."
    read -p "  lab@lab179:~$ " cmd14
    echo
    if [[ "$cmd14" != "grep -E '^[^#].*\\s/\\s' /etc/fstab" ]]; then
        print_error "Incorrect. Try again. (Use: grep -E '^[^#].*\\s/\\s' /etc/fstab )"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  UUID=UUID-ROOT-PLACEHOLDER  /  xfs  defaults  0  1"
    echo

    echo "  Step 15: Regenerate GRUB configuration (good practice after boot fixes)."
    read -p "  lab@lab179:~$ " cmd15
    echo
    if [[ "$cmd15" != "grub2-mkconfig -o /boot/grub2/grub.cfg" ]]; then
        print_error "Incorrect. Try again. (Use: grub2-mkconfig -o /boot/grub2/grub.cfg)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Generating grub configuration file ..."
    echo "  Found linux image: /boot/vmlinuz-<KERNEL>"
    echo "  Found initrd image: /boot/initramfs-<KERNEL>.img"
    echo "  done"
    echo

    echo "  Step 16: Reboot to verify the system now boots cleanly without GRUB edits."
    read -p "  lab@lab179:~$ " cmd16
    echo
    if [[ "$cmd16" != "reboot" && "$cmd16" != "reboot -f" ]]; then
        print_error "Incorrect. Try again. (Use: reboot)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Rebooting (simulated). System boots normally with correct root mapping."
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
