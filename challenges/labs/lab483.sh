#!/bin/bash

# Lab 483: RHCSA Archives & Compression — tar, gzip, and bzip2

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 483: Archive and Compress Files (tar, gzip, bzip2)"
LAB_ID="lab483"
LAB_XP=48300
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab483:~$ "

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
  center_text "You must archive, compress, extract, and inspect files"
  center_text "using tar, gzip, and bzip2 as expected on the RHCSA exam."
  echo
  center_text "Resources:"
  center_text "- Directory: /home/examuser/data"
  center_text "- Working directory: \$HOME"
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Create a tar archive
  echo "  Step 1: Create an uncompressed tar archive named archive.tar from ~/data."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "tar -cvf archive.tar /home/examuser/data" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  data/"
  echo "  data/file1.txt"
  echo "  data/file2.log"
  echo

  # STEP 2: List tar contents
  echo "  Step 2: List the contents of archive.tar without extracting."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "tar -tvf archive.tar" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  drwxr-xr-x examuser examuser 0 data/"
  echo "  -rw-r--r-- examuser examuser 128 file1.txt"
  echo "  -rw-r--r-- examuser examuser 256 file2.log"
  echo

  # STEP 3: Extract tar archive
  echo "  Step 3: Extract archive.tar into /tmp."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "tar -xvf archive.tar -C /tmp" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  data/"
  echo "  data/file1.txt"
  echo "  data/file2.log"
  echo

  # STEP 4: Compress a file with gzip
  echo "  Step 4: Compress myfile.txt using gzip."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "gzip myfile.txt" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  myfile.txt.gz"
  echo

  # STEP 5: Decompress gzip file
  echo "  Step 5: Decompress myfile.txt.gz."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "gunzip myfile.txt.gz" && "$cmd5" != "gzip -d myfile.txt.gz" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  myfile.txt"
  echo

  # STEP 6: Create gzip-compressed tar archive
  echo "  Step 6: Create archive.tar.gz from ~/data."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "tar -czvf archive.tar.gz /home/examuser/data" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  data/"
  echo "  data/file1.txt"
  echo "  data/file2.log"
  echo

  # STEP 7: Extract gzip tar archive
  echo "  Step 7: Extract archive.tar.gz into /tmp."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "tar -xzvf archive.tar.gz -C /tmp" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  data/"
  echo

  # STEP 8: Compress file with bzip2
  echo "  Step 8: Compress myfile.txt using bzip2."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "bzip2 myfile.txt" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  myfile.txt.bz2"
  echo

  # STEP 9: Decompress bzip2 file
  echo "  Step 9: Decompress myfile.txt.bz2."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "bunzip2 myfile.txt.bz2" && "$cmd9" != "bzip2 -d myfile.txt.bz2" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  myfile.txt"
  echo

  # STEP 10: Create bzip2-compressed tar archive
  echo "  Step 10: Create archive.tar.bz2 from ~/data."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "tar -cjvf archive.tar.bz2 /home/examuser/data" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  data/"
  echo

  # STEP 11: Extract bzip2 tar archive
  echo "  Step 11: Extract archive.tar.bz2 into /tmp."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "tar -xjvf archive.tar.bz2 -C /tmp" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  data/"
  echo

  print_success "Excellent work."
  print_info "You demonstrated RHCSA-level archive and compression skills by:"
  print_info "- creating and extracting tar archives"
  print_info "- compressing and decompressing files with gzip and bzip2"
  print_info "- working with .tar.gz and .tar.bz2 archives"
  print_info "- listing archive contents safely"
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
