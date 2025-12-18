#!/bin/bash

# Lab 285: tar — archive, compress, list, extract, exclude, append, update
# Rules:
# - Only real terminal output should appear.
# - Prompts do not reveal the exact commands.
# - Exactly 10 prompts.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 285: tar Mastery (10 Prompts)"
LAB_ID="lab285"
LAB_XP=35000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

WORK="/root/tarlab"
ARC_DIR="/tmp"
PLAIN="$ARC_DIR/tarlab.tar"
GZ="$ARC_DIR/tarlab.tar.gz"
GZ_NOLOGS="$ARC_DIR/tarlab-no-logs.tar.gz"

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
  center_text "Goal: Create/list/extract archives; compress; exclude; append; update — using tar."
  echo
  center_text "Press Enter to begin…"
  read _

  # 1) Initialize dataset (one-liner)
  draw_lab_ui
  echo "  1) Initialize a small dataset under $WORK (two dirs, two files) in a single command."
  read -p "  lab@lab285:~$ " a1
  [[ "$a1" != "mkdir -p /root/tarlab/dir1 /root/tarlab/dir2 && printf 'alpha\n' > /root/tarlab/dir1/file1.txt && printf 'beta\n' > /root/tarlab/dir2/file2.log" ]] && { print_error "Try again."; read -p "" _; continue; }
  echo

  # 2) Create plain tar (no output expected)
  echo "  2) Create an uncompressed archive file at $PLAIN containing $WORK."
  read -p "  lab@lab285:~$ " a2
  [[ "$a2" != "tar -cf /tmp/tarlab.tar -C /root tarlab" ]] && { print_error "Try again."; read -p "" _; continue; }
  echo

  # 3) List plain tar (verbose)
  echo "  3) List the contents of the uncompressed archive verbosely."
  read -p "  lab@lab285:~$ " a3
  [[ "$a3" != "tar -tvf /tmp/tarlab.tar" ]] && { print_error "Try again."; read -p "" _; continue; }
  echo "drwxr-xr-x root/root         0 $(date +'%Y-%m-%d %H:%M') tarlab/"
  echo "drwxr-xr-x root/root         0 $(date +'%Y-%m-%d %H:%M') tarlab/dir1/"
  echo "-rw-r--r-- root/root         6 $(date +'%Y-%m-%d %H:%M') tarlab/dir1/file1.txt"
  echo "drwxr-xr-x root/root         0 $(date +'%Y-%m-%d %H:%M') tarlab/dir2/"
  echo "-rw-r--r-- root/root         5 $(date +'%Y-%m-%d %H:%M') tarlab/dir2/file2.log"
  echo

  # 4) Create gzip tarball (no output)
  echo "  4) Create a gzip-compressed archive at $GZ from $WORK."
  read -p "  lab@lab285:~$ " a4
  [[ "$a4" != "tar -czf /tmp/tarlab.tar.gz -C /root tarlab" ]] && { print_error "Try again."; read -p "" _; continue; }
  echo

  # 5) List gzip archive (names only)
  echo "  5) List the names inside the gzip-compressed archive."
  read -p "  lab@lab285:~$ " a5
  [[ "$a5" != "tar -tzf /tmp/tarlab.tar.gz" ]] && { print_error "Try again."; read -p "" _; continue; }
  echo "tarlab/"
  echo "tarlab/dir1/"
  echo "tarlab/dir1/file1.txt"
  echo "tarlab/dir2/"
  echo "tarlab/dir2/file2.log"
  echo

  # 6) Create gzip archive excluding *.log (no output)
  echo "  6) Create a gzip archive at $GZ_NOLOGS while excluding any *.log files."
  read -p "  lab@lab285:~$ " a6
  [[ "$a6" != "tar -czf /tmp/tarlab-no-logs.tar.gz --exclude='*.log' -C /root tarlab" ]] && { print_error "Try again."; read -p "" _; continue; }
  echo

  # 7) List excluded-logs archive to confirm file2.log missing
  echo "  7) List the new archive and verify the log file is absent."
  read -p "  lab@lab285:~$ " a7
  [[ "$a7" != "tar -tzf /tmp/tarlab-no-logs.tar.gz" ]] && { print_error "Try again."; read -p "" _; continue; }
  echo "tarlab/"
  echo "tarlab/dir1/"
  echo "tarlab/dir1/file1.txt"
  echo "tarlab/dir2/"
  echo

  # 8) Append a new file to the plain tar (single command; no output)
  echo "  8) Create a new file in $WORK and append it to the uncompressed archive in a single command."
  read -p "  lab@lab285:~$ " a8
  [[ "$a8" != "printf 'gamma\n' > /root/tarlab/newfile.txt && tar -rf /tmp/tarlab.tar -C /root tarlab/newfile.txt" ]] && { print_error "Try again."; read -p "" _; continue; }
  echo

  # 9) Update the plain tar with a file only if it is newer (single command; no output)
  echo "  9) Touch an existing file in $WORK, then update only that file into $PLAIN if it is newer (single command)."
  read -p "  lab@lab285:~$ " a9
  [[ "$a9" != "touch /root/tarlab/dir1/file1.txt && tar -uf /tmp/tarlab.tar -C /root tarlab/dir1/file1.txt" ]] && { print_error "Try again."; read -p "" _; continue; }
  echo

  # 10) Extract the gzip archive to a target directory and list the extracted tree (single command; shows listing)
  echo "  10) Extract the gzip archive to /tmp/extract1 and show the full extracted tree in a single command."
  read -p "  lab@lab285:~$ " a10
  [[ "$a10" != "mkdir -p /tmp/extract1 && tar -xzf /tmp/tarlab.tar.gz -C /tmp/extract1 && ls -R /tmp/extract1/tarlab" ]] && { print_error "Try again."; read -p "" _; continue; }
  echo "/tmp/extract1/tarlab:"
  echo "dir1  dir2"
  echo
  echo "/tmp/extract1/tarlab/dir1:"
  echo "file1.txt"
  echo
  echo "/tmp/extract1/tarlab/dir2:"
  echo "file2.log"
  echo

  print_success "Great work!"
  print_info "You earned $LAB_XP XP for completing this lab."
  award_xp $LAB_XP
  XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON"); export XP; export LEVEL
  record_lab_completion
  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've successfully completed this lab $completion_count time(s)."
  echo
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  read -p "  > " post_choice
  [[ "$post_choice" == "2" ]] && exit 0
done
