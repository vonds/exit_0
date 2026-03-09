#!/bin/bash

# Lab 214: VG + LVs (ext4 & XFS) with persistent mounts
# SAFETY: This lab is fully simulated. It does not touch your real system.
# Output policy: Only realistic, canned command output is shown. Silent steps print nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 214: VG + LVs (ext4 & XFS) with persistent mounts"
LAB_ID="lab214"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

draw_lab_ui() {
    clear
    center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
    center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
    echo
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
    center_text "Goal: Create VG vgdata on /dev/sde, then create lvext4 and lvxfs."
    center_text "Format them as ext4 and XFS, mount them, and persist entries to a simulated fstab."
    echo
    center_text "Press Enter to begin..."
    read _

    draw_lab_ui
    echo "  Step 1: Initialize /dev/sde as a physical volume."
    read -p "  lab@lab214:~$ " cmd1
    echo
    [[ "$cmd1" != "pvcreate /dev/sde" ]] && {
        print_error "Use: pvcreate /dev/sde"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Physical volume \"/dev/sde\" successfully created."
    echo

    echo "  Step 2: Create a volume group named vgdata."
    read -p "  lab@lab214:~$ " cmd2
    echo
    [[ "$cmd2" != "vgcreate vgdata /dev/sde" ]] && {
        print_error "Use: vgcreate vgdata /dev/sde"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Volume group \"vgdata\" successfully created"
    echo

    echo "  Step 3: Create a 300M logical volume named lvext4."
    read -p "  lab@lab214:~$ " cmd3
    echo
    [[ "$cmd3" != "lvcreate -L 300M -n lvext4 vgdata" ]] && {
        print_error "Use: lvcreate -L 300M -n lvext4 vgdata"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Logical volume \"lvext4\" created."
    echo

    echo "  Step 4: Create a 500M logical volume named lvxfs."
    read -p "  lab@lab214:~$ " cmd4
    echo
    [[ "$cmd4" != "lvcreate -L 500M -n lvxfs vgdata" ]] && {
        print_error "Use: lvcreate -L 500M -n lvxfs vgdata"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Logical volume \"lvxfs\" created."
    echo

    echo "  Step 5: List the logical volumes."
    read -p "  lab@lab214:~$ " cmd5
    echo
    [[ "$cmd5" != "lvs" ]] && {
        print_error "Use: lvs"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  LV     VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert"
    echo "  lvext4 vgdata -wi-a----- 300.00m"
    echo "  lvxfs  vgdata -wi-a----- 500.00m"
    echo

    echo "  Step 6: Create an ext4 filesystem on /dev/vgdata/lvext4."
    read -p "  lab@lab214:~$ " cmd6
    echo
    [[ "$cmd6" != "mkfs.ext4 -L data_ext4 /dev/vgdata/lvext4" ]] && {
        print_error "Use: mkfs.ext4 -L data_ext4 /dev/vgdata/lvext4"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  mke2fs 1.46.5 (30-Dec-2021)"
    echo "  Creating filesystem with 76800 4k blocks and 19200 inodes"
    echo "  Filesystem UUID: 22222222-3333-4444-5555-666666666666"
    echo "  Superblock backups stored on blocks:"
    echo "          32768, 98304"
    echo "  Writing superblocks and filesystem accounting information: done"
    echo

    echo "  Step 7: Create an XFS filesystem on /dev/vgdata/lvxfs."
    read -p "  lab@lab214:~$ " cmd7
    echo
    [[ "$cmd7" != "mkfs.xfs -f -L data_xfs /dev/vgdata/lvxfs" ]] && {
        print_error "Use: mkfs.xfs -f -L data_xfs /dev/vgdata/lvxfs"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  meta-data=/dev/vgdata/lvxfs     isize=512    agcount=4, agsize=32000 blks"
    echo "  data     =                       bsize=4096   blocks=128000, imaxpct=25"
    echo "  naming   =version 2              bsize=4096   ascii-ci=0, ftype=1"
    echo "  log      =internal log           bsize=4096   blocks=2560, version=2"
    echo "  realtime =none                   extsz=4096   blocks=0, rtextents=0"
    echo

    echo "  Step 8: Retrieve the UUID of /dev/vgdata/lvext4."
    read -p "  lab@lab214:~$ " cmd8
    echo
    [[ "$cmd8" != "blkid -s UUID -o value /dev/vgdata/lvext4" ]] && {
        print_error "Use: blkid -s UUID -o value /dev/vgdata/lvext4"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  22222222-3333-4444-5555-666666666666"
    echo

    echo "  Step 9: Retrieve the UUID of /dev/vgdata/lvxfs."
    read -p "  lab@lab214:~$ " cmd9
    echo
    [[ "$cmd9" != "blkid -s UUID -o value /dev/vgdata/lvxfs" ]] && {
        print_error "Use: blkid -s UUID -o value /dev/vgdata/lvxfs"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  bbbbbbb2-cccc-dddd-eeee-ffffffffffff"
    echo

    echo "  Step 10: Create the ext4 mount point."
    read -p "  lab@lab214:~$ " cmd10
    echo
    [[ "$cmd10" != "mkdir -p /mnt/data_ext4" ]] && {
        print_error "Use: mkdir -p /mnt/data_ext4"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 11: Create the XFS mount point."
    read -p "  lab@lab214:~$ " cmd11
    echo
    [[ "$cmd11" != "mkdir -p /mnt/data_xfs" ]] && {
        print_error "Use: mkdir -p /mnt/data_xfs"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 12: Mount the ext4 filesystem by UUID."
    read -p "  lab@lab214:~$ " cmd12
    echo
    [[ "$cmd12" != "mount -t ext4 UUID=22222222-3333-4444-5555-666666666666 /mnt/data_ext4" ]] && {
        print_error "Use: mount -t ext4 UUID=22222222-3333-4444-5555-666666666666 /mnt/data_ext4"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 13: Mount the XFS filesystem by UUID."
    read -p "  lab@lab214:~$ " cmd13
    echo
    [[ "$cmd13" != "mount -t xfs UUID=bbbbbbb2-cccc-dddd-eeee-ffffffffffff /mnt/data_xfs" ]] && {
        print_error "Use: mount -t xfs UUID=bbbbbbb2-cccc-dddd-eeee-ffffffffffff /mnt/data_xfs"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 14: Verify both mounts."
    read -p "  lab@lab214:~$ " cmd14
    echo
    [[ "$cmd14" != "df -T | egrep '/mnt/data_ext4|/mnt/data_xfs'" ]] && {
        print_error "Use: df -T | egrep '/mnt/data_ext4|/mnt/data_xfs'"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Filesystem               Type  1K-blocks  Used Available Use% Mounted on"
    echo "  /dev/vgdata/lvext4       ext4     307200  6144    301056   2% /mnt/data_ext4"
    echo "  /dev/vgdata/lvxfs        xfs      512000  2048    509952   1% /mnt/data_xfs"
    echo

    echo "  Step 15: Add the ext4 entry to the simulated fstab."
    read -p "  lab@lab214:~$ " cmd15
    echo
    [[ "$cmd15" != "echo 'UUID=22222222-3333-4444-5555-666666666666 /mnt/data_ext4 ext4 defaults 0 0' | tee -a /tmp/fstab.lab214" ]] && {
        print_error "Use: echo 'UUID=22222222-3333-4444-5555-666666666666 /mnt/data_ext4 ext4 defaults 0 0' | tee -a /tmp/fstab.lab214"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  UUID=22222222-3333-4444-5555-666666666666 /mnt/data_ext4 ext4 defaults 0 0"
    echo

    echo "  Step 16: Add the XFS entry to the simulated fstab."
    read -p "  lab@lab214:~$ " cmd16
    echo
    [[ "$cmd16" != "echo 'UUID=bbbbbbb2-cccc-dddd-eeee-ffffffffffff /mnt/data_xfs xfs defaults 0 0' | tee -a /tmp/fstab.lab214" ]] && {
        print_error "Use: echo 'UUID=bbbbbbb2-cccc-dddd-eeee-ffffffffffff /mnt/data_xfs xfs defaults 0 0' | tee -a /tmp/fstab.lab214"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  UUID=bbbbbbb2-cccc-dddd-eeee-ffffffffffff /mnt/data_xfs xfs defaults 0 0"
    echo

    echo "  Step 17: Display the simulated fstab file."
    read -p "  lab@lab214:~$ " cmd17
    echo
    [[ "$cmd17" != "cat /tmp/fstab.lab214" ]] && {
        print_error "Use: cat /tmp/fstab.lab214"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  UUID=22222222-3333-4444-5555-666666666666 /mnt/data_ext4 ext4 defaults 0 0"
    echo "  UUID=bbbbbbb2-cccc-dddd-eeee-ffffffffffff /mnt/data_xfs xfs defaults 0 0"
    echo

    print_success "Nice work!"
    print_info "You earned $LAB_XP XP for completing this lab."
    award_xp "$LAB_XP"
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