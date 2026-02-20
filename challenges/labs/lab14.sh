#!/bin/bash

# Lab 14: Archiving and Compression with tar, gzip, and xz

# Dynamically locate root directory and source core scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 14: Archiving and Compression with tar, gzip, and xz"
LAB_ID="lab14"
LAB_XP=4277
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
  center_text "You need to archive a project directory, compress it, and verify"
  center_text "the results. This lab walks you through using tar, gzip, and xz."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # Step 0 context (now interactive as cmd1)
  echo "  Step 1: List the contents of the 'project/' directory."
  read -p "  lab@lpic-lab14:~$ " cmd1
  echo
  if [[ "$cmd1" != "ls project/" && "$cmd1" != "ls -1 project/" && "$cmd1" != "ls project" ]]; then
    print_error "Incorrect. Hint: Use 'ls project/' to view the directory."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  README.md  src/  assets/  data/"
  echo

  echo "  Step 2: Create an uncompressed tar archive of 'project/' named project.tar."
  read -p "  lab@lpic-lab14:~$ " cmd2
  echo
  # Accept common flag orders
  if [[ "$cmd2" != "tar -cvf project.tar project/" && "$cmd2" != "tar -cf project.tar project/" && "$cmd2" != "tar cvf project.tar project/" ]]; then
    print_error "Incorrect. Hint: tar -c -v -f project.tar project/"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  project/"
  echo "  project/README.md"
  echo "  project/src/"
  echo "  project/assets/"
  echo "  project/data/"
  echo

  echo "  Step 3: Compress the tar file with gzip to create project.tar.gz."
  read -p "  lab@lpic-lab14:~$ " cmd3
  echo
  if [[ "$cmd3" != "gzip project.tar" && "$cmd3" != "gzip -9 project.tar" ]]; then
    print_error "Incorrect. Hint: Run gzip against the tar file (e.g., 'gzip project.tar')."
    read -p "Press Enter to try again..." _
    continue
  fi

  echo "  Step 4: Extract the gzip-compressed archive back to the current directory."
  read -p "  lab@lpic-lab14:~$ " cmd4
  echo
  if [[ "$cmd4" != "tar -xvzf project.tar.gz" && "$cmd4" != "tar -xzvf project.tar.gz" && "$cmd4" != "tar -xzf project.tar.gz" ]]; then
    print_error "Incorrect. Hint: Use tar with -x -z -f (e.g., 'tar -xvzf project.tar.gz')."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  project/"
  echo "  project/README.md"
  echo "  project/src/"
  echo "  project/assets/"
  echo "  project/data/"
  echo

  echo "  Step 5: Recreate an uncompressed tar (project.tar) from 'project/' again."
  read -p "  lab@lpic-lab14:~$ " cmd5
  echo
  if [[ "$cmd5" != "tar -cvf project.tar project/" && "$cmd5" != "tar -cf project.tar project/" && "$cmd5" != "tar cvf project.tar project/" ]]; then
    print_error "Incorrect. Hint: tar -c -v -f project.tar project/"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  project/"
  echo "  project/README.md"
  echo "  project/src/"
  echo "  project/assets/"
  echo "  project/data/"
  echo

  echo "  Step 6: Compress 'project.tar' using xz to create project.tar.xz."
  read -p "  lab@lpic-lab14:~$ " cmd6
  echo
  if [[ "$cmd6" != "xz project.tar" && "$cmd6" != "xz -z project.tar" && "$cmd6" != "xz -T0 project.tar" ]]; then
    print_error "Incorrect. Hint: Use 'xz project.tar' (you may add options like -T0 for multithread)."
    read -p "Press Enter to try again..." _
    continue
  fi

  echo "  Step 7: Decompress 'project.tar.xz' to restore 'project.tar'."
  read -p "  lab@lpic-lab14:~$ " cmd7
  echo
  if [[ "$cmd7" != "unxz project.tar.xz" && "$cmd7" != "xz -d project.tar.xz" ]]; then
    print_error "Incorrect. Hint: Use 'unxz project.tar.xz' or 'xz -d project.tar.xz'."
    read -p "Press Enter to try again..." _
    continue
  fi

  echo "  Step 8: (Bonus) Extract an .xz-compressed tar directly without a separate unxz step."
  read -p "  lab@lpic-lab14:~$ " cmd8
  echo
  if [[ "$cmd8" != "tar -xvJf project.tar.xz" && "$cmd8" != "tar -xJf project.tar.xz" && "$cmd8" != "tar -xJvf project.tar.xz" ]]; then
    print_error "Incorrect. Hint: Use tar with -J for xz (e.g., 'tar -xvJf project.tar.xz')."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  project/"
  echo "  project/README.md"
  echo "  project/src/"
  echo "  project/assets/"
  echo "  project/data/"
  echo

  print_success "Awesome work!"
  print_info "You listed contents, archived a directory, compressed and extracted with gzip and xz,"
  print_info "and verified multiple ways to handle .tar.gz and .tar.xz files."
  print_info "You earned $LAB_XP XP for completing this lab!"
  award_xp $LAB_XP
  XP=$(jq '.XP' "$SAVE_JSON")
  LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
  export XP
  export LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've successfully completed this lab $completion_count time(s)."
  echo
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " choice

  [[ "$choice" == "2" ]] && exit 0
done
