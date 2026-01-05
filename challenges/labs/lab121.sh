#!/bin/bash

# Lab 121: Configure DNF/YUM Repositories on RHEL (/etc/yum.repos.d)
# Focus: auditing enabled repos, safely adding a repo file, validating repodata, and disabling it cleanly
# Key skills: dnf repolist, dnf repoinfo, /etc/yum.repos.d/*.repo, dnf config-manager,
# curl, rpm --import, dnf makecache, dnf clean, and safe verification.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 121: Configure DNF Repositories (RHEL)"
LAB_ID="lab121"
LAB_XP=3100
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
  center_text "A RHEL server was cloned into a lab network and package installs are failing."
  center_text "The admin suspects the repo configuration is incomplete or a custom repo was added incorrectly."
  center_text "You must audit enabled repos, add a repo file safely, validate metadata, then disable it."
  echo
  center_text "Goal: manage repos under /etc/yum.repos.d and verify dnf can read repodata."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1
  echo "  Step 1: List enabled repositories."
  read -p "  lab@rhel-lab121:~$ " cmd1
  echo
  if [[ "$cmd1" != "dnf repolist" && \
        "$cmd1" != "sudo dnf repolist" && \
        "$cmd1" != "dnf repolist enabled" && \
        "$cmd1" != "sudo dnf repolist enabled" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  repo id                      repo name"
  echo "  appstream                    Rocky Linux 9 - AppStream"
  echo "  baseos                       Rocky Linux 9 - BaseOS"
  echo "  extras                       Rocky Linux 9 - Extras"
  echo

  # STEP 2
  echo "  Step 2: Show the repo definitions currently present on disk."
  read -p "  lab@rhel-lab121:~$ " cmd2
  echo
  if [[ "$cmd2" != "ls -1 /etc/yum.repos.d" && "$cmd2" != "sudo ls -1 /etc/yum.repos.d" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  rocky.repo"
  echo "  rocky-addons.repo"
  echo

  # STEP 3
  echo "  Step 3: Back up an existing repo file before changes."
  read -p "  lab@rhel-lab121:~$ " cmd3
  echo
  if [[ "$cmd3" != "sudo cp /etc/yum.repos.d/rocky.repo /etc/yum.repos.d/rocky.repo.bak" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Backup created: /etc/yum.repos.d/rocky.repo.bak"
  echo

  # STEP 4
  echo "  Step 4: Inspect the details for one enabled repo (BaseOS)."
  read -p "  lab@rhel-lab121:~$ " cmd4
  echo
  if [[ "$cmd4" != "dnf repoinfo baseos" && "$cmd4" != "sudo dnf repoinfo baseos" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Repo-id            : baseos"
  echo "  Repo-name          : Rocky Linux 9 - BaseOS"
  echo "  Repo-baseurl       : https://download.rockylinux.org/pub/rocky/9/BaseOS/x86_64/os/"
  echo "  Repo-enabled       : yes"
  echo

  # STEP 5
  echo "  Step 5: Add a custom repo file under /etc/yum.repos.d (custom.repo)."
  read -p "  lab@rhel-lab121:~$ " cmd5
  echo
  if [[ "$cmd5" != "sudo vim /etc/yum.repos.d/custom.repo" && \
        "$cmd5" != "sudo nano /etc/yum.repos.d/custom.repo" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (editor opened)"
  echo "  (custom.repo saved)"
  echo

  # STEP 6
  echo "  Step 6: Verify the repo file you created is readable and contains a repo id."
  read -p "  lab@rhel-lab121:~$ " cmd6
  echo
  if [[ "$cmd6" != "sudo cat /etc/yum.repos.d/custom.repo" && \
        "$cmd6" != "cat /etc/yum.repos.d/custom.repo" && \
        "$cmd6" != "sudo sed -n '1,120p' /etc/yum.repos.d/custom.repo" && \
        "$cmd6" != "sed -n '1,120p' /etc/yum.repos.d/custom.repo" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  [custom-tools]"
  echo "  name=Custom Tools Repo"
  echo "  baseurl=https://repo.example.lab/rhel/9/x86_64/"
  echo "  enabled=1"
  echo "  gpgcheck=0"
  echo

  # STEP 7
  echo "  Step 7: Build repo metadata cache (validate DNF can read repo configuration)."
  read -p "  lab@rhel-lab121:~$ " cmd7
  echo
  if [[ "$cmd7" != "sudo dnf makecache" && "$cmd7" != "dnf makecache" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Rocky Linux 9 - BaseOS                          2.1 MB/s | 2.2 MB     00:01"
  echo "  Rocky Linux 9 - AppStream                       3.8 MB/s | 8.6 MB     00:02"
  echo "  Custom Tools Repo                                0.0  B/s |   0  B     00:00"
  echo "  Errors during downloading metadata for repository 'custom-tools':"
  echo "    - Status code: 404 for https://repo.example.lab/rhel/9/x86_64/repodata/repomd.xml"
  echo

  # STEP 8
  echo "  Step 8: Disable the custom repo safely (without deleting the file)."
  read -p "  lab@rhel-lab121:~$ " cmd8
  echo
  if [[ "$cmd8" != "sudo dnf config-manager --set-disabled custom-tools" && \
        "$cmd8" != "dnf config-manager --set-disabled custom-tools" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Repository 'custom-tools' is disabled."
  echo

  # STEP 9
  echo "  Step 9: Clean metadata and rebuild cache so the error is gone."
  read -p "  lab@rhel-lab121:~$ " cmd9
  echo
  if [[ "$cmd9" != "sudo dnf clean metadata" && \
        "$cmd9" != "dnf clean metadata" && \
        "$cmd9" != "sudo dnf clean all" && \
        "$cmd9" != "dnf clean all" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  0 files removed"
  echo
  echo "  Step 10: Confirm the custom repo no longer appears as enabled."
  read -p "  lab@rhel-lab121:~$ " cmd10
  echo
  if [[ "$cmd10" != "dnf repolist enabled" && \
        "$cmd10" != "sudo dnf repolist enabled" && \
        "$cmd10" != "dnf repolist" && \
        "$cmd10" != "sudo dnf repolist" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  repo id                      repo name"
  echo "  appstream                    Rocky Linux 9 - AppStream"
  echo "  baseos                       Rocky Linux 9 - BaseOS"
  echo "  extras                       Rocky Linux 9 - Extras"
  echo "  (custom-tools is disabled)"
  echo

  print_success "Great job."
  print_info "You managed repository configuration the RHEL way:"
  print_info "- audited enabled repos, edited /etc/yum.repos.d/*.repo, validated metadata with dnf makecache,"
  print_info "- and disabled a broken repo cleanly using dnf config-manager."
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
