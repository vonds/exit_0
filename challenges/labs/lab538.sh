#!/bin/bash

# Lab 538: Configure a Container to Start Automatically as a systemd Service (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 538: Configure a Container to Start Automatically as a systemd Service (RHCSA)"
LAB_ID="lab538"
LAB_XP=53800
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab538:~$ "

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
  center_text "A teammate needs a containerized web service that starts automatically at boot."
  center_text "You will run Apache HTTPD in a container, generate a systemd unit with Podman,"
  center_text "install and enable it, verify the service state, then clean up."
  echo
  center_text "Targets:"
  center_text "- podman pull"
  center_text "- podman run -d --name ... -p host:container"
  center_text "- podman generate systemd --name ... --files --new"
  center_text "- systemctl daemon-reload / enable / start / status / is-enabled"
  center_text "- curl -I http://localhost:PORT"
  center_text "- cleanup: stop/disable service, remove unit, remove container, remove image"
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

  echo "  Step 2: Run httpd in the background as a container named websvc,"
  echo "          publish it on host port 8080 -> container port 80."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "podman run -d --name websvc -p 8080:80 docker.io/library/httpd" ]]; then
    print_error "Incorrect."
    print_error "Use: podman run -d --name websvc -p 8080:80 docker.io/library/httpd"
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
  echo "  9abcde        docker.io/library/httpd:latest  httpd-foreground     1 minute ago   Up 1 minute   0.0.0.0:8080->80/tcp   websvc"
  echo

  echo "  Step 4: Generate a systemd unit file for the container (must create files, use --new)."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "podman generate systemd --name websvc --files --new" ]]; then
    print_error "Incorrect."
    print_error "Use: podman generate systemd --name websvc --files --new"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  ./container-websvc.service"
  echo

  echo "  Step 5: Move the generated unit file into /etc/systemd/system/."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo mv container-websvc.service /etc/systemd/system/" ]]; then
    print_error "Incorrect. Use: sudo mv container-websvc.service /etc/systemd/system/"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 6: Reload systemd to pick up the new unit file."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo systemctl daemon-reload" ]]; then
    print_error "Incorrect. Use: sudo systemctl daemon-reload"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 7: Enable the container service so it starts at boot."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo systemctl enable container-websvc" ]]; then
    print_error "Incorrect. Use: sudo systemctl enable container-websvc"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Created symlink /etc/systemd/system/multi-user.target.wants/container-websvc.service -> /etc/systemd/system/container-websvc.service."
  echo

  echo "  Step 8: Start the container service using systemd."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "sudo systemctl start container-websvc" ]]; then
    print_error "Incorrect. Use: sudo systemctl start container-websvc"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 9: Verify the service is active (running) with systemctl status."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "systemctl status container-websvc" ]]; then
    print_error "Incorrect. Use: systemctl status container-websvc"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  ● container-websvc.service - Podman container-websvc.service"
  echo "     Loaded: loaded (/etc/systemd/system/container-websvc.service; enabled)"
  echo "     Active: active (running)"
  echo

  echo "  Step 10: Verify the service is enabled at boot."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "systemctl is-enabled container-websvc" ]]; then
    print_error "Incorrect. Use: systemctl is-enabled container-websvc"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  enabled"
  echo

  echo "  Step 11: Verify the web service responds from the host (headers only)."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "curl -I http://localhost:8080" ]]; then
    print_error "Incorrect. Use: curl -I http://localhost:8080"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  HTTP/1.1 200 OK"
  echo "  Server: Apache/2.4"
  echo

  echo "  Step 12: Stop the systemd service."
  read -p "$PROMPT" cmd12
  echo
  if [[ "$cmd12" != "sudo systemctl stop container-websvc" ]]; then
    print_error "Incorrect. Use: sudo systemctl stop container-websvc"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 13: Disable the service."
  read -p "$PROMPT" cmd13
  echo
  if [[ "$cmd13" != "sudo systemctl disable container-websvc" ]]; then
    print_error "Incorrect. Use: sudo systemctl disable container-websvc"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 14: Remove the unit file and reload systemd (use && in one line)."
  read -p "$PROMPT" cmd14
  echo
  if [[ "$cmd14" != "sudo rm -f /etc/systemd/system/container-websvc.service && sudo systemctl daemon-reload" ]]; then
    print_error "Incorrect."
    print_error "Use: sudo rm -f /etc/systemd/system/container-websvc.service && sudo systemctl daemon-reload"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 15: Remove the container."
  read -p "$PROMPT" cmd15
  echo
  if [[ "$cmd15" != "podman rm -f websvc" ]]; then
    print_error "Incorrect. Use: podman rm -f websvc"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  websvc"
  echo

  echo "  Step 16: Remove the image."
  read -p "$PROMPT" cmd16
  echo
  if [[ "$cmd16" != "podman rmi docker.io/library/httpd" ]]; then
    print_error "Incorrect. Use: podman rmi docker.io/library/httpd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Untagged: docker.io/library/httpd:latest"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- ran a containerized web service (httpd)"
  print_info "- generated and installed a systemd unit using Podman"
  print_info "- enabled the service to start automatically at boot"
  print_info "- verified service state with systemctl and validated HTTP response"
  print_info "- cleaned up systemd unit, container, and image"
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
