#!/bin/bash

# Lab 537: Run a Service Inside a Container (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 537: Run a Service Inside a Container (RHCSA)"
LAB_ID="lab537"
LAB_XP=53700
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab537:~$ "

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
  center_text "A teammate needs a quick internal web service for a maintenance window."
  center_text "You will run Apache HTTPD inside a container, publish it on the host,"
  center_text "verify it from the host using curl, confirm restart policy, then clean up."
  echo
  center_text "Targets:"
  center_text "- podman pull"
  center_text "- podman run -d --name ... --restart=always -p host:container"
  center_text "- podman ps"
  center_text "- curl http://localhost:PORT"
  center_text "- podman logs"
  center_text "- podman inspect --format"
  center_text "- podman stop / podman rm / podman rmi"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Pull the httpd image."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "podman pull docker.io/library/httpd" ]]; then
    print_error "Incorrect. Use: podman pull docker.io/library/httpd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Trying to pull docker.io/library/httpd..."
  echo "  Successfully pulled docker.io/library/httpd"
  echo

  echo "  Step 2: Run httpd as a service in a container named webserver,"
  echo "          publish it on host port 8080 -> container port 80,"
  echo "          and set restart policy to always."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "podman run -d --name webserver --restart=always -p 8080:80 docker.io/library/httpd" ]]; then
    print_error "Incorrect."
    print_error "Use: podman run -d --name webserver --restart=always -p 8080:80 docker.io/library/httpd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  fedcba0987654321fedcba0987654321fedcba0987654321fedcba0987654321"
  echo

  echo "  Step 3: Verify the container is running."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "podman ps" ]]; then
    print_error "Incorrect. Use: podman ps"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  CONTAINER ID  IMAGE                           COMMAND              CREATED        STATUS        PORTS                  NAMES"
  echo "  9abcde        docker.io/library/httpd:latest  httpd-foreground     1 minute ago   Up 1 minute   0.0.0.0:8080->80/tcp   webserver"
  echo

  echo "  Step 4: Test the web service from the host using curl."
  echo "          (You should see HTML output starting with '<!DOCTYPE html>' or '<html>')"
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "curl http://localhost:8080" ]]; then
    print_error "Incorrect. Use: curl http://localhost:8080"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  <!DOCTYPE html>"
  echo "  <html><head><title>It works!</title></head><body><h1>It works!</h1></body></html>"
  echo

  echo "  Step 5: View the container logs to confirm requests are being served."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "podman logs webserver" ]]; then
    print_error "Incorrect. Use: podman logs webserver"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  AH00558: httpd: Could not reliably determine the server's fully qualified domain name"
  echo "  127.0.0.1 - - [01/Feb/2026:12:00:01 +0000] 'GET / HTTP/1.1' 200 45"
  echo

  echo "  Step 6: Verify the restart policy is always using podman inspect --format."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "podman inspect --format '{{ .HostConfig.RestartPolicy.Name }}' webserver" ]]; then
    print_error "Incorrect."
    print_error "Use: podman inspect --format '{{ .HostConfig.RestartPolicy.Name }}' webserver"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  always"
  echo

  echo "  Step 7: Stop the container."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "podman stop webserver" ]]; then
    print_error "Incorrect. Use: podman stop webserver"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  webserver"
  echo

  echo "  Step 8: Confirm the container is stopped (no output expected)."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "podman ps" ]]; then
    print_error "Incorrect. Use: podman ps"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  CONTAINER ID  IMAGE  COMMAND  CREATED  STATUS  PORTS  NAMES"
  echo "  (no output)"
  echo

  echo "  Step 9: Remove the container."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "podman rm webserver" ]]; then
    print_error "Incorrect. Use: podman rm webserver"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  webserver"
  echo

  echo "  Step 10: Remove the image."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "podman rmi docker.io/library/httpd" ]]; then
    print_error "Incorrect. Use: podman rmi docker.io/library/httpd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Untagged: docker.io/library/httpd:latest"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- pulled a service image (httpd)"
  print_info "- ran the service inside a container with host port publishing"
  print_info "- verified service health using curl and logs"
  print_info "- verified restart policy with formatted inspect output"
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
