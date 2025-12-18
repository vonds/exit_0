#!/bin/bash

# Lab 289: Filesystem Creation & ISO Images (Packaging & recovery)
# Scenario: Prepare a small filesystem image and a recovery ISO for a VM.
# Tasks:
#  - create a 128MB image file and format it ext4
#  - attach as a loop device and mount it
#  - add sample files, unmount, and produce an ISO image
#  - mount the ISO image and verify contents
# This script is interactive: type the expected commands (several sudo variants accepted).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 289: Filesystem Creation & ISO Images"
LAB_ID="lab289"
LAB_XP=1700
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"

[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

draw_lab_ui() {
    clear
    center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
    center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
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
    center_text "You will create a 128MB filesystem image, populate it, then create and verify a recovery ISO."
    center_text "Follow the prompts and run the expected commands exactly (sudo variants accepted)."
    echo
    center_text "Press Enter to begin the lab..."
    read _
    draw_lab_ui

    # ---- Step 1 ----
    echo "  Step 1: Create a 128MB zero-filled image file at /tmp/vm.img."
    read -p "  lab@lab289:~$ " cmd1
    echo
    if [[ "$cmd1" == "dd if=/dev/zero of=/tmp/vm.img bs=1M count=128" || "$cmd1" == "sudo dd if=/dev/zero of=/tmp/vm.img bs=1M count=128" ]]; then
        echo "128+0 records in"
        echo "128+0 records out"
        echo "134217728 bytes (134 MB, 128 MiB) copied, 0.040123 s, 3.3 GB/s"
    else
        print_error "Incorrect. Use: dd if=/dev/zero of=/tmp/vm.img bs=1M count=128"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    # ---- Step 2 ----
    echo "  Step 2: Format the image as ext4 (use -F or apply mkfs on the loop device after attaching)."
    echo "          Acceptable single-step: sudo mkfs.ext4 -F /tmp/vm.img"
    read -p "  lab@lab289:~$ " cmd2
    echo
    if [[ "$cmd2" == "sudo mkfs.ext4 -F /tmp/vm.img" || "$cmd2" == "mkfs.ext4 -F /tmp/vm.img" ]]; then
        echo "mke2fs 1.45.5 (example)"
        echo "Creating filesystem with 32768 4k blocks and 32768 inodes"
        echo "Filesystem UUID: aaaa-bbbb-cccc-dddd"
    else
        print_error "Incorrect. Use: sudo mkfs.ext4 -F /tmp/vm.img"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    # ---- Step 3 ----
    echo "  Step 3: Attach the image to a loop device and show the loop device path."
    echo "          Example: sudo losetup -f --show /tmp/vm.img"
    read -p "  lab@lab289:~$ " cmd3
    echo
    if [[ "$cmd3" == "sudo losetup -f --show /tmp/vm.img" || "$cmd3" == "losetup -f --show /tmp/vm.img" ]]; then
        echo "/dev/loop2"
    else
        print_error "Incorrect. Use: sudo losetup -f --show /tmp/vm.img"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    # ---- Step 4 ----
    echo "  Step 4: Mount the loop device read-write at /mnt, creating /mnt if necessary."
    echo "          Example: sudo mkdir -p /mnt && sudo mount -o loop /dev/loop2 /mnt"
    read -p "  lab@lab289:~$ " cmd4
    echo
    if [[ "$cmd4" == "sudo mkdir -p /mnt && sudo mount -o loop /dev/loop2 /mnt" || \
          "$cmd4" == "sudo mkdir -p /mnt; sudo mount -o loop /dev/loop2 /mnt" || \
          "$cmd4" == "mkdir -p /mnt && sudo mount -o loop /dev/loop2 /mnt" ]]; then
        echo
        # mount typically produces no output on success
    else
        print_error "Incorrect. Use: sudo mkdir -p /mnt && sudo mount -o loop /dev/loop2 /mnt"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    # ---- Step 5 ----
    echo "  Step 5: Create a recovery directory and add README.txt and a sample script inside the mounted image."
    echo "          Example: sudo mkdir -p /mnt/recovery && echo 'Recovery' | sudo tee /mnt/recovery/README.txt && sudo chmod 644 /mnt/recovery/README.txt"
    read -p "  lab@lab289:~$ " cmd5
    echo
    if [[ "$cmd5" == "sudo mkdir -p /mnt/recovery && echo 'Recovery' | sudo tee /mnt/recovery/README.txt && sudo chmod 644 /mnt/recovery/README.txt" || \
          "$cmd5" == "sudo mkdir -p /mnt/recovery; echo 'Recovery' | sudo tee /mnt/recovery/README.txt; sudo chmod 644 /mnt/recovery/README.txt" ]]; then
        echo "Recovery"
        echo "/mnt/recovery/README.txt"
    else
        print_error "Incorrect. Use a command that creates /mnt/recovery and writes README.txt (with tee) and sets permissions."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    # ---- Step 6 ----
    echo "  Step 6: Unmount the image and detach the loop device."
    echo "          Example: sudo umount /mnt && sudo losetup -d /dev/loop2"
    read -p "  lab@lab289:~$ " cmd6
    echo
    if [[ "$cmd6" == "sudo umount /mnt && sudo losetup -d /dev/loop2" || \
          "$cmd6" == "sudo umount /mnt; sudo losetup -d /dev/loop2" || \
          "$cmd6" == "umount /mnt && sudo losetup -d /dev/loop2" ]]; then
        echo
        # umount/losetup -d typically produce no output on success
    else
        print_error "Incorrect. Use: sudo umount /mnt && sudo losetup -d /dev/loop2"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    # ---- Step 7 ----
    echo "  Step 7: Create a temporary directory for ISO root, copy the recovery tree, and build an ISO named /tmp/recovery.iso"
    echo "          Example: mkdir -p /tmp/iso-root && sudo mkdir -p /tmp/iso-root/recovery && sudo cp /tmp/vm.img /tmp/iso-root/recovery/ && mkisofs -o /tmp/recovery.iso -J -R /tmp/iso-root"
    read -p "  lab@lab289:~$ " cmd7
    echo
    if [[ "$cmd7" == "mkdir -p /tmp/iso-root && sudo mkdir -p /tmp/iso-root/recovery && sudo cp /tmp/vm.img /tmp/iso-root/recovery/ && mkisofs -o /tmp/recovery.iso -J -R /tmp/iso-root" || \
          "$cmd7" == "mkdir -p /tmp/iso-root; sudo mkdir -p /tmp/iso-root/recovery; sudo cp /tmp/vm.img /tmp/iso-root/recovery/; mkisofs -o /tmp/recovery.iso -J -R /tmp/iso-root" || \
          "$cmd7" == "sudo mkisofs -o /tmp/recovery.iso -J -R /tmp/iso-root" ]]; then
        echo "mkisofs: writing ISO image /tmp/recovery.iso"
        echo "mkisofs: 1 directory, 1 file"
    else
        print_error "Incorrect. Build /tmp/iso-root and use mkisofs to produce /tmp/recovery.iso. Example sequence shown in the prompt."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    # ---- Step 8 ----
    echo "  Step 8: Mount the ISO loopback at /mnt and list its contents."
    echo "          Example: sudo mount -o loop /tmp/recovery.iso /mnt && ls -l /mnt"
    read -p "  lab@lab289:~$ " cmd8
    echo
    if [[ "$cmd8" == "sudo mount -o loop /tmp/recovery.iso /mnt && ls -l /mnt" || \
          "$cmd8" == "sudo mount -o loop /tmp/recovery.iso /mnt; ls -l /mnt" || \
          "$cmd8" == "mount -o loop /tmp/recovery.iso /mnt && ls -l /mnt" ]]; then
        echo "total 4"
        echo "-rw-r--r-- 1 root root 134217728 Jul 19 12:00 vm.img"
        echo "drwxr-xr-x 2 root root      4096 Jul 19 12:00 recovery"
    else
        print_error "Incorrect. Mount the ISO and list /mnt. Example: sudo mount -o loop /tmp/recovery.iso /mnt && ls -l /mnt"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    # ---- Step 9 ----
    echo "  Step 9: Unmount the ISO and clean up the temporary iso-root directory."
    read -p "  lab@lab289:~$ " cmd9
    echo
    if [[ "$cmd9" == "sudo umount /mnt && rm -rf /tmp/iso-root" || "$cmd9" == "sudo umount /mnt; rm -rf /tmp/iso-root" || "$cmd9" == "umount /mnt && rm -rf /tmp/iso-root" ]]; then
        echo
    else
        print_error "Incorrect. Use: sudo umount /mnt && rm -rf /tmp/iso-root"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    # ---- Step 10 ----
    echo "  Step 10: Which filesystem is preferable for a recovery image when you want to avoid journaling (choose ext2 or ext4)?"
    read -p "  lab@lab289:~$ " cmd10
    echo
    lower_cmd10=$(echo "$cmd10" | tr '[:upper:]' '[:lower:]')
    if [[ "$lower_cmd10" == "ext2" || "$lower_cmd10" == "ext2" ]]; then
        echo "Accepted: ext2 is often used when avoiding journaling is desirable for simple recovery images."
    else
        print_error "Incorrect. For an image where you explicitly want to avoid journaling, ext2 is the usual choice."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo

    # ---- Completion ----
    echo "Lab complete: created and formatted an image, attached and populated it, generated an ISO, verified contents, and cleaned up."
    echo "You earned $LAB_XP XP for completing this lab!"
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON")
    LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
    export XP
    export LEVEL
    record_lab_completion

    completion_count=$(get_lab_completion_count)
    echo
    echo "Completed: $completion_count time(s)"
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
