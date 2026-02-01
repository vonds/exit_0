#!/bin/bash

# Lab 539: Attach Persistent Storage to a Container (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 539: Attach Persistent Storage to a Container (RHCSA)"
LAB_ID="lab539"
LAB_XP=53900
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab539:~$ "

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
  center_text "A teammate needs container data to persist even if the container is removed."
  center_text "You will attach persistent storage using a bind mount and a named volume,"
  center_text "verify persistence, inspect storage, then clean up."
  echo
  center_text "Targets:"
  center_text "- sudo mkdir / permission sanity"
  center_text "- podman pull"
  center_text "- podman run -d --name ... -v hostdir:containerdir:Z"
  center_text "- podman exec / podman stop / podman rm"
  center_text "- podman volume create / podman volume inspect"
  center_text "- verify persistence on host"
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

  echo "  Step 2: Create a host directory for persistent data at /srv/persist-web."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo mkdir -p /srv/persist-web" ]]; then
    print_error "Incorrect. Use: sudo mkdir -p /srv/persist-web"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 3: Run an httpd container named persistweb with a bind mount."
  echo "          Mount /srv/persist-web on the host to /usr/local/apache2/htdocs in the container."
  echo "          Include :Z for SELinux labeling."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "podman run -d --name persistweb -p 8080:80 -v /srv/persist-web:/usr/local/apache2/htdocs:Z docker.io/library/httpd" ]]; then
    print_error "Incorrect."
    print_error "Use: podman run -d --name persistweb -p 8080:80 -v /srv/persist-web:/usr/local/apache2/htdocs:Z docker.io/library/httpd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  fedcba0987654321fedcba0987654321fedcba0987654321fedcba0987654321"
  echo

  echo "  Step 4: Create an index.html on the HOST inside /srv/persist-web."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo sh -c \"echo 'Persistent OK' > /srv/persist-web/index.html\"" ]]; then
    print_error "Incorrect."
    print_error "Use: sudo sh -c \"echo 'Persistent OK' > /srv/persist-web/index.html\""
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 5: Verify httpd serves the persisted content from the host."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "curl http://localhost:8080" ]]; then
    print_error "Incorrect. Use: curl http://localhost:8080"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Persistent OK"
  echo

  echo "  Step 6: Stop and remove the container (but NOT the host directory)."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "podman stop persistweb && podman rm persistweb" ]]; then
    print_error "Incorrect. Use: podman stop persistweb && podman rm persistweb"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  persistweb"
  echo "  persistweb"
  echo

  echo "  Step 7: Confirm the persisted file still exists on the host."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo cat /srv/persist-web/index.html" ]]; then
    print_error "Incorrect. Use: sudo cat /srv/persist-web/index.html"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Persistent OK"
  echo

  echo "  Step 8: Create a named volume called webdata."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "podman volume create webdata" ]]; then
    print_error "Incorrect. Use: podman volume create webdata"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  webdata"
  echo

  echo "  Step 9: Inspect the named volume to see where it lives on the host."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "podman volume inspect webdata" ]]; then
    print_error "Incorrect. Use: podman volume inspect webdata"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  ["
  echo "    {"
  echo "      \"Name\": \"webdata\","
  echo "      \"Driver\": \"local\","
  echo "      \"Mountpoint\": \"/var/lib/containers/storage/volumes/webdata/_data\""
  echo "    }"
  echo "  ]"
  echo

  echo "  Step 10: Run a container named volweb using the named volume webdata,"
  echo "           mounted to /usr/local/apache2/htdocs (include :Z)."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "podman run -d --name volweb -p 8081:80 -v webdata:/usr/local/apache2/htdocs:Z docker.io/library/httpd" ]]; then
    print_error "Incorrect."
    print_error "Use: podman run -d --name volweb -p 8081:80 -v webdata:/usr/local/apache2/htdocs:Z docker.io/library/httpd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
  echo

  echo "  Step 11: Write a file INSIDE the container into the mounted directory."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "podman exec volweb sh -c \"echo 'Volume Persistent OK' > /usr/local/apache2/htdocs/index.html\"" ]]; then
    print_error "Incorrect."
    print_error "Use: podman exec volweb sh -c \"echo 'Volume Persistent OK' > /usr/local/apache2/htdocs/index.html\""
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 12: Verify the service returns the file written through the volume."
  read -p "$PROMPT" cmd12
  echo
  if [[ "$cmd12" != "curl http://localhost:8081" ]]; then
    print_error "Incorrect. Use: curl http://localhost:8081"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Volume Persistent OK"
  echo

  echo "  Step 13: Stop and remove the container volweb."
  read -p "$PROMPT" cmd13
  echo
  if [[ "$cmd13" != "podman stop volweb && podman rm volweb" ]]; then
    print_error "Incorrect. Use: podman stop volweb && podman rm volweb"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  volweb"
  echo "  volweb"
  echo

  echo "  Step 14: Run a NEW container volweb2 using the SAME named volume,"
  echo "           then verify it still serves the persisted data."
  read -p "$PROMPT" cmd14
  echo
  if [[ "$cmd14" != "podman run -d --name volweb2 -p 8081:80 -v webdata:/usr/local/apache2/htdocs:Z docker.io/library/httpd" ]]; then
    print_error "Incorrect."
    print_error "Use: podman run -d --name volweb2 -p 8081:80 -v webdata:/usr/local/apache2/htdocs:Z docker.io/library/httpd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789"
  echo

  echo "  Step 15: Confirm the content is still there after the container replacement."
  read -p "$PROMPT" cmd15
  echo
  if [[ "$cmd15" != "curl http://localhost:8081" ]]; then
    print_error "Incorrect. Use: curl http://localhost:8081"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Volume Persistent OK"
  echo

  echo "  Step 16: Clean up: stop/remove volweb2, remove named volume, remove bind mount directory,"
  echo "           and remove the image (use && in one line)."
  read -p "$PROMPT" cmd16
  echo
  if [[ "$cmd16" != "podman stop volweb2 && podman rm volweb2 && podman volume rm webdata && sudo rm -rf /srv/persist-web && podman rmi docker.io/library/httpd" ]]; then
    print_error "Incorrect."
    print_error "Use: podman stop volweb2 && podman rm volweb2 && podman volume rm webdata && sudo rm -rf /srv/persist-web && podman rmi docker.io/library/httpd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  volweb2"
  echo "  volweb2"
  echo "  webdata"
  echo "  Untagged: docker.io/library/httpd:latest"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- attached persistent storage using a bind mount with SELinux labeling (:Z)"
  print_info "- verified persistence after container removal"
  print_info "- created and inspected a named volume"
  print_info "- verified volume-backed persistence across container replacement"
  print_info "- cleaned up containers, volumes, host paths, and images"
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
