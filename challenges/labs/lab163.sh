#!/bin/bash

# Lab Security 1: Flatpak Trust, Remotes, Permissions & Policy (part 1)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 163: Flatpak Trust, Remotes & Permissions (1)"
LAB_ID="lab163"
LAB_XP=28600
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab-sec1:~$ "

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
  center_text "A developer reports: \"My Flatpak app can read my home directory and access the network.\""
  center_text "You must audit Flatpak remotes and permissions, then apply a tighter policy."
  center_text "Your changes must be verifiable and the app must still launch."
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Confirm Flatpak is installed (check version)."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "flatpak --version" ]]; then
    print_error "Incorrect. Use: flatpak --version"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Flatpak 1.14.6"
  echo

  echo "  Step 2: List configured remotes with details."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "flatpak remotes --show-details" ]]; then
    print_error "Incorrect. Use: flatpak remotes --show-details"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Name     Title    URL                                         Collection ID  Subset  Filter  Priority  Options"
  echo "  flathub  Flathub  https://dl.flathub.org/repo/                 org.flathub    -       -       1         system"
  echo

  echo "  Step 3: Confirm Flathub is installed as a system remote."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "flatpak remote-list --system" ]]; then
    print_error "Incorrect. Use: flatpak remote-list --system"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Name     Options"
  echo "  flathub  system"
  echo

  echo "  Step 4: Search Flathub for Flatseal (permissions manager)."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "flatpak search flatseal" ]]; then
    print_error "Incorrect. Use: flatpak search flatseal"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Name      Description                         Application ID                 Version  Branch  Remotes"
  echo "  Flatseal  Manage Flatpak application permissions  com.github.tchx84.Flatseal  2.2.0    stable  flathub"
  echo

  echo "  Step 5: Install Flatseal from Flathub (system install, non-interactive)."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo flatpak install -y flathub com.github.tchx84.Flatseal" ]]; then
    print_error "Incorrect. Use: sudo flatpak install -y flathub com.github.tchx84.Flatseal"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Looking for matches…"
  echo "  Installing…"
  echo "  1. [####################] org.gnome.Platform 45"
  echo "  2. [####################] com.github.tchx84.Flatseal 2.2.0 stable"
  echo "  Installation complete."
  echo

  echo "  Step 6: Confirm an example app is installed (Firefox Flatpak)."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "flatpak list --app | grep -i firefox" ]]; then
    print_error "Incorrect. Use: flatpak list --app | grep -i firefox"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Firefox  org.mozilla.firefox  123.0.1  stable  flathub  system"
  echo

  echo "  Step 7: Inspect current permissions for the Firefox Flatpak."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "flatpak info --show-permissions org.mozilla.firefox" ]]; then
    print_error "Incorrect. Use: flatpak info --show-permissions org.mozilla.firefox"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  [Context]"
  echo "  shared=network;ipc;"
  echo "  sockets=x11;pulseaudio;"
  echo "  devices=dri;"
  echo "  filesystems=home;xdg-download;"
  echo "  [Session Bus Policy]"
  echo "  org.freedesktop.Notifications=talk"
  echo

  echo "  Step 8: Restrict filesystem access by removing home and download access via an override."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo flatpak override --nosocket=ssh-auth --nofilesystem=home --nofilesystem=xdg-download org.mozilla.firefox" ]]; then
    print_error "Incorrect. Use: sudo flatpak override --nosocket=ssh-auth --nofilesystem=home --nofilesystem=xdg-download org.mozilla.firefox"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 9: Restrict network access for Firefox using an override."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo flatpak override --unshare=network org.mozilla.firefox" ]]; then
    print_error "Incorrect. Use: sudo flatpak override --unshare=network org.mozilla.firefox"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 10: Verify the applied override(s) for Firefox."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "flatpak override --show org.mozilla.firefox" ]]; then
    print_error "Incorrect. Use: flatpak override --show org.mozilla.firefox"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  [Context]"
  echo "  unshare=network;"
  echo "  filesystems=!home;!xdg-download;"
  echo "  sockets=!ssh-auth;"
  echo

  echo "  Step 11: Launch Firefox to confirm it still starts (but has no network)."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "flatpak run org.mozilla.firefox" ]]; then
    print_error "Incorrect. Use: flatpak run org.mozilla.firefox"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  [flatpak] Launching org.mozilla.firefox..."
  echo "  (GUI application started)"
  echo "  (Browsing fails as expected: network is disabled by override)"
  echo "  (Application exited)"
  echo

  echo "  Step 12: Remove the network restriction override (restore normal connectivity)."
  read -p "$PROMPT" cmd12
  echo
  if [[ "$cmd12" != "sudo flatpak override --reset org.mozilla.firefox" ]]; then
    print_error "Incorrect. Use: sudo flatpak override --reset org.mozilla.firefox"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "Audited remotes and validated trust source"
  print_info "Installed Flatseal for permission reviews"
  print_info "Inspected app permissions with flatpak info"
  print_info "Applied and verified overrides to tighten access"
  print_info "Validated behavior by launching the app"
  print_info "Reset overrides to restore defaults"
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