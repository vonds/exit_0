#!/bin/bash

# Lab 532: Find and Retrieve Container Images from a Remote Registry (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 532: Podman Image Discovery + Retrieval (RHCSA)"
LAB_ID="lab532"
LAB_XP=53200
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab532:~$ "

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
  center_text "Your system uses Podman for container management."
  center_text "You must locate container images from a remote registry,"
  center_text "retrieve them locally, verify availability, and run containers."
  echo
  center_text "Targets:"
  center_text "- podman search"
  center_text "- podman pull (Red Hat registry + Docker Hub)"
  center_text "- podman images"
  center_text "- podman run"
  center_text "- podman ps"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Verify Podman is installed and available."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "podman --version" ]]; then
    print_error "Incorrect. Use: podman --version"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  podman version 4.x.x"
  echo

  echo "  Step 2: Search the default remote registry for the nginx image."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "podman search nginx" ]]; then
    print_error "Incorrect. Use: podman search nginx"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  INDEX       NAME                               DESCRIPTION"
  echo "  docker.io   docker.io/library/nginx           Official build of Nginx"
  echo

  echo "  Step 3: Pull the nginx image from Docker Hub explicitly."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "podman pull docker.io/library/nginx" ]]; then
    print_error "Incorrect. Use: podman pull docker.io/library/nginx"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Trying to pull docker.io/library/nginx..."
  echo "  Successfully pulled docker.io/library/nginx"
  echo

  echo "  Step 4: Pull the RHEL 9 UBI image from the Red Hat registry."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "podman pull registry.access.redhat.com/ubi9/ubi" ]]; then
    print_error "Incorrect. Use: podman pull registry.access.redhat.com/ubi9/ubi"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Trying to pull registry.access.redhat.com/ubi9/ubi..."
  echo "  Successfully pulled registry.access.redhat.com/ubi9/ubi"
  echo

  echo "  Step 5: List all locally available container images."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "podman images" ]]; then
    print_error "Incorrect. Use: podman images"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  REPOSITORY                               TAG     IMAGE ID      CREATED        SIZE"
  echo "  docker.io/library/nginx                 latest  abc123        2 days ago     142 MB"
  echo "  registry.access.redhat.com/ubi9/ubi     latest  def456        1 week ago     215 MB"
  echo

  echo "  Step 6: Run the nginx container in detached mode, mapping host port 8080 to container port 80."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "podman run -d --name mynginx -p 8080:80 nginx" ]]; then
    print_error "Incorrect. Use: podman run -d --name mynginx -p 8080:80 nginx"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Container started: mynginx"
  echo

  echo "  Step 7: Verify the container is running."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "podman ps" ]]; then
    print_error "Incorrect. Use: podman ps"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  CONTAINER ID  IMAGE    COMMAND               STATUS          PORTS"
  echo "  789xyz        nginx    nginx -g daemon off; Up 5 seconds    0.0.0.0:8080->80/tcp"
  echo

  echo "  Step 8: Stop and remove the nginx container (cleanup)."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "podman stop mynginx && podman rm mynginx" ]]; then
    print_error "Incorrect. Use: podman stop mynginx && podman rm mynginx"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  mynginx"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- searched remote container registries"
  print_info "- pulled images from Docker Hub and Red Hat registry"
  print_info "- verified local images"
  print_info "- ran and validated a container using Podman"
  print_info "- cleaned up containers properly"
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
