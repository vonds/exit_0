#!/bin/bash

# Lab 228: Stratis advanced — snapshot + persistent mount (SIMULATED & SAFE)
# SAFETY: Validates typed commands and prints canned outputs only.
#         No real disks, pools, filesystems, mounts, or /etc/fstab are changed.
#         A simulated fstab is written under /tmp for persistence testing.
# Output policy: Show only realistic, canned command output. Silent steps print nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 228: Stratis — Snapshot + Persistent Mount"
LAB_ID="lab228"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated existing pool/filesystem from prior labs
POOL="poolA"
FS="fsA"
SNAP="fsA_snap"
FS_DEV="/dev/stratis/${POOL}/${FS}"
SNAP_DEV="/dev/stratis/${POOL}/${SNAP}"
MNT_ORIG="/mnt/stratis/${FS}"
MNT_SNAP="/mnt/stratis/${SNAP}"
SIM_FSTAB="/tmp/fstab.lab228"
SNAP_UUID_SIM="b3f1a2c0-5b6e-4a21-9d0c-7f2f1b8c3d55"

draw_lab_ui() {
  clear
  center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
  center_draw_progress_bar "$LEVEL" "$(calculate_xp_to_next_level)"
  echo; echo; echo
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
  center_text "Goal: Create a Stratis snapshot of ${FS} → ${SNAP}, mount it read-only, and"
  center_text "add a persistent (simulated) fstab entry. Then validate by remounting from the sim fstab."
  echo
  center_text "Assume ${POOL}/${FS} already exists (device ${FS_DEV}) and ${str:-mounted elsewhere if needed}."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Verify stratisd is active (SIMULATED)
  draw_lab_ui
  echo "  Step 1: Check that the Stratis daemon is running."
  read -p "  lab@lab228:~$ " cmd1
  [[ "$cmd1" != "systemctl status stratisd" ]] && {
    print_error "Hint: Use the service-status command for the Stratis daemon."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "  ● stratisd.service - Stratis daemon"
  echo "       Loaded: loaded (/usr/lib/systemd/system/stratisd.service; enabled; vendor preset: enabled)"
  echo "       Active: active (running) since Tue 2025-07-22 12:34:11 UTC; 8s ago"
  echo "     Main PID: 2147 (stratisd)"
  echo "        Tasks: 4 (limit: 32768)"
  echo "       Memory: 10.4M"
  echo "          CPU: 64ms"
  echo "       CGroup: /system.slice/stratisd.service"
  echo "               └─2147 /usr/libexec/stratis/stratisd"
  echo

  # Step 2: Confirm pool/filesystem exist (SIMULATED)
  echo "  Step 2: List Stratis pools."
  read -p "  lab@lab228:~$ " cmd2
  [[ "$cmd2" != "stratis pool list" ]] && {
    print_error "Hint: Use the Stratis CLI to enumerate pools."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "Name   UUID                                  Total Physical   Free        Overprovisioned"
  echo "poolA  2b7a4a2f-6c3a-4a2e-8fd4-1b8a1b20b9a0  40 GiB           39.9 GiB    False"
  echo
  echo "  Step 2b: List Stratis filesystems."
  read -p "  lab@lab228:~$ " cmd2b
  [[ "$cmd2b" != "stratis filesystem list" ]] && {
    print_error "Hint: Use the Stratis CLI to enumerate filesystems."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "Pool   Name  Used    Created                    Device"
  echo "poolA  fsA   10 GiB  Tue Jul 22 12:04:01 2025  /dev/stratis/poolA/fsA"
  echo

  # Step 3: Create a snapshot of fsA (SIMULATED)
  echo "  Step 3: Create a snapshot '${SNAP}' from '${FS}'."
  read -p "  lab@lab228:~$ " cmd3
  [[ "$cmd3" != "sudo stratis filesystem snapshot poolA fsA fsA_snap" ]] && {
    print_error "Hint: Use the Stratis CLI subcommand to snapshot a filesystem (pool, origin, snapshot)."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "Created snapshot 'fsA_snap' from 'fsA' in pool 'poolA'"
  echo

  # Step 4: Verify snapshot appears (SIMULATED)
  echo "  Step 4: Verify snapshot listing."
  read -p "  lab@lab228:~$ " cmd4
  [[ "$cmd4" != "stratis filesystem list" ]] && {
    print_error "Hint: List filesystems again to see the new snapshot."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "Pool   Name      Used    Created                    Device"
  echo "poolA  fsA       10 GiB  Tue Jul 22 12:04:01 2025  /dev/stratis/poolA/fsA"
  echo "poolA  fsA_snap  10 GiB  Tue Jul 22 12:35:09 2025  /dev/stratis/poolA/fsA_snap"
  echo

  # Step 5: Mount the snapshot read-only (SIMULATED)
  echo "  Step 5: Create mountpoint and mount the snapshot read-only."
  read -p "  lab@lab228:~$ " cmd5a
  [[ "$cmd5a" != "sudo mkdir -p /mnt/stratis/fsA_snap" ]] && {
    print_error "Hint: Ensure a mountpoint exists for the snapshot."
    read -p "Press Enter to try again..." _
    continue
  }
  echo
  read -p "  lab@lab228:~$ " cmd5b
  [[ "$cmd5b" != "sudo mount -o ro /dev/stratis/poolA/fsA_snap /mnt/stratis/fsA_snap" ]] && {
    print_error "Hint: Mount the snapshot device read-only at its mountpoint."
    read -p "Press Enter to try again..." _
    continue
  }
  echo
  read -p "  lab@lab228:~$ " cmd5c
  [[ "$cmd5c" != "findmnt -T /mnt/stratis/fsA_snap" ]] && {
    print_error "Hint: Verify the mount using a tool that locates the target in the mount tree."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "TARGET                 SOURCE                          FSTYPE OPTIONS"
  echo "/mnt/stratis/fsA_snap  /dev/stratis/poolA/fsA_snap    xfs    ro,relatime,attr2,inode64,quota"
  echo

  # Step 6: Get the snapshot UUID (SIMULATED)
  echo "  Step 6: Obtain the filesystem UUID of the snapshot."
  read -p "  lab@lab228:~$ " cmd6
  [[ "$cmd6" != "blkid -s UUID -o value /dev/stratis/poolA/fsA_snap" ]] && {
    print_error "Hint: Use a tool that probes block devices and prints a specific tag value."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "$SNAP_UUID_SIM"
  echo

  # Step 7: Add a persistent entry (SIMULATED fstab)
  echo "  Step 7: Append a persistent entry for the snapshot to a simulated fstab (${SIM_FSTAB})."
  read -p "  lab@lab228:~$ " cmd7
  [[ "$cmd7" != "echo 'UUID=b3f1a2c0-5b6e-4a21-9d0c-7f2f1b8c3d55  /mnt/stratis/fsA_snap  xfs  ro,_netdev  0 0' | sudo tee -a /tmp/fstab.lab228" ]] && {
    print_error "Hint: Use the UUID you just retrieved and append an fstab-style line to the simulated file."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "UUID=b3f1a2c0-5b6e-4a21-9d0c-7f2f1b8c3d55  /mnt/stratis/fsA_snap  xfs  ro,_netdev  0 0"
  echo

  # Step 8: Test the simulated fstab by remounting via -T (SIMULATED)
  echo "  Step 8: Unmount and re-mount using the simulated fstab."
  read -p "  lab@lab228:~$ " cmd8a
  [[ "$cmd8a" != "sudo umount /mnt/stratis/fsA_snap" ]] && {
    print_error "Hint: Unmount the snapshot mountpoint first."
    read -p "Press Enter to try again..." _
    continue
  }
  echo
  read -p "  lab@lab228:~$ " cmd8b
  [[ "$cmd8b" != "sudo mount -a -T /tmp/fstab.lab228" ]] && {
    print_error "Hint: Use the option that reads an alternative fstab file."
    read -p "Press Enter to try again..." _
    continue
  }
  # (mount -a success is silent)
  echo
  read -p "  lab@lab228:~$ " cmd8c
  [[ "$cmd8c" != "findmnt -T /mnt/stratis/fsA_snap" ]] && {
    print_error "Hint: Verify the snapshot was mounted again from the simulated fstab."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "TARGET                 SOURCE                          FSTYPE OPTIONS"
  echo "/mnt/stratis/fsA_snap  UUID=$SNAP_UUID_SIM            xfs    ro,relatime,attr2,inode64,_netdev"
  echo

  # Step 9 (bonus): Demonstrate snapshot immutability (SIMULATED)
  echo "  Step 9 (bonus): Attempt a write to the read-only snapshot (should fail)."
  read -p "  lab@lab228:~$ " cmd9
  [[ "$cmd9" != "sudo touch /mnt/stratis/fsA_snap/should_fail" ]] && {
    print_error "Hint: Try creating a file under the snapshot mount (expect a read-only error)."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "touch: cannot touch '/mnt/stratis/fsA_snap/should_fail': Read-only file system"
  echo

  print_success "Great job! You created a Stratis snapshot, mounted it read-only, and added a persistent (simulated) fstab entry."
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
