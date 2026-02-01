#!/bin/bash

# Lab 536: Basic Container Management with Podman (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 536: Basic Podman Container Management (RHCSA)"
LAB_ID="lab536"
LAB_XP=53600
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab536:~$ "

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
  center_text "You are a junior sysadmin asked to prove you can manage containers on RHEL 9"
  center_text "using Podman. You must pull an image, run a container, list containers,"
  center_text "stop/start it, and then clean up. You will also verify restart policy."
  echo
  center_text "Targets:"
  center_text "- podman pull"
  center_text "- podman run -d --name ... --restart=always -p host:container"
  center_text "- podman ps / podman ps -a"
  center_text "- podman stop / podman start"
  center_text "- podman rm"
  center_text "- verification using podman inspect --format"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Pull the nginx image from Docker Hub."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "podman pull docker.io/library/nginx" ]]; then
    print_error "Incorrect. Use: podman pull docker.io/library/nginx"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Trying to pull docker.io/library/nginx..."
  echo "  Successfully pulled docker.io/library/nginx"
  echo

  echo "  Step 2: Run nginx in the background named my_nginx,"
  echo "          map host port 8080 to container port 80,"
  echo "          and set restart policy to always."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "podman run -d --name my_nginx --restart=always -p 8080:80 docker.io/library/nginx" ]]; then
    print_error "Incorrect."
    print_error "Use: podman run -d --name my_nginx --restart=always -p 8080:80 docker.io/library/nginx"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890"
  echo

  echo "  Step 3: List running containers."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "podman ps" ]]; then
    print_error "Incorrect. Use: podman ps"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  CONTAINER ID  IMAGE                           COMMAND               CREATED        STATUS        PORTS                  NAMES"
  echo "  123abc        docker.io/library/nginx:latest  nginx -g 'daemon off;' 1 minute ago   Up 1 minute   0.0.0.0:8080->80/tcp   my_nginx"
  echo

  echo "  Step 4: List ALL containers (running and stopped)."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "podman ps -a" ]]; then
    print_error "Incorrect. Use: podman ps -a"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  CONTAINER ID  IMAGE                           COMMAND               CREATED        STATUS        PORTS                  NAMES"
  echo "  123abc        docker.io/library/nginx:latest  nginx -g 'daemon off;' 1 minute ago   Up 1 minute   0.0.0.0:8080->80/tcp   my_nginx"
  echo

  echo "  Step 5: Stop the container."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "podman stop my_nginx" ]]; then
    print_error "Incorrect. Use: podman stop my_nginx"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  my_nginx"
  echo

  echo "  Step 6: Confirm it is stopped by listing running containers."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "podman ps" ]]; then
    print_error "Incorrect. Use: podman ps"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  CONTAINER ID  IMAGE  COMMAND  CREATED  STATUS  PORTS  NAMES"
  echo "  (no output)"
  echo

  echo "  Step 7: Confirm it still exists by listing all containers."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "podman ps -a" ]]; then
    print_error "Incorrect. Use: podman ps -a"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  CONTAINER ID  IMAGE                           COMMAND               CREATED        STATUS                     PORTS                  NAMES"
  echo "  123abc        docker.io/library/nginx:latest  nginx -g 'daemon off;' 2 minutes ago  Exited (0) 5 seconds ago  0.0.0.0:8080->80/tcp   my_nginx"
  echo

  echo "  Step 8: Start the stopped container."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "podman start my_nginx" ]]; then
    print_error "Incorrect. Use: podman start my_nginx"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  my_nginx"
  echo

  echo "  Step 9: Verify the restart policy is set to always using podman inspect --format."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "podman inspect --format '{{ .HostConfig.RestartPolicy.Name }}' my_nginx" ]]; then
    print_error "Incorrect."
    print_error "Use: podman inspect --format '{{ .HostConfig.RestartPolicy.Name }}' my_nginx"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  always"
  echo

  echo "  Step 10: Stop and remove the container."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "podman stop my_nginx && podman rm my_nginx" ]]; then
    print_error "Incorrect. Use: podman stop my_nginx && podman rm my_nginx"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  my_nginx"
  echo "  my_nginx"
  echo

  echo "  Step 11: Remove the nginx image."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "podman rmi docker.io/library/nginx" ]]; then
    print_error "Incorrect. Use: podman rmi docker.io/library/nginx"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Untagged: docker.io/library/nginx:latest"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- pulled an image"
  print_info "- ran a container in detached mode with port mapping"
  print_info "- listed running and all containers"
  print_info "- stopped and started a container"
  print_info "- verified restart policy using formatted inspect output"
  print_info "- cleaned up containers and images"
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
