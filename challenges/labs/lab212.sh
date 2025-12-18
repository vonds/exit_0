#!/bin/bash

# Lab 212: Configure swap (partition + LV) with priorities in fstab (SIMULATED & SAFE)
# SAFETY: This lab DOES NOT execute typed commands. It only compares your input strings and prints canned output.
#         No reads/writes from your system occur. "fstab" edits go to /tmp/fstab.lab212 (mock), not /etc/fstab.
# Output policy: Show only realistic, canned command output. Silent steps print nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 212: Swap on Partition + LVM (fstab priorities, SIMULATED)"
LAB_ID="lab212"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Mock devices/paths (placeholders; not probed)
DISK_SDB="/dev/sdb"
PART_SDB="/dev/sdb1"            # ~512MiB swap partition (mock)
DISK_SDC="/dev/sdc"             # disk for LVM PV (mock)
VG="vgswap"
LV="lvswap"                     # 512MiB swap LV (mock)
LV_PATH="/dev/$VG/$LV"

# Mock UUIDs (fixed values; not from your system)
UUID_PART="6a1f3c0b-5d98-4a2e-9f61-53a8b7c4d2ab"
UUID_LV="b4e8d3f2-91c5-4f7a-8e3b-62a9d1c0ee77"

# Mock fstab target (SIMULATED)
FSTAB_SIM="/tmp/fstab.lab212"

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
  center_text "Goal: Create a swap partition ($PART_SDB ~512MiB) and a swap LV ($LV_PATH ~512MiB),"
  center_text "then add both to a simulated fstab ($FSTAB_SIM) with priorities (LV higher), activate, and verify."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Partition /dev/sdb (~512MiB swap) — SIMULATED
  draw_lab_ui
  echo "  Step 1: Create a ~512MiB swap partition on /dev/sdb."
  echo "          Expected: parted -s $DISK_SDB mklabel gpt"
  read -p "  lab@lab212:~$ " cmd1a
  [[ "$cmd1a" != "parted -s /dev/sdb mklabel gpt" ]] && { print_error "Use: parted -s /dev/sdb mklabel gpt"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "          Expected: parted -s $DISK_SDB mkpart primary linux-swap 1MiB 513MiB"
  read -p "  lab@lab212:~$ " cmd1b
  [[ "$cmd1b" != "parted -s /dev/sdb mkpart primary linux-swap 1MiB 513MiB" ]] && { print_error "Use: parted -s /dev/sdb mkpart primary linux-swap 1MiB 513MiB"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "          Expected: partprobe $DISK_SDB"
  read -p "  lab@lab212:~$ " cmd1c
  [[ "$cmd1c" != "partprobe /dev/sdb" ]] && { print_error "Use: partprobe /dev/sdb"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 2: Verify partition exists — SIMULATED lsblk output
  echo "  Step 2: Verify sdb1 exists."
  echo "          Expected: lsblk $DISK_SDB"
  read -p "  lab@lab212:~$ " cmd2
  [[ "$cmd2" != "lsblk /dev/sdb" ]] && { print_error "Use: lsblk /dev/sdb"; read -p "Press Enter to try again..." _; continue; }
  echo "NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS"
  echo "sdb      8:16   0   10G  0 disk"
  echo "└─sdb1   8:17   0  512M  0 part"
  echo

  # Step 3: Make swap on the partition — SIMULATED mkswap output
  echo "  Step 3: Initialize /dev/sdb1 as swap."
  echo "          Expected: mkswap $PART_SDB"
  read -p "  lab@lab212:~$ " cmd3
  [[ "$cmd3" != "mkswap /dev/sdb1" ]] && { print_error "Use: mkswap /dev/sdb1"; read -p "Press Enter to try again..." _; continue; }
  echo "Setting up swapspace version 1, size = 512 MiB (536866816 bytes)"
  echo "no label, UUID=$UUID_PART"
  echo

  # Step 4: Create LVM PV/VG/LV for swap — SIMULATED outputs
  echo "  Step 4: Prepare an LVM-based swap LV (~512MiB) on /dev/sdc."
  echo "          Expected: pvcreate $DISK_SDC"
  read -p "  lab@lab212:~$ " cmd4a
  [[ "$cmd4a" != "pvcreate /dev/sdc" ]] && { print_error "Use: pvcreate /dev/sdc"; read -p "Press Enter to try again..." _; continue; }
  echo "  Physical volume \"/dev/sdc\" successfully created."
  echo
  echo "          Expected: vgcreate $VG $DISK_SDC"
  read -p "  lab@lab212:~$ " cmd4b
  [[ "$cmd4b" != "vgcreate vgswap /dev/sdc" ]] && { print_error "Use: vgcreate vgswap /dev/sdc"; read -p "Press Enter to try again..." _; continue; }
  echo "  Volume group \"vgswap\" successfully created"
  echo
  echo "          Expected: lvcreate -L 512M -n $LV $VG"
  read -p "  lab@lab212:~$ " cmd4c
  [[ "$cmd4c" != "lvcreate -L 512M -n lvswap vgswap" ]] && { print_error "Use: lvcreate -L 512M -n lvswap vgswap"; read -p "Press Enter to try again..." _; continue; }
  echo "  Logical volume \"lvswap\" created."
  echo

  # Step 5: Make swap on the LV — SIMULATED mkswap output
  echo "  Step 5: Initialize $LV_PATH as swap."
  echo "          Expected: mkswap $LV_PATH"
  read -p "  lab@lab212:~$ " cmd5
  [[ "$cmd5" != "mkswap /dev/vgswap/lvswap" ]] && { print_error "Use: mkswap /dev/vgswap/lvswap"; read -p "Press Enter to try again..." _; continue; }
  echo "Setting up swapspace version 1, size = 512 MiB (536866816 bytes)"
  echo "no label, UUID=$UUID_LV"
  echo

  # Step 6: Get UUIDs — SIMULATED blkid output
  echo "  Step 6: Retrieve UUIDs to use in fstab."
  echo "          Expected: blkid -s UUID -o value $PART_SDB"
  read -p "  lab@lab212:~$ " cmd6a
  [[ "$cmd6a" != "blkid -s UUID -o value /dev/sdb1" ]] && { print_error "Use: blkid -s UUID -o value /dev/sdb1"; read -p "Press Enter to try again..." _; continue; }
  echo "$UUID_PART"
  echo
  echo "          Expected: blkid -s UUID -o value $LV_PATH"
  read -p "  lab@lab212:~$ " cmd6b
  [[ "$cmd6b" != "blkid -s UUID -o value /dev/vgswap/lvswap" ]] && { print_error "Use: blkid -s UUID -o value /dev/vgswap/lvswap"; read -p "Press Enter to try again..." _; continue; }
  echo "$UUID_LV"
  echo

  # Step 7: Add both swap entries to a SIMULATED fstab with priorities
  echo "  Step 7: Append fstab entries with priorities (LV pri=120, partition pri=60) to $FSTAB_SIM (SIMULATED)."
  echo "          Expected: echo 'UUID=$UUID_LV none swap defaults,pri=120 0 0' | tee -a $FSTAB_SIM"
  read -p "  lab@lab212:~$ " cmd7a
  [[ "$cmd7a" != "echo 'UUID=$UUID_LV none swap defaults,pri=120 0 0' | tee -a $FSTAB_SIM" ]] && { print_error "Use the exact echo | tee -a form for the LV entry (simulated file)"; read -p "Press Enter to try again..." _; continue; }
  echo "UUID=$UUID_LV none swap defaults,pri=120 0 0"
  echo
  echo "          Expected: echo 'UUID=$UUID_PART none swap defaults,pri=60 0 0' | tee -a $FSTAB_SIM"
  read -p "  lab@lab212:~$ " cmd7b
  [[ "$cmd7b" != "echo 'UUID=$UUID_PART none swap defaults,pri=60 0 0' | tee -a $FSTAB_SIM" ]] && { print_error "Use the exact echo | tee -a form for the partition entry (simulated file)"; read -p "Press Enter to try again..." _; continue; }
  echo "UUID=$UUID_PART none swap defaults,pri=60 0 0"
  echo

  # Step 8: Activate swaps — SIMULATED swapon -a (no effect)
  echo "  Step 8: Activate all swap entries from the simulated fstab."
  echo "          Expected: swapon -a"
  read -p "  lab@lab212:~$ " cmd8
  [[ "$cmd8" != "swapon -a" ]] && { print_error "Use: swapon -a"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 9: Verify swap devices and priorities — SIMULATED swapon --show
  echo "  Step 9: Verify with swapon --show."
  echo "          Expected: swapon --show"
  read -p "  lab@lab212:~$ " cmd9
  [[ "$cmd9" != "swapon --show" ]] && { print_error "Use: swapon --show"; read -p "Press Enter to try again..." _; continue; }
  echo "NAME                       TYPE      SIZE   USED PRIO"
  echo "/dev/mapper/vgswap-lvswap  partition 512M     0B  120"
  echo "/dev/sdb1                  partition 512M     0B   60"
  echo

  # Step 10: Memory/Swap summary — SIMULATED free -h
  echo "  Step 10: Show memory and swap summary."
  echo "           Expected: free -h"
  read -p "  lab@lab212:~$ " cmd10
  [[ "$cmd10" != "free -h" ]] && { print_error "Use: free -h"; read -p "Press Enter to try again..." _; continue; }
  echo "              total        used        free      shared  buff/cache   available"
  echo "Mem:           7.6G        1.2G        5.1G        120M        1.3G        6.1G"
  echo "Swap:          1.0G          0B        1.0G"
  echo

  print_success "Nice work!"
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
