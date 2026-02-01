#!/bin/bash

# Lab 513: Install and Update Software Packages (DNF, RHCSA-Style)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 513: Install and Update Software Packages (DNF)"
LAB_ID="lab513"
LAB_XP=51300
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab513:~$ "

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
  center_text "Scenario:"
  center_text "You are responsible for installing, updating, and managing software"
  center_text "packages using DNF from repositories and local RPM files."
  center_text "You must verify installations, search packages, and cleanly remove software."
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Verify the system is using dnf as the package manager."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "dnf --version" ]]; then
    print_error "Incorrect. Use: dnf --version"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  4.14.0"
  echo

  echo "  Step 2: List all enabled repositories."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "dnf repolist" ]]; then
    print_error "Incorrect. Use: dnf repolist"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  repo id            repo name"
  echo "  baseos             Rocky Linux BaseOS"
  echo "  appstream          Rocky Linux AppStream"
  echo

  echo "  Step 3: Search for the wget package."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "dnf search wget" ]]; then
    print_error "Incorrect. Use: dnf search wget"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  wget.x86_64 : A utility for retrieving files using HTTP or FTP"
  echo

  echo "  Step 4: Install the wget package from a remote repository."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo dnf install -y wget" ]]; then
    print_error "Incorrect. Use: sudo dnf install -y wget"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Installed:"
  echo "    wget.x86_64"
  echo

  echo "  Step 5: Verify that wget is installed."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "rpm -q wget" ]]; then
    print_error "Incorrect. Use: rpm -q wget"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  wget-1.21.1-10.el9.x86_64"
  echo

  echo "  Step 6: Install a local RPM package using dnf."
  echo "          The file is located at /tmp/vim-enhanced.rpm"
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo dnf install /tmp/vim-enhanced.rpm" ]]; then
    print_error "Incorrect. Use: sudo dnf install /tmp/vim-enhanced.rpm"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Installing:"
  echo "    vim-enhanced.x86_64"
  echo

  echo "  Step 7: Verify vim-enhanced installation."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "rpm -q vim-enhanced" ]]; then
    print_error "Incorrect. Use: rpm -q vim-enhanced"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  vim-enhanced-9.0.1677-1.el9.x86_64"
  echo

  echo "  Step 8: Update all installed packages."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo dnf update -y" ]]; then
    print_error "Incorrect. Use: sudo dnf update -y"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Complete!"
  echo

  echo "  Step 9: Remove the wget package."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo dnf remove -y wget" ]]; then
    print_error "Incorrect. Use: sudo dnf remove -y wget"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Removed:"
  echo "    wget.x86_64"
  echo

  echo "  Step 10: Verify wget is no longer installed."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "rpm -q wget" ]]; then
    print_error "Incorrect. Use: rpm -q wget"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  package wget is not installed"
  echo

  echo "  Step 11: Create a custom repository file using vim."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "sudo vim /etc/yum.repos.d/custom.repo" ]]; then
    print_error "Incorrect. Use: sudo vim /etc/yum.repos.d/custom.repo"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (vim opened)"
  echo

  echo "  Step 12: Add the following repository configuration EXACTLY:"
  echo "  [custom]"
  echo "  name=Custom Repo"
  echo "  baseurl=http://repo.example.com/packages"
  echo "  enabled=1"
  echo "  gpgcheck=0"
  read -p "  > " repo_line
  if [[ "$repo_line" != "baseurl=http://repo.example.com/packages" ]]; then
    print_error "Incorrect repo configuration."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 13: Verify repository list includes the custom repo."
  read -p "$PROMPT" cmd13
  echo
  if [[ "$cmd13" != "dnf repolist" ]]; then
    print_error "Incorrect. Use: dnf repolist"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  custom  Custom Repo"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- searched, installed, updated, and removed packages using dnf"
  print_info "- installed software from a local RPM"
  print_info "- verified installations using rpm"
  print_info "- configured a persistent custom repository"
  print_info "You earned $LAB_XP XP."

  award_xp $LAB_XP
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
