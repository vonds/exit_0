#!/bin/bash

# Lab 464: RHEL Storage — Create RAID1 with mdadm (Add Hot Spare) and Verify

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 464: Create RAID1 with mdadm + Spare"
LAB_ID="lab464"
LAB_XP=46400
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
  center_text "Scenario:"
  center_text "A host needs a small RAID1 mirror for resilience. You'll create /dev/md0"
  center_text "using /dev/vdc and /dev/vdd, enable the write-intent bitmap, and add /dev/vde"
  center_text "as a hot spare."
  echo
  center_text "Goal: validate no arrays exist, install mdadm, create RAID1, add spare, verify status."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Verify current md status
  echo "  Step 1: Check current RAID status (should show no active arrays)."
  read -p "  lab@rhel-lab463:~$ " cmd1
  echo
  if [[ "$cmd1" != "cat /proc/mdstat" && \
        "$cmd1" != "sudo cat /proc/mdstat" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Personalities :"
  echo "  unused devices: <none>"
  echo

  # STEP 2: Install mdadm
  echo "  Step 2: Install mdadm."
  read -p "  lab@rhel-lab463:~$ " cmd2
  echo
  if [[ "$cmd2" != "sudo dnf install mdadm -y" && \
        "$cmd2" != "dnf install mdadm -y" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Last metadata expiration check: 0:05:43 ago on Thu 15 Jan 2026 12:55:57 AM UTC."
  echo "  Dependencies resolved."
  echo "  ===================================================================================================="
  echo "   Package              Architecture          Version                     Repository             Size"
  echo "  ===================================================================================================="
  echo "  Installing:"
  echo "   mdadm                x86_64                4.4-3.el9                   baseos                440 k"
  echo
  echo "  Transaction Summary"
  echo "  ===================================================================================================="
  echo "  Install  1 Package"
  echo
  echo "  Total download size: 440 k"
  echo "  Installed size: 1.0 M"
  echo "  Downloading Packages:"
  echo "  mdadm-4.4-3.el9.x86_64.rpm                                          1.1 MB/s | 440 kB     00:00"
  echo "  ----------------------------------------------------------------------------------------------------"
  echo "  Total                                                               819 kB/s | 440 kB     00:00"
  echo "  Running transaction check"
  echo "  Transaction check succeeded."
  echo "  Running transaction test"
  echo "  Transaction test succeeded."
  echo "  Running transaction"
  echo "    Preparing        :                                                                            1/1"
  echo "    Installing       : mdadm-4.4-3.el9.x86_64                                                     1/1"
  echo "    Running scriptlet: mdadm-4.4-3.el9.x86_64                                                     1/1"
  echo "  Created symlink /etc/systemd/system/multi-user.target.wants/mdmonitor.service → /usr/lib/systemd/system/mdmonitor.service."
  echo
  echo "    Verifying        : mdadm-4.4-3.el9.x86_64                                                     1/1"
  echo
  echo "  Installed:"
  echo "    mdadm-4.4-3.el9.x86_64"
  echo
  echo "  Complete!"
  echo

  # STEP 3: Create RAID1 array
  echo "  Step 3: Create a RAID1 array /dev/md0 with /dev/vdc and /dev/vdd."
  read -p "  lab@rhel-lab463:~$ " cmd3
  echo
  if [[ "$cmd3" != "sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/vdc /dev/vdd" && \
        "$cmd3" != "mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/vdc /dev/vdd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  To optimize recovery speed, it is recommended to enable write-intent bitmap, do you want to enable it now? [y/N]? y"
  echo "  mdadm: Note: this array has metadata at the start and"
  echo "      may not be suitable as a boot device.  If you plan to"
  echo "      store '/boot' on this device please ensure that"
  echo "      your boot-loader understands md/v1.x metadata, or use"
  echo "      --metadata=0.90"
  echo "  Continue creating array [y/N]? y"
  echo "  mdadm: Defaulting to version 1.2 metadata"
  echo "  mdadm: array /dev/md0 started."
  echo

  # STEP 4: Add a spare device
  echo "  Step 4: Add /dev/vde as a spare device to /dev/md0."
  read -p "  lab@rhel-lab463:~$ " cmd4
  echo
  if [[ "$cmd4" != "sudo mdadm --manage /dev/md0 --add /dev/vde" && \
        "$cmd4" != "mdadm --manage /dev/md0 --add /dev/vde" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  mdadm: added /dev/vde"
  echo

  # STEP 5: Verify /proc/mdstat shows md0
  echo "  Step 5: Verify array status in /proc/mdstat."
  read -p "  lab@rhel-lab463:~$ " cmd5
  echo
  if [[ "$cmd5" != "cat /proc/mdstat" && \
        "$cmd5" != "sudo cat /proc/mdstat" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Personalities : [raid1]"
  echo "  md0 : active raid1 vde[2](S) vdd[1] vdc[0]"
  echo "        5238784 blocks super 1.2 [2/2] [UU]"
  echo
  echo "  unused devices: <none>"
  echo

  # STEP 6: Confirm details (spare + bitmap)
  echo "  Step 6: Confirm details (including spare) with mdadm."
  read -p "  lab@rhel-lab463:~$ " cmd6
  echo
  if [[ "$cmd6" != "sudo mdadm --detail /dev/md0" && \
        "$cmd6" != "mdadm --detail /dev/md0" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  /dev/md0:"
  echo "           Version : 1.2"
  echo "     Creation Time : Thu Jan 15 00:56:30 2026"
  echo "        Raid Level : raid1"
  echo "        Array Size : 5238784 (5.00 GiB 5.37 GB)"
  echo "     Raid Devices : 2"
  echo "    Total Devices : 3"
  echo "      Persistence : Superblock is persistent"
  echo
  echo "    Write Intent Bitmap : Internal"
  echo
  echo "      State : clean"
  echo "     Active Devices : 2"
  echo "    Working Devices : 3"
  echo "     Failed Devices : 0"
  echo "      Spare Devices : 1"
  echo
  echo "    Number   Major   Minor   RaidDevice State"
  echo "       0     252       32        0      active sync   /dev/vdc"
  echo "       1     252       48        1      active sync   /dev/vdd"
  echo "       2     252       64        -      spare         /dev/vde"
  echo

  print_success "Great job."
  print_info "You successfully created a RAID1 mirror with mdadm and added a hot spare:"
  print_info "- verified no arrays existed via /proc/mdstat"
  print_info "- installed mdadm"
  print_info "- created /dev/md0 (RAID1) with /dev/vdc and /dev/vdd"
  print_info "- enabled write-intent bitmap and confirmed it via mdadm --detail"
  print_info "- added /dev/vde as a spare and verified via /proc/mdstat and mdadm --detail"
  print_info "You earned $LAB_XP XP for completing this lab."
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

  [[ "$choice" == "2" ]] && exit 0
done
