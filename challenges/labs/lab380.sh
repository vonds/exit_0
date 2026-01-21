#!/bin/bash

# Lab 380: RHEL Storage/Filesystems — Diagnose a Mount Point Blocking Access
# Scenario: A web service is "up" but content is missing. /var/www/html looks empty.
# Root cause: an incorrect mount is masking the real directory contents.
# Goal: prove the mount is the problem, remove the bad mount, prevent it from returning on reboot,
# and verify the content is accessible again.
#
# Key skills: ls, findmnt, mount, umount, /etc/fstab, mount -a, curl, verification workflow.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 380: Diagnose Mount Point Blocking Access"
LAB_ID="lab380"
LAB_XP=38000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@rhel-lab380:~$ "

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
  center_text "Users report the local site is returning 404 and the web root looks empty."
  center_text "The app team insists the files exist on disk."
  echo
  center_text "Goal:"
  center_text "Determine why a mount point is masking the real directory, fix it, and verify content returns."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Reproduce symptom
  echo "  Step 1: Reproduce the issue by requesting the local web server headers."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "curl -I http://localhost" && \
        "$cmd1" != "curl -I http://127.0.0.1" ]]; then
    print_error "Incorrect. Try again."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  HTTP/1.1 404 Not Found"
  echo "  Server: nginx/1.24.0"
  echo "  Date: Thu, 15 Jan 2026 11:32:18 GMT"
  echo "  Content-Type: text/html"
  echo "  Connection: keep-alive"
  echo

  # STEP 2: Confirm web root looks empty
  echo "  Step 2: Inspect the web root directory contents."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "ls -la /var/www/html" && \
        "$cmd2" != "ls -l /var/www/html" ]]; then
    print_error "Incorrect. Try again."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  total 0"
  echo "  drwxr-xr-x. 2 root root  6 Jan 15 11:02 ."
  echo "  drwxr-xr-x. 3 root root 18 Jan 15 11:02 .."
  echo

  # STEP 3: Prove something is mounted on that path (masking)
  echo "  Step 3: Check what (if anything) is mounted on /var/www/html."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "findmnt /var/www/html" && \
        "$cmd3" != "mount | grep -F /var/www/html" && \
        "$cmd3" != "sudo findmnt /var/www/html" ]]; then
    print_error "Incorrect. Try again."
    read -p "Press Enter to try again..." _
    continue
  fi

  if [[ "$cmd3" == "mount | grep -F /var/www/html" ]]; then
    echo "  tmpfs on /var/www/html type tmpfs (rw,nosuid,nodev,seclabel,relatime,size=64m,mode=755)"
  else
    echo "  TARGET        SOURCE FSTYPE OPTIONS"
    echo "  /var/www/html tmpfs  tmpfs  rw,nosuid,nodev,seclabel,relatime,size=64m,mode=755"
  fi
  echo

  # STEP 4: Identify why it keeps happening (fstab)
  echo "  Step 4: Find the entry that causes /var/www/html to be mounted at boot."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo grep -n '/var/www/html' /etc/fstab" && \
        "$cmd4" != "grep -n '/var/www/html' /etc/fstab" ]]; then
    print_error "Incorrect. Try again."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  19:tmpfs  /var/www/html  tmpfs  defaults,size=64m,mode=0755  0  0"
  echo

  # STEP 5: Remove the masking mount right now (unmount)
  echo "  Step 5: Unmount /var/www/html to reveal the real directory contents underneath."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo umount /var/www/html" && \
        "$cmd5" != "sudo umount -l /var/www/html" ]]; then
    print_error "Incorrect. Try again."
    read -p "Press Enter to try again..." _
    continue
  fi
  # Realistic: umount is silent on success.

  # STEP 6: Verify content reappears
  echo "  Step 6: Verify the web root now shows the expected files."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "ls -la /var/www/html" && \
        "$cmd6" != "ls -l /var/www/html" ]]; then
    print_error "Incorrect. Try again."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  total 16"
  echo "  drwxr-xr-x. 3 root root   35 Jan 15 10:40 ."
  echo "  drwxr-xr-x. 3 root root   18 Jan 15 11:02 .."
  echo "  -rw-r--r--. 1 root root 1256 Jan 15 10:40 index.html"
  echo "  drwxr-xr-x. 2 root root   24 Jan 15 10:40 assets"
  echo

  # STEP 7: Prevent recurrence on reboot (edit fstab)
  echo "  Step 7: Edit /etc/fstab and remove (or comment out) the tmpfs mount for /var/www/html."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo vim /etc/fstab" && \
        "$cmd7" != "sudo vi /etc/fstab" && \
        "$cmd7" != "sudo nano /etc/fstab" && \
        "$cmd7" != "sudoedit /etc/fstab" ]]; then
    print_error "Incorrect. Try again."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (opened /etc/fstab)"
  echo "  (removed/commented the /var/www/html tmpfs entry)"
  echo "  (saved and exited)"
  echo

  # STEP 8: Validate fstab won’t re-mask it (mount -a) + final verification
  echo "  Step 8: Validate the change by running mount -a, then confirm /var/www/html is NOT a mount."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo mount -a && findmnt /var/www/html" && \
        "$cmd8" != "sudo mount -a && mount | grep -F /var/www/html" ]]; then
    print_error "Incorrect. Try again."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  (no output)"
  echo

  echo "  Final Check: Confirm the site returns 200 now."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "curl -I http://localhost" && \
        "$cmd9" != "curl -I http://127.0.0.1" ]]; then
    print_error "Incorrect. Try again."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  HTTP/1.1 200 OK"
  echo "  Server: nginx/1.24.0"
  echo "  Content-Type: text/html; charset=UTF-8"
  echo "  Connection: keep-alive"
  echo

  print_success "Nice work!"
  print_info "You diagnosed why access was blocked by a mount point by:"
  print_info "- reproducing the symptom at the service layer"
  print_info "- confirming the directory was being masked by an unexpected mount"
  print_info "- tracing the mount back to /etc/fstab"
  print_info "- unmounting to restore access and verifying files reappeared"
  print_info "- removing the bad mount so it won't return"
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
