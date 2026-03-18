#!/bin/bash

# Lab 541E: Configure Flatpak and Install an Application (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 541E: Configure Flatpak and Install an Application"
LAB_ID="lab541e"
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
  center_text "ServerA must allow installing desktop applications using"
  center_text "Flatpak. Configure the Flathub remote repository and install"
  center_text "the GNOME Text Editor application."
  echo

  center_text "Requirements:"
  center_text "- Remote repository name: flathub"
  center_text "- Remote URL: https://dl.flathub.org/repo/flathub.flatpakrepo"
  center_text "- Application: org.gnome.TextEditor"
  echo

  center_text "Press Enter to begin..."
  read _
  draw_lab_ui


  echo "  Step 1: Verify that the Flatpak command is available."
  read -p "$PROMPT" cmd1
  echo

  if [[ "$cmd1" != "flatpak --version" && "$cmd1" != "sudo flatpak --version" ]]; then
      print_error "Incorrect. Use: flatpak --version"
      read -p "Press Enter to retry..." _
      continue
  fi

  echo "  Flatpak 1.15.8"
  echo


  echo "  Step 2: Inspect the currently configured Flatpak remotes."
  read -p "$PROMPT" cmd2
  echo

  if [[ "$cmd2" != "flatpak remotes" && "$cmd2" != "sudo flatpak remotes" ]]; then
      print_error "Incorrect. Use: flatpak remotes"
      read -p "Press Enter to retry..." _
      continue
  fi

  echo "  (no remotes configured)"
  echo


  echo "  Step 3: Add the Flathub remote repository."
  read -p "$PROMPT" cmd3
  echo

  if [[ "$cmd3" != "flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo" && \
        "$cmd3" != "sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo" ]]; then
      print_error "Incorrect."
      print_info "Use: flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo"
      read -p "Press Enter to retry..." _
      continue
  fi
  echo


  echo "  Step 4: Verify the Flathub remote was added."
  read -p "$PROMPT" cmd4
  echo

  if [[ "$cmd4" != "flatpak remotes" && "$cmd4" != "sudo flatpak remotes" ]]; then
      print_error "Incorrect. Use: flatpak remotes"
      read -p "Press Enter to retry..." _
      continue
  fi

  echo "  flathub"
  echo


  echo "  Step 5: Install the GNOME Text Editor application from Flathub."
  read -p "$PROMPT" cmd5
  echo

  if [[ "$cmd5" != "flatpak install -y flathub org.gnome.TextEditor" && \
        "$cmd5" != "sudo flatpak install -y flathub org.gnome.TextEditor" ]]; then
      print_error "Incorrect."
      print_info "Use: flatpak install -y flathub org.gnome.TextEditor"
      read -p "Press Enter to retry..." _
      continue
  fi

  echo "  Installing: org.gnome.TextEditor"
  echo "  Installation complete."
  echo


  echo "  Step 6: Verify the installed Flatpak applications."
  read -p "$PROMPT" cmd6
  echo

  if [[ "$cmd6" != "flatpak list" && "$cmd6" != "sudo flatpak list" ]]; then
      print_error "Incorrect. Use: flatpak list"
      read -p "Press Enter to retry..." _
      continue
  fi

  echo "  Name               Application ID          Version"
  echo "  GNOME Text Editor org.gnome.TextEditor     46.0"
  echo


  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- verified Flatpak availability"
  print_info "- inspected existing Flatpak remotes"
  print_info "- added the Flathub remote repository"
  print_info "- installed the GNOME Text Editor application"
  print_info "- verified the installed Flatpak software"
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
