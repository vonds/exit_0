#!/bin/bash

# Lab 159: Docker Images (Tagging + Save/Load + Evidence + Cleanup, condensed)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 159: Docker Images (Tag, Save/Load, Verify, Cleanup)"
LAB_ID="lab159"
LAB_XP=20000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT_ROOT="  root@lab159:~# "

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
  center_text "Ops ticket: 'Prepare an image for offline transfer to a restricted environment.'"
  center_text "Pull a base image, add an internal tag, export it to a tar archive, remove it locally,"
  center_text "then load it back and prove it's available.'"
  echo
  center_text "Press Enter to begin the lab..."
  read -r _
  draw_lab_ui

  # STEP 1: Evidence first (current images)
  echo "  Step 1: List local Docker images."
  read -r -p "$PROMPT_ROOT" cmd1
  echo
  if [[ "$cmd1" != "docker images" ]]; then
    print_error "Incorrect."
    print_info "List images with: docker images"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  REPOSITORY   TAG       IMAGE ID       CREATED       SIZE"
  echo

  # STEP 2: Pull a known image
  echo "  Step 2: Pull the alpine image."
  read -r -p "$PROMPT_ROOT" cmd2
  echo
  if [[ "$cmd2" != "docker pull alpine:latest" ]]; then
    print_error "Incorrect."
    print_info "Pull it with: docker pull alpine:latest"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  latest: Pulling from library/alpine"
  echo "  Digest: sha256:........................................................"
  echo "  Status: Downloaded newer image for alpine:latest"
  echo "  docker.io/library/alpine:latest"
  echo

  # STEP 3: Tag the image for internal use
  echo "  Step 3: Add an internal tag: corp/alpine:transfer"
  read -r -p "$PROMPT_ROOT" cmd3
  echo
  if [[ "$cmd3" != "docker tag alpine:latest corp/alpine:transfer" ]]; then
    print_error "Incorrect."
    print_info "Tag it with: docker tag alpine:latest corp/alpine:transfer"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  (tag created)"
  echo

  # STEP 4: Verify tags exist
  echo "  Step 4: Verify both tags appear in docker images."
  read -r -p "$PROMPT_ROOT" cmd4
  echo
  if [[ "$cmd4" != "docker images | grep -E \"^(alpine|corp/alpine)\"" ]]; then
    print_error "Incorrect."
    print_info "Use grep to show only alpine/corp tags:"
    print_info "docker images | grep -E \"^(alpine|corp/alpine)\""
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  alpine       latest     4e38e38c8ce0   2 weeks ago   7.3MB"
  echo "  corp/alpine  transfer   4e38e38c8ce0   2 weeks ago   7.3MB"
  echo

  # STEP 5: Save image to tar for offline transfer
  echo "  Step 5: Save the internal tag to /root/alpine-transfer.tar"
  read -r -p "$PROMPT_ROOT" cmd5
  echo
  if [[ "$cmd5" != "docker save -o /root/alpine-transfer.tar corp/alpine:transfer" ]]; then
    print_error "Incorrect."
    print_info "Save it with: docker save -o /root/alpine-transfer.tar corp/alpine:transfer"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  (image saved)"
  echo

  # STEP 6: Remove local images (simulate clean host)
  echo "  Step 6: Remove both tags from the local host."
  read -r -p "$PROMPT_ROOT" cmd6
  echo
  if [[ "$cmd6" != "docker rmi corp/alpine:transfer alpine:latest" ]]; then
    print_error "Incorrect."
    print_info "Remove both tags with: docker rmi corp/alpine:transfer alpine:latest"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  Untagged: corp/alpine:transfer"
  echo "  Untagged: alpine:latest"
  echo "  Deleted: sha256:........................................................"
  echo

  # STEP 7: Prove the image is gone
  echo "  Step 7: Confirm alpine no longer appears in docker images."
  read -r -p "$PROMPT_ROOT" cmd7
  echo
  if [[ "$cmd7" != "docker images | grep -E \"^(alpine|corp/alpine)\" || true" ]]; then
    print_error "Incorrect."
    print_info "Run grep and prevent non-zero exit from failing the lab:"
    print_info "docker images | grep -E \"^(alpine|corp/alpine)\" || true"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  (no output)"
  echo

  # STEP 8: Load the image back from tar
  echo "  Step 8: Load the image back from /root/alpine-transfer.tar"
  read -r -p "$PROMPT_ROOT" cmd8
  echo
  if [[ "$cmd8" != "docker load -i /root/alpine-transfer.tar" ]]; then
    print_error "Incorrect."
    print_info "Load it with: docker load -i /root/alpine-transfer.tar"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  Loaded image: corp/alpine:transfer"
  echo

  # STEP 9: Verify image is available and runnable
  echo "  Step 9: Prove the loaded image runs by printing its /etc/os-release."
  read -r -p "$PROMPT_ROOT" cmd9
  echo
  if [[ "$cmd9" != "docker run --rm corp/alpine:transfer cat /etc/os-release" ]]; then
    print_error "Incorrect."
    print_info "Run: docker run --rm corp/alpine:transfer cat /etc/os-release"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  NAME=\"Alpine Linux\""
  echo "  ID=alpine"
  echo "  VERSION_ID=3.19.1"
  echo

  # STEP 10: Cleanup (remove image + tar)
  echo "  Step 10: Remove the loaded image."
  read -r -p "$PROMPT_ROOT" cmd10
  echo
  if [[ "$cmd10" != "docker rmi corp/alpine:transfer" ]]; then
    print_error "Incorrect."
    print_info "Remove it with: docker rmi corp/alpine:transfer"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  Untagged: corp/alpine:transfer"
  echo "  Deleted: sha256:........................................................"
  echo
  echo "  Step 11: Remove the tar archive."
  read -r -p "$PROMPT_ROOT" cmd11
  echo
  if [[ "$cmd11" != "rm -f /root/alpine-transfer.tar" ]]; then
    print_error "Incorrect."
    print_info "Use: rm -f /root/alpine-transfer.tar"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  (removed)"
  echo

  print_success "Nice work."
  print_info "You pulled an image, applied an internal tag, saved it for offline transfer, proved removal,"
  print_info "loaded it back, validated it runs, then cleaned up artifacts."
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
