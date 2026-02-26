#!/bin/bash

# Lab 161: Healthchecks (Dockerfile HEALTHCHECK + Verify via docker ps, condensed)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 161: Healthchecks (HEALTHCHECK + docker ps)"
LAB_ID="lab161"
LAB_XP=20000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT_ROOT="  root@lab161:~# "

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
  center_text "You are on-call for a small internal platform that runs in Docker."
  center_text "A recent incident showed containers can appear 'Up' while the app inside is non-functional."
  center_text "Your task is to add container self-reporting so operators can quickly see health status"
  center_text "using standard tooling (docker ps) and triage faster during incidents."
  center_text ""
  echo
  center_text "Press Enter to begin the lab..."
  read -r _
  draw_lab_ui

  # STEP 1: Create working directory
  echo "  Step 1: Create /root/healthcheck-lab and cd into it."
  read -r -p "$PROMPT_ROOT" cmd1
  echo
  if [[ "$cmd1" != "mkdir -p /root/healthcheck-lab && cd /root/healthcheck-lab" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi

  # STEP 2: Create Dockerfile (user only starts heredoc; content displayed as output)
  echo "  Step 2: Create a Dockerfile with a HEALTHCHECK using a heredoc."
  read -r -p "$PROMPT_ROOT" cmd2
  echo
  if [[ "$cmd2" != "cat > Dockerfile << 'EOF'" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi

  # Simulate user entering file content + EOF (display only)
  echo "  FROM busybox:latest"
  echo "  # Simple container that stays running"
  echo "  CMD [\"sh\", \"-c\", \"while true; do sleep 2; done\"]"
  echo ""
  echo "  # Self-reporting health: always succeeds (simulates a passing check)"
  echo "  HEALTHCHECK --interval=5s --timeout=2s --start-period=3s --retries=3 \\"
  echo "    CMD sh -c 'exit 0'"
  echo "  EOF"
  echo
  echo "  (Dockerfile created)"
  echo

  # STEP 3: Build the image
  echo "  Step 3: Build the image tagged hc-demo:1."
  read -r -p "$PROMPT_ROOT" cmd3
  echo
  if [[ "$cmd3" != "docker build -t hc-demo:1 ." ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  [+] Building 3.1s (6/6) FINISHED"
  echo "   => => naming to docker.io/library/hc-demo:1"
  echo

  # STEP 4: Run the container
  echo "  Step 4: Run the container in detached mode named hc1."
  read -r -p "$PROMPT_ROOT" cmd4
  echo
  if [[ "$cmd4" != "docker run -d --name hc1 hc-demo:1" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  8c2d7b0e2a6f7c8a0b5a2b1c9f2a3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c"
  echo

  # STEP 5: Verify status shows healthy
  echo "  Step 5: Show container name + status using docker ps formatting."
  read -r -p "$PROMPT_ROOT" cmd5
  echo
  if [[ "$cmd5" != "docker ps --format '{{.Names}} {{.Status}}'" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  hc1 Up 12 seconds (healthy)"
  echo

  # STEP 6: Cleanup container
  echo "  Step 6: Stop and remove the container."
  read -r -p "$PROMPT_ROOT" cmd6
  echo
  if [[ "$cmd6" != "docker rm -f hc1" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  hc1"
  echo

  # STEP 7: Cleanup image
  echo "  Step 7: Remove the image."
  read -r -p "$PROMPT_ROOT" cmd7
  echo
  if [[ "$cmd7" != "docker rmi hc-demo:1" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  Untagged: hc-demo:1"
  echo "  Deleted: sha256:3d9c1c0b7a9e..."
  echo

  # STEP 8: Cleanup directory
  echo "  Step 8: Remove the lab directory."
  read -r -p "$PROMPT_ROOT" cmd8
  echo
  if [[ "$cmd8" != "rm -rf /root/healthcheck-lab" ]]; then
    print_error "Incorrect."
    read -r -p "Press Enter to try again..." _
    continue
  fi

  print_success "Nice work."
  print_info "You added a Dockerfile HEALTHCHECK, ran the container, and verified it self-reports as healthy via docker ps."
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