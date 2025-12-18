#!/bin/bash

# Lab 223: VDO — Create volume, enable compression & dedup, view status (SIMULATED & SAFE)
# SAFETY: This lab does NOT modify your system. It validates typed commands and prints canned outputs.
#         No real disks, VDO volumes, services, or filesystems are touched.
# Output policy: Show only realistic, canned command output. Silent steps print nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 223: VDO Create + Compress/Dedup + Status"
LAB_ID="lab223"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated resources
DISK="/dev/sdd"                    # placeholder backing device
VDO_NAME="vdo1"
VDO_DEV="/dev/mapper/${VDO_NAME}"
VDO_SIZE="50G"

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
  center_text "Goal: Create a VDO volume on $DISK with logical size $VDO_SIZE, enable compression and"
  center_text "deduplication, then verify using vdo list/status (all simulated)."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Verify VDO packages (SIMULATED)
  draw_lab_ui
  echo "  Step 1: Check that VDO is installed."
  echo "          Expected: rpm -q vdo"
  read -p "  lab@lab223:~$ " cmd1
  [[ "$cmd1" != "rpm -q vdo" ]] && { print_error "Use: rpm -q vdo"; read -p "Press Enter to try again..." _; continue; }
  echo "vdo-8.2.0-10.el9.x86_64"
  echo

  # Step 2: Enable and start the VDO service (SIMULATED — no output on success)
  echo "  Step 2: Enable and start the VDO service."
  echo "          Expected: sudo systemctl enable --now vdo"
  read -p "  lab@lab223:~$ " cmd2
  [[ "$cmd2" != "sudo systemctl enable --now vdo" ]] && { print_error "Use: sudo systemctl enable --now vdo"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 3: Create the VDO volume (SIMULATED)
  echo "  Step 3: Create a VDO volume named $VDO_NAME on $DISK with logical size $VDO_SIZE."
  echo "          Expected: sudo vdo create --name=$VDO_NAME --device=$DISK --vdoLogicalSize=$VDO_SIZE"
  read -p "  lab@lab223:~$ " cmd3
  [[ "$cmd3" != "sudo vdo create --name=vdo1 --device=/dev/sdd --vdoLogicalSize=50G" ]] && {
    print_error "Use exactly: sudo vdo create --name=vdo1 --device=/dev/sdd --vdoLogicalSize=50G"
    read -p "Press Enter to try again..." _
    continue
  }
  echo "Creating VDO vdo1"
  echo "Starting VDO vdo1"
  echo "VDO instance vdo1 is ready at /dev/mapper/vdo1"
  echo

  # Step 4: Confirm the device exists (SIMULATED)
  echo "  Step 4: Confirm the new VDO device node."
  echo "          Expected: lsblk -no NAME,TYPE,SIZE $VDO_DEV"
  read -p "  lab@lab223:~$ " cmd4
  [[ "$cmd4" != "lsblk -no NAME,TYPE,SIZE /dev/mapper/vdo1" ]] && {
    print_error "Use: lsblk -no NAME,TYPE,SIZE /dev/mapper/vdo1"
    read -p "Press Enter to try again..." _
    continue
  }
  echo "vdo1 dm 50G"
  echo

  # Step 5: List VDO volumes (SIMULATED)
  echo "  Step 5: List known VDO volumes."
  echo "          Expected: sudo vdo list"
  read -p "  lab@lab223:~$ " cmd5
  [[ "$cmd5" != "sudo vdo list" ]] && { print_error "Use: sudo vdo list"; read -p "Press Enter to try again..." _; continue; }
  echo "vdo1"
  echo

  # Step 6: Show status before enabling features (SIMULATED)
  echo "  Step 6: Show current status/details for $VDO_NAME."
  echo "          Expected: sudo vdo status --name=$VDO_NAME"
  read -p "  lab@lab223:~$ " cmd6
  [[ "$cmd6" != "sudo vdo status --name=vdo1" ]] && { print_error "Use: sudo vdo status --name=vdo1"; read -p "Press Enter to try again..." _; continue; }
  echo "VDO status:"
  echo "  Name:                      vdo1"
  echo "  Device:                    /dev/sdd"
  echo "  VDO device:                /dev/mapper/vdo1"
  echo "  State:                     running"
  echo "  Logical size:              50.0 GB"
  echo "  Compression:               disabled"
  echo "  Deduplication:             disabled"
  echo "  Used data blocks:          0.0% (logical)"
  echo "  Used physical space:       0.0%"
  echo

  # Step 7: Enable compression (SIMULATED)
  echo "  Step 7: Enable compression on $VDO_NAME."
  echo "          Expected: sudo vdo enableCompression --name=$VDO_NAME"
  read -p "  lab@lab223:~$ " cmd7
  [[ "$cmd7" != "sudo vdo enableCompression --name=vdo1" ]] && {
    print_error "Use: sudo vdo enableCompression --name=vdo1"
    read -p "Press Enter to try again..." _
    continue
  }
  echo "Compression enabled on vdo1"
  echo

  # Step 8: Enable deduplication (SIMULATED)
  echo "  Step 8: Enable deduplication on $VDO_NAME."
  echo "          Expected: sudo vdo enableDeduplication --name=$VDO_NAME"
  read -p "  lab@lab223:~$ " cmd8
  [[ "$cmd8" != "sudo vdo enableDeduplication --name=vdo1" ]] && {
    print_error "Use: sudo vdo enableDeduplication --name=vdo1"
    read -p "Press Enter to try again..." _
    continue
  }
  echo "Deduplication enabled on vdo1"
  echo

  # Step 9: Verify status shows both features enabled (SIMULATED)
  echo "  Step 9: Verify both features are active."
  echo "          Expected: sudo vdo status --name=$VDO_NAME"
  read -p "  lab@lab223:~$ " cmd9
  [[ "$cmd9" != "sudo vdo status --name=vdo1" ]] && { print_error "Use: sudo vdo status --name=vdo1"; read -p "Press Enter to try again..." _; continue; }
  echo "VDO status:"
  echo "  Name:                      vdo1"
  echo "  Device:                    /dev/sdd"
  echo "  VDO device:                /dev/mapper/vdo1"
  echo "  State:                     running"
  echo "  Logical size:              50.0 GB"
  echo "  Compression:               enabled"
  echo "  Deduplication:             enabled"
  echo "  Used data blocks:          0.0% (logical)"
  echo "  Used physical space:       0.0%"
  echo

  # Step 10 (bonus): Show concise list & a simulated savings snapshot (SIMULATED)
  echo "  Step 10 (bonus): Quick list and a savings snapshot."
  echo "           Expected: sudo vdo list"
  read -p "  lab@lab223:~$ " cmd10a
  [[ "$cmd10a" != "sudo vdo list" ]] && { print_error "Use: sudo vdo list"; read -p "Press Enter to try again..." _; continue; }
  echo "vdo1"
  echo
  echo "           Expected (simulated): sudo vdostats --human-readable"
  read -p "  lab@lab223:~$ " cmd10b
  [[ "$cmd10b" != "sudo vdostats --human-readable" ]] && { print_error "Use: sudo vdostats --human-readable"; read -p "Press Enter to try again..." _; continue; }
  echo "Device                1K-blocks    Used    Available  Use%  Space saving"
  echo "/dev/mapper/vdo1       52428800   10240    52418560    0%        0.0%"
  echo

  print_success "Nice work! VDO volume created, compression & dedup enabled, and status verified (simulated)."
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
