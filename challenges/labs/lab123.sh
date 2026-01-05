#!/bin/bash

# Lab 123: YUM & DNF Basics (search, info, install, remove, update, history)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 123: YUM & DNF Basics"
LAB_ID="lab123"
LAB_XP=3250
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
  center_text "Scenario: Manage software on an RPM-based system using YUM/DNF."
  center_text "Update metadata, search/info, install, verify, remove, check updates, upgrade, clean, and undo."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1
  echo "  Step 1: Build or refresh local repo metadata cache."
  read -p "  lab@lpic-lab123:~$ " cmd1
  echo
  if [[ "$cmd1" != "yum makecache" && \
        "$cmd1" != "sudo yum makecache" && \
        "$cmd1" != "dnf makecache" && \
        "$cmd1" != "sudo dnf makecache" ]]; then
    print_error "Incorrect. Use: yum makecache   or   dnf makecache"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Metadata cache created."
  echo

  # STEP 2
  echo "  Step 2: Search repositories for the 'htop' package."
  read -p "  lab@lpic-lab123:~$ " cmd2
  echo
  if [[ "$cmd2" != "yum search htop" && \
        "$cmd2" != "sudo yum search htop" && \
        "$cmd2" != "dnf search htop" && \
        "$cmd2" != "sudo dnf search htop" ]]; then
    print_error "Incorrect. Use: yum search htop   or   dnf search htop"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  ============================== Name Matched: htop =============================="
  echo "  htop.x86_64 : Interactive process viewer"
  echo

  # STEP 3
  echo "  Step 3: Show package information for 'htop'."
  read -p "  lab@lpic-lab123:~$ " cmd3
  echo
  if [[ "$cmd3" != "yum info htop" && \
        "$cmd3" != "sudo yum info htop" && \
        "$cmd3" != "dnf info htop" && \
        "$cmd3" != "sudo dnf info htop" ]]; then
    print_error "Incorrect. Use: yum info htop   or   dnf info htop"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Name         : htop"
  echo "  Version      : 3.3.0"
  echo "  Release      : 1.el9"
  echo "  Architecture : x86_64"
  echo "  Summary      : Interactive process viewer"
  echo "  From repo    : appstream"
  echo

  # STEP 4
  echo "  Step 4: Install the 'htop' package."
  read -p "  lab@lpic-lab123:~$ " cmd4
  echo
  if [[ "$cmd4" != "yum install htop" && \
        "$cmd4" != "sudo yum install htop" && \
        "$cmd4" != "dnf install htop" && \
        "$cmd4" != "sudo dnf install htop" && \
        "$cmd4" != "yum install -y htop" && \
        "$cmd4" != "sudo yum install -y htop" && \
        "$cmd4" != "dnf install -y htop" && \
        "$cmd4" != "sudo dnf install -y htop" ]]; then
    print_error "Incorrect. Use: yum install htop   or   dnf install htop"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Dependencies resolved."
  echo "  Installed: htop-3.3.0-1.el9.x86_64"
  echo

  # STEP 5
  echo "  Step 5: Verify that 'htop' is installed."
  read -p "  lab@lpic-lab123:~$ " cmd5
  echo
  if [[ "$cmd5" != "yum list installed htop" && \
        "$cmd5" != "sudo yum list installed htop" && \
        "$cmd5" != "dnf list installed htop" && \
        "$cmd5" != "sudo dnf list installed htop" ]]; then
    print_error "Incorrect. Use: yum list installed htop   or   dnf list installed htop"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Installed Packages"
  echo "  htop.x86_64  3.3.0-1.el9    @appstream"
  echo

  # STEP 6
  echo "  Step 6: Remove the 'htop' package."
  read -p "  lab@lpic-lab123:~$ " cmd6
  echo
  if [[ "$cmd6" != "yum remove htop" && \
        "$cmd6" != "sudo yum remove htop" && \
        "$cmd6" != "dnf remove htop" && \
        "$cmd6" != "sudo dnf remove htop" && \
        "$cmd6" != "yum erase htop" && \
        "$cmd6" != "sudo yum erase htop" && \
        "$cmd6" != "dnf erase htop" && \
        "$cmd6" != "sudo dnf erase htop" ]]; then
    print_error "Incorrect. Use: yum remove htop   or   dnf remove htop"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Removed: htop-3.3.0-1.el9.x86_64"
  echo

  # STEP 7
  echo "  Step 7: Check for available updates."
  read -p "  lab@lpic-lab123:~$ " cmd7
  echo
  if [[ "$cmd7" != "yum check-update" && \
        "$cmd7" != "sudo yum check-update" && \
        "$cmd7" != "dnf check-update" && \
        "$cmd7" != "sudo dnf check-update" ]]; then
    print_error "Incorrect. Use: yum check-update   or   dnf check-update"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Loaded plugins: fastestmirror"
  echo "  openssl.x86_64        1:3.0.7-24.el9_2     appstream"
  echo "  kernel.x86_64         6.6.0-100.el9        baseos"
  echo

  # STEP 8
  echo "  Step 8: Upgrade the system packages."
  read -p "  lab@lpic-lab123:~$ " cmd8
  echo
  if [[ "$cmd8" != "yum update" && \
        "$cmd8" != "sudo yum update" && \
        "$cmd8" != "yum upgrade" && \
        "$cmd8" != "sudo yum upgrade" && \
        "$cmd8" != "dnf update" && \
        "$cmd8" != "sudo dnf update" && \
        "$cmd8" != "dnf upgrade" && \
        "$cmd8" != "sudo dnf upgrade" ]]; then
    print_error "Incorrect. Use: yum update|upgrade   or   dnf update|upgrade"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Upgrades complete."
  echo

  # STEP 9
  echo "  Step 9: Clean cached metadata and packages."
  read -p "  lab@lpic-lab123:~$ " cmd9
  echo
  if [[ "$cmd9" != "yum clean all" && \
        "$cmd9" != "sudo yum clean all" && \
        "$cmd9" != "dnf clean all" && \
        "$cmd9" != "sudo dnf clean all" ]]; then
    print_error "Incorrect. Use: yum clean all   or   dnf clean all"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Cache and metadata removed."
  echo

  # STEP 10
  echo "  Step 10: Undo the last transaction using history."
  read -p "  lab@lpic-lab123:~$ " cmd10
  echo
  if [[ "$cmd10" != "yum history undo last" && \
        "$cmd10" != "sudo yum history undo last" && \
        "$cmd10" != "dnf history undo last" && \
        "$cmd10" != "sudo dnf history undo last" ]]; then
    print_error "Incorrect. Use: yum history undo last   or   dnf history undo last"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Undoing last transaction..."
  echo "  Complete."
  echo

  print_success "Lab complete."
  print_info "You earned $LAB_XP XP for completing this lab."
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
  read -p "  > " post_choice

  [[ "$post_choice" == "2" ]] && exit 0
done
