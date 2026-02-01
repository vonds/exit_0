#!/bin/bash

# Lab 540: Manage Software Using Flatpak (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 540: Manage Software Using Flatpak (RHCSA)"
LAB_ID="lab540"
LAB_XP=54000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab540:~$ "

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
  center_text "A workstation uses Flatpak to install sandboxed desktop applications."
  center_text "You must install Flatpak, manage remotes, search, install, run,"
  center_text "inspect, update, remove applications, and understand scope and permissions."
  echo
  center_text "Targets:"
  center_text "- flatpak install / uninstall"
  center_text "- flatpak remote-add / remote-list"
  center_text "- flatpak search / list"
  center_text "- flatpak run"
  center_text "- flatpak info / permissions"
  center_text "- flatpak update"
  center_text "- flatpak override"
  center_text "- system vs user installs"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Verify Flatpak is installed."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "flatpak --version" ]]; then
    print_error "Incorrect. Use: flatpak --version"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Flatpak 1.x.x"
  echo

  echo "  Step 2: List configured Flatpak remotes."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "flatpak remotes" ]]; then
    print_error "Incorrect. Use: flatpak remotes"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  flathub  system"
  echo

  echo "  Step 3: Add the Flathub remote system-wide."
  echo "          (Use --if-not-exists and --system)"
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo flatpak remote-add --if-not-exists --system flathub https://flathub.org/repo/flathub.flatpakrepo" ]]; then
    print_error "Incorrect."
    print_error "Use: sudo flatpak remote-add --if-not-exists --system flathub https://flathub.org/repo/flathub.flatpakrepo"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Flathub remote added."
  echo

  echo "  Step 4: Verify the remote configuration."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "flatpak remote-list" ]]; then
    print_error "Incorrect. Use: flatpak remote-list"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Name     Options"
  echo "  flathub  system"
  echo

  echo "  Step 5: Search Flathub for the 'org.gnome.Calculator' application."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "flatpak search calculator" ]]; then
    print_error "Incorrect. Use: flatpak search calculator"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Name        Description           Application ID"
  echo "  Calculator  Perform calculations  org.gnome.Calculator"
  echo

  echo "  Step 6: Install org.gnome.Calculator system-wide."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo flatpak install -y flathub org.gnome.Calculator" ]]; then
    print_error "Incorrect."
    print_error "Use: sudo flatpak install -y flathub org.gnome.Calculator"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Installing: org.gnome.Calculator"
  echo

  echo "  Step 7: List installed Flatpak applications."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "flatpak list" ]]; then
    print_error "Incorrect. Use: flatpak list"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Application ID             Branch  Installation"
  echo "  org.gnome.Calculator       stable  system"
  echo

  echo "  Step 8: Display detailed information about the application."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "flatpak info org.gnome.Calculator" ]]; then
    print_error "Incorrect. Use: flatpak info org.gnome.Calculator"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  ID: org.gnome.Calculator"
  echo "  Installation: system"
  echo "  Runtime: org.gnome.Platform"
  echo

  echo "  Step 9: Show application permissions."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "flatpak info --show-permissions org.gnome.Calculator" ]]; then
    print_error "Incorrect."
    print_error "Use: flatpak info --show-permissions org.gnome.Calculator"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  [Context]"
  echo "  shared=network;ipc"
  echo

  echo "  Step 10: Launch the application from the terminal."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "flatpak run org.gnome.Calculator" ]]; then
    print_error "Incorrect. Use: flatpak run org.gnome.Calculator"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (Calculator window opens)"
  echo

  echo "  Step 11: Check for available Flatpak updates."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "flatpak update --dry-run" ]]; then
    print_error "Incorrect. Use: flatpak update --dry-run"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Nothing to update."
  echo

  echo "  Step 12: Apply all Flatpak updates system-wide."
  read -p "$PROMPT" cmd12
  echo
  if [[ "$cmd12" != "sudo flatpak update -y" ]]; then
    print_error "Incorrect. Use: sudo flatpak update -y"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  All Flatpak applications are up to date."
  echo

  echo "  Step 13: Override permissions to disable network access."
  read -p "$PROMPT" cmd13
  echo
  if [[ "$cmd13" != "sudo flatpak override --nosocket=network org.gnome.Calculator" ]]; then
    print_error "Incorrect."
    print_error "Use: sudo flatpak override --nosocket=network org.gnome.Calculator"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Network access removed."
  echo

  echo "  Step 14: Verify overridden permissions."
  read -p "$PROMPT" cmd14
  echo
  if [[ "$cmd14" != "flatpak info --show-permissions org.gnome.Calculator" ]]; then
    print_error "Incorrect. Use: flatpak info --show-permissions org.gnome.Calculator"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  network=none"
  echo

  echo "  Step 15: Remove the application."
  read -p "$PROMPT" cmd15
  echo
  if [[ "$cmd15" != "sudo flatpak uninstall -y org.gnome.Calculator" ]]; then
    print_error "Incorrect."
    print_error "Use: sudo flatpak uninstall -y org.gnome.Calculator"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Application removed."
  echo

  echo "  Step 16: Remove unused runtimes."
  read -p "$PROMPT" cmd16
  echo
  if [[ "$cmd16" != "sudo flatpak uninstall --unused -y" ]]; then
    print_error "Incorrect."
    print_error "Use: sudo flatpak uninstall --unused -y"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Unused runtimes removed."
  echo

  print_success "Outstanding work."
  print_info "You successfully:"
  print_info "- managed Flatpak remotes system-wide"
  print_info "- searched, installed, ran, updated, and removed applications"
  print_info "- inspected application metadata and permissions"
  print_info "- modified sandbox permissions using overrides"
  print_info "- cleaned unused runtimes"
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
