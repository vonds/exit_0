#!/bin/bash

# Lab 466: Rocky Linux 10 Storage — Stratis End-to-End (Install, Service, Pool/FS, fstab, Add Disk, Snapshot Rollback)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 466: Stratis End-to-End + Snapshot Rollback"
LAB_ID="lab466"
LAB_XP=46600
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
  center_text "You're on Rocky Linux 10. A dev host needs Stratis storage for a team share."
  center_text "You'll install Stratis, enable the daemon, create a pool and filesystem,"
  center_text "mount it persistently, add another disk, take a snapshot, and roll back safely."
  echo
  center_text "Target:"
  center_text "- pool: developers"
  center_text "- fs: devfs"
  center_text "- mount: /mnt/devstorage"
  center_text "- snapshot: devfs-snapshot"
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Refresh repo metadata
  echo "  Step 1: Refresh repository metadata cache (Rocky 10 uses dnf)."
  read -p "  lab@rhel-lab466:~$ " cmd1
  echo
  if [[ "$cmd1" != "sudo dnf makecache" && \
        "$cmd1" != "dnf makecache" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Rocky Linux 10 - BaseOS                                             36 kB/s | 6.2 kB     00:00"
  echo "  Rocky Linux 10 - AppStream                                          68 kB/s | 6.3 kB     00:00"
  echo "  Rocky Linux 10 - Extras packages                                    48 kB/s | 7.3 kB     00:00"
  echo "  Extra Packages for Enterprise Linux 10 - x86_64                     173 kB/s |  32 kB     00:00"
  echo "  Metadata cache created."
  echo

  # STEP 2: Install Stratis packages
  echo "  Step 2: Install stratisd and stratis-cli."
  read -p "  lab@rhel-lab466:~$ " cmd2
  echo
  if [[ "$cmd2" != "sudo dnf install -y stratisd stratis-cli" && \
        "$cmd2" != "dnf install -y stratisd stratis-cli" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Last metadata expiration check: 0:00:10 ago on Thu 15 Jan 2026 01:38:41 AM UTC."
  echo "  Dependencies resolved."
  echo "  ===================================================================================================="
  echo "   Package                                 Architecture  Version               Repository        Size"
  echo "  ===================================================================================================="
  echo "  Installing:"
  echo "   stratis-cli                             noarch        3.7.0-1.el10          appstream        135 k"
  echo "   stratisd                                x86_64        3.7.3-1.el10          appstream        3.4 M"
  echo "  Installing dependencies:"
  echo "   cryptsetup                              x86_64        2.7.x-*.el10          baseos           330 k"
  echo "   device-mapper-persistent-data           x86_64        1.1.x-*.el10          baseos           1.1 M"
  echo "  Transaction Summary"
  echo "  ===================================================================================================="
  echo "  Install  N Packages"
  echo
  echo "  Complete!"
  echo

  # STEP 3: Enable + start daemon
  echo "  Step 3: Enable and start stratisd now."
  read -p "  lab@rhel-lab466:~$ " cmd3
  echo
  if [[ "$cmd3" != "sudo systemctl enable --now stratisd.service" && \
        "$cmd3" != "systemctl enable --now stratisd.service" && \
        "$cmd3" != "sudo systemctl enable --now stratisd" && \
        "$cmd3" != "systemctl enable --now stratisd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  # STEP 4: Confirm service status
  echo "  Step 4: Check service status (no pager)."
  read -p "  lab@rhel-lab466:~$ " cmd4
  echo
  if [[ "$cmd4" != "systemctl status stratisd --no-pager" && \
        "$cmd4" != "sudo systemctl status stratisd --no-pager" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  ● stratisd.service - Stratis daemon"
  echo "       Loaded: loaded (/usr/lib/systemd/system/stratisd.service; enabled; preset: enabled)"
  echo "       Active: active (running) since Thu 2026-01-15 01:39:02 UTC; 10s ago"
  echo "         Docs: man:stratisd(8)"
  echo "     Main PID: 32777 (stratisd)"
  echo "        Tasks: 5 (limit: 5892)"
  echo "       Memory: 2.6M"
  echo "          CPU: 19ms"
  echo "       CGroup: /system.slice/stratisd.service"
  echo "               └─32777 /usr/libexec/stratisd --log-level debug"
  echo

  # STEP 5: Verify packages
  echo "  Step 5: Verify installed RPMs."
  read -p "  lab@rhel-lab466:~$ " cmd5
  echo
  if [[ "$cmd5" != "rpm -q stratisd stratis-cli" && \
        "$cmd5" != "sudo rpm -q stratisd stratis-cli" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  stratisd-3.7.3-1.el10.x86_64"
  echo "  stratis-cli-3.7.0-1.el10.noarch"
  echo

  # STEP 6: Confirm CLI exists
  echo "  Step 6: Confirm the stratis CLI is available."
  read -p "  lab@rhel-lab466:~$ " cmd6
  echo
  if [[ "$cmd6" != "command -v stratis" && \
        "$cmd6" != "which stratis" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  /usr/bin/stratis"
  echo

  # STEP 7: Pool list (empty)
  echo "  Step 7: Confirm there are no pools yet."
  read -p "  lab@rhel-lab466:~$ " cmd7
  echo
  if [[ "$cmd7" != "sudo stratis pool list" && \
        "$cmd7" != "stratis pool list" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Name   Total / Used / Free   Properties   UUID   Alerts"
  echo

  # STEP 8: Create pool
  echo "  Step 8: Create pool 'developers' from /dev/vdb and /dev/vdc."
  read -p "  lab@rhel-lab466:~$ " cmd8
  echo
  if [[ "$cmd8" != "sudo stratis pool create developers /dev/vdb /dev/vdc" && \
        "$cmd8" != "stratis pool create developers /dev/vdb /dev/vdc" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 9: Verify pool list (no file save)
  echo "  Step 9: Verify the pool exists by listing Stratis pools."
  read -p "  lab@rhel-lab466:~$ " cmd9
  echo
  if [[ "$cmd9" != "sudo stratis pool list" && \
        "$cmd9" != "stratis pool list" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Name        Total Physical Size  Total Physical Used"
  echo "  developers  10.00 GiB            546 MiB"
  echo

  # STEP 10: Create filesystem
  echo "  Step 10: Create filesystem 'devfs' in pool 'developers'."
  read -p "  lab@rhel-lab466:~$ " cmd10
  echo
  if [[ "$cmd10" != "sudo stratis fs create developers devfs" && \
        "$cmd10" != "stratis fs create developers devfs" && \
        "$cmd10" != "sudo stratis filesystem create developers devfs" && \
        "$cmd10" != "stratis filesystem create developers devfs" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 11: Verify filesystem list (no file save)
  echo "  Step 11: Verify the filesystem exists by listing Stratis filesystems."
  read -p "  lab@rhel-lab466:~$ " cmd11
  echo
  if [[ "$cmd11" != "sudo stratis fs list" && \
        "$cmd11" != "stratis fs list" && \
        "$cmd11" != "sudo stratis filesystem list" && \
        "$cmd11" != "stratis filesystem list" && \
        "$cmd11" != "sudo stratis fs" && \
        "$cmd11" != "stratis fs" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Pool        Name    Used      Created               Device"
  echo "  developers  devfs   1.0 GiB   2026-01-15 01:40:22   /stratis/developers/devfs"
  echo

  # STEP 12: Create mountpoint
  echo "  Step 12: Create mountpoint /mnt/devstorage."
  read -p "  lab@rhel-lab466:~$ " cmd12
  echo
  if [[ "$cmd12" != "sudo mkdir /mnt/devstorage" && \
        "$cmd12" != "sudo mkdir -p /mnt/devstorage" && \
        "$cmd12" != "mkdir /mnt/devstorage" && \
        "$cmd12" != "mkdir -p /mnt/devstorage" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 13: Edit fstab (no answer)
  echo "  Step 13: Edit /etc/fstab and add a Stratis mount entry so devfs mounts at /mnt/devstorage on boot."
  read -p "  lab@rhel-lab466:~$ " cmd13
  echo
  if [[ "$cmd13" != "sudo vi /etc/fstab" && \
        "$cmd13" != "sudo vim /etc/fstab" && \
        "$cmd13" != "sudo nano /etc/fstab" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (editor opened)"
  echo "  (saved and exited)"
  echo

  # STEP 14: Reload systemd units
  echo "  Step 14: Reload systemd after editing fstab."
  read -p "  lab@rhel-lab466:~$ " cmd14
  echo
  if [[ "$cmd14" != "sudo systemctl daemon-reload" && \
        "$cmd14" != "systemctl daemon-reload" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 15: Mount all from fstab
  echo "  Step 15: Mount all entries from /etc/fstab."
  read -p "  lab@rhel-lab466:~$ " cmd15
  echo
  if [[ "$cmd15" != "sudo mount -a" && \
        "$cmd15" != "mount -a" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 16: Create file
  echo "  Step 16: Create a test file in the mounted Stratis filesystem."
  read -p "  lab@rhel-lab466:~$ " cmd16
  echo
  if [[ "$cmd16" != "sudo touch /mnt/devstorage/developers.txt" && \
        "$cmd16" != "touch /mnt/devstorage/developers.txt" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 17: Add disk to pool
  echo "  Step 17: Add /dev/vdd to pool 'developers'."
  read -p "  lab@rhel-lab466:~$ " cmd17
  echo
  if [[ "$cmd17" != "sudo stratis pool add-data developers /dev/vdd" && \
        "$cmd17" != "stratis pool add-data developers /dev/vdd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 18: Verify block devices (no file save)
  echo "  Step 18: Verify Stratis block devices."
  read -p "  lab@rhel-lab466:~$ " cmd18
  echo
  if [[ "$cmd18" != "sudo stratis blockdev" && \
        "$cmd18" != "stratis blockdev" && \
        "$cmd18" != "sudo stratis blockdev list" && \
        "$cmd18" != "stratis blockdev list" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Pool        Device     Physical Size"
  echo "  developers  /dev/vdb   5.00 GiB"
  echo "  developers  /dev/vdc   5.00 GiB"
  echo "  developers  /dev/vdd   5.00 GiB"
  echo

  # STEP 19: Create snapshot
  echo "  Step 19: Create snapshot devfs-snapshot from devfs."
  read -p "  lab@rhel-lab466:~$ " cmd19
  echo
  if [[ "$cmd19" != "sudo stratis fs snapshot developers devfs devfs-snapshot" && \
        "$cmd19" != "stratis fs snapshot developers devfs devfs-snapshot" && \
        "$cmd19" != "sudo stratis filesystem snapshot developers devfs devfs-snapshot" && \
        "$cmd19" != "stratis filesystem snapshot developers devfs devfs-snapshot" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 20: Delete file (bad change)
  echo "  Step 20: Simulate a bad change by deleting the test file."
  read -p "  lab@rhel-lab466:~$ " cmd20
  echo
  if [[ "$cmd20" != "sudo rm /mnt/devstorage/developers.txt" && \
        "$cmd20" != "rm /mnt/devstorage/developers.txt" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 21: Rename devfs -> devfs-bad
  echo "  Step 21: Rename current filesystem devfs -> devfs-bad."
  read -p "  lab@rhel-lab466:~$ " cmd21
  echo
  if [[ "$cmd21" != "sudo stratis fs rename developers devfs devfs-bad" && \
        "$cmd21" != "stratis fs rename developers devfs devfs-bad" && \
        "$cmd21" != "sudo stratis filesystem rename developers devfs devfs-bad" && \
        "$cmd21" != "stratis filesystem rename developers devfs devfs-bad" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 22: Rename snapshot -> devfs (rollback)
  echo "  Step 22: Roll back by renaming snapshot devfs-snapshot -> devfs."
  read -p "  lab@rhel-lab466:~$ " cmd22
  echo
  if [[ "$cmd22" != "sudo stratis fs rename developers devfs-snapshot devfs" && \
        "$cmd22" != "stratis fs rename developers devfs-snapshot devfs" && \
        "$cmd22" != "sudo stratis filesystem rename developers devfs-snapshot devfs" && \
        "$cmd22" != "stratis filesystem rename developers devfs-snapshot devfs" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 23: Unmount
  echo "  Step 23: Unmount /mnt/devstorage."
  read -p "  lab@rhel-lab466:~$ " cmd23
  echo
  if [[ "$cmd23" != "sudo umount /mnt/devstorage" && \
        "$cmd23" != "umount /mnt/devstorage" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 24: Mount again
  echo "  Step 24: Mount /mnt/devstorage again."
  read -p "  lab@rhel-lab466:~$ " cmd24
  echo
  if [[ "$cmd24" != "sudo mount /mnt/devstorage" && \
        "$cmd24" != "mount /mnt/devstorage" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  print_success "Great job."
  print_info "You completed a full Stratis workflow on Rocky 10 with persistence and rollback:"
  print_info "- installed stratisd/stratis-cli and enabled stratisd"
  print_info "- created pool 'developers' and filesystem 'devfs'"
  print_info "- mounted persistently via /etc/fstab with a systemd dependency"
  print_info "- added /dev/vdd to the pool and verified block devices"
  print_info "- created a snapshot and practiced rollback via filesystem renames"
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
