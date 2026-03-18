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
    echo
    echo
    echo
}

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Scenario: The system dropped into the dracut emergency shell during boot."
    center_text "Goal: Review boot diagnostics, activate LVM, mount the real root at /sysroot,"
    center_text "and continue the boot process successfully."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Show the current kernel command line so you can verify boot parameters."
    read -p "  dracut:/# " cmd1
    echo
    if [[ "$cmd1" != "cat /proc/cmdline" ]]; then
        print_error "Incorrect. Try again. (Use: cat /proc/cmdline)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  BOOT_IMAGE=(hd0,gpt2)/vmlinuz-5.14.0-503.35.1.el9_5.x86_64 root=/dev/mapper/rhel-root ro rd.lvm.lv=rhel/root rd.lvm.lv=rhel/swap rhgb quiet"
    echo

    echo "  Step 2: Review detailed diagnostics from the current failed boot."
    read -p "  dracut:/# " cmd2
    echo
    if [[ "$cmd2" != "journalctl -xb" ]]; then
        print_error "Incorrect. Try again. (Use: journalctl -xb)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Mar 12 08:14:21 localhost kernel: XFS (dm-0): Mounting V5 Filesystem"
    echo "  Mar 12 08:14:21 localhost systemd[1]: Starting Dracut Emergency Shell..."
    echo "  Mar 12 08:14:21 localhost dracut-initqueue[643]: Warning: dracut-initqueue timeout - starting timeout scripts"
    echo "  Mar 12 08:14:21 localhost dracut-initqueue[643]: Warning: Could not boot."
    echo "  Mar 12 08:14:21 localhost dracut-initqueue[643]: Warning: /dev/mapper/rhel-root does not exist"
    echo "  Mar 12 08:14:21 localhost systemd[1]: sysroot.mount: Mount process exited, code=exited, status=32"
    echo "  Mar 12 08:14:21 localhost systemd[1]: sysroot.mount: Failed with result 'exit-code'."
    echo "  Mar 12 08:14:21 localhost systemd[1]: Failed to mount /sysroot."
    echo "  Mar 12 08:14:21 localhost dracut[842]: Warning: /dev/rhel/root does not exist"
    echo "  Mar 12 08:14:21 localhost dracut[842]: Warning: /dev/mapper/rhel-root does not exist"
    echo "  Mar 12 08:14:21 localhost dracut[842]: Refusing to continue"
    echo "  Mar 12 08:14:21 localhost systemd[1]: Started Dracut Emergency Shell."
    echo "  Hint: a full report is available at /run/initramfs/rdsosreport.txt"
    echo

    echo "  Step 3: Inspect the dracut SOS report for a more focused summary."
    read -p "  dracut:/# " cmd3
    echo
    if [[ "$cmd3" != "head -n 15 /run/initramfs/rdsosreport.txt" ]]; then
        print_error "Incorrect. Try again. (Use: head -n 15 /run/initramfs/rdsosreport.txt)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  ============================================================"
    echo "  dracut-055-12.git20240104.el9"
    echo "  dracut module 'systemd'"
    echo "  kernel command line:"
    echo "    BOOT_IMAGE=(hd0,gpt2)/vmlinuz-5.14.0-503.35.1.el9_5.x86_64 root=/dev/mapper/rhel-root ro rd.lvm.lv=rhel/root rd.lvm.lv=rhel/swap rhgb quiet"
    echo "  devices scanned:"
    echo "    /dev/sda1"
    echo "    /dev/sda2"
    echo "  lvm:"
    echo "    volume group \"rhel\" present but not activated"
    echo "  mount:"
    echo "    mount: /sysroot: special device /dev/mapper/rhel-root does not exist"
    echo "  ============================================================"
    echo

    echo "  Step 4: List block devices so you can see the underlying disk layout."
    read -p "  dracut:/# " cmd4
    echo
    if [[ "$cmd4" != "lsblk" ]]; then
        print_error "Incorrect. Try again. (Use: lsblk)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  NAME          MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS"
    echo "  sda             8:0    0   40G  0 disk"
    echo "  ├─sda1          8:1    0    1G  0 part"
    echo "  └─sda2          8:2    0   39G  0 part"
    echo "  No mapper devices are currently active."
    echo

    echo "  Step 5: Scan for available LVM volume groups."
    read -p "  dracut:/# " cmd5
    echo
    if [[ "$cmd5" != "vgscan" ]]; then
        print_error "Incorrect. Try again. (Use: vgscan)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  WARNING: Running as a single process."
    echo "  Reading volume groups from cache."
    echo "  Found volume group \"rhel\" using metadata type lvm2"
    echo

    echo "  Step 6: Activate all logical volumes in the detected volume groups."
    read -p "  dracut:/# " cmd6
    echo
    if [[ "$cmd6" != "vgchange -ay" ]]; then
        print_error "Incorrect. Try again. (Use: vgchange -ay)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  2 logical volume(s) in volume group \"rhel\" now active"
    echo

    echo "  Step 7: List logical volumes to confirm the expected root LV exists."
    read -p "  dracut:/# " cmd7
    echo
    if [[ "$cmd7" != "lvs" ]]; then
        print_error "Incorrect. Try again. (Use: lvs)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  LV   VG   Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert"
    echo "  root rhel -wi-ao---- 34.00g"
    echo "  swap rhel -wi-ao----  4.00g"
    echo

    echo "  Step 8: Identify the filesystem type on /dev/mapper/rhel-root before mounting it."
    read -p "  dracut:/# " cmd8
    echo
    if [[ "$cmd8" != "blkid /dev/mapper/rhel-root" ]]; then
        print_error "Incorrect. Try again. (Use: blkid /dev/mapper/rhel-root)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  /dev/mapper/rhel-root: UUID=\"6f7d7d4d-9d95-47df-a7e2-4a3d58fd97b1\" BLOCK_SIZE=\"512\" TYPE=\"xfs\""
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

    echo "  Step 10: Verify that the operating system tree is present under /sysroot."
    read -p "  dracut:/# " cmd10
    echo
    if [[ "$cmd10" != "ls /sysroot" ]]; then
        print_error "Incorrect. Try again. (Use: ls /sysroot)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  afs  bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var"
    echo

    echo "  Step 11: Exit the dracut shell so the boot process can continue."
    read -p "  dracut:/# " cmd11
    echo
    if [[ "$cmd11" != "exit" ]]; then
        print_error "Incorrect. Try again. (Use: exit)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  exit"
    echo "  Warning: /sysroot is mounted read-only."
    echo "  Switching root."
    echo "  [  OK  ] Started NetworkManager-wait-online.service."
    echo "  [  OK  ] Reached target Multi-User System."
    echo "  [  OK  ] Started GNOME Display Manager."
    echo

    echo "  Step 12: After boot completes, confirm the system is fully operational."
    read -p "  lab@lab181:~$ " cmd12
    echo
    if [[ "$cmd12" != "systemctl is-system-running" ]]; then
        print_error "Incorrect. Try again. (Use: systemctl is-system-running)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  running"
    echo

    echo "  Step 13: Verify that the root filesystem is mounted from the expected device."
    read -p "  lab@lab181:~$ " cmd13
    echo
    if [[ "$cmd13" != "findmnt /" ]]; then
        print_error "Incorrect. Try again. (Use: findmnt /)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  TARGET SOURCE                    FSTYPE OPTIONS"
    echo "  /      /dev/mapper/rhel-root     xfs    rw,relatime,seclabel,attr2,inode64,logbufs=8,logbsize=32k,prjquota"
    echo

    echo "  Step 14: Confirm the LVM volumes remain active after the system comes up."
    read -p "  lab@lab181:~$ " cmd14
    echo
    if [[ "$cmd14" != "lvs rhel" && "$cmd14" != "lvs" ]]; then
        print_error "Incorrect. Try again. (Use: lvs)"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  LV   VG   Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert"
    echo "  root rhel -wi-ao---- 34.00g"
    echo "  swap rhel -wi-ao----  4.00g"
    echo

    print_success "Nice work!"
    print_info "You earned $LAB_XP XP for completing this lab."
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
    read -p "  > " post_choice
    [[ "$post_choice" == "2" ]] && exit 0
done