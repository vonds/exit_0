#!/bin/bash

# Lab 225: Install Stratis and enable the stratisd service (SIMULATED & SAFE)
# SAFETY: This lab validates typed commands and prints canned outputs only.
#         No real packages, services, or filesystems are changed.
# Output policy: Show only realistic, canned command output. Silent steps print nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 225: Install Stratis + Enable stratisd"
LAB_ID="lab225"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

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
  center_text "Goal: Install Stratis (daemon + CLI) and enable the stratisd service."
  center_text "Then verify the daemon status and basic CLI functionality."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Check if Stratis packages are already present
  draw_lab_ui
  echo "  Step 1: Check if Stratis packages are installed."
  echo "          Expected (RHEL/Fedora): rpm -q stratisd stratis-cli"
  echo "          Or (Debian/Ubuntu):     dpkg -l stratisd stratis-cli"
  read -p "  lab@lab225:~$ " cmd1
  if [[ "$cmd1" == "rpm -q stratisd stratis-cli" ]]; then
    echo "package stratisd is not installed"
    echo "package stratis-cli is not installed"
  elif [[ "$cmd1" == "dpkg -l stratisd stratis-cli" ]]; then
    echo "Desired=Unknown/Install/Remove/Purge/Hold"
    echo "| Status=Not/Inst/Conf-files/Unpacked/halF-conf/Half-inst/trig-aWait/Trig-pend"
    echo "|/ Err?=(none)/Reinst-required (Status,Err: uppercase=bad)"
    echo "un  stratisd        <none>            <none>            (no description available)"
    echo "un  stratis-cli     <none>            <none>            (no description available)"
  else
    print_error "Use either: rpm -q stratisd stratis-cli   OR   dpkg -l stratisd stratis-cli"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 2: Install Stratis (daemon + CLI)
  echo "  Step 2: Install Stratis packages."
  echo "          Expected (RHEL/Fedora): sudo dnf install -y stratisd stratis-cli"
  echo "          Or (Debian/Ubuntu):     sudo apt-get install -y stratisd stratis-cli"
  read -p "  lab@lab225:~$ " cmd2
  if [[ "$cmd2" == "sudo dnf install -y stratisd stratis-cli" ]]; then
    echo "Last metadata expiration check: 0:12:03 ago on Tue 22 Jul 2025 11:48:01 AM UTC."
    echo "Dependencies resolved."
    echo "================================================================================"
    echo " Package       Arch     Version             Repository           Size"
    echo "================================================================================"
    echo "Installing:"
    echo " stratisd      x86_64   3.5.1-1.el9        appstream            1.3 M"
    echo " stratis-cli   noarch   3.5.1-1.el9        appstream            220 k"
    echo ""
    echo "Installed:"
    echo "  stratisd-3.5.1-1.el9.x86_64     stratis-cli-3.5.1-1.el9.noarch"
  elif [[ "$cmd2" == "sudo apt-get install -y stratisd stratis-cli" ]]; then
    echo "Reading package lists... Done"
    echo "Building dependency tree... Done"
    echo "Reading state information... Done"
    echo "The following NEW packages will be installed:"
    echo "  stratisd stratis-cli"
    echo "0 upgraded, 2 newly installed, 0 to remove and 0 not upgraded."
    echo "Setting up stratisd (3.5.1-1) ..."
    echo "Setting up stratis-cli (3.5.1-1) ..."
  else
    print_error "Use either: sudo dnf install -y stratisd stratis-cli   OR   sudo apt-get install -y stratisd stratis-cli"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 3: Enable and start stratisd
  echo "  Step 3: Enable and start the stratisd service."
  echo "          Expected: sudo systemctl enable --now stratisd"
  read -p "  lab@lab225:~$ " cmd3
  [[ "$cmd3" != "sudo systemctl enable --now stratisd" ]] && { print_error "Use: sudo systemctl enable --now stratisd"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 4: Check service status
  echo "  Step 4: Verify stratisd is running."
  echo "          Expected: systemctl status stratisd"
  read -p "  lab@lab225:~$ " cmd4
  [[ "$cmd4" != "systemctl status stratisd" ]] && { print_error "Use: systemctl status stratisd"; read -p "Press Enter to try again..." _; continue; }
  echo "  ● stratisd.service - Stratis daemon"
  echo "       Loaded: loaded (/usr/lib/systemd/system/stratisd.service; enabled; vendor preset: enabled)"
  echo "       Active: active (running) since Tue 2025-07-22 11:50:22 UTC; 6s ago"
  echo "     Main PID: 1879 (stratisd)"
  echo "        Tasks: 4 (limit: 32768)"
  echo "       Memory: 9.8M"
  echo "          CPU: 55ms"
  echo "       CGroup: /system.slice/stratisd.service"
  echo "               └─1879 /usr/libexec/stratis/stratisd"
  echo

  # Step 5: Confirm CLI works
  echo "  Step 5: Check the Stratis CLI."
  echo "          Expected: stratis --version"
  read -p "  lab@lab225:~$ " cmd5a
  [[ "$cmd5a" != "stratis --version" ]] && { print_error "Use: stratis --version"; read -p "Press Enter to try again..." _; continue; }
  echo "stratis 3.5.1"
  echo
  echo "          Expected: stratis pool list"
  read -p "  lab@lab225:~$ " cmd5b
  [[ "$cmd5b" != "stratis pool list" ]] && { print_error "Use: stratis pool list"; read -p "Press Enter to try again..." _; continue; }
  echo "Name   UUID   Total Physical   Free   Overprovisioned"
  # (no pools yet)
  echo

  # Step 6 (bonus): Verify service enables at boot
  echo "  Step 6 (bonus): Confirm enablement at boot."
  echo "          Expected: systemctl is-enabled stratisd"
  read -p "  lab@lab225:~$ " cmd6
  [[ "$cmd6" != "systemctl is-enabled stratisd" ]] && { print_error "Use: systemctl is-enabled stratisd"; read -p "Press Enter to try again..." _; continue; }
  echo "enabled"
  echo

  print_success "Nice work! Stratis installed, stratisd enabled and running, CLI verified (simulated)."
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
