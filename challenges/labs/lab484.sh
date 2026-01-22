#!/bin/bash

# Lab 484: RHCSA File Management — Create Hard and Soft Links
# Focus: creating/verifying/removing hard links and symbolic links, spotting broken symlinks,
# and using ls/stat/find to validate inode/link behavior.
# Key skills: ln, ln -s, ls -li, ls -l, stat, rm, cat, find -type l

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 484: Hard Links and Symbolic Links"
LAB_ID="lab484"
LAB_XP=48400
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab484:~$ "

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
  center_text "A shared notes file needs multiple names, and a shortcut is needed"
  center_text "to a log directory. You must prove which links share an inode and"
  center_text "what happens when targets are deleted."
  echo
  center_text "Resources (already exist):"
  center_text "- /home/examuser/original.txt"
  center_text "- /home/examuser/docs/  (directory exists)"
  echo
  center_text "Goal: create hard links and symlinks, verify them, and identify a broken symlink."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Create a hard link
  echo "  Step 1: Create a hard link named ~/docs/link.txt pointing to ~/original.txt."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "ln /home/examuser/original.txt /home/examuser/docs/link.txt" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  # ln succeeds silently
  echo

  # STEP 2: Verify inode + link count for both paths
  echo "  Step 2: Verify both files share the same inode number and link count increased."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "ls -li /home/examuser/original.txt /home/examuser/docs/link.txt" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  1049012 -rw-r--r-- 2 examuser examuser  48 Jan 21 09:14 /home/examuser/docs/link.txt"
  echo "  1049012 -rw-r--r-- 2 examuser examuser  48 Jan 21 09:14 /home/examuser/original.txt"
  echo

  # STEP 3: Remove the hard link and prove data remains via the other name
  echo "  Step 3: Remove ~/docs/link.txt, then show the contents of ~/original.txt."
  echo "          (Do both actions in one command line.)"
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "rm /home/examuser/docs/link.txt && cat /home/examuser/original.txt" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Notes for the deployment window:"
  echo "  - verify DNS"
  echo "  - verify NTP"
  echo

  # STEP 4: Check hard link count using stat
  echo "  Step 4: Use stat to confirm the link count for ~/original.txt is now 1."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "stat /home/examuser/original.txt" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  File: /home/examuser/original.txt"
  echo "  Size: 48        Blocks: 8          IO Block: 4096   regular file"
  echo "Device: 0,45      Inode: 1049012     Links: 1"
  echo "Access: (0644/-rw-r--r--)  Uid: ( 1000/ examuser)   Gid: ( 1000/ examuser)"
  echo "Access: 2026-01-21 09:16:02.000000000 -0500"
  echo "Modify: 2026-01-21 09:14:33.000000000 -0500"
  echo "Change: 2026-01-21 09:16:01.000000000 -0500"
  echo " Birth: 2026-01-21 09:14:33.000000000 -0500"
  echo

  # STEP 5: Create a symbolic link to a file
  echo "  Step 5: Create a symbolic link named ~/docs/softlink.txt pointing to ~/original.txt."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "ln -s /home/examuser/original.txt /home/examuser/docs/softlink.txt" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  # ln -s succeeds silently
  echo

  # STEP 6: Verify symlink target
  echo "  Step 6: Verify ~/docs/softlink.txt is a symlink and show what it points to."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "ls -l /home/examuser/docs/softlink.txt" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  lrwxrwxrwx. 1 examuser examuser 25 Jan 21 09:17 /home/examuser/docs/softlink.txt -> /home/examuser/original.txt"
  echo

  # STEP 7: Create a symlink to a directory
  echo "  Step 7: Create a symlink named ~/logdir pointing to /var/log."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "ln -s /var/log /home/examuser/logdir" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 8: Create a broken symlink + detect it
  echo "  Step 8: Create ~/docs/brokenlink.txt pointing to ~/tempfile.txt, then remove ~/tempfile.txt."
  echo "          (Do both actions in one command line.)"
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "ln -s /home/examuser/tempfile.txt /home/examuser/docs/brokenlink.txt && rm -f /home/examuser/tempfile.txt" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # STEP 9: Show the broken symlink
  echo "  Step 9: Verify brokenlink.txt exists and points to a missing target."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "ls -l /home/examuser/docs/brokenlink.txt" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  lrwxrwxrwx. 1 examuser examuser 24 Jan 21 09:18 /home/examuser/docs/brokenlink.txt -> /home/examuser/tempfile.txt"
  echo "  ls: cannot access '/home/examuser/tempfile.txt': No such file or directory"
  echo

  # STEP 10: Find symlinks in docs
  echo "  Step 10: List all symbolic links under ~/docs."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "find /home/examuser/docs -type l" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  /home/examuser/docs/softlink.txt"
  echo "  /home/examuser/docs/brokenlink.txt"
  echo

  print_success "Nice work."
  print_info "You proved the core link behaviors RHCSA expects:"
  print_info "- hard links share the same inode and keep data alive until the last link is removed"
  print_info "- symlinks point to a path (can target directories and cross filesystems)"
  print_info "- deleting a symlink does not delete the target, but deleting the target breaks the symlink"
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
