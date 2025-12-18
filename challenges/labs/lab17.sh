#!/bin/bash

# Lab 17: Mounting Filesystems and Editing /etc/fstab

# Dynamically locate root directory and source core scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 17: Mounting Filesystems and Editing /etc/fstab"
LAB_ID="lab17"
LAB_XP=4189
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
    center_text "A new partition was added as /dev/sdb1. You're responsible for"
    center_text "formatting, mounting it to /mnt/data, and ensuring it mounts"
    center_text "automatically at boot using /etc/fstab."
    echo
    center_text "Press Enter to begin the lab..."
    read _
    draw_lab_ui

    # Step 1: Run lsblk interactively
    echo "  Step 1: List block devices to see the new partition."
    read -p "  lab@lpic-lab17:~$ " cmd1
    echo

    if [[ "$cmd1" != "lsblk" ]]; then
        print_error "Incorrect. Hint: Use lsblk to list block devices."
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT"
    echo "  sda      8:0    0   40G  0 disk"
    echo "  ├─sda1   8:1    0  512M  0 part /boot"
    echo "  └─sda2   8:2    0 39.5G  0 part /"
    echo "  sdb      8:16   0   20G  0 disk"
    echo "  └─sdb1   8:17   0   20G  0 part"
    echo

    # Step 2: Format partition
    echo "  Step 2: What command formats /dev/sdb1 with ext4?"
    read -p "  lab@lpic-lab17:~$ " cmd2
    echo

    if [[ "$cmd2" != "sudo mkfs.ext4 /dev/sdb1" ]]; then
        print_error "Incorrect. Hint: Use mkfs.ext4 and target the partition, not the disk."
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  mke2fs 1.45.5 (07-Jan-2020)"
    echo "  Creating filesystem with 5242880 4k blocks and 1310720 inodes"
    echo "  Filesystem UUID: abc12345-6789-4def-aaaa-bbbbccccdddd"
    echo "  Superblock backups stored on blocks: 32768, 98304, 163840..."
    echo "  Filesystem created successfully."
    echo

    # Step 3: Mount partition
    echo "  Step 3: What command mounts /dev/sdb1 to /mnt/data?"
    read -p "  lab@lpic-lab17:~$ " cmd3
    echo

    if [[ "$cmd3" != "sudo mount /dev/sdb1 /mnt/data" ]]; then
        print_error "Incorrect. Hint: Use 'mount' with device and mountpoint."
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  /dev/sdb1 mounted to /mnt/data"
    echo

    # Step 4: Verify mount
    echo "  Step 4: What command shows mounted filesystems?"
    read -p "  lab@lpic-lab17:~$ " cmd4
    echo

    if [[ "$cmd4" != "mount" && "$cmd4" != "findmnt" ]]; then
        print_error "Incorrect. Hint: Use 'mount' or 'findmnt' to verify."
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  /dev/sdb1 on /mnt/data type ext4 (rw,relatime)"
    echo

    # Step 5: Edit fstab entry
    echo "  Step 5: What line would you add to /etc/fstab to mount it at boot?"
    read -p "  (fstab entry) > " cmd5
    echo

    if [[ "$cmd5" != "/dev/sdb1 /mnt/data ext4 defaults 0 2" ]]; then
        print_error "Incorrect. Format: device mountpoint fs-type options dump pass"
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  fstab line added: /dev/sdb1 /mnt/data ext4 defaults 0 2"
    echo

    # Step 6: Test fstab
    echo "  Step 6: What command tests fstab entries without rebooting?"
    read -p "  lab@lpic-lab17:~$ " cmd6
    echo

    if [[ "$cmd6" != "sudo mount -a" ]]; then
        print_error "Incorrect. Hint: It mounts all entries from fstab."
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  All valid entries from /etc/fstab mounted successfully."
    echo

    print_success "Well done!"
    print_info "You listed block devices, formatted a partition, mounted it,"
    print_info "verified it, and updated /etc/fstab for persistent automatic mounting."
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
