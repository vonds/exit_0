#!/bin/bash

# Lab 158: Docker Volumes (Persistent Data + Backup/Restore Workflow, condensed)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 158: Docker Volumes (Create, Mount, Backup, Restore, Cleanup)"
LAB_ID="lab158"
LAB_XP=20000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT_ROOT="  root@lab158:~# "

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
  center_text "Ops ticket: 'We need persistent storage for a container and a proof-of-backup."
  center_text "Create a named volume, write data into it from a container, back it up to a tar,"
  center_text "restore into a new volume, verify the data, then clean up.'"
  echo
  center_text "Press Enter to begin the lab..."
  read -r _
  draw_lab_ui

  # STEP 1: Evidence first (current volumes)
  echo "  Step 1: List existing Docker volumes."
  read -r -p "$PROMPT_ROOT" cmd1
  echo
  if [[ "$cmd1" != "docker volume ls" ]]; then
    print_error "Incorrect."
    print_info "List volumes with: docker volume ls"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  DRIVER    VOLUME NAME"
  echo

  # STEP 2: Create a named volume
  echo "  Step 2: Create a named volume called appdata."
  read -r -p "$PROMPT_ROOT" cmd2
  echo
  if [[ "$cmd2" != "docker volume create appdata" ]]; then
    print_error "Incorrect."
    print_info "Create the volume with: docker volume create appdata"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  appdata"
  echo

  # STEP 3: Verify volume exists
  echo "  Step 3: Verify appdata exists."
  read -r -p "$PROMPT_ROOT" cmd3
  echo
  if [[ "$cmd3" != "docker volume ls" ]]; then
    print_error "Incorrect."
    print_info "Run: docker volume ls"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  DRIVER    VOLUME NAME"
  echo "  local     appdata"
  echo

  # STEP 4: Write data into the volume using a container
  echo "  Step 4: Write a marker file into the volume using an Alpine container."
  echo "          Create /data/marker.txt with the text: 'lab158-ok'"
  read -r -p "$PROMPT_ROOT" cmd4
  echo
  if [[ "$cmd4" != "docker run --rm -v appdata:/data alpine:latest sh -c \"echo lab158-ok > /data/marker.txt\"" ]]; then
    print_error "Incorrect."
    print_info "Use the exact command (quotes matter) to write into the mounted volume."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  (container exited)"
  echo

  # STEP 5: Verify the data is present (read from volume)
  echo "  Step 5: Verify the file exists by reading it from a container."
  read -r -p "$PROMPT_ROOT" cmd5
  echo
  if [[ "$cmd5" != "docker run --rm -v appdata:/data alpine:latest cat /data/marker.txt" ]]; then
    print_error "Incorrect."
    print_info "Read it with: docker run --rm -v appdata:/data alpine:latest cat /data/marker.txt"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  lab158-ok"
  echo

  # STEP 6: Backup the volume to a tar file on the host
  echo "  Step 6: Backup the appdata volume into /root/appdata-backup.tar"
  echo "          (Create /backup inside the container and write tar there.)"
  read -r -p "$PROMPT_ROOT" cmd6
  echo
  if [[ "$cmd6" != "docker run --rm -v appdata:/data -v /root:/backup alpine:latest sh -c \"cd /data && tar -cf /backup/appdata-backup.tar .\"" ]]; then
    print_error "Incorrect."
    print_info "Use docker run with two mounts: appdata:/data and /root:/backup, then tar from /data into /backup."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  (backup created)"
  echo

  # STEP 7: Create a new volume to restore into
  echo "  Step 7: Create a new volume called appdata_restored."
  read -r -p "$PROMPT_ROOT" cmd7
  echo
  if [[ "$cmd7" != "docker volume create appdata_restored" ]]; then
    print_error "Incorrect."
    print_info "Create it with: docker volume create appdata_restored"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  appdata_restored"
  echo

  # STEP 8: Restore the tar into the new volume
  echo "  Step 8: Restore /root/appdata-backup.tar into appdata_restored."
  read -r -p "$PROMPT_ROOT" cmd8
  echo
  if [[ "$cmd8" != "docker run --rm -v appdata_restored:/data -v /root:/backup alpine:latest sh -c \"cd /data && tar -xf /backup/appdata-backup.tar\"" ]]; then
    print_error "Incorrect."
    print_info "Mount appdata_restored at /data and /root at /backup, then extract the tar into /data."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  (restore complete)"
  echo

  # STEP 9: Verify restored data
  echo "  Step 9: Verify the restored volume contains the marker file."
  read -r -p "$PROMPT_ROOT" cmd9
  echo
  if [[ "$cmd9" != "docker run --rm -v appdata_restored:/data alpine:latest cat /data/marker.txt" ]]; then
    print_error "Incorrect."
    print_info "Read it with: docker run --rm -v appdata_restored:/data alpine:latest cat /data/marker.txt"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  lab158-ok"
  echo

  # STEP 10: Cleanup volumes + backup file
  echo "  Step 10: Remove both volumes in one command."
  read -r -p "$PROMPT_ROOT" cmd10
  echo
  if [[ "$cmd10" != "docker volume rm appdata appdata_restored" ]]; then
    print_error "Incorrect."
    print_info "Remove them with: docker volume rm appdata appdata_restored"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  appdata"
  echo "  appdata_restored"
  echo
  echo "  Step 11: Remove the backup tar from /root."
  read -r -p "$PROMPT_ROOT" cmd11
  echo
  if [[ "$cmd11" != "rm -f /root/appdata-backup.tar" ]]; then
    print_error "Incorrect."
    print_info "Use: rm -f /root/appdata-backup.tar"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  (removed)"
  echo

  print_success "Nice work."
  print_info "You created a named volume, wrote and verified persistent data, produced a tar backup,"
  print_info "restored into a new volume, verified integrity, then cleaned up volumes and artifacts."
  print_info "You earned $LAB_XP XP for completing this lab."
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
  read -r -p "  > " post_choice
  [[ "$post_choice" == "2" ]] && exit 0
done
