#!/bin/bash

# Lab 486: RHCSA Documentation — man, info, apropos, and /usr/share/doc
# Focus: locating and using system documentation efficiently under exam conditions.
# Key skills: man (search + sections), info, apropos, whatis, --help, help (built-ins),
# and reading package docs in /usr/share/doc.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 486: System Documentation (man, info, /usr/share/doc)"
LAB_ID="lab486"
LAB_XP=48600
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab486:~$ "

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
  center_text "You are troubleshooting a system and must quickly find accurate information"
  center_text "using built-in documentation tools available on any RHEL system."
  echo
  center_text "Goal:"
  center_text "- Navigate man pages and search within them"
  center_text "- Use info pages"
  center_text "- Discover commands with apropos / whatis"
  center_text "- Read package documentation in /usr/share/doc"
  center_text "- Use --help and shell built-in help"
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Open man page
  echo "  Step 1: Open the man page for the tar command."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "man tar" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (man page opens)"
  echo "  tar — an archiving utility"
  echo "  Press 'q' to quit."
  echo

  # STEP 2: Search within man page
  echo "  Step 2: While inside the tar man page, search for the gzip option."
  echo "          (Type the search exactly as you would in man.)"
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "/gzip" ]]; then
    print_error "Incorrect. This is an in-man search."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  -z, --gzip, --gunzip, --ungzip"
  echo

  # STEP 3: Use info
  echo "  Step 3: Open the info documentation for tar."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "info tar" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  File: tar.info,  Node: Top"
  echo "  Tar is a program for packaging a set of files..."
  echo "  Press 'q' to quit."
  echo

  # STEP 4: Explore /usr/share/doc
  echo "  Step 4: List the documentation directory for the httpd package."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "ls /usr/share/doc/httpd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  README"
  echo "  CHANGES"
  echo "  LICENSE"
  echo

  # STEP 5: Read README from /usr/share/doc
  echo "  Step 5: Display the README file for the httpd package."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "cat /usr/share/doc/httpd/README" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  This directory contains documentation for the Apache HTTP Server."
  echo "  ..."
  echo

  # STEP 6: Discover commands with apropos
  echo "  Step 6: Find commands related to archiving."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "apropos archive" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  tar (1)          - an archiving utility"
  echo "  gzip (1)         - compress or expand files"
  echo "  cpio (1)         - copy files to and from archives"
  echo

  # STEP 7: Use --help
  echo "  Step 7: Display quick help for the cp command."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "cp --help" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Usage: cp [OPTION]... [-T] SOURCE DEST"
  echo "  -r, -R, --recursive   copy directories recursively"
  echo

  # STEP 8: Use shell built-in help
  echo "  Step 8: Display built-in shell help for the cd command."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "help cd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  cd: cd [-L|[-P [-e]] [-@]] [dir]"
  echo "  Change the shell working directory."
  echo

  # STEP 9: Use man section
  echo "  Step 9: Open the man page describing the passwd file format."
  echo "          (Hint: this is not the passwd command.)"
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "man 5 passwd" ]]; then
    print_error "Incorrect. Specify the correct man section."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  passwd(5) — password file"
  echo "  /etc/passwd contains user account information."
  echo

  print_success "Excellent work."
  print_info "You demonstrated RHCSA-level documentation skills:"
  print_info "- navigating man pages and searching within them"
  print_info "- using info for GNU utilities"
  print_info "- discovering commands with apropos"
  print_info "- reading package docs in /usr/share/doc"
  print_info "- using --help and shell built-in help"
  print_info "You earned $LAB_XP XP for completing this lab."
  award_xp $LAB_XP

  XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON"); export XP; export LEVEL
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
