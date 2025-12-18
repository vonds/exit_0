#!/bin/bash

# Lab 188: Permissions Drill — chmod add/remove, rwx combos (Essential Tools)
# Output policy: Only show real command output. If a command is silent, show nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 188: Permissions Drill (chmod)"
LAB_ID="lab188"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

F="/tmp/perm_file1"
U="$(id -un)"
G="$(id -gn)"
TS_M="$(date +%b)"
TS_D="$(date +%e)"
TS_T="$(date +%H:%M)"

print_ls_sim() {
  # $1: mode string (e.g., -rwxr-xr--)
  printf "%s 1 %-8s %-8s %4d %s %2s %s %s\n" \
    "$1" "$U" "$G" 0 "$TS_M" "$TS_D" "$TS_T" "$F"
}
print_stat_sim() { echo "$1"; } # $1: octal

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
  center_text "Goal: Create $F and practice chmod changes. Only real command output is shown."
  echo
  center_text "Press Enter to begin the lab..."
  read _

  # Step 1: Create file (no output)
  draw_lab_ui
  echo "  Step 1: Create an empty file at $F."
  echo "          Expected: touch $F"
  read -p "  lab@lab188:~$ " s1
  [[ "$s1" != "touch /tmp/perm_file1" ]] && { print_error "Use: touch /tmp/perm_file1"; read -p "Press Enter to try again..." _; continue; }
  echo

  # Step 2: chmod 444 (no output), then ls/stat (show output)
  echo "  Step 2: Set read-only for owner, group, other."
  echo "          Expected: chmod 444 $F"
  read -p "  lab@lab188:~$ " s2
  [[ "$s2" != "chmod 444 /tmp/perm_file1" ]] && { print_error "Use: chmod 444 /tmp/perm_file1"; read -p "Press Enter to try again..." _; continue; }
  # ls output
  read -p "  lab@lab188:~$ " s2a
  [[ "$s2a" != "ls -l /tmp/perm_file1" ]] && { print_error "Next: ls -l /tmp/perm_file1"; read -p "Press Enter to try again..." _; continue; }
  print_ls_sim "-r--r--r--"
  # stat output
  read -p "  lab@lab188:~$ " s2b
  [[ "$s2b" != "stat -c %a /tmp/perm_file1" ]] && { print_error "Next: stat -c %a /tmp/perm_file1"; read -p "Press Enter to try again..." _; continue; }
  print_stat_sim "444"
  echo

  # Step 3: chmod u+x (no output), then ls/stat
  echo "  Step 3: Add execute for owner."
  echo "          Expected: chmod u+x $F"
  read -p "  lab@lab188:~$ " s3
  [[ "$s3" != "chmod u+x /tmp/perm_file1" ]] && { print_error "Use: chmod u+x /tmp/perm_file1"; read -p "Press Enter to try again..." _; continue; }
  read -p "  lab@lab188:~$ " s3a
  [[ "$s3a" != "ls -l /tmp/perm_file1" ]] && { print_error "Next: ls -l /tmp/perm_file1"; read -p "Press Enter to try again..." _; continue; }
  print_ls_sim "-r-xr--r--"
  read -p "  lab@lab188:~$ " s3b
  [[ "$s3b" != "stat -c %a /tmp/perm_file1" ]] && { print_error "Next: stat -c %a /tmp/perm_file1"; read -p "Press Enter to try again..." _; continue; }
  print_stat_sim "544"
  echo

  # Step 4: add write for group & others (no output), then ls/stat
  echo "  Step 4: Add write for group and others."
  echo "          Expected: chmod g+w,o+w $F"
  read -p "  lab@lab188:~$ " s4
  [[ "$s4" != "chmod g+w,o+w /tmp/perm_file1" ]] && { print_error "Use: chmod g+w,o+w /tmp/perm_file1"; read -p "Press Enter to try again..." _; continue; }
  read -p "  lab@lab188:~$ " s4a
  [[ "$s4a" != "ls -l /tmp/perm_file1" ]] && { print_error "Next: ls -l /tmp/perm_file1"; read -p "Press Enter to try again..." _; continue; }
  print_ls_sim "-r-xrw-rw-"
  read -p "  lab@lab188:~$ " s4b
  [[ "$s4b" != "stat -c %a /tmp/perm_file1" ]] && { print_error "Next: stat -c %a /tmp/perm_file1"; read -p "Press Enter to try again..." _; continue; }
  print_stat_sim "566"
  echo

  # Step 5: revoke write from others (no output), then ls/stat
  echo "  Step 5: Revoke write from others."
  echo "          Expected: chmod o-w $F"
  read -p "  lab@lab188:~$ " s5
  [[ "$s5" != "chmod o-w /tmp/perm_file1" ]] && { print_error "Use: chmod o-w /tmp/perm_file1"; read -p "Press Enter to try again..." _; continue; }
  read -p "  lab@lab188:~$ " s5a
  [[ "$s5a" != "ls -l /tmp/perm_file1" ]] && { print_error "Next: ls -l /tmp/perm_file1"; read -p "Press Enter to try again..." _; continue; }
  print_ls_sim "-r-xrw-r--"
  read -p "  lab@lab188:~$ " s5b
  [[ "$s5b" != "stat -c %a /tmp/perm_file1" ]] && { print_error "Next: stat -c %a /tmp/perm_file1"; read -p "Press Enter to try again..." _; continue; }
  print_stat_sim "564"
  echo

  # Step 6: a=rwx (no output), then ls/stat
  echo "  Step 6: Give rwx to all (a=rwx)."
  echo "          Expected: chmod a=rwx $F"
  read -p "  lab@lab188:~$ " s6
  [[ "$s6" != "chmod a=rwx /tmp/perm_file1" ]] && { print_error "Use: chmod a=rwx /tmp/perm_file1"; read -p "Press Enter to try again..." _; continue; }
  read -p "  lab@lab188:~$ " s6a
  [[ "$s6a" != "ls -l /tmp/perm_file1" ]] && { print_error "Next: ls -l /tmp/perm_file1"; read -p "Press Enter to try again..." _; continue; }
  print_ls_sim "-rwxrwxrwx"
  read -p "  lab@lab188:~$ " s6b
  [[ "$s6b" != "stat -c %a /tmp/perm_file1" ]] && { print_error "Next: stat -c %a /tmp/perm_file1"; read -p "Press Enter to try again..." _; continue; }
  print_stat_sim "777"
  echo

  # Step 7: revoke write from group (no output), then ls/stat
  echo "  Step 7: Revoke write from group."
  echo "          Expected: chmod g-w $F"
  read -p "  lab@lab188:~$ " s7
  [[ "$s7" != "chmod g-w /tmp/perm_file1" ]] && { print_error "Use: chmod g-w /tmp/perm_file1"; read -p "Press Enter to try again..." _; continue; }
  read -p "  lab@lab188:~$ " s7a
  [[ "$s7a" != "ls -l /tmp/perm_file1" ]] && { print_error "Next: ls -l /tmp/perm_file1"; read -p "Press Enter to try again..." _; continue; }
  print_ls_sim "-rwxr-xrwx"
  read -p "  lab@lab188:~$ " s7b
  [[ "$s7b" != "stat -c %a /tmp/perm_file1" ]] && { print_error "Next: stat -c %a /tmp/perm_file1"; read -p "Press Enter to try again..." _; continue; }
  print_stat_sim "757"
  echo

  # Step 8: revoke write and execute from others (no output), then ls/stat
  echo "  Step 8: Revoke write and execute from others."
  echo "          Expected: chmod o-wx $F"
  read -p "  lab@lab188:~$ " s8
  [[ "$s8" != "chmod o-wx /tmp/perm_file1" ]] && { print_error "Use: chmod o-wx /tmp/perm_file1"; read -p "Press Enter to try again..." _; continue; }
  read -p "  lab@lab188:~$ " s8a
  [[ "$s8a" != "ls -l /tmp/perm_file1" ]] && { print_error "Next: ls -l /tmp/perm_file1"; read -p "Press Enter to try again..." _; continue; }
  print_ls_sim "-rwxr-xr--"
  read -p "  lab@lab188:~$ " s8b
  [[ "$s8b" != "stat -c %a /tmp/perm_file1" ]] && { print_error "Next: stat -c %a /tmp/perm_file1"; read -p "Press Enter to try again..." _; continue; }
  print_stat_sim "754"
  echo

  # Step 9: numeric mode 640 (no output), then ls/stat
  echo "  Step 9 (bonus): Set permissions numerically to 640 and verify."
  echo "          Expected: chmod 640 $F"
  read -p "  lab@lab188:~$ " s9
  [[ "$s9" != "chmod 640 /tmp/perm_file1" ]] && { print_error "Use: chmod 640 /tmp/perm_file1"; read -p "Press Enter to try again..." _; continue; }
  read -p "  lab@lab188:~$ " s9a
  [[ "$s9a" != "ls -l /tmp/perm_file1" ]] && { print_error "Next: ls -l /tmp/perm_file1"; read -p "Press Enter to try again..." _; continue; }
  print_ls_sim "-rw-r-----"
  read -p "  lab@lab188:~$ " s9b
  [[ "$s9b" != "stat -c %a /tmp/perm_file1" ]] && { print_error "Next: stat -c %a /tmp/perm_file1"; read -p "Press Enter to try again..." _; continue; }
  print_stat_sim "640"
  echo

  print_success "Nice work!"
  print_info "You earned $LAB_XP XP for completing this lab."
  award_xp $LAB_XP
  XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON"); export XP; export LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've successfully completed this lab $completion_count time(s)."
  echo
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " post_choice
  [[ "$post_choice" == "2" ]] && exit 0
done
