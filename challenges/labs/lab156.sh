#!/bin/bash

# Lab 156: Docker Basics (Realistic Admin Workflow, condensed)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 156: Docker Basics (Images, Containers, Exec, Logs, Cleanup)"
LAB_ID="lab156"
LAB_XP=20000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT_ROOT="  root@lab156:~# "

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
  center_text "Ops ticket: 'Validate Docker is running, launch a test web container, verify it works,"
  center_text "inspect logs, exec into it, then clean up all resources.'"
  echo
  center_text "Press Enter to begin the lab..."
  read -r _
  draw_lab_ui

  # STEP 1: Verify Docker service is active
  echo "  Step 1: Verify Docker is running (service health)."
  read -r -p "$PROMPT_ROOT" cmd1
  echo
  if [[ "$cmd1" != "systemctl is-active docker" ]]; then
    print_error "Incorrect."
    print_info "Check Docker service state with: systemctl is-active docker"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  active"
  echo

  # STEP 2: Confirm Docker CLI can talk to the daemon
  echo "  Step 2: Confirm Docker CLI is functional."
  read -r -p "$PROMPT_ROOT" cmd2
  echo
  if [[ "$cmd2" != "docker version" ]]; then
    print_error "Incorrect."
    print_info "Run: docker version"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  Client: Docker Engine - Community"
  echo "   Version:           24.0.7"
  echo "   API version:       1.43"
  echo "  Server: Docker Engine - Community"
  echo "   Engine:"
  echo "    Version:          24.0.7"
  echo "    API version:      1.43 (minimum version 1.12)"
  echo

  # STEP 3: Pull a known image (evidence + reproducibility)
  echo "  Step 3: Pull the nginx image (ensure it's present locally)."
  read -r -p "$PROMPT_ROOT" cmd3
  echo
  if [[ "$cmd3" != "docker pull nginx:latest" ]]; then
    print_error "Incorrect."
    print_info "Pull the image using: docker pull nginx:latest"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  latest: Pulling from library/nginx"
  echo "  Digest: sha256:........................................................"
  echo "  Status: Downloaded newer image for nginx:latest"
  echo "  docker.io/library/nginx:latest"
  echo

  # STEP 4: Run a container in detached mode with a name and port mapping
  echo "  Step 4: Run nginx in the background named web1 and publish host port 8080 -> container 80."
  read -r -p "$PROMPT_ROOT" cmd4
  echo
  if [[ "$cmd4" != "docker run -d --name web1 -p 8080:80 nginx:latest" ]]; then
    print_error "Incorrect."
    print_info "Use: docker run -d --name web1 -p 8080:80 nginx:latest"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  9f2c3b0a1d2e3f4a5b6c7d8e9f00112233445566778899aabbccddeeff0011"
  echo

  # STEP 5: Verify container is running (basic ops check)
  echo "  Step 5: Verify the container is running."
  read -r -p "$PROMPT_ROOT" cmd5
  echo
  if [[ "$cmd5" != "docker ps" ]]; then
    print_error "Incorrect."
    print_info "List running containers with: docker ps"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  CONTAINER ID   IMAGE          COMMAND                  STATUS          PORTS                  NAMES"
  echo "  9f2c3b0a1d2e   nginx:latest   \"/docker-entrypoint…\"   Up 5 seconds    0.0.0.0:8080->80/tcp   web1"
  echo

  # STEP 6: Validate the service responds via curl
  echo "  Step 6: Validate nginx responds on localhost:8080."
  read -r -p "$PROMPT_ROOT" cmd6
  echo
  if [[ "$cmd6" != "curl -I http://localhost:8080" ]]; then
    print_error "Incorrect."
    print_info "Use curl to fetch headers: curl -I http://localhost:8080"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  HTTP/1.1 200 OK"
  echo "  Server: nginx/1.25.x"
  echo "  Date: Tue, 10 Feb 2026 23:00:00 GMT"
  echo "  Content-Type: text/html"
  echo

  # STEP 7: View logs (quick triage)
  echo "  Step 7: View the last 5 log lines from the container."
  read -r -p "$PROMPT_ROOT" cmd7
  echo
  if [[ "$cmd7" != "docker logs --tail 5 web1" ]]; then
    print_error "Incorrect."
    print_info "Use: docker logs --tail 5 web1"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  127.0.0.1 - - [10/Feb/2026:23:00:00 +0000] \"HEAD / HTTP/1.1\" 200 0 \"-\" \"curl/7.88.1\""
  echo

  # STEP 8: Exec into container and confirm nginx config exists
  echo "  Step 8: Exec into the container and list /etc/nginx inside it."
  read -r -p "$PROMPT_ROOT" cmd8
  echo
  if [[ "$cmd8" != "docker exec -it web1 ls -l /etc/nginx" ]]; then
    print_error "Incorrect."
    print_info "Use: docker exec -it web1 ls -l /etc/nginx"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  total 12"
  echo "  -rw-r--r-- 1 root root 1007 Feb 10 22:59 nginx.conf"
  echo "  drwxr-xr-x 2 root root 4096 Feb 10 22:59 conf.d"
  echo "  drwxr-xr-x 2 root root 4096 Feb 10 22:59 modules"
  echo

  # STEP 9: Stop and remove container (cleanup)
  echo "  Step 9: Stop and remove the container in one command."
  read -r -p "$PROMPT_ROOT" cmd9
  echo
  if [[ "$cmd9" != "docker rm -f web1" ]]; then
    print_error "Incorrect."
    print_info "Force remove (stops + removes): docker rm -f web1"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  web1"
  echo

  # STEP 10: Remove the image (cleanup + disk hygiene)
  echo "  Step 10: Remove the nginx:latest image."
  read -r -p "$PROMPT_ROOT" cmd10
  echo
  if [[ "$cmd10" != "docker rmi nginx:latest" ]]; then
    print_error "Incorrect."
    print_info "Remove the image with: docker rmi nginx:latest"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  Untagged: nginx:latest"
  echo "  Deleted: sha256:........................................................"
  echo

  print_success "Nice work."
  print_info "You verified Docker, pulled an image, ran a container with port mapping, validated service health,"
  print_info "checked logs, exec'd for inspection, then cleaned up container + image."
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
