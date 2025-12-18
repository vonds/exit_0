#!/bin/bash

# Lab 18: Partitioning a Disk Using fdisk

# Dynamically locate root directory and source core scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 18: Partitioning a Disk Using fdisk"
LAB_ID="lab18"
LAB_XP=2750
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
    center_text "A new 10GB disk has been attached at /dev/sdc. You're tasked with"
    center_text "creating a primary partition, writing changes, and preparing it for use."
    echo
    center_text "Press Enter to begin the lab..."
    read _
    draw_lab_ui

    # STEP 1 (interactive): Discover the new disk with lsblk
    echo "  Step 1: List block devices to confirm /dev/sdc is present."
    read -p "  lab@lpic-lab18:~$ " cmd1
    echo
    if [[ "$cmd1" != "lsblk" ]]; then
        print_error "Incorrect. Use: lsblk"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT"
    echo "  sda      8:0    0   40G  0 disk"
    echo "  ├─sda1   8:1    0  512M  0 part /boot"
    echo "  └─sda2   8:2    0 39.5G  0 part /"
    echo "  sdc      8:32   0   10G  0 disk"
    echo

    # STEP 2 (interactive): Launch fdisk on the whole disk
    echo "  Step 2: What command launches fdisk on /dev/sdc?"
    read -p "  lab@lpic-lab18:~$ " cmd2
    echo
    if [[ "$cmd2" != "sudo fdisk /dev/sdc" ]]; then
        print_error "Incorrect. Hint: Use fdisk and target the whole disk, not a partition."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Welcome to fdisk. Type 'm' for help, 'n' to create a new partition."
    echo

    # STEP 3 (interactive): Create a new partition inside fdisk
    echo "  Step 3: In fdisk, what letter creates a new partition?"
    read -p "  (fdisk command) > " cmd3
    echo
    if [[ "$cmd3" != "n" ]]; then
        print_error "Incorrect. Hint: 'n' is for 'new'."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Partition type: primary (default p)"
    echo "  Partition number: 1"
    echo "  First sector: (default)"
    echo "  Last sector: (default)"
    echo "  Created a new partition 1 of type 'Linux' and size ~10 GiB."
    echo

    # STEP 4 (interactive): Write the partition table
    echo "  Step 4: In fdisk, what letter writes the partition table to disk and exits?"
    read -p "  (fdisk command) > " cmd4
    echo
    if [[ "$cmd4" != "w" ]]; then
        print_error "Incorrect. Hint: Use 'w' to write changes and exit."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Partition table written. Syncing disks."
    echo

    # STEP 5 (interactive): Verify the new partition exists
    echo "  Step 5: What command confirms the new partition exists?"
    read -p "  lab@lpic-lab18:~$ " cmd5
    echo
    if [[ "$cmd5" != "lsblk" && "$cmd5" != "sudo fdisk -l" ]]; then
        print_error "Incorrect. Use: lsblk   or   sudo fdisk -l"
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT"
    echo "  sdc      8:32   0   10G  0 disk"
    echo "  └─sdc1   8:33   0   10G  0 part"
    echo

    # STEP 6 (interactive): Create a filesystem on the new partition
    echo "  Step 6: What command formats the new partition for use with ext4?"
    read -p "  lab@lpic-lab18:~$ " cmd6
    echo
    if [[ "$cmd6" != "sudo mkfs.ext4 /dev/sdc1" ]]; then
        print_error "Incorrect. Hint: Use mkfs.ext4 on the new partition."
        echo
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  Filesystem created on /dev/sdc1"
    echo

    print_success "Excellent!"
    print_info "You discovered the disk with lsblk, used fdisk to create a partition,"
    print_info "wrote the partition table, verified with lsblk/fdisk -l, and formatted the new partition."
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
