#!/bin/bash

# Lab 364: RHEL Troubleshooting — /tmp behavior changed unexpectedly (noexec option breaks scripts)
# RHCSA focus: verifying mount options (findmnt/mount), identifying why execution fails in /tmp,
# inspecting /etc/fstab and systemd tmp.mount, correcting mount options safely, remounting,
# and verifying expected /tmp behavior.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 364"
LAB_ID="lab364"
LAB_XP=36400
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

PROMPT="student@lab364:~$ > "

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "RHEL Troubleshooting — scripts that used to run from /tmp now fail with 'Permission denied'."
  center_text "Interactive: identify what changed about /tmp and restore expected behavior safely."
  echo
  center_text "Press Enter to begin."
  read _
  draw_lab_ui

  # STEP 1
  echo "  Step 1: Reproduce the failure by trying to execute a script from /tmp."
  read -p "  $PROMPT" cmd1
  if [[ "$cmd1" != "bash /tmp/test.sh" ]]; then
    print_error "Incorrect. Use: bash /tmp/test.sh"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  bash: /tmp/test.sh: Permission denied"

  # STEP 2
  echo
  echo "  Step 2: Check how /tmp is mounted (look for noexec/nosuid/nodev)."
  read -p "  $PROMPT" cmd2
  if [[ "$cmd2" != "findmnt /tmp" && "$cmd2" != "mount | grep ' on /tmp '" ]]; then
    print_error "Incorrect. Use: findmnt /tmp  (or: mount | grep ' on /tmp ')"
    read -p "Press Enter to continue..." _
    continue
  fi
  if [[ "$cmd2" == "findmnt /tmp" ]]; then
    echo "  TARGET SOURCE    FSTYPE OPTIONS"
    echo "  /tmp   tmpfs     tmpfs  rw,nosuid,nodev,noexec,relatime,seclabel,size=1024m,mode=1777"
  else
    echo "  tmpfs on /tmp type tmpfs (rw,nosuid,nodev,noexec,relatime,seclabel,size=1024m,mode=1777)"
  fi

  # STEP 3
  echo
  echo "  Step 3: Confirm what service/unit is responsible for mounting /tmp."
  read -p "  $PROMPT" cmd3
  if [[ "$cmd3" != "systemctl status tmp.mount" && "$cmd3" != "sudo systemctl status tmp.mount" ]]; then
    print_error "Incorrect. Use: systemctl status tmp.mount"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  ● tmp.mount - Temporary Directory /tmp"
  echo "     Loaded: loaded (/usr/lib/systemd/system/tmp.mount; enabled; vendor preset: disabled)"
  echo "     Active: active (mounted) since Fri 2025-12-21 15:00:21 EST; 6min ago"
  echo "      Where: /tmp"
  echo "       What: tmpfs"
  echo "  "
  echo "  Dec 21 15:00:21 rhel-lab systemd[1]: Mounting Temporary Directory /tmp..."
  echo "  Dec 21 15:00:21 rhel-lab systemd[1]: Mounted Temporary Directory /tmp."

  # STEP 4
  echo
  echo "  Step 4: Inspect tmp.mount to see the configured mount options."
  read -p "  $PROMPT" cmd4
  if [[ "$cmd4" != "systemctl cat tmp.mount" && "$cmd4" != "sudo systemctl cat tmp.mount" ]]; then
    print_error "Incorrect. Use: systemctl cat tmp.mount"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  # /usr/lib/systemd/system/tmp.mount"
  echo "  [Mount]"
  echo "  What=tmpfs"
  echo "  Where=/tmp"
  echo "  Type=tmpfs"
  echo "  Options=mode=1777,strictatime,nosuid,nodev,noexec"

  # STEP 5
  echo
  echo "  Step 5: Check whether /etc/fstab is overriding /tmp mount behavior."
  read -p "  $PROMPT" cmd5
  if [[ "$cmd5" != "sudo grep -n ' /tmp ' /etc/fstab" ]]; then
    print_error "Incorrect. Use: sudo grep -n ' /tmp ' /etc/fstab"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  "

  # STEP 6
  echo
  echo "  Step 6: Disable systemd's tmp.mount so /tmp behaves as a normal directory again."
  read -p "  $PROMPT" cmd6
  if [[ "$cmd6" != "sudo systemctl disable --now tmp.mount" ]]; then
    print_error "Incorrect. Use: sudo systemctl disable --now tmp.mount"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  Removed \"/etc/systemd/system/local-fs.target.wants/tmp.mount\"."
  echo "  "

  # STEP 7
  echo
  echo "  Step 7: Verify /tmp is no longer mounted as tmpfs with noexec."
  read -p "  $PROMPT" cmd7
  if [[ "$cmd7" != "findmnt /tmp" && "$cmd7" != "mount | grep ' on /tmp '" ]]; then
    print_error "Incorrect. Use: findmnt /tmp  (or: mount | grep ' on /tmp ')"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  "
  echo "  findmnt: /tmp: no mount point specified."

  # STEP 8
  echo
  echo "  Step 8: Confirm the script can now run from /tmp."
  read -p "  $PROMPT" cmd8
  if [[ "$cmd8" != "bash /tmp/test.sh" ]]; then
    print_error "Incorrect. Use: bash /tmp/test.sh"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  OK"

  # STEP 9
  echo
  echo "  Step 9: Verify the tmp.mount unit is no longer enabled."
  read -p "  $PROMPT" cmd9
  if [[ "$cmd9" != "systemctl is-enabled tmp.mount" && "$cmd9" != "sudo systemctl is-enabled tmp.mount" ]]; then
    print_error "Incorrect. Use: systemctl is-enabled tmp.mount"
    read -p "Press Enter to continue..." _
    continue
  fi
  echo "  disabled"

  print_success "Excellent work!"
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

  if [[ "$choice" == "2" ]]; then
    exit 0
  fi
done
