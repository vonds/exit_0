#!/bin/bash

# Lab 469: Rocky Linux 10 Package Management — Repos + Groups + Modules (RHCSA Focus)
# Focus: inspecting repo configuration, safely handling a missing repo name, exploring comps groups,
# installing a package, listing module streams, and installing a specific module stream/profile.
# Key skills: dnf repolist -v, dnf config-manager --disable, dnf group list --hidden,
# dnf install, dnf module list, dnf module install.
#
# Notes:
# - Rocky Linux 10 is RHEL-compatible; dnf is preferred, but yum works as a symlink.
# - This lab uses the same strict template style as Lab 467 (manual entry practice).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 469: Repos + Groups + Modules (Rocky 10)"
LAB_ID="lab469"
LAB_XP=46900
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"

[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@rhel-lab469:~$ "

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
  center_text "You're on a Rocky Linux 10 server preparing it for web workloads."
  center_text "You must verify repository visibility, handle a repo disable attempt,"
  center_text "review available software groups, install a package, and install a module stream."
  echo
  center_text "Requirements (type commands exactly):"
  center_text "- Inspect enabled repos (verbose)"
  center_text "- Attempt to disable repo 'KodeKloud' (it is not present)"
  center_text "- List hidden groups"
  center_text "- Install httpd"
  center_text "- List module streams for php"
  center_text "- Install php stream 8.2 with the minimal profile"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  # STEP 1: dnf repolist -v
  echo "  Step 1: Show enabled repositories (verbose)."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "sudo dnf repolist -v" && \
        "$cmd1" != "dnf repolist -v" && \
        "$cmd1" != "sudo yum repolist -v" && \
        "$cmd1" != "yum repolist -v" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Rocky Linux 10 - BaseOS                                              12 MB/s | 8.9 MB     00:00"
  echo "  Rocky Linux 10 - AppStream                                           17 MB/s |  26 MB     00:01"
  echo "  Rocky Linux 10 - Extras                                              23 kB/s |  20 kB     00:00"
  echo "  Extra Packages for Enterprise Linux 10 - x86_64                        9.2 MB/s |  20 MB     00:02"
  echo "  Extra Packages for Enterprise Linux 10 openh264 (From Cisco)           4.0 kB/s | 2.5 kB     00:00"
  echo "  Extra Packages for Enterprise Linux 10 - Next                          675 kB/s | 259 kB     00:00"
  echo "  Last metadata expiration check: 0:00:01 ago on Thu Jan 15 12:15:04 2026."
  echo

  # STEP 2: Attempt to disable a missing repo
  echo "  Step 2: Attempt to disable repository named 'KodeKloud'."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo dnf config-manager --disable KodeKloud" && \
        "$cmd2" != "dnf config-manager --disable KodeKloud" && \
        "$cmd2" != "sudo yum-config-manager --disable KodeKloud" && \
        "$cmd2" != "yum-config-manager --disable KodeKloud" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Error: No matching repo to modify: KodeKloud."
  echo

  # STEP 3: group list --hidden
  echo "  Step 3: List comps groups (including hidden)."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo dnf group list --hidden" && \
        "$cmd3" != "dnf group list --hidden" && \
        "$cmd3" != "sudo yum group list --hidden" && \
        "$cmd3" != "yum group list --hidden" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Last metadata expiration check: 0:01:04 ago on Thu Jan 15 12:15:04 2026."
  echo "  Available Environment Groups:"
  echo "     Server with GUI"
  echo "     Server"
  echo "     Minimal Install"
  echo "     Workstation"
  echo "     Virtualization Host"
  echo "  Installed Groups:"
  echo "     Development Tools"
  echo "  Available Groups:"
  echo "     Container Management"
  echo "     Debugging Tools"
  echo "     DNS Name Server"
  echo "     File and Storage Server"
  echo "     GNOME"
  echo "     Networking Tools"
  echo "     Performance Tools"
  echo "     Security Tools"
  echo "     System Tools"
  echo "     Virtualization Tools"
  echo "     Basic Web Server"
  echo "     Core"
  echo "     Standard"
  echo

  # STEP 4: install httpd
  echo "  Step 4: Install Apache (httpd)."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo dnf install httpd -y" && \
        "$cmd4" != "dnf install httpd -y" && \
        "$cmd4" != "sudo yum install httpd -y" && \
        "$cmd4" != "yum install httpd -y" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Last metadata expiration check: 0:01:22 ago on Thu Jan 15 12:15:04 2026."
  echo "  Dependencies resolved."
  echo "  ================================================================================"
  echo "   Package                      Arch     Version                     Repo    Size"
  echo "  ================================================================================"
  echo "  Installing:"
  echo "   httpd                         x86_64    2.4.x-*.el10               appstream  46 k"
  echo "  Installing dependencies:"
  echo "   apr                           x86_64    1.7.x-*.el10               appstream 123 k"
  echo "   apr-util                      x86_64    1.6.x-*.el10               appstream  95 k"
  echo "   httpd-core                    x86_64    2.4.x-*.el10               appstream 1.5 M"
  echo "   httpd-filesystem              noarch    2.4.x-*.el10               appstream  12 k"
  echo "   httpd-tools                   x86_64    2.4.x-*.el10               appstream  81 k"
  echo
  echo "  Transaction Summary"
  echo "  ================================================================================"
  echo "  Install  12 Packages"
  echo
  echo "  Complete!"
  echo

  # STEP 5: module list php
  echo "  Step 5: List available module streams for php."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo dnf module list php" && \
        "$cmd5" != "dnf module list php" && \
        "$cmd5" != "sudo yum module list php" && \
        "$cmd5" != "yum module list php" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Last metadata expiration check: 0:01:43 ago on Thu Jan 15 12:15:04 2026."
  echo "  Rocky Linux 10 - AppStream"
  echo "  Name           Stream           Profiles                             Summary"
  echo "  php            8.1              common [d], devel, minimal           PHP scripting language"
  echo "  php            8.2              common [d], devel, minimal           PHP scripting language"
  echo "  php            8.3              common, devel, minimal               PHP scripting language"
  echo
  echo "  Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled"
  echo

  # STEP 6: module install php:8.2/minimal
  echo "  Step 6: Install php stream 8.2 with the minimal profile."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo dnf module install php:8.2/minimal -y" && \
        "$cmd6" != "dnf module install php:8.2/minimal -y" && \
        "$cmd6" != "sudo yum module install php:8.2/minimal -y" && \
        "$cmd6" != "yum module install php:8.2/minimal -y" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Last metadata expiration check: 0:02:01 ago on Thu Jan 15 12:15:04 2026."
  echo "  Dependencies resolved."
  echo "  ================================================================================"
  echo "   Package           Arch   Version                                   Repo      Size"
  echo "  ================================================================================"
  echo "  Installing group/module packages:"
  echo "   php-cli           x86_64  8.2.*.module_el10+*                       appstream  3.6 M"
  echo "   php-common        x86_64  8.2.*.module_el10+*                       appstream  724 k"
  echo "  Installing module profiles:"
  echo "   php/minimal"
  echo "  Enabling module streams:"
  echo "   php              8.2"
  echo
  echo "  Transaction Summary"
  echo "  ================================================================================"
  echo "  Install  2 Packages"
  echo
  echo "  Complete!"
  echo

  print_success "Great job."
  print_info "You practiced RHCSA package management on Rocky 10:"
  print_info "- verified repos with repolist -v"
  print_info "- used config-manager to manage repos (and handled a missing repo cleanly)"
  print_info "- explored environment/groups with group list --hidden"
  print_info "- installed a package with dnf/yum"
  print_info "- listed module streams and installed a specific stream/profile"
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
