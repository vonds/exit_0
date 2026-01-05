#!/bin/bash

# Lab 119: YUM Basics — Search, Info, List, Provides, History, Repos, and Transactions
# Focus: using yum for discovery, troubleshooting package ownership, and safe transaction workflows
# Key skills: yum repolist, yum list, yum search, yum info, yum provides, yum whatprovides,
# yum history, yum check-update, yum reinstall, yum downgrade, yum clean, and verification.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 119: YUM Basics"
LAB_ID="lab119"
LAB_XP=3200
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
  center_text "You are onboarding to a RHEL-like system where you must use yum to:"
  center_text "- verify repositories"
  center_text "- discover packages and ownership of files"
  center_text "- review transaction history and safely manage packages"
  echo
  center_text "Goal: complete common yum workflows."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1
  echo "  Step 1: List enabled repositories."
  read -p "  lab@rhel-lab119:~$ " cmd1
  echo
  if [[ "$cmd1" != "yum repolist" && "$cmd1" != "sudo yum repolist" && "$cmd1" != "yum repolist enabled" && "$cmd1" != "sudo yum repolist enabled" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  repo id                               repo name"
  echo "  appstream                             Rocky Linux 9 - AppStream"
  echo "  baseos                                Rocky Linux 9 - BaseOS"
  echo "  extras                                Rocky Linux 9 - Extras"
  echo

  # STEP 2
  echo "  Step 2: List installed packages matching 'bash' (pattern match)."
  read -p "  lab@rhel-lab119:~$ " cmd2
  echo
  if [[ "$cmd2" != "yum list installed bash" && \
        "$cmd2" != "sudo yum list installed bash" && \
        "$cmd2" != "yum list installed '*bash*'" && \
        "$cmd2" != "sudo yum list installed '*bash*'" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Installed Packages"
  echo "  bash.x86_64                          5.1.8-6.el9                      @baseos"
  echo

  # STEP 3
  echo "  Step 3: Search the repos for packages related to 'http server'."
  read -p "  lab@rhel-lab119:~$ " cmd3
  echo
  if [[ "$cmd3" != "yum search http server" && \
        "$cmd3" != "sudo yum search http server" && \
        "$cmd3" != "yum search httpd" && \
        "$cmd3" != "sudo yum search httpd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  ==================== Name & Summary Matched: http ====================="
  echo "  httpd.x86_64 : Apache HTTP Server"
  echo "  mod_ssl.x86_64 : SSL/TLS module for the Apache HTTP Server"
  echo

  # STEP 4
  echo "  Step 4: Show detailed info about the 'httpd' package."
  read -p "  lab@rhel-lab119:~$ " cmd4
  echo
  if [[ "$cmd4" != "yum info httpd" && "$cmd4" != "sudo yum info httpd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Available Packages"
  echo "  Name        : httpd"
  echo "  Version     : 2.4.57"
  echo "  Release     : 8.el9"
  echo "  Arch        : x86_64"
  echo "  Repo        : appstream"
  echo "  Summary     : Apache HTTP Server"
  echo

  # STEP 5
  echo "  Step 5: Find which package provides the file /usr/bin/top."
  read -p "  lab@rhel-lab119:~$ " cmd5
  echo
  if [[ "$cmd5" != "yum provides /usr/bin/top" && \
        "$cmd5" != "sudo yum provides /usr/bin/top" && \
        "$cmd5" != "yum whatprovides /usr/bin/top" && \
        "$cmd5" != "sudo yum whatprovides /usr/bin/top" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  procps-ng-3.3.17-13.el9.x86_64 : System and process monitoring utilities"
  echo "  Repo        : baseos"
  echo "  Matched from:"
  echo "  Filename    : /usr/bin/top"
  echo

  # STEP 6
  echo "  Step 6: Check for available updates without installing them."
  read -p "  lab@rhel-lab119:~$ " cmd6
  echo
  if [[ "$cmd6" != "yum check-update" && "$cmd6" != "sudo yum check-update" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  curl.x86_64                         7.76.1-26.el9_4                 baseos"
  echo "  openssl-libs.x86_64                 3.0.7-25.el9_4                  baseos"
  echo

  # STEP 7
  echo "  Step 7: View yum transaction history."
  read -p "  lab@rhel-lab119:~$ " cmd7
  echo
  if [[ "$cmd7" != "yum history" && "$cmd7" != "sudo yum history" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  ID     | Command line             | Date and time    | Action(s) | Altered"
  echo "  12     | install vim-enhanced     | 2026-01-02 12:20 | Install   |    1"
  echo "  11     | update                   | 2026-01-01 09:10 | Update    |   14"
  echo

  # STEP 8
  echo "  Step 8: Reinstall a core package (bash) to repair missing files."
  read -p "  lab@rhel-lab119:~$ " cmd8
  echo
  if [[ "$cmd8" != "sudo yum reinstall -y bash" && \
        "$cmd8" != "yum reinstall -y bash" && \
        "$cmd8" != "sudo yum reinstall bash" && \
        "$cmd8" != "yum reinstall bash" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Dependencies resolved."
  echo "  Reinstalling:"
  echo "    bash.x86_64  5.1.8-6.el9  baseos"
  echo "  Complete!"
  echo

  # STEP 9
  echo "  Step 9: Clean cached metadata."
  read -p "  lab@rhel-lab119:~$ " cmd9
  echo
  if [[ "$cmd9" != "yum clean metadata" && "$cmd9" != "sudo yum clean metadata" && "$cmd9" != "yum clean all" && "$cmd9" != "sudo yum clean all" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  0 files removed"
  echo

  # STEP 10
  echo "  Step 10: Confirm enabled repos again (verification step)."
  read -p "  lab@rhel-lab119:~$ " cmd10
  echo
  if [[ "$cmd10" != "yum repolist" && "$cmd10" != "sudo yum repolist" && "$cmd10" != "yum repolist enabled" && "$cmd10" != "sudo yum repolist enabled" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  repo id                               repo name"
  echo "  appstream                             Rocky Linux 9 - AppStream"
  echo "  baseos                                Rocky Linux 9 - BaseOS"
  echo "  extras                                Rocky Linux 9 - Extras"
  echo

  print_success "Great job."
  print_info "You practiced yum workflows used in real admin work:"
  print_info "- repo verification, package discovery, file ownership lookup, update checks, and history review"
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
