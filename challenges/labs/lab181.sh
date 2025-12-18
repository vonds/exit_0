#!/bin/bash

# Lab 181: Dracut Emergency Shell Triage (logs → storage → mount → continue)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 181: Dracut Emergency Shell Triage"
LAB_ID="lab181"
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
    center_text "Scenario: The system dropped to the dracut emergency shell."
    center_text "Goal: Inspect logs, activate storage (LVM), mount the real root at /sysroot, and continue boot."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    # --- You are at the dracut emergency shell ---
    draw_lab_ui
    echo "  The system is in the initramfs emergency environment (simulated)."
    echo "  dracut:/#"
    echo

    echo "  Step 1: Show the current kernel command line."
    read -p "  dracut:/# " cmd1
    echo
    if [[ "$cmd1" != "cat /proc/cmdline" ]]; then
        print_error "Incorrect. Try again. (Use: cat /proc/cmdline)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  BOOT_IMAGE=/vmlinuz-<KERNEL> root=UUID=<ROOT-UUID> ro rd.lvm.lv=rhel/root rhgb quiet"
    echo

    echo "  Step 2: Review boot diagnostics from the current boot."
    read -p "  dracut:/# " cmd2
    echo
    if [[ "$cmd2" != "journalctl -xb" ]]; then
        print_error "Incorrect. Try again. (Use: journalctl -xb)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  dracut: Timed out waiting for device /dev/mapper/rhel-root"
    echo "  systemd: Failed to mount /sysroot."
    echo "  dracut: Entering emergency mode."
    echo "  Hint: A detailed report is saved at /run/initramfs/rdsosreport.txt"
    echo

    echo "  Step 3: Inspect the dracut SOS report (first lines)."
    read -p "  dracut:/# " cmd3
    echo
    if [[ "$cmd3" != "head -n 15 /run/initramfs/rdsosreport.txt" ]]; then
        print_error "Incorrect. Try again. (Use: head -n 15 /run/initramfs/rdsosreport.txt)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  ==== rdsosreport: collected diagnostics (truncated) ===="
    echo "  cmdline: ... rd.lvm.lv=rhel/root ..."
    echo "  lvm: PV(s) not yet active"
    echo "  mount: /sysroot: special device /dev/mapper/rhel-root does not exist"
    echo

    echo "  Step 4: List available disks and partitions."
    read -p "  dracut:/# " cmd4
    echo
    if [[ "$cmd4" != "lsblk" ]]; then
        print_error "Incorrect. Try again. (Use: lsblk)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT"
    echo "  sda           8:0    0   40G  0 disk"
    echo "  ├─sda1        8:1    0  512M  0 part"
    echo "  └─sda2        8:2    0 39.5G  0 part"
    echo

    echo "  Step 5: Scan for LVM volume groups."
    read -p "  dracut:/# " cmd5
    echo
    if [[ "$cmd5" != "vgscan" ]]; then
        print_error "Incorrect. Try again. (Use: vgscan)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Reading volume groups from cache."
    echo "  Found volume group \"rhel\" using metadata type lvm2"
    echo

    echo "  Step 6: Activate LVM volumes so the root LV appears."
    read -p "  dracut:/# " cmd6
    echo
    if [[ "$cmd6" != "vgchange -ay" ]]; then
        print_error "Incorrect. Try again. (Use: vgchange -ay)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  2 logical volume(s) in volume group \"rhel\" now active"
    echo

    echo "  Step 7: List logical volumes to confirm the root LV name."
    read -p "  dracut:/# " cmd7
    echo
    if [[ "$cmd7" != "lvs" ]]; then
        print_error "Incorrect. Try again. (Use: lvs)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  LV    VG   Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert"
    echo "  root  rhel -wi-ao----  20.0g"
    echo "  swap  rhel -wi-ao----   2.0g"
    echo

    echo "  Step 8: (Optional) Identify filesystem type of the root LV."
    read -p "  dracut:/# " cmd8
    echo
    if [[ "$cmd8" != "blkid /dev/mapper/rhel-root" ]]; then
        print_error "Incorrect. Try again. (Use: blkid /dev/mapper/rhel-root)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  /dev/mapper/rhel-root: UUID=\"<UUID>\" TYPE=\"xfs\""
    echo

    echo "  Step 9: Mount the real root filesystem read-only at /sysroot."
    read -p "  dracut:/# " cmd9
    echo
    if [[ "$cmd9" != "mount -o ro /dev/mapper/rhel-root /sysroot" ]]; then
        print_error "Incorrect. Try again. (Use: mount -o ro /dev/mapper/rhel-root /sysroot)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    echo "  Step 10: Verify that the OS tree is visible under /sysroot."
    read -p "  dracut:/# " cmd10
    echo
    if [[ "$cmd10" != "ls /sysroot" ]]; then
        print_error "Incorrect. Try again. (Use: ls /sysroot)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  bin  boot  etc  home  lib  lib64  root  sbin  usr  var"
    echo

    echo "  Step 11: Continue the boot process now that /sysroot is mounted."
    echo "           (Exit the emergency shell to let dracut proceed.)"
    read -p "  dracut:/# " cmd11
    echo
    if [[ "$cmd11" != "exit" ]]; then
        print_error "Incorrect. Try again. (Use: exit)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  dracut: Switching root to /sysroot"
    echo "  systemd: Continuing boot (simulated)..."
    echo

    echo "  Step 12: After boot, confirm the system is up to the default target."
    read -p "  lab@lab181:~$ " cmd12
    echo
    if [[ "$cmd12" != "systemctl is-system-running" ]]; then
        print_error "Incorrect. Try again. (Use: systemctl is-system-running)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  running"
    echo

    echo "  Step 13: Verify that the root filesystem is mounted and active."
    read -p "  lab@lab181:~$ " cmd13
    echo
    if [[ "$cmd13" != "findmnt /" ]]; then
        print_error "Incorrect. Try again. (Use: findmnt /)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  TARGET SOURCE                   FSTYPE OPTIONS"
    echo "  /      /dev/mapper/rhel-root    xfs    rw,relatime,attr2,inode64"
    echo

    echo "  Step 14: (Optional) Show that LVM volumes are still active post-boot."
    read -p "  lab@lab181:~$ " cmd14
    echo
    if [[ "$cmd14" != "lvs rhel" && "$cmd14" != "lvs" ]]; then
        print_error "Incorrect. Try again. (Use: lvs)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  LV    VG   Attr       LSize"
    echo "  root  rhel -wi-ao----  20.0g"
    echo "  swap  rhel -wi-ao----   2.0g"
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
