#!/bin/bash

# Lab 541B: Configure a Local DNF Repository from ISO (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 541B: Configure a Local DNF Repository from ISO"
LAB_ID="lab541b"
LAB_XP=54100
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@servera:~$ "

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
  center_text "ServerA must install packages from the provided RHEL-10.iso image"
  center_text "instead of using remote repositories. Configure local BaseOS and"
  center_text "AppStream repositories so DNF can use them successfully."
  echo
  center_text "Important:"
  center_text "- Use dnf for package-management tasks"
  center_text "- Discover values from the system before using them"
  center_text "- Create a new repository file named local.repo"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Create the mount point directory /mnt if it does not already exist."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "sudo mkdir -p /mnt" ]]; then
    print_error "Incorrect. Use: sudo mkdir -p /mnt"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 2: Mount the provided RHEL-10.iso image at /mnt using a loop mount."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo mount -o loop RHEL-10.iso /mnt" ]]; then
    print_error "Incorrect. Use: sudo mount -o loop RHEL-10.iso /mnt"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 3: Inspect the contents of /mnt to discover the repository paths."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "ls /mnt" ]]; then
    print_error "Incorrect. Use: ls /mnt"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  AppStream"
  echo "  BaseOS"
  echo "  EFI"
  echo "  images"
  echo "  isolinux"
  echo

  echo "  Step 4: Inspect the existing repository definition directory."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "ls /etc/yum.repos.d/" ]]; then
    print_error "Incorrect. Use: ls /etc/yum.repos.d/"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  redhat.repo"
  echo

  echo "  Step 5: Create the BaseOS repository section header in /etc/yum.repos.d/local.repo."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "echo '[BaseOS]' | sudo tee /etc/yum.repos.d/local.repo > /dev/null" ]]; then
    print_error "Incorrect. Use: echo '[BaseOS]' | sudo tee /etc/yum.repos.d/local.repo > /dev/null"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 6: Add the BaseOS repository name."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "echo 'name=BaseOS' | sudo tee -a /etc/yum.repos.d/local.repo > /dev/null" ]]; then
    print_error "Incorrect. Use: echo 'name=BaseOS' | sudo tee -a /etc/yum.repos.d/local.repo > /dev/null"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 7: Add the BaseOS baseurl."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "echo 'baseurl=file:///mnt/BaseOS' | sudo tee -a /etc/yum.repos.d/local.repo > /dev/null" ]]; then
    print_error "Incorrect. Use: echo 'baseurl=file:///mnt/BaseOS' | sudo tee -a /etc/yum.repos.d/local.repo > /dev/null"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 8: Enable the BaseOS repository."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "echo 'enabled=1' | sudo tee -a /etc/yum.repos.d/local.repo > /dev/null" ]]; then
    print_error "Incorrect. Use: echo 'enabled=1' | sudo tee -a /etc/yum.repos.d/local.repo > /dev/null"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 9: Disable GPG checking for BaseOS."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "echo 'gpgcheck=0' | sudo tee -a /etc/yum.repos.d/local.repo > /dev/null" ]]; then
    print_error "Incorrect. Use: echo 'gpgcheck=0' | sudo tee -a /etc/yum.repos.d/local.repo > /dev/null"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 10: Add a blank line to separate the repository sections."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "echo '' | sudo tee -a /etc/yum.repos.d/local.repo > /dev/null" ]]; then
    print_error "Incorrect. Use: echo '' | sudo tee -a /etc/yum.repos.d/local.repo > /dev/null"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 11: Create the AppStream repository section header."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "echo '[AppStream]' | sudo tee -a /etc/yum.repos.d/local.repo > /dev/null" ]]; then
    print_error "Incorrect. Use: echo '[AppStream]' | sudo tee -a /etc/yum.repos.d/local.repo > /dev/null"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 12: Add the AppStream repository name."
  read -p "$PROMPT" cmd12
  echo
  if [[ "$cmd12" != "echo 'name=AppStream' | sudo tee -a /etc/yum.repos.d/local.repo > /dev/null" ]]; then
    print_error "Incorrect. Use: echo 'name=AppStream' | sudo tee -a /etc/yum.repos.d/local.repo > /dev/null"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 13: Add the AppStream baseurl."
  read -p "$PROMPT" cmd13
  echo
  if [[ "$cmd13" != "echo 'baseurl=file:///mnt/AppStream' | sudo tee -a /etc/yum.repos.d/local.repo > /dev/null" ]]; then
    print_error "Incorrect. Use: echo 'baseurl=file:///mnt/AppStream' | sudo tee -a /etc/yum.repos.d/local.repo > /dev/null"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 14: Enable the AppStream repository."
  read -p "$PROMPT" cmd14
  echo
  if [[ "$cmd14" != "echo 'enabled=1' | sudo tee -a /etc/yum.repos.d/local.repo > /dev/null" ]]; then
    print_error "Incorrect. Use: echo 'enabled=1' | sudo tee -a /etc/yum.repos.d/local.repo > /dev/null"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 15: Disable GPG checking for AppStream."
  read -p "$PROMPT" cmd15
  echo
  if [[ "$cmd15" != "echo 'gpgcheck=0' | sudo tee -a /etc/yum.repos.d/local.repo > /dev/null" ]]; then
    print_error "Incorrect. Use: echo 'gpgcheck=0' | sudo tee -a /etc/yum.repos.d/local.repo > /dev/null"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 16: Verify the repository file contents."
  read -p "$PROMPT" cmd16
  echo
  if [[ "$cmd16" != "cat /etc/yum.repos.d/local.repo" ]]; then
    print_error "Incorrect. Use: cat /etc/yum.repos.d/local.repo"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  [BaseOS]"
  echo "  name=BaseOS"
  echo "  baseurl=file:///mnt/BaseOS"
  echo "  enabled=1"
  echo "  gpgcheck=0"
  echo
  echo "  [AppStream]"
  echo "  name=AppStream"
  echo "  baseurl=file:///mnt/AppStream"
  echo "  enabled=1"
  echo "  gpgcheck=0"
  echo

  echo "  Step 17: Refresh the DNF repository metadata."
  read -p "$PROMPT" cmd17
  echo
  if [[ "$cmd17" != "sudo dnf clean all && sudo dnf makecache" ]]; then
    print_error "Incorrect. Use: sudo dnf clean all && sudo dnf makecache"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  0 files removed"
  echo "  Metadata cache created."
  echo

  echo "  Step 18: Verify that DNF can see the configured repositories."
  read -p "$PROMPT" cmd18
  echo
  if [[ "$cmd18" != "dnf repolist" && "$cmd18" != "sudo dnf repolist" ]]; then
    print_error "Incorrect. Use: dnf repolist"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  repo id      repo name"
  echo "  AppStream    AppStream"
  echo "  BaseOS       BaseOS"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- created the mount point and mounted the ISO"
  print_info "- inspected the mounted media to discover BaseOS and AppStream"
  print_info "- inspected /etc/yum.repos.d before creating a new repo file"
  print_info "- created a new local.repo file for BaseOS and AppStream"
  print_info "- disabled GPG checking as required"
  print_info "- verified the repo file contents"
  print_info "- refreshed metadata and confirmed DNF can see both repositories"
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
