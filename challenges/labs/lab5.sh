#!/bin/bash

# Lab 5: Investigate and Document the System Boot Process

# Dynamically locate root directory and source core scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 5: Investigate and Document the System Boot Process"
LAB_ID="lab5"
LAB_XP=2852
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
    center_text "Your client suspects their system takes too long to boot."
    center_text "You’ve been asked to investigate the boot sequence, identify"
    center_text "the bootloader, the kernel/init system, and capture details."
    echo
    center_text "Press Enter to begin the lab..."
    read _
    draw_lab_ui

    echo "  Step 1: What command shows the block devices and mount points?"
    read -p "  lab@lpic-lab5:~\$ > " cmd0
    echo

    if [[ "$cmd0" != "lsblk" ]]; then
        print_error "Incorrect. Hint: This command lists block devices."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT"
    echo "  sda      8:0    0   40G  0 disk "
    echo "  ├─sda1   8:1    0  512M  0 part /boot"
    echo "  └─sda2   8:2    0 39.5G  0 part /"
    echo

    echo "  Step 2: What command shows the files in the /boot directory?"
    read -p "  lab@lpic-lab5:~\$ > " cmd1
    echo

    if [[ "$cmd1" != "ls /boot" ]]; then
        print_error "Incorrect. Hint: Use 'ls' to inspect that directory."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  config-5.15.0-91-generic"
    echo "  initrd.img-5.15.0-91-generic"
    echo "  vmlinuz-5.15.0-91-generic"
    echo

    echo "  Step 3: What command shows the kernel boot parameters?"
    read -p "  lab@lpic-lab5:~\$ > " cmd2
    echo

    if [[ "$cmd2" != "cat /proc/cmdline" ]]; then
        print_error "Incorrect. Hint: Try inspecting /proc for kernel info."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  BOOT_IMAGE=/boot/vmlinuz-5.15.0-91-generic root=/dev/sda2 ro quiet splash"
    echo

    echo "  Step 4: What command shows metadata for the kernel image?"
    read -p "  lab@lpic-lab5:~\$ > " cmd3
    echo

    if [[ "$cmd3" != "stat /boot/vmlinuz*" ]]; then
        print_error "Incorrect. Hint: Use stat on the kernel image."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  File: /boot/vmlinuz-5.15.0-91-generic"
    echo "  Size: 11894272"
    echo "  Access: 2025-07-01 09:14:22.000000000"
    echo "  Modify: 2025-06-30 22:51:03.000000000"
    echo "  Change: 2025-06-30 22:51:03.000000000"
    echo

    echo "  Step 5: What command shows the init system in use via symlink?"
    read -p "  lab@lpic-lab5:~\$ > " cmd4
    echo

    if [[ "$cmd4" != "ls -l /sbin/init" ]]; then
        print_error "Incorrect. Hint: init is symlinked. Look at /sbin/init."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  lrwxrwxrwx 1 root root 20 Jan  1 00:00 /sbin/init -> /lib/systemd/systemd"
    echo

    print_success "Great work!"
    print_info "You successfully examined the boot device layout, located the kernel,"
    print_info "read boot parameters, and verified the init system."
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
