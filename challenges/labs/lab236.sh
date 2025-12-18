#!/bin/bash

# Lab 236: Package info + install/remove (cifs-utils) — SIMULATED & SAFE
# SAFETY: Validates typed commands and prints canned outputs only.
#         No real repos or packages are modified. Outputs are realistic but simulated.
# Output policy: Show only realistic, canned command output. Silent steps print nothing.
# Formatting policy: Every simulated command OUTPUT line begins with exactly two spaces.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 236: Package info + install/remove (cifs-utils)"
LAB_ID="lab236"
LAB_XP=21000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PKG="cifs-utils"

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
  center_text "Goal: Inspect package info for ${PKG}, identify which package provides mount.cifs,"
  center_text "install it, verify files/binaries, then remove and confirm removal (SIMULATED)."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Show package information
  draw_lab_ui
  echo "  Step 1: Display package information for ${PKG}."
  read -p "  lab@lab236:~$ " cmd1
  if [[ "$cmd1" == "dnf info $PKG" || "$cmd1" == "yum info $PKG" ]]; then
    echo "  Available Packages"
    echo "  Name         : ${PKG}"
    echo "  Version      : 6.11"
    echo "  Release      : 1.el8"
    echo "  Architecture : x86_64"
    echo "  Size         : 120 k"
    echo "  Source       : ${PKG}-6.11-1.el8.src.rpm"
    echo "  Repository   : AppStream"
    echo "  Summary      : Utilities for mounting and managing CIFS (SMB) filesystems"
    echo "  URL          : https://wiki.samba.org/index.php/LinuxCIFS_utils"
    echo "  License      : GPLv3+"
    echo "  Description  : Common Internet File System utilities including mount.cifs and helpers."
  elif [[ "$cmd1" == "apt show $PKG" ]]; then
    echo "  Package: ${PKG}"
    echo "  Version: 2:6.11-1"
    echo "  Priority: optional"
    echo "  Section: net"
    echo "  Maintainer: Debian Samba Maintainers"
    echo "  Installed-Size: 320 kB"
    echo "  Depends: libc6, keyutils, samba-common-bin"
    echo "  Homepage: https://wiki.samba.org/index.php/LinuxCIFS_utils"
    echo "  Description: Common Internet File System utilities (mount.cifs, umount.cifs, tools)"
  else
    print_error "Hint: Use your package manager to show info (e.g., 'dnf info cifs-utils' or 'apt show cifs-utils')."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 2: Identify which package provides mount.cifs
  echo "  Step 2: Find which package provides the 'mount.cifs' binary."
  read -p "  lab@lab236:~$ " cmd2
  if [[ "$cmd2" == "dnf provides '*/mount.cifs'" || "$cmd2" == "dnf whatprovides '*/mount.cifs'" || "$cmd2" == "yum whatprovides '*/mount.cifs'" ]]; then
    echo "  Last metadata expiration check: 0:02:03 ago on Tue 22 Jul 2025 12:56:37 PM UTC."
    echo "  ${PKG}-6.11-1.el8.x86_64 : Utilities for mounting and managing CIFS filesystems"
    echo "  Repo        : AppStream"
    echo "  Matched from:"
    echo "  Filename    : /usr/sbin/mount.cifs"
  else
    print_error "Hint: Try the package manager's 'provides' or 'whatprovides' against */mount.cifs."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 3: Install the package
  echo "  Step 3: Install ${PKG}."
  read -p "  lab@lab236:~$ " cmd3
  if [[ "$cmd3" == "sudo dnf install -y $PKG" || "$cmd3" == "dnf install -y $PKG" ]]; then
    echo "  Dependencies resolved."
    echo "  ================================================================================"
    echo "   Package      Arch     Version        Repository   Size"
    echo "  ================================================================================"
    echo "  Installing:"
    echo "   ${PKG}       x86_64   6.11-1.el8     AppStream    120 k"
    echo
    echo "  Installed:"
    echo "    ${PKG}-6.11-1.el8.x86_64"
  elif [[ "$cmd3" == "sudo yum install -y $PKG" || "$cmd3" == "yum install -y $PKG" ]]; then
    echo "  Resolving Dependencies"
    echo "  --> Running transaction check"
    echo "  --> Finished Dependency Resolution"
    echo "  Installed: ${PKG}.x86_64 6.11-1.el8"
  elif [[ "$cmd3" == "sudo apt-get install -y $PKG" || "$cmd3" == "apt-get install -y $PKG" ]]; then
    echo "  Reading package lists... Done"
    echo "  Building dependency tree... Done"
    echo "  Reading state information... Done"
    echo "  The following NEW packages will be installed:"
    echo "    ${PKG}"
    echo "  0 upgraded, 1 newly installed, 0 to remove and 0 not upgraded."
    echo "  Setting up ${PKG} (2:6.11-1) ..."
  else
    print_error "Hint: Use your package manager to install (e.g., 'dnf install -y cifs-utils')."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 4: Verify install & locate binary
  echo "  Step 4: Verify the package is installed and locate the binary."
  read -p "  lab@lab236:~$ " cmd4
  if [[ "$cmd4" == "rpm -q $PKG" ]]; then
    echo "  ${PKG}-6.11-1.el8.x86_64"
  elif [[ "$cmd4" == "dpkg -l $PKG" ]]; then
    echo "  ii  ${PKG}  2:6.11-1  amd64  Common Internet File System utilities"
  elif [[ "$cmd4" == "which mount.cifs" ]]; then
    echo "  /usr/sbin/mount.cifs"
  else
    print_error "Hint: Try 'rpm -q cifs-utils', 'dpkg -l cifs-utils', or 'which mount.cifs'."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 5: List some installed files
  echo "  Step 5: List a few files provided by ${PKG}."
  read -p "  lab@lab236:~$ " cmd5
  if [[ "$cmd5" == "rpm -ql $PKG | head -n 10" ]]; then
    echo "  /usr/sbin/mount.cifs"
    echo "  /usr/sbin/umount.cifs"
    echo "  /usr/sbin/cifs.idmap"
    echo "  /usr/sbin/cifs.upcall"
    echo "  /usr/share/man/man8/mount.cifs.8.gz"
    echo "  /usr/share/man/man8/umount.cifs.8.gz"
    echo "  /usr/share/doc/${PKG}/README"
    echo "  /usr/share/licenses/${PKG}/LICENSE"
    echo "  /etc/request-key.d/cifs.idmap.conf"
    echo "  /etc/request-key.d/cifs.spnego.conf"
  elif [[ "$cmd5" == "dpkg -L $PKG | head -n 10" ]]; then
    echo "  /."
    echo "  /usr"
    echo "  /usr/sbin/mount.cifs"
    echo "  /usr/sbin/umount.cifs"
    echo "  /usr/sbin/cifs.upcall"
    echo "  /usr/share/man/man8/mount.cifs.8.gz"
    echo "  /usr/share/doc/${PKG}/changelog.Debian.gz"
    echo "  /usr/share/doc/${PKG}/copyright"
    echo "  /etc/request-key.d/cifs.idmap.conf"
    echo "  /etc/request-key.d/cifs.spnego.conf"
  else
    print_error "Hint: Use 'rpm -ql cifs-utils | head -n 10' or 'dpkg -L cifs-utils | head -n 10'."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 6: Remove the package
  echo "  Step 6: Remove ${PKG}."
  read -p "  lab@lab236:~$ " cmd6
  if [[ "$cmd6" == "sudo dnf remove -y $PKG" || "$cmd6" == "dnf remove -y $PKG" ]]; then
    echo "  Dependencies resolved."
    echo "  ================================================================================"
    echo "   Package      Arch     Version        Repository   Size"
    echo "  ================================================================================"
    echo "  Removing:"
    echo "   ${PKG}       x86_64   6.11-1.el8     @System      120 k"
    echo
    echo "  Removed:"
    echo "    ${PKG}-6.11-1.el8.x86_64"
  elif [[ "$cmd6" == "sudo yum remove -y $PKG" || "$cmd6" == "yum remove -y $PKG" ]]; then
    echo "  Resolving Dependencies"
    echo "  --> Running transaction check"
    echo "  --> Finished Dependency Resolution"
    echo "  Removed: ${PKG}.x86_64 6.11-1.el8"
  elif [[ "$cmd6" == "sudo apt-get remove -y $PKG" || "$cmd6" == "apt-get remove -y $PKG" || "$cmd6" == "sudo apt remove -y $PKG" || "$cmd6" == "apt remove -y $PKG" ]]; then
    echo "  Reading package lists... Done"
    echo "  Building dependency tree... Done"
    echo "  Reading state information... Done"
    echo "  The following packages will be REMOVED:"
    echo "    ${PKG}"
    echo "  After this operation, 320 kB disk space will be freed."
    echo "  Removing ${PKG} (2:6.11-1) ..."
  else
    print_error "Hint: Use your package manager to remove ${PKG}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 7: Confirm removal
  echo "  Step 7: Confirm ${PKG} is no longer installed."
  read -p "  lab@lab236:~$ " cmd7
  if [[ "$cmd7" == "rpm -q $PKG" ]]; then
    echo "  package ${PKG} is not installed"
  elif [[ "$cmd7" == "dpkg -l $PKG" ]]; then
    echo "  dpkg-query: no packages found matching ${PKG}"
  else
    print_error "Hint: Verify removal with 'rpm -q cifs-utils' or 'dpkg -l cifs-utils'."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  print_success "Nice work! You reviewed info, identified provider, installed, inspected, and removed ${PKG} (simulated)."
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
