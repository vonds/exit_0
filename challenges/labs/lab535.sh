#!/bin/bash

# Lab 535: Container Management with Podman + Skopeo (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 535: Podman + Skopeo Container Management (RHCSA)"
LAB_ID="lab535"
LAB_XP=53500
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab535:~$ "

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
  center_text "You must manage containers locally with Podman and inspect/copy images"
  center_text "across registries with Skopeo. You will pull images, run containers,"
  center_text "inspect metadata, commit changes, clean up, and inspect remote images"
  center_text "without pulling them."
  echo
  center_text "Targets:"
  center_text "- podman pull / images"
  center_text "- podman run -d --name ... -p host:container"
  center_text "- podman ps / ps -a"
  center_text "- podman stop / start"
  center_text "- podman inspect"
  center_text "- podman exec"
  center_text "- podman commit"
  center_text "- podman rm / rmi"
  center_text "- skopeo inspect docker://..."
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Verify Podman is installed."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "podman --version" ]]; then
    print_error "Incorrect. Use: podman --version"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  podman version 4.x.x"
  echo

  echo "  Step 2: Verify Skopeo is installed."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "skopeo --version" ]]; then
    print_error "Incorrect. Use: skopeo --version"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  skopeo version 1.x.x"
  echo

  echo "  Step 3: Pull the httpd image (Docker Hub)."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "podman pull docker.io/library/httpd" ]]; then
    print_error "Incorrect. Use: podman pull docker.io/library/httpd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Trying to pull docker.io/library/httpd..."
  echo "  Successfully pulled docker.io/library/httpd"
  echo

  echo "  Step 4: Run httpd in the background named my_httpd mapping host 8080 to container 80."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "podman run -d --name my_httpd -p 8080:80 docker.io/library/httpd" ]]; then
    print_error "Incorrect. Use: podman run -d --name my_httpd -p 8080:80 docker.io/library/httpd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890"
  echo

  echo "  Step 5: List running containers."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "podman ps" ]]; then
    print_error "Incorrect. Use: podman ps"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  CONTAINER ID  IMAGE                           COMMAND               CREATED        STATUS        PORTS                  NAMES"
  echo "  123abc        docker.io/library/httpd:latest  httpd-foreground       1 minute ago   Up 1 minute   0.0.0.0:8080->80/tcp   my_httpd"
  echo

  echo "  Step 6: Inspect the container and extract ONLY its image name using --format."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "podman inspect --format '{{ .ImageName }}' my_httpd" ]]; then
    print_error "Incorrect. Use: podman inspect --format '{{ .ImageName }}' my_httpd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  docker.io/library/httpd:latest"
  echo

  echo "  Step 7: Stop the container."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "podman stop my_httpd" ]]; then
    print_error "Incorrect. Use: podman stop my_httpd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  my_httpd"
  echo

  echo "  Step 8: Start the container again."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "podman start my_httpd" ]]; then
    print_error "Incorrect. Use: podman start my_httpd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  my_httpd"
  echo

  echo "  Step 9: Create a file inside the running container to simulate a change."
  echo "          Create /usr/local/apache2/htdocs/rhcsa.txt with the text: RHCSA-CONTAINERS"
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "podman exec my_httpd sh -c \"echo 'RHCSA-CONTAINERS' > /usr/local/apache2/htdocs/rhcsa.txt\"" ]]; then
    print_error "Incorrect."
    print_error "Use: podman exec my_httpd sh -c \"echo 'RHCSA-CONTAINERS' > /usr/local/apache2/htdocs/rhcsa.txt\""
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Step 10: Commit the running container to a new local image named custom_httpd:rhcsa."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "podman commit my_httpd custom_httpd:rhcsa" ]]; then
    print_error "Incorrect. Use: podman commit my_httpd custom_httpd:rhcsa"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  sha256:999aaa888bbb777ccc666ddd555eee444fff333aaa222bbb111ccc000ddd"
  echo

  echo "  Step 11: Verify the new image exists locally."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "podman images" ]]; then
    print_error "Incorrect. Use: podman images"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  REPOSITORY                  TAG    IMAGE ID     CREATED        SIZE"
  echo "  localhost/custom_httpd      rhcsa  999aaa       10 seconds ago 150 MB"
  echo "  docker.io/library/httpd     latest 888bbb       2 days ago     150 MB"
  echo

  echo "  Step 12: Inspect a remote image with Skopeo WITHOUT pulling it."
  echo "          Inspect UBI 9 from Red Hat registry."
  read -p "$PROMPT" cmd12
  echo
  if [[ "$cmd12" != "skopeo inspect docker://registry.access.redhat.com/ubi9/ubi" ]]; then
    print_error "Incorrect. Use: skopeo inspect docker://registry.access.redhat.com/ubi9/ubi"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  {"
  echo "    'Name': 'registry.access.redhat.com/ubi9/ubi',"
  echo "    'Digest': 'sha256:abcdef...',"
  echo "    'Created': '2024-01-01T12:34:56Z',"
  echo "    'Architecture': 'amd64',"
  echo "    'Os': 'linux'"
  echo "  }"
  echo

  echo "  Step 13: Stop and remove the container."
  read -p "$PROMPT" cmd13
  echo
  if [[ "$cmd13" != "podman stop my_httpd && podman rm my_httpd" ]]; then
    print_error "Incorrect. Use: podman stop my_httpd && podman rm my_httpd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  my_httpd"
  echo "  my_httpd"
  echo

  echo "  Step 14: Remove the pulled base image (httpd)."
  read -p "$PROMPT" cmd14
  echo
  if [[ "$cmd14" != "podman rmi docker.io/library/httpd" ]]; then
    print_error "Incorrect. Use: podman rmi docker.io/library/httpd"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Untagged: docker.io/library/httpd:latest"
  echo

  echo "  Step 15: Remove the custom committed image."
  read -p "$PROMPT" cmd15
  echo
  if [[ "$cmd15" != "podman rmi custom_httpd:rhcsa" ]]; then
    print_error "Incorrect. Use: podman rmi custom_httpd:rhcsa"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Untagged: localhost/custom_httpd:rhcsa"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- pulled images and ran containers with podman"
  print_info "- inspected containers with formatted output"
  print_info "- executed commands inside a running container"
  print_info "- committed a container to a new image"
  print_info "- inspected a remote image using skopeo without pulling it"
  print_info "- cleaned up containers and images safely"
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
