#!/bin/bash

# Lab 226: Create Stratis pool/filesystem, then expand pool with a new disk (SIMULATED & SAFE)
# SAFETY: Validates typed commands and prints canned outputs only.
#         No real disks, pools, filesystems, or mounts are changed.
# Output policy: Show only realistic, canned command output. Silent steps print nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 226: Stratis — Create Pool/FS + Expand Pool"
LAB_ID="lab226"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated block devices (placeholders)
DEV1="/dev/sde"   # first data disk (e.g., 20G)
DEV2="/dev/sdf"   # second data disk to add (e.g., +20G)

# Simulated Stratis names
POOL="poolA"
FS="fsA"
FS_DEV="/dev/stratis/${POOL}/${FS}"
MNT="/mnt/stratis/${FS}"

draw_lab_ui() {
  clear
  center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
  center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
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
  center_text "Goal: Create a Stratis pool (${POOL}) on ${DEV1}, make a filesystem (${FS}), mount it,"
  center_text "then expand the pool by adding ${DEV2} and grow the filesystem (simulated)."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Confirm stratisd is running (SIMULATED)
  draw_lab_ui
  echo "  Step 1: Verify the Stratis daemon is active."
  echo "          Expected: systemctl status stratisd"
  read -p "  lab@lab226:~$ " cmd1
  [[ "$cmd1" != "systemctl status stratisd" ]] && { print_error "Use: systemctl status stratisd"; read -p "Press Enter to try again..." _; continue; }
  echo "  ● stratisd.service - Stratis daemon"
  echo "       Loaded: loaded (/usr/lib/systemd/system/stratisd.service; enabled; vendor preset: enabled)"
  echo "       Active: active (running) since Tue 2025-07-22 12:02:14 UTC; 9s ago"
  echo "     Main PID: 1992 (stratisd)"
  echo "        Tasks: 4 (limit: 32768)"
  echo "       Memory: 10.1M"
  echo "          CPU: 62ms"
  echo "       CGroup: /system.slice/stratisd.service"
  echo "               └─1992 /usr/libexec/stratis/stratisd"
  echo

  # Step 2: Create a Stratis pool on DEV1 (SIMULATED)
  echo "  Step 2: Create pool '${POOL}' on ${DEV1}."
  echo "          Expected: sudo stratis pool create ${POOL} ${DEV1}"
  read -p "  lab@lab226:~$ " cmd2
  [[ "$cmd2" != "sudo stratis pool create poolA /dev/sde" ]] && { print_error "Use: sudo stratis pool create poolA /dev/sde"; read -p "Press Enter to try again..." _; continue; }
  echo "Created pool 'poolA'"
  echo

  # Step 3: Verify pool details (SIMULATED)
  echo "  Step 3: List Stratis pools."
  echo "          Expected: stratis pool list"
  read -p "  lab@lab226:~$ " cmd3
  [[ "$cmd3" != "stratis pool list" ]] && { print_error "Use: stratis pool list"; read -p "Press Enter to try again..." _; continue; }
  echo "Name   UUID                                  Total Physical   Free        Overprovisioned"
  echo "poolA  2b7a4a2f-6c3a-4a2e-8fd4-1b8a1b20b9a0  20 GiB           19.9 GiB    False"
  echo

  # Step 4: Create a filesystem in the pool (SIMULATED)
  echo "  Step 4: Create filesystem '${FS}' in pool '${POOL}'."
  echo "          Expected: sudo stratis filesystem create ${POOL} ${FS}"
  read -p "  lab@lab226:~$ " cmd4
  [[ "$cmd4" != "sudo stratis filesystem create poolA fsA" ]] && { print_error "Use: sudo stratis filesystem create poolA fsA"; read -p "Press Enter to try again..." _; continue; }
  echo "Created filesystem 'fsA' in pool 'poolA'"
  echo

  # Step 5: Show filesystem list (SIMULATED)
  echo "  Step 5: Verify the filesystem exists."
  echo "          Expected: stratis filesystem list"
  read -p "  lab@lab226:~$ " cmd5
  [[ "$cmd5" != "stratis filesystem list" ]] && { print_error "Use: stratis filesystem list"; read -p "Press Enter to try again..." _; continue; }
  echo "Pool   Name  Used  Created                    Device"
  echo "poolA  fsA   0 B   Tue Jul 22 12:04:01 2025  /dev/stratis/poolA/fsA"
  echo

  # Step 6: Mount the filesystem (SIMULATED)
  echo "  Step 6: Mount ${FS_DEV} at ${MNT}."
  echo "          Expected: sudo mkdir -p ${MNT}"
  read -p "  lab@lab226:~$ " cmd6a
  [[ "$cmd6a" != "sudo mkdir -p /mnt/stratis/fsA" ]] && { print_error "Use: sudo mkdir -p /mnt/stratis/fsA"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "          Expected: sudo mount ${FS_DEV} ${MNT}"
  read -p "  lab@lab226:~$ " cmd6b
  [[ "$cmd6b" != "sudo mount /dev/stratis/poolA/fsA /mnt/stratis/fsA" ]] && { print_error "Use: sudo mount /dev/stratis/poolA/fsA /mnt/stratis/fsA"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "          Expected: findmnt -T ${MNT}"
  read -p "  lab@lab226:~$ " cmd6c
  [[ "$cmd6c" != "findmnt -T /mnt/stratis/fsA" ]] && { print_error "Use: findmnt -T /mnt/stratis/fsA"; read -p "Press Enter to try again..." _; continue; }
  echo "TARGET               SOURCE                     FSTYPE OPTIONS"
  echo "/mnt/stratis/fsA     /dev/stratis/poolA/fsA     xfs    rw,relatime,attr2,inode64,quota"
  echo

  # Step 7: Expand the pool by adding DEV2 (SIMULATED)
  echo "  Step 7: Add another data device to expand the pool."
  echo "          Expected: sudo stratis pool add-data ${POOL} ${DEV2}"
  read -p "  lab@lab226:~$ " cmd7
  [[ "$cmd7" != "sudo stratis pool add-data poolA /dev/sdf" ]] && { print_error "Use: sudo stratis pool add-data poolA /dev/sdf"; read -p "Press Enter to try again..." _; continue; }
  echo "Added data device /dev/sdf to pool 'poolA'"
  echo

  # Step 8: Verify larger pool capacity (SIMULATED)
  echo "  Step 8: Check pool size after expansion."
  echo "          Expected: stratis pool list"
  read -p "  lab@lab226:~$ " cmd8
  [[ "$cmd8" != "stratis pool list" ]] && { print_error "Use: stratis pool list"; read -p "Press Enter to try again..." _; continue; }
  echo "Name   UUID                                  Total Physical   Free        Overprovisioned"
  echo "poolA  2b7a4a2f-6c3a-4a2e-8fd4-1b8a1b20b9a0  40 GiB           39.9 GiB    False"
  echo

  # Step 9: Show block devices in the pool (SIMULATED)
  echo "  Step 9: List pool block devices."
  echo "          Expected: stratis blockdev list ${POOL}"
  read -p "  lab@lab226:~$ " cmd9
  [[ "$cmd9" != "stratis blockdev list poolA" ]] && { print_error "Use: stratis blockdev list poolA"; read -p "Press Enter to try again..." _; continue; }
  echo "Pool Name: poolA"
  echo "Blockdev: sde"
  echo "  Device Node: /dev/sde"
  echo "  Tier: Data"
  echo "  Size: 20 GiB"
  echo "  State: In-use"
  echo "Blockdev: sdf"
  echo "  Device Node: /dev/sdf"
  echo "  Tier: Data"
  echo "  Size: 20 GiB"
  echo "  State: In-use"
  echo

  # Step 10: Grow the filesystem logical size (SIMULATED)
  echo "  Step 10: Increase filesystem '${FS}' size to 10G."
  echo "           Expected: sudo stratis filesystem set-size ${POOL} ${FS} 10G"
  read -p "  lab@lab226:~$ " cmd10
  [[ "$cmd10" != "sudo stratis filesystem set-size poolA fsA 10G" ]] && { print_error "Use: sudo stratis filesystem set-size poolA fsA 10G"; read -p "Press Enter to try again..." _; continue; }
  echo "Set size of filesystem 'fsA' in pool 'poolA' to 10 GiB"
  echo
  echo "           Expected: stratis filesystem list"
  read -p "  lab@lab226:~$ " cmd10b
  [[ "$cmd10b" != "stratis filesystem list" ]] && { print_error "Use: stratis filesystem list"; read -p "Press Enter to try again..." _; continue; }
  echo "Pool   Name  Used   Created                    Device"
  echo "poolA  fsA   10 GiB Tue Jul 22 12:04:01 2025  /dev/stratis/poolA/fsA"
  echo

  print_success "Nice work! Stratis pool/filesystem created, pool expanded with a new device, and filesystem grown (simulated)."
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
