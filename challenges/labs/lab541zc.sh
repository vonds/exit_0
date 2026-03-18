#!/bin/bash

# Lab 541ZC: Securely Transfer a File While Preserving Attributes (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 541ZC: Securely Transfer a File While Preserving Attributes"
LAB_ID="lab541zc"
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
  center_text "A kickstart file on ServerA must be securely copied to"
  center_text "another system for review and backup."
  echo
  center_text "Requirements:"
  center_text "- Source file: /root/anaconda-ks.cfg"
  center_text "- Destination: /tmp on ServerB"
  center_text "- Preserve file attributes during transfer"
  center_text "- If ServerB is unavailable, use localhost"
  echo

  center_text "Press Enter to begin..."
  read _
  draw_lab_ui


  echo "  Step 1: Verify the source file exists on ServerA."
  read -p "$PROMPT" cmd1
  echo

  if [[ "$cmd1" != "sudo ls -l /root/anaconda-ks.cfg" ]]; then
    print_error "Incorrect. Use: sudo ls -l /root/anaconda-ks.cfg"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  -rw-------. 1 root root 1543 Mar 15 17:10 /root/anaconda-ks.cfg"
  echo


  echo "  Step 2: Securely copy the file to ServerB while preserving attributes."
  read -p "$PROMPT" cmd2
  echo

  if [[ "$cmd2" != "sudo scp -p /root/anaconda-ks.cfg root@serverb:/tmp/" && "$cmd2" != "sudo scp -p /root/anaconda-ks.cfg root@localhost:/tmp/" ]]; then
    print_error "Incorrect."
    print_info "Use one of the following:"
    print_info "sudo scp -p /root/anaconda-ks.cfg root@serverb:/tmp/"
    print_info "sudo scp -p /root/anaconda-ks.cfg root@localhost:/tmp/"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  anaconda-ks.cfg                                           100% 1543   1.6MB/s   00:00"
  echo


  echo "  Step 3: Verify the file exists on the remote system."
  read -p "$PROMPT" cmd3
  echo

  if [[ "$cmd3" != "ssh root@serverb 'ls -l /tmp/anaconda-ks.cfg'" && "$cmd3" != "ssh root@localhost 'ls -l /tmp/anaconda-ks.cfg'" ]]; then
    print_error "Incorrect."
    print_info "Use one of the following:"
    print_info "ssh root@serverb 'ls -l /tmp/anaconda-ks.cfg'"
    print_info "ssh root@localhost 'ls -l /tmp/anaconda-ks.cfg'"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  -rw-------. 1 root root 1543 Mar 15 17:10 /tmp/anaconda-ks.cfg"
  echo


  echo "  Step 4: Compare timestamps to confirm attributes were preserved."
  read -p "$PROMPT" cmd4
  echo

  if [[ "$cmd4" != "ssh root@serverb 'stat /tmp/anaconda-ks.cfg'" && "$cmd4" != "ssh root@localhost 'stat /tmp/anaconda-ks.cfg'" ]]; then
    print_error "Incorrect."
    print_info "Use one of the following:"
    print_info "ssh root@serverb 'stat /tmp/anaconda-ks.cfg'"
    print_info "ssh root@localhost 'stat /tmp/anaconda-ks.cfg'"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "    File: /tmp/anaconda-ks.cfg"
  echo "    Size: 1543       Blocks: 8          IO Block: 4096   regular file"
  echo "  Device: fd00h/64768d   Inode: 262251      Links: 1"
  echo "  Access: (0600/-rw-------)  Uid: (    0/    root)   Gid: (    0/    root)"
  echo "  Access: 2026-03-15 17:10:41.000000000 -0400"
  echo "  Modify: 2026-03-15 17:10:41.000000000 -0400"
  echo "  Change: 2026-03-15 17:11:04.000000000 -0400"
  echo "   Birth: 2026-03-15 17:11:04.000000000 -0400"
  echo


  echo "  Step 5: Confirm the remote copy matches the source filename in /tmp."
  read -p "$PROMPT" cmd5
  echo

  if [[ "$cmd5" != "ssh root@serverb 'ls /tmp | grep anaconda-ks.cfg'" && "$cmd5" != "ssh root@localhost 'ls /tmp | grep anaconda-ks.cfg'" ]]; then
    print_error "Incorrect."
    print_info "Use one of the following:"
    print_info "ssh root@serverb 'ls /tmp | grep anaconda-ks.cfg'"
    print_info "ssh root@localhost 'ls /tmp | grep anaconda-ks.cfg'"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  anaconda-ks.cfg"
  echo


  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- verified the source file on ServerA"
  print_info "- securely transferred the file with scp"
  print_info "- preserved timestamps and permissions using -p"
  print_info "- verified the file on the remote system"
  print_info "- confirmed the transferred file exists in /tmp"
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