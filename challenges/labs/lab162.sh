#!/bin/bash

# Lab 162: Flatpak App Deployment for a Locked-Down Workstation (real scenario)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 162: Flatpak Real-World App Deployment (Obsidian)"
LAB_ID="lab162"
LAB_XP=15800
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT=" examuser@rhel-lab162:~$ "

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
  center_text "A developer on a managed workstation requests Obsidian for documentation."
  center_text "They cannot install RPMs. You will deploy the app using Flatpak."
  center_text "You must verify Flatpak, add Flathub if missing, install, verify, update, and remove."
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Confirm Flatpak is installed by checking its version."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "flatpak --version" ]]; then
    print_error "Incorrect. Use: flatpak --version"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Flatpak 1.14.6"
  echo

  echo "  Step 2: Check which Flatpak remotes are configured on this workstation."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "flatpak remotes --show-details" ]]; then
    print_error "Incorrect. Use: flatpak remotes --show-details"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Name    Title   URL                                      Collection ID  Subset  Filter  Priority  Options"
  echo "  fedora  Fedora  oci+https://registry.fedoraproject.org    -              -       -       1         system"
  echo

  echo "  Step 3: Add Flathub system-wide because it is not present."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo" ]]; then
    print_error "Incorrect. Use: sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  [sudo] password for lab:"
  echo "  Remote 'flathub' successfully added."
  echo

  echo "  Step 4: Confirm Flathub now appears in the remote list."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "flatpak remotes" ]]; then
    print_error "Incorrect. Use: flatpak remotes"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Name"
  echo "  fedora"
  echo "  flathub"
  echo

  echo "  Step 5: Search Flathub for the Obsidian app ID before installing."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "flatpak search obsidian" ]]; then
    print_error "Incorrect. Use: flatpak search obsidian"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Name      Description                    Application ID         Version  Branch  Remotes"
  echo "  Obsidian  Markdown-based knowledge base  md.obsidian.Obsidian   1.5.8    stable  flathub"
  echo

  echo "  Step 6: Install Obsidian from Flathub."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "flatpak install -y flathub md.obsidian.Obsidian" ]]; then
    print_error "Incorrect. Use: flatpak install -y flathub md.obsidian.Obsidian"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Looking for matches…"
  echo "  Required runtime for md.obsidian.Obsidian/x86_64/stable (runtime/org.freedesktop.Platform/x86_64/23.08) found in remote flathub"
  echo "  Installing…"
  echo "  1. [####################] org.freedesktop.Platform 23.08"
  echo "  2. [####################] md.obsidian.Obsidian 1.5.8 stable"
  echo "  Installation complete."
  echo

  echo "  Step 7: List installed Flatpak applications to confirm Obsidian is present."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "flatpak list --app" ]]; then
    print_error "Incorrect. Use: flatpak list --app"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Name      Application ID         Version  Branch  Origin   Installation"
  echo "  Obsidian  md.obsidian.Obsidian   1.5.8    stable  flathub  system"
  echo

  echo "  Step 8: Display detailed information so you can document install details in the ticket."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "flatpak info md.obsidian.Obsidian" ]]; then
    print_error "Incorrect. Use: flatpak info md.obsidian.Obsidian"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  ID: md.obsidian.Obsidian"
  echo "  Ref: app/md.obsidian.Obsidian/x86_64/stable"
  echo "  Arch: x86_64"
  echo "  Branch: stable"
  echo "  Version: 1.5.8"
  echo "  Origin: flathub"
  echo "  Installation: system"
  echo "  Runtime: org.freedesktop.Platform/x86_64/23.08"
  echo

  echo "  Step 9: Launch Obsidian to verify the app starts successfully."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "flatpak run md.obsidian.Obsidian" ]]; then
    print_error "Incorrect. Use: flatpak run md.obsidian.Obsidian"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  [flatpak] Launching md.obsidian.Obsidian..."
  echo "  (GUI application started)"
  echo "  (User confirms app opens)"
  echo "  (Application exited)"
  echo

  echo "  Step 10: Run updates to ensure the workstation is current."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "flatpak update -y" ]]; then
    print_error "Incorrect. Use: flatpak update -y"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Looking for updates…"
  echo "  Nothing to do."
  echo

  echo "  Step 11: uninstall Obsidian."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "flatpak uninstall -y md.obsidian.Obsidian" ]]; then
    print_error "Incorrect. Use: flatpak uninstall -y md.obsidian.Obsidian"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Uninstalling md.obsidian.Obsidian…"
  echo "  Uninstallation complete."
  echo

  print_success "Excellent work."
  print_info "You successfully deployed and worked with Flatpak"
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