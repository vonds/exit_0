#!/bin/bash

# Lab 160: Docker Compose Basics (Multi-Container App + Verify + Cleanup, condensed)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 160: Docker Compose (Up, Ps, Logs, Down)"
LAB_ID="lab160"
LAB_XP=20000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT_ROOT="  root@lab160:~# "

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
  center_text "Ops ticket: 'Spin up a small local stack for testing using Docker Compose."
  center_text "Bring up nginx + redis, verify both services are running, check logs, then tear it down.'"
  echo
  center_text "Press Enter to begin the lab..."
  read -r _
  draw_lab_ui

  # STEP 1: Verify docker compose is available
  echo "  Step 1: Verify Docker Compose is installed."
  read -r -p "$PROMPT_ROOT" cmd1
  echo
  if [[ "$cmd1" != "docker compose version" ]]; then
    print_error "Incorrect."
    print_info "Check it with: docker compose version"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  Docker Compose version v2.24.6"
  echo

  # STEP 2: Create a working directory
  echo "  Step 2: Create /root/compose-lab and cd into it."
  read -r -p "$PROMPT_ROOT" cmd2
  echo
  if [[ "$cmd2" != "mkdir -p /root/compose-lab && cd /root/compose-lab" ]]; then
    print_error "Incorrect."
    print_info "Use: mkdir -p /root/compose-lab && cd /root/compose-lab"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  (directory ready)"
  echo

   # STEP 3: Create docker-compose.yml (user only starts the heredoc; content is displayed as output)
  echo "  Step 3: Create docker-compose.yml using a heredoc (nginx + redis)."
  read -r -p "$PROMPT_ROOT" cmd3
  echo
  if [[ "$cmd3" != "cat > docker-compose.yml << 'EOF'" ]]; then
    print_error "Incorrect."
    print_info "Start the heredoc with: cat > docker-compose.yml << 'EOF'"
    read -r -p "Press Enter to try again..." _
    continue
  fi

  # Simulate the user entering file content + EOF (display only)
  echo "  services:"
  echo "    web:"
  echo "      image: nginx:latest"
  echo "      ports:"
  echo "        - \"8081:80\""
  echo "    cache:"
  echo "      image: redis:latest"
  echo "      ports:"
  echo "        - \"6379:6379\""
  echo "  EOF"
  echo
  echo "  (docker-compose.yml created)"
  echo

  # STEP 4: Bring the stack up
  echo "  Step 4: Start the stack in detached mode."
  read -r -p "$PROMPT_ROOT" cmd4
  echo
  if [[ "$cmd4" != "docker compose up -d" ]]; then
    print_error "Incorrect."
    print_info "Use: docker compose up -d"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  [+] Running 2/2"
  echo "   ✔ Container compose-lab-web-1    Started"
  echo "   ✔ Container compose-lab-cache-1  Started"
  echo

  # STEP 5: Check status
  echo "  Step 5: Show compose service status."
  read -r -p "$PROMPT_ROOT" cmd5
  echo
  if [[ "$cmd5" != "docker compose ps" ]]; then
    print_error "Incorrect."
    print_info "Use: docker compose ps"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  NAME                 IMAGE          STATUS          PORTS"
  echo "  compose-lab-web-1     nginx:latest   Up              0.0.0.0:8081->80/tcp"
  echo "  compose-lab-cache-1   redis:latest   Up              0.0.0.0:6379->6379/tcp"
  echo

  # STEP 6: Verify web responds
  echo "  Step 6: Verify nginx responds on localhost:8081."
  read -r -p "$PROMPT_ROOT" cmd6
  echo
  if [[ "$cmd6" != "curl -I http://localhost:8081" ]]; then
    print_error "Incorrect."
    print_info "Use: curl -I http://localhost:8081"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  HTTP/1.1 200 OK"
  echo "  Server: nginx/1.25.x"
  echo

  # STEP 7: View logs (quick triage)
  echo "  Step 7: Show the last 5 lines of logs for the web service."
  read -r -p "$PROMPT_ROOT" cmd7
  echo
  if [[ "$cmd7" != "docker compose logs --tail 5 web" ]]; then
    print_error "Incorrect."
    print_info "Use: docker compose logs --tail 5 web"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  web-1  | 127.0.0.1 - - [10/Feb/2026:23:00:00 +0000] \"HEAD / HTTP/1.1\" 200 0 \"-\" \"curl/7.88.1\""
  echo

  # STEP 8: Tear down the stack
  echo "  Step 8: Stop and remove the stack (containers + network)."
  read -r -p "$PROMPT_ROOT" cmd8
  echo
  if [[ "$cmd8" != "docker compose down" ]]; then
    print_error "Incorrect."
    print_info "Use: docker compose down"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  [+] Running 2/2"
  echo "   ✔ Container compose-lab-cache-1  Removed"
  echo "   ✔ Container compose-lab-web-1    Removed"
  echo "   ✔ Network compose-lab_default    Removed"
  echo

  # STEP 9: Cleanup directory
  echo "  Step 9: Remove the lab directory."
  read -r -p "$PROMPT_ROOT" cmd9
  echo
  if [[ "$cmd9" != "rm -rf /root/compose-lab" ]]; then
    print_error "Incorrect."
    print_info "Use: rm -rf /root/compose-lab"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  (removed)"
  echo

  print_success "Nice work."
  print_info "You verified Compose, created a minimal multi-service stack, validated service health,"
  print_info "reviewed logs, then cleanly tore down and removed the working directory."
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
