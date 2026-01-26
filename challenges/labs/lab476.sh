#!/bin/bash

# Lab 476: Rocky Linux 10 — Podman Basics + Image Cleanup + Skopeo Inspect/Sync (RHCSA Focus)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 476: Podman + Skopeo Image Workflows (Rocky 10)"
LAB_ID="lab476"
LAB_XP=47600
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"

[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@rhel-lab476:~$ "

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
  center_text "Scenario:"
  center_text "You're validating container tooling on a Rocky Linux 10 host."
  center_text "You must pull and run an NGINX container, verify it, clean it up cleanly,"
  center_text "then install skopeo and mirror a Fedora image to a local directory."
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  # STEP 1: podman pull nginx
  echo "  Step 1: Pull the nginx image."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "sudo podman pull docker.io/library/nginx" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Trying to pull docker.io/library/nginx:latest..."
  echo "  Getting image source signatures"
  echo "  Copying blob 57f0dd1befe2 done"
  echo "  Copying blob 119d43eec815 done"
  echo "  Copying blob 700146c8ad64 done"
  echo "  Copying blob d989100b8a84 done"
  echo "  Copying blob 500799c30424 done"
  echo "  Copying blob 10b68cfefee1 done"
  echo "  Copying blob eaf8753feae0 done"
  echo "  Copying config 4af177a024 done"
  echo "  Writing manifest to image destination"
  echo "  4af177a024eb8a1e43f4fb6c66735bb8260115cb5925a64f51673219bd97c144"
  echo

  # STEP 2: run container
  echo "  Step 2: Run nginx in detached mode, publish 1234:80, name it website."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo podman run -d -p 1234:80 --name website nginx" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  abcaf2db28838ca6d65eccc2d67d1dd516fe9f49736253216c588cc694d6c236"
  echo

  # STEP 3: list images
  echo "  Step 3: List local images."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo podman images" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  REPOSITORY               TAG     IMAGE ID      CREATED      SIZE"
  echo "  docker.io/library/nginx  latest  4af177a024eb  2 days ago   164 MB"
  echo

  # STEP 4: list containers
  echo "  Step 4: List all containers (including stopped)."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo podman ps -a" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  CONTAINER ID  IMAGE                           COMMAND               CREATED         STATUS         PORTS                 NAMES"
  echo "  abcaf2db2883  docker.io/library/nginx:latest  nginx -g daemon o...  25 seconds ago  Up 25 seconds  0.0.0.0:1234->80/tcp  website"
  echo

  # STEP 5: stop container
  echo "  Step 5: Stop the website container using its container ID."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo podman stop abcaf2db2883" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  abcaf2db2883"
  echo

  # STEP 6: remove container
  echo "  Step 6: Remove the website container using its container ID."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo podman rm abcaf2db2883" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  abcaf2db2883"
  echo

  # STEP 7: remove image correctly using real image ID
  echo "  Step 7: Remove the nginx image using its REAL image ID (4af177a024eb)."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo podman rmi 4af177a024eb" && "$cmd7" != "sudo podman rmi 4af177a024eb -f" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Untagged: docker.io/library/nginx:latest"
  echo "  Deleted: 4af177a024eb8a1e43f4fb6c66735bb8260115cb5925a64f51673219bd97c144"
  echo

  # STEP 8: install skopeo
  echo "  Step 8: Install skopeo."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo yum install skopeo -y" && "$cmd8" != "sudo dnf install skopeo -y" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Last metadata expiration check: 0:28:40 ago on Thu 15 Jan 2026 11:06:20 PM UTC."
  echo "  Dependencies resolved."
  echo "  ===================================================================================================="
  echo "   Package   Architecture   Version            Repository                             Size"
  echo "  ===================================================================================================="
  echo "  Installing:"
  echo "   skopeo    x86_64         2:1.20.0-2.el10    appstream                              8.2 M"
  echo
  echo "  Transaction Summary"
  echo "  ===================================================================================================="
  echo "  Install  1 Package"
  echo
  echo "  Total download size: 8.2 M"
  echo "  Installed size: 28 M"
  echo "  Downloading Packages:"
  echo "  skopeo-1.20.0-2.el10.x86_64.rpm                                   24 MB/s | 8.2 MB  00:00"
  echo "  Running transaction check"
  echo "  Transaction check succeeded."
  echo "  Running transaction test"
  echo "  Transaction test succeeded."
  echo "  Running transaction"
  echo "    Installing : skopeo-2:1.20.0-2.el10.x86_64                                     1/1"
  echo "  Complete!"
  echo

  # STEP 9: skopeo inspect -> file
  echo "  Step 9: Inspect Fedora image metadata and save it to /home/student/fedora.txt."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo skopeo inspect docker://registry.fedoraproject.org/fedora:latest > /home/student/fedora.txt" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # STEP 10: skopeo sync to dir
  echo "  Step 10: Sync Fedora:latest to a local directory /home/student/fedora."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "sudo skopeo sync --src docker --dest dir registry.fedoraproject.org/fedora:latest /home/student/fedora" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  INFO[0000] Tag presence check                            imagename=\"registry.fedoraproject.org/fedora:latest\" tagged=true"
  echo "  INFO[0000] Copying image ref 1/1                         from=\"docker://registry.fedoraproject.org/fedora:latest\" to=\"dir:/home/student/fedora/fedora:latest\""
  echo "  Getting image source signatures"
  echo "  Copying blob a57c11d0ee76 done"
  echo "  Copying config 228912402b done"
  echo "  Writing manifest to image destination"
  echo "  INFO[0001] Synced 1 images from 1 sources"
  echo

  print_success "Great job."
  print_info "You practiced RHCSA-relevant container workflows on Rocky Linux 10:"
  print_info "- pulled and ran nginx with Podman"
  print_info "- inspected images and containers"
  print_info "- performed clean container + image removal using real IDs"
  print_info "- installed and used skopeo to inspect and mirror an image"
  print_info "You earned $LAB_XP XP."
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
