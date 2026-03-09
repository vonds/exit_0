#!/bin/bash

# Lab 120: DNF/RPM Basics — Query, Verify, File Ownership, and Repository Packages (RHEL)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 120: DNF/RPM Package Management Basics"
LAB_ID="lab120"
LAB_XP=13400
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
  center_text "A teammate reports: 'bash completion stopped working and a binary might be modified.'"
  center_text "You must use rpm/dnf to verify package integrity and troubleshoot ownership of files."
  echo
  center_text "Goal: use rpm + dnf to inspect, verify, and repair packages on a RHEL-like system."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1
  echo "  Step 1: Confirm the installed version of the bash package."
  read -p "  lab@rhel-lab120:~$ " cmd1
  echo
  if [[ "$cmd1" != "rpm -q bash" && "$cmd1" != "sudo rpm -q bash" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  bash-5.1.8-6.el9.x86_64"
  echo

  # STEP 2
  echo "  Step 2: Show package info for bash."
  read -p "  lab@rhel-lab120:~$ " cmd2
  echo
  if [[ "$cmd2" != "rpm -qi bash" && "$cmd2" != "sudo rpm -qi bash" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Name        : bash"
  echo "  Version     : 5.1.8"
  echo "  Release     : 6.el9"
  echo "  Architecture: x86_64"
  echo "  Install Date: Sun 04 Jan 2026 09:13:27 AM EST"
  echo "  Group       : Unspecified"
  echo "  Size        : 7643211"
  echo "  License     : GPLv3+"
  echo "  Signature   : RSA/SHA256, Wed 18 Jun 2025 02:11:09 PM EDT, Key ID 199e2f91fd431d51"
  echo "  Source RPM  : bash-5.1.8-6.el9.src.rpm"
  echo "  Build Date  : Wed 18 Jun 2025 01:42:51 PM EDT"
  echo "  Build Host  : x86-03.stream.rdu2.redhat.com"
  echo "  Packager    : Red Hat, Inc. <http://bugzilla.redhat.com/bugzilla>"
  echo "  Vendor      : Red Hat, Inc."
  echo "  URL         : https://www.gnu.org/software/bash"
  echo "  Summary     : The GNU Bourne Again shell"
  echo "  Description :"
  echo "  Bash is the GNU Project's Bourne Again SHell, a sh-compatible shell"
  echo "  that incorporates useful features from the Korn shell (ksh) and C shell (csh)."
  echo

  # STEP 3
  echo "  Step 3: List 10 files installed by bash."
  read -p "  lab@rhel-lab120:~$ " cmd3
  echo
  if [[ "$cmd3" != "rpm -ql bash | head" && "$cmd3" != "sudo rpm -ql bash | head" && "$cmd3" != "rpm -ql bash" && "$cmd3" != "sudo rpm -ql bash" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  /bin/bash"
  echo "  /etc/bashrc"
  echo "  /etc/skel/.bash_logout"
  echo "  /etc/skel/.bash_profile"
  echo "  /etc/skel/.bashrc"
  echo "  /usr/bin/bashbug"
  echo "  /usr/lib/.build-id"
  echo "  /usr/lib/.build-id/7e"
  echo "  /usr/lib/.build-id/7e/3f0f4b4c6d9fd8d4774f8f4b5bc8473c123456"
  echo "  /usr/share/doc/bash"
  echo

  # STEP 4
  echo "  Step 4: Find which package owns /etc/bashrc."
  read -p "  lab@rhel-lab120:~$ " cmd4
  echo
  if [[ "$cmd4" != "rpm -qf /etc/bashrc" && "$cmd4" != "sudo rpm -qf /etc/bashrc" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  bash-5.1.8-6.el9.x86_64"
  echo

  # STEP 5
  echo "  Step 5: Verify package integrity for bash."
  read -p "  lab@rhel-lab120:~$ " cmd5
  echo
  if [[ "$cmd5" != "sudo rpm -V bash" && "$cmd5" != "rpm -V bash" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  S.5....T.  c /etc/bashrc"
  echo

  # STEP 6
  echo "  Step 6: Reinstall bash to restore packaged files."
  read -p "  lab@rhel-lab120:~$ " cmd6
  echo
  if [[ "$cmd6" != "sudo dnf reinstall -y bash" && "$cmd6" != "dnf reinstall -y bash" && "$cmd6" != "sudo dnf reinstall bash" && "$cmd6" != "dnf reinstall bash" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Last metadata expiration check: 0:02:11 ago on Sun 04 Jan 2026 09:21:14 AM EST."
  echo "  Dependencies resolved."
  echo "  =============================================================================="
  echo "   Package        Architecture     Version              Repository          Size"
  echo "  =============================================================================="
  echo "  Reinstalling:"
  echo "   bash           x86_64           5.1.8-6.el9          baseos             1.8 M"
  echo
  echo "  Transaction Summary"
  echo "  =============================================================================="
  echo "  Reinstall  1 Package"
  echo
  echo "  Total download size: 1.8 M"
  echo "  Installed size: 7.3 M"
  echo "  Downloading Packages:"
  echo "  Running transaction check"
  echo "  Transaction check succeeded."
  echo "  Running transaction test"
  echo "  Transaction test succeeded."
  echo "  Running transaction"
  echo "    Preparing        :                                                        1/1"
  echo "    Reinstalling     : bash-5.1.8-6.el9.x86_64                               1/2"
  echo "    Cleanup          : bash-5.1.8-6.el9.x86_64                               2/2"
  echo "    Verifying        : bash-5.1.8-6.el9.x86_64                               1/2"
  echo "    Verifying        : bash-5.1.8-6.el9.x86_64                               2/2"
  echo
  echo "  Reinstalled:"
  echo "    bash-5.1.8-6.el9.x86_64"
  echo
  echo "  Complete!"
  echo

  # STEP 7
  echo "  Step 7: Confirm verification is clean now."
  read -p "  lab@rhel-lab120:~$ " cmd7
  echo
  if [[ "$cmd7" != "rpm -V bash" && "$cmd7" != "sudo rpm -V bash" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  # STEP 8
  echo "  Step 8: List available versions of bash in repos."
  read -p "  lab@rhel-lab120:~$ " cmd8
  echo
  if [[ "$cmd8" != "dnf list bash" && "$cmd8" != "sudo dnf list bash" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Installed Packages"
  echo "  bash.x86_64                        5.1.8-6.el9                        @baseos"
  echo "  Available Packages"
  echo "  bash.x86_64                        5.1.8-6.el9                        baseos"
  echo

  # STEP 9
  echo "  Step 9: Use repoquery to show which repository provides 'httpd'."
  read -p "  lab@rhel-lab120:~$ " cmd9
  echo
  if [[ "$cmd9" != "dnf repoquery --info httpd" && "$cmd9" != "sudo dnf repoquery --info httpd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Name         : httpd"
  echo "  Version      : 2.4.57"
  echo "  Release      : 8.el9"
  echo "  Architecture : x86_64"
  echo "  Size         : 5873421"
  echo "  Source       : httpd-2.4.57-8.el9.src.rpm"
  echo "  Repository   : appstream"
  echo "  Summary      : Apache HTTP Server"
  echo "  URL          : https://httpd.apache.org/"
  echo "  License      : ASL 2.0"
  echo "  Description  :"
  echo "  The Apache HTTP Server is a powerful, efficient, and extensible"
  echo "  web server."
  echo

  # STEP 10
  echo "  Step 10: Clean dnf metadata cache."
  read -p "  lab@rhel-lab120:~$ " cmd10
  echo
  if [[ "$cmd10" != "sudo dnf clean metadata" && "$cmd10" != "dnf clean metadata" && "$cmd10" != "sudo dnf clean all" && "$cmd10" != "dnf clean all" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi

  if [[ "$cmd10" == *"clean metadata" ]]; then
    echo "  Cache was expired"
    echo "  5 files removed"
  else
    echo "  12 files removed"
  fi

  print_success "Great job."
  print_info "You practiced rpm/dnf workflows used in real troubleshooting:"
  print_info "- verifying package integrity, identifying ownership of files, and safely reinstalling packages"
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