#!/bin/bash

# Lab 227: Destroy Stratis pool/filesystem (SIMULATED & SAFE)
# SAFETY: Validates typed commands and prints canned outputs only.
#         No real disks, pools, filesystems, mounts, or configs are changed.
# Output policy: Show only realistic, canned command output. Silent steps print nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 227: Stratis — Destroy Pool & Filesystem"
LAB_ID="lab227"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated names/mounts (from prior labs)
POOL="poolA"
FS="fsA"
FS_DEV="/dev/stratis/${POOL}/${FS}"
MNT="/mnt/stratis/${FS}"

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
  center_text "Goal: Cleanly remove a Stratis filesystem and its pool. Ensure it’s unmounted,"
  center_text "destroy the filesystem, destroy the pool, and verify they’re gone."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Verify the Stratis daemon is running (SIMULATED)
  draw_lab_ui
  echo "  Step 1: Check the status of the Stratis daemon."
  read -p "  lab@lab227:~$ " cmd1
  [[ "$cmd1" != "systemctl status stratisd" ]] && {
    print_error "Hint: Use the service status tool for the Stratis daemon."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "  ● stratisd.service - Stratis daemon"
  echo "       Loaded: loaded (/usr/lib/systemd/system/stratisd.service; enabled; vendor preset: enabled)"
  echo "       Active: active (running) since Tue 2025-07-22 12:22:41 UTC; 7s ago"
  echo "     Main PID: 2103 (stratisd)"
  echo "        Tasks: 4 (limit: 32768)"
  echo "       Memory: 10.2M"
  echo "          CPU: 58ms"
  echo "       CGroup: /system.slice/stratisd.service"
  echo "               └─2103 /usr/libexec/stratis/stratisd"
  echo

  # Step 2: Inspect current pools (SIMULATED)
  echo "  Step 2: Show existing Stratis pools."
  read -p "  lab@lab227:~$ " cmd2
  [[ "$cmd2" != "stratis pool list" ]] && {
    print_error "Hint: Use the Stratis CLI to list pools."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "Name   UUID                                  Total Physical   Free        Overprovisioned"
  echo "poolA  2b7a4a2f-6c3a-4a2e-8fd4-1b8a1b20b9a0  40 GiB           39.9 GiB    False"
  echo

  # Step 3: Inspect filesystems (SIMULATED)
  echo "  Step 3: List Stratis filesystems."
  read -p "  lab@lab227:~$ " cmd3
  [[ "$cmd3" != "stratis filesystem list" ]] && {
    print_error "Hint: Use the Stratis CLI to list filesystems."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "Pool   Name  Used   Created                    Device"
  echo "poolA  fsA   10 GiB Tue Jul 22 12:04:01 2025  /dev/stratis/poolA/fsA"
  echo

  # Step 4: Ensure the filesystem is not mounted (SIMULATED)
  echo "  Step 4: Unmount the filesystem’s mountpoint if mounted."
  read -p "  lab@lab227:~$ " cmd4
  if [[ "$cmd4" != "sudo umount /mnt/stratis/fsA" && "$cmd4" != "umount /mnt/stratis/fsA" ]]; then
    print_error "Hint: Unmount the mountpoint for this filesystem."
    read -p "Press Enter to try again..." _
    continue
  fi
  # (umount success is silent)
  echo

  # Step 5: Destroy the filesystem (SIMULATED)
  echo "  Step 5: Remove the filesystem from its pool."
  read -p "  lab@lab227:~$ " cmd5
  if [[ "$cmd5" != "sudo stratis filesystem destroy poolA fsA" && "$cmd5" != "stratis filesystem destroy poolA fsA" ]]; then
    print_error "Hint: Use the Stratis CLI to destroy a filesystem in a pool."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "Destroyed filesystem 'fsA' in pool 'poolA'"
  echo

  # Step 6: Verify no filesystems remain (SIMULATED)
  echo "  Step 6: Confirm the filesystem list is now empty."
  read -p "  lab@lab227:~$ " cmd6
  [[ "$cmd6" != "stratis filesystem list" ]] && {
    print_error "Hint: List filesystems again to verify."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "Pool   Name  Used   Created  Device"
  # (no entries)
  echo

  # Step 7: Destroy the pool (SIMULATED)
  echo "  Step 7: Remove the pool."
  read -p "  lab@lab227:~$ " cmd7
  if [[ "$cmd7" != "sudo stratis pool destroy poolA" && "$cmd7" != "stratis pool destroy poolA" ]]; then
    print_error "Hint: Use the Stratis CLI to destroy the pool."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "Destroyed pool 'poolA'"
  echo

  # Step 8: Verify pools are gone (SIMULATED)
  echo "  Step 8: Confirm no pools remain."
  read -p "  lab@lab227:~$ " cmd8
  [[ "$cmd8" != "stratis pool list" ]] && {
    print_error "Hint: List pools again to verify."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "Name   UUID   Total Physical   Free   Overprovisioned"
  # (no entries)
  echo

  # Step 9: Sanity checks — no mounts, no device path (SIMULATED)
  echo "  Step 9: Check that nothing is mounted from Stratis."
  read -p "  lab@lab227:~$ " cmd9a
  [[ "$cmd9a" != "mount | grep -i stratis" ]] && {
    print_error "Hint: Inspect current mounts and filter by the storage layer."
    read -p "Press Enter to try again..." _
    continue
  }
  # (no output if nothing found)
  echo
  echo "          Optionally confirm the target mountpoint is not found."
  read -p "  lab@lab227:~$ " cmd9b
  [[ "$cmd9b" != "findmnt -T /mnt/stratis/fsA" ]] && {
    print_error "Hint: Try checking the mountpoint directly."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "findmnt: /mnt/stratis/fsA: not found"
  echo

  print_success "Clean removal complete! Filesystem and pool are destroyed (simulated)."
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
