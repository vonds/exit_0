#!/bin/bash

# Lab 462: RHEL Storage Management — Stratis Pools, Filesystems, and Snapshots

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 462: Stratis Pool, FS, Extend, Snapshot"
LAB_ID="lab462"
LAB_XP=46200
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
  center_text "You are asked to stand up Stratis-based storage for a new application."
  center_text "Policy:"
  center_text "- Use /dev/nvme1 and /dev/nvme2 as backing devices"
  center_text "- Pool name: pool462"
  center_text "- Filesystem name: fs462"
  center_text "- Mount point: /stratis462"
  center_text "- Snapshot name: snap462"
  echo
  center_text "Goal: install Stratis, enable/start stratisd, create pool, add disk, create FS,"
  center_text "mount it, and take a snapshot."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Install stratis packages
  echo "  Step 1: Install Stratis packages (stratis-cli and stratisd)."
  read -p "  lab@rhel-lab462:~$ " cmd1
  echo
  if [[ "$cmd1" != "sudo dnf -y install stratis-cli stratisd" && \
        "$cmd1" != "dnf -y install stratis-cli stratisd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Last metadata expiration check: 0:01:18 ago on Thu 15 Jan 2026 10:44:12 PM UTC."
  echo "  Dependencies resolved."
  echo "  ===================================================================================================="
  echo "   Package                 Architecture     Version                 Repository                   Size"
  echo "  ===================================================================================================="
  echo "  Installing:"
  echo "   stratis-cli             x86_64           3.6.0-2.el9             appstream                   102 k"
  echo "   stratisd                x86_64           3.6.0-2.el9             appstream                   654 k"
  echo "   stratisd-dracut         x86_64           3.6.0-2.el9             appstream                   119 k"
  echo "   thin-provisioning-tools x86_64           0.9.0-4.el9             baseos                      433 k"
  echo "   xfsprogs                x86_64           6.4.0-2.el9             baseos                      1.1 M"
  echo
  echo "  Transaction Summary"
  echo "  ===================================================================================================="
  echo "  Install  5 Packages"
  echo
  echo "  Total download size: 2.4 M"
  echo "  Installed size: 7.9 M"
  echo "  Downloading Packages:"
  echo "  (1/5): stratis-cli-3.6.0-2.el9.x86_64.rpm                          1.1 MB/s | 102 kB     00:00"
  echo "  (2/5): stratisd-3.6.0-2.el9.x86_64.rpm                             4.6 MB/s | 654 kB     00:00"
  echo "  (3/5): stratisd-dracut-3.6.0-2.el9.x86_64.rpm                      2.0 MB/s | 119 kB     00:00"
  echo "  (4/5): thin-provisioning-tools-0.9.0-4.el9.x86_64.rpm              3.7 MB/s | 433 kB     00:00"
  echo "  (5/5): xfsprogs-6.4.0-2.el9.x86_64.rpm                             8.9 MB/s | 1.1 MB     00:00"
  echo "  ----------------------------------------------------------------------------------------------------"
  echo "  Total                                                               7.3 MB/s | 2.4 MB     00:00"
  echo "  Running transaction check"
  echo "  Transaction check succeeded."
  echo "  Running transaction test"
  echo "  Transaction test succeeded."
  echo "  Running transaction"
  echo "    Preparing        :                                                                           1/1"
  echo "    Installing       : xfsprogs-6.4.0-2.el9.x86_64                                               1/5"
  echo "    Installing       : thin-provisioning-tools-0.9.0-4.el9.x86_64                                 2/5"
  echo "    Installing       : stratis-cli-3.6.0-2.el9.x86_64                                             3/5"
  echo "    Installing       : stratisd-3.6.0-2.el9.x86_64                                                4/5"
  echo "    Installing       : stratisd-dracut-3.6.0-2.el9.x86_64                                         5/5"
  echo "    Running scriptlet: stratisd-3.6.0-2.el9.x86_64                                                5/5"
  echo "    Verifying        : stratis-cli-3.6.0-2.el9.x86_64                                             1/5"
  echo "    Verifying        : stratisd-3.6.0-2.el9.x86_64                                                2/5"
  echo "    Verifying        : stratisd-dracut-3.6.0-2.el9.x86_64                                         3/5"
  echo "    Verifying        : thin-provisioning-tools-0.9.0-4.el9.x86_64                                 4/5"
  echo "    Verifying        : xfsprogs-6.4.0-2.el9.x86_64                                                5/5"
  echo
  echo "  Installed:"
  echo "    stratis-cli-3.6.0-2.el9.x86_64  stratisd-3.6.0-2.el9.x86_64  stratisd-dracut-3.6.0-2.el9.x86_64"
  echo "    thin-provisioning-tools-0.9.0-4.el9.x86_64  xfsprogs-6.4.0-2.el9.x86_64"
  echo
  echo "  Complete!"
  echo

  # STEP 2: Enable stratisd
  echo "  Step 2: Enable the Stratis daemon."
  read -p "  lab@rhel-lab462:~$ " cmd2
  echo
  if [[ "$cmd2" != "sudo systemctl enable stratisd" && \
        "$cmd2" != "systemctl enable stratisd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Created symlink /etc/systemd/system/multi-user.target.wants/stratisd.service → /usr/lib/systemd/system/stratisd.service."
  echo

  # STEP 3: Start stratisd
  echo "  Step 3: Start the Stratis daemon."
  read -p "  lab@rhel-lab462:~$ " cmd3
  echo
  if [[ "$cmd3" != "sudo systemctl start stratisd" && \
        "$cmd3" != "systemctl start stratisd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  # STEP 4: Check status
  echo "  Step 4: Check the status of stratisd."
  read -p "  lab@rhel-lab462:~$ " cmd4
  echo
  if [[ "$cmd4" != "sudo systemctl status stratisd" && \
        "$cmd4" != "systemctl status stratisd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  ● stratisd.service - Stratis daemon"
  echo "       Loaded: loaded (/usr/lib/systemd/system/stratisd.service; enabled; preset: disabled)"
  echo "       Active: active (running) since Thu 2026-01-15 22:45:01 UTC; 9s ago"
  echo "     Main PID: 28641 (stratisd)"
  echo "        Tasks: 8 (limit: 11120)"
  echo "       Memory: 16.4M"
  echo "          CPU: 102ms"
  echo "       CGroup: /system.slice/stratisd.service"
  echo "               └─28641 /usr/libexec/stratisd --log-level=info"
  echo

  # STEP 5: Verify disks
  echo "  Step 5: Verify available disks in the system."
  read -p "  lab@rhel-lab462:~$ " cmd5
  echo
  if [[ "$cmd5" != "lsblk" && "$cmd5" != "sudo lsblk" && \
        "$cmd5" != "lsblk -f" && "$cmd5" != "sudo lsblk -f" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS"
  echo "  nvme0n1     259:0    0   40G  0 disk"
  echo "  ├─nvme0n1p1 259:1    0    1G  0 part /boot"
  echo "  └─nvme0n1p2 259:2    0   39G  0 part /"
  echo "  nvme1       259:3    0    5G  0 disk"
  echo "  nvme2       259:4    0    5G  0 disk"
  echo

  # STEP 6: Create a new Stratis pool
  echo "  Step 6: Create a new Stratis pool named pool462 using /dev/nvme1."
  read -p "  lab@rhel-lab462:~$ " cmd6
  echo
  if [[ "$cmd6" != "sudo stratis pool create pool462 /dev/nvme1" && \
        "$cmd6" != "stratis pool create pool462 /dev/nvme1" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  # STEP 7: Verify pool creation
  echo "  Step 7: Verify the pool exists."
  read -p "  lab@rhel-lab462:~$ " cmd7
  echo
  if [[ "$cmd7" != "sudo stratis pool list" && \
        "$cmd7" != "stratis pool list" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Name     Total Physical Size  Total Physical Used"
  echo "  pool462  5.00 GiB             552 MiB"
  echo

  # STEP 8: Add disk(s) to pool to extend capacity
  echo "  Step 8: Add /dev/nvme2 to pool462 to extend the pool."
  read -p "  lab@rhel-lab462:~$ " cmd8
  echo
  if [[ "$cmd8" != "sudo stratis pool add-data pool462 /dev/nvme2" && \
        "$cmd8" != "stratis pool add-data pool462 /dev/nvme2" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  # STEP 9: Verify pool size increased
  echo "  Step 9: Verify the pool shows additional capacity."
  read -p "  lab@rhel-lab462:~$ " cmd9
  echo
  if [[ "$cmd9" != "sudo stratis pool list" && \
        "$cmd9" != "stratis pool list" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Name     Total Physical Size  Total Physical Used"
  echo "  pool462  10.00 GiB            552 MiB"
  echo

  # STEP 10: Create filesystem in pool
  echo "  Step 10: Create a Stratis filesystem named fs462 in pool462."
  read -p "  lab@rhel-lab462:~$ " cmd10
  echo
  if [[ "$cmd10" != "sudo stratis filesystem create pool462 fs462" && \
        "$cmd10" != "stratis filesystem create pool462 fs462" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  # STEP 11: Create mount point directory
  echo "  Step 11: Create the mount point directory /stratis462."
  read -p "  lab@rhel-lab462:~$ " cmd11
  echo
  if [[ "$cmd11" != "sudo mkdir -p /stratis462" && \
        "$cmd11" != "mkdir -p /stratis462" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  # STEP 12: Mount the filesystem
  echo "  Step 12: Mount the Stratis filesystem at /stratis462."
  read -p "  lab@rhel-lab462:~$ " cmd12
  echo
  if [[ "$cmd12" != "sudo mount /stratis/pool462/fs462 /stratis462" && \
        "$cmd12" != "mount /stratis/pool462/fs462 /stratis462" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  # STEP 13: Verify mount (fix: Stratis is *not* 1.0T)
  echo "  Step 13: Verify the filesystem is mounted."
  read -p "  lab@rhel-lab462:~$ " cmd13
  echo
  if [[ "$cmd13" != "df -h | grep stratis462" && \
        "$cmd13" != "mount | grep stratis462" && \
        "$cmd13" != "findmnt /stratis462" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  /stratis/pool462/fs462   9.8G   80M  9.8G   1% /stratis462"
  echo

  # STEP 14: Create snapshot
  echo "  Step 14: Create a snapshot named snap462 of fs462."
  read -p "  lab@rhel-lab462:~$ " cmd14
  echo
  if [[ "$cmd14" != "sudo stratis filesystem snapshot pool462 fs462 snap462" && \
        "$cmd14" != "stratis filesystem snapshot pool462 fs462 snap462" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi


  # STEP 15: Verify snapshot exists
  echo "  Step 15: Verify filesystem and snapshot are listed."
  read -p "  lab@rhel-lab462:~$ " cmd15
  echo
  if [[ "$cmd15" != "sudo stratis filesystem list" && \
        "$cmd15" != "stratis filesystem list" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Pool     Name     Used     Created                Device"
  echo "  pool462  fs462    80 MiB   2026-01-15 22:46:08    /stratis/pool462/fs462"
  echo "  pool462  snap462  0 B      2026-01-15 22:46:22    /stratis/pool462/snap462"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- installed Stratis tooling and started/enabled stratisd"
  print_info "- created a Stratis pool and expanded it by adding a second disk"
  print_info "- created and mounted a Stratis filesystem"
  print_info "- created and verified a snapshot to preserve filesystem state"
  print_info "You earned $LAB_XP XP."
  award_xp $LAB_XP

  XP=$(jq '.XP' "$SAVE_JSON")
  LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
  export XP
  export LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've completed this lab $completion_count time(s)."
  echo
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " choice

  [[ "$choice" == "2" ]] && exit 0
done
