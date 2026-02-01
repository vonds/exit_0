#!/bin/bash

# Lab 533: Flatpak Application Management (RHEL)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 533: Flatpak Application Management (RHEL)"
LAB_ID="lab533"
LAB_XP=53300
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab533:~$ "

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
  center_text "Your system uses Flatpak to deliver desktop applications in a sandboxed way."
  center_text "You must verify Flatpak, configure Flathub, install an app, verify it, update,"
  center_text "and clean up applications and unused runtimes."
  echo
  center_text "Targets:"
  center_text "- flatpak --version"
  center_text "- flatpak remotes"
  center_text "- flatpak remote-add"
  center_text "- flatpak search"
  center_text "- flatpak install"
  center_text "- flatpak list"
  center_text "- flatpak update"
  center_text "- flatpak uninstall --unused"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Verify Flatpak is installed and available."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "flatpak --version" ]]; then
    print_error "Incorrect. Use: flatpak --version"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Flatpak 1.14.x"
  echo

  echo "  Step 2: List the configured Flatpak remotes."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "flatpak remotes" ]]; then
    print_error "Incorrect. Use: flatpak remotes"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Name    Options"
  echo "  (none)"
  echo

  echo "  Step 3: Add the Flathub remote if it does not exist."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo" ]]; then
    print_error "Incorrect. Use: flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Adding remote 'flathub'..."
  echo "  Remote 'flathub' added."
  echo

  echo "  Step 4: Search Flathub for Firefox."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "flatpak search firefox" ]]; then
    print_error "Incorrect. Use: flatpak search firefox"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Name     Description         Application ID         Version     Branch   Remotes"
  echo "  Firefox  Web Browser         org.mozilla.firefox    1xx.x       stable   flathub"
  echo

  echo "  Step 5: Install Firefox from Flathub (non-interactive)."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "flatpak install -y flathub org.mozilla.firefox" ]]; then
    print_error "Incorrect. Use: flatpak install -y flathub org.mozilla.firefox"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Looking for matches…"
  echo "  Installing: org.mozilla.firefox//stable"
  echo "  Installation complete."
  echo

  echo "  Step 6: List installed Flatpak applications (apps only)."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "flatpak list --app" ]]; then
    print_error "Incorrect. Use: flatpak list --app"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Name     Application ID        Version   Branch   Installation"
  echo "  Firefox  org.mozilla.firefox   1xx.x     stable   system"
  echo

  echo "  Step 7: Apply available updates for Flatpak apps and runtimes."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "flatpak update -y" ]]; then
    print_error "Incorrect. Use: flatpak update -y"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Looking for updates…"
  echo "  Nothing to do."
  echo

  echo "  Step 8: Remove Firefox and then remove unused runtimes (cleanup)."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "flatpak uninstall -y org.mozilla.firefox && flatpak uninstall -y --unused" ]]; then
    print_error "Incorrect. Use: flatpak uninstall -y org.mozilla.firefox && flatpak uninstall -y --unused"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Uninstalling: org.mozilla.firefox"
  echo "  Uninstall complete."
  echo "  Removing unused runtimes…"
  echo "  Nothing unused to uninstall."
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- verified Flatpak availability"
  print_info "- configured the Flathub remote"
  print_info "- searched for and installed an application"
  print_info "- verified installed Flatpak apps"
  print_info "- applied updates"
  print_info "- cleaned up apps and unused runtimes"
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
