#!/bin/bash

# Lab 541R: Configure Autofs for On-Demand NFS Mount (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 541R: Configure Autofs for On-Demand NFS Mount"
LAB_ID="lab541r"
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
  center_text "ServerA must access an NFS share using Autofs so the"
  center_text "mount occurs only when the directory is accessed."
  echo
  center_text "Remote Share:"
  center_text "192.168.1.100:/shares/public"
  center_text "Local Mount Point:"
  center_text "/data/public"
  echo

  center_text "Press Enter to begin..."
  read _
  draw_lab_ui


  echo "  Step 1: Install the required NFS and Autofs packages."
  read -p "$PROMPT" cmd1
  echo

  if [[ "$cmd1" != "sudo dnf install -y nfs-utils autofs" ]]; then
    print_error "Incorrect. Use: sudo dnf install -y nfs-utils autofs"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Installed:"
  echo "    autofs"
  echo "    nfs-utils"
  echo


  echo "  Step 2: Create the base directory where the NFS share will mount."
  read -p "$PROMPT" cmd2
  echo

  if [[ "$cmd2" != "sudo mkdir -p /data" ]]; then
    print_error "Incorrect. Use: sudo mkdir -p /data"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 3: Inspect the Autofs master configuration."
  read -p "$PROMPT" cmd3
  echo

  if [[ "$cmd3" != "grep -v '^#' /etc/auto.master" ]]; then
    print_error "Incorrect. Use: grep -v '^#' /etc/auto.master"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  /misc   /etc/auto.misc"
  echo


  echo "  Step 4: Add a new Autofs map for /data."
  read -p "$PROMPT" cmd4
  echo

  if [[ "$cmd4" != "echo '/data /etc/auto.data' | sudo tee -a /etc/auto.master > /dev/null" ]]; then
    print_error "Incorrect."
    print_info "Use: echo '/data /etc/auto.data' | sudo tee -a /etc/auto.master > /dev/null"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 5: Create the map file defining the NFS mount."
  read -p "$PROMPT" cmd5
  echo

  if [[ "$cmd5" != "echo 'public -fstype=nfs 192.168.1.100:/shares/public' | sudo tee /etc/auto.data > /dev/null" ]]; then
    print_error "Incorrect."
    print_info "Use: echo 'public -fstype=nfs 192.168.1.100:/shares/public' | sudo tee /etc/auto.data > /dev/null"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo


  echo "  Step 6: Enable and start the Autofs service."
  read -p "$PROMPT" cmd6
  echo

  if [[ "$cmd6" != "sudo systemctl enable --now autofs" ]]; then
    print_error "Incorrect. Use: sudo systemctl enable --now autofs"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Created symlink /etc/systemd/system/multi-user.target.wants/autofs.service"
  echo


  echo "  Step 7: Access the directory to trigger the on-demand mount."
  read -p "$PROMPT" cmd7
  echo

  if [[ "$cmd7" != "ls /data/public" ]]; then
    print_error "Incorrect. Use: ls /data/public"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  project1"
  echo "  project2"
  echo "  shared_docs"
  echo


  echo "  Step 8: Verify the mount is active."
  read -p "$PROMPT" cmd8
  echo

  if [[ "$cmd8" != "mount | grep public" ]]; then
    print_error "Incorrect. Use: mount | grep public"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  192.168.1.100:/shares/public on /data/public type nfs"
  echo


  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- installed autofs and NFS tools"
  print_info "- configured an autofs master map"
  print_info "- created a custom autofs map file"
  print_info "- configured an on-demand NFS mount"
  print_info "- enabled the autofs service"
  print_info "- verified the mount activates on access"
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