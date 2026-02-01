#!/bin/bash

# Lab 534: Inspect Container Images (RHCSA)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 534: Inspect Container Images (RHCSA)"
LAB_ID="lab534"
LAB_XP=53400
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  examuser@rhel-lab534:~$ "

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
  center_text "Your team pulled images from remote registries."
  center_text "Before running anything, you must inspect images to confirm"
  center_text "metadata, ports, environment variables, volumes, and layer history."
  echo
  center_text "Targets:"
  center_text "- podman pull"
  center_text "- podman inspect (full JSON)"
  center_text "- podman inspect --format '...'"
  center_text "- podman history"
  center_text "- podman images"
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  echo "  Step 1: Verify Podman is available."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "podman --version" ]]; then
    print_error "Incorrect. Use: podman --version"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  podman version 4.x.x"
  echo

  echo "  Step 2: Pull the nginx image (Docker Hub) so it is available locally."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "podman pull docker.io/library/nginx" ]]; then
    print_error "Incorrect. Use: podman pull docker.io/library/nginx"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Trying to pull docker.io/library/nginx..."
  echo "  Successfully pulled docker.io/library/nginx"
  echo

  echo "  Step 3: Confirm nginx is present in your local image list."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "podman images" ]]; then
    print_error "Incorrect. Use: podman images"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  REPOSITORY                 TAG     IMAGE ID      CREATED        SIZE"
  echo "  docker.io/library/nginx    latest  abc123        2 days ago     142 MB"
  echo

  echo "  Step 4: Inspect nginx and view the full JSON metadata."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "podman inspect nginx" ]]; then
    print_error "Incorrect. Use: podman inspect nginx"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  ["
  echo "    {"
  echo "      'Id': 'sha256:abcdef...',"
  echo "      'Created': '2024-01-01T12:34:56Z',"
  echo "      'RepoTags': [ 'docker.io/library/nginx:latest' ],"
  echo "      'Config': {"
  echo "        'Env': [ 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' ],"
  echo "        'Cmd': [ 'nginx', '-g', 'daemon off;' ]"
  echo "      }"
  echo "    }"
  echo "  ]"
  echo

  echo "  Step 5: Extract ONLY the creation time using --format."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "podman inspect --format '{{ .Created }}' nginx" ]]; then
    print_error "Incorrect. Use: podman inspect --format '{{ .Created }}' nginx"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  2024-01-01T12:34:56Z"
  echo

  echo "  Step 6: Extract ONLY exposed ports from nginx using --format."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "podman inspect --format '{{ .Config.ExposedPorts }}' nginx" ]]; then
    print_error "Incorrect. Use: podman inspect --format '{{ .Config.ExposedPorts }}' nginx"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  map[80/tcp:{}]"
  echo

  echo "  Step 7: Extract ONLY environment variables from nginx using --format."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "podman inspect --format '{{ .Config.Env }}' nginx" ]]; then
    print_error "Incorrect. Use: podman inspect --format '{{ .Config.Env }}' nginx"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  [PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin]"
  echo

  echo "  Step 8: Check whether nginx defines volumes (it may be empty)."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "podman inspect --format '{{ .Config.Volumes }}' nginx" ]]; then
    print_error "Incorrect. Use: podman inspect --format '{{ .Config.Volumes }}' nginx"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  <nil>"
  echo

  echo "  Step 9: View the layer history for nginx."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "podman history nginx" ]]; then
    print_error "Incorrect. Use: podman history nginx"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  ID            CREATED       CREATED BY                                SIZE"
  echo "  111aaa        2 weeks ago   /bin/sh -c '... CMD ...'                   0B"
  echo "  222bbb        2 weeks ago   /bin/sh -c '... EXPOSE 80/tcp ...'         0B"
  echo "  333ccc        2 weeks ago   /bin/sh -c '... install packages ...'      15MB"
  echo

  echo "  Step 10: Pull the UBI 9 image from Red Hat registry."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "podman pull registry.access.redhat.com/ubi9/ubi" ]]; then
    print_error "Incorrect. Use: podman pull registry.access.redhat.com/ubi9/ubi"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Trying to pull registry.access.redhat.com/ubi9/ubi..."
  echo "  Successfully pulled registry.access.redhat.com/ubi9/ubi"
  echo

  echo "  Step 11: Inspect UBI 9 and extract ONLY environment variables."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "podman inspect --format '{{ .Config.Env }}' registry.access.redhat.com/ubi9/ubi" ]]; then
    print_error "Incorrect. Use: podman inspect --format '{{ .Config.Env }}' registry.access.redhat.com/ubi9/ubi"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  [PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin]"
  echo

  print_success "Excellent work."
  print_info "You successfully:"
  print_info "- pulled images from remote registries"
  print_info "- inspected full image metadata using podman inspect"
  print_info "- extracted specific fields with --format using single quotes inside double quotes"
  print_info "- reviewed image layer history using podman history"
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
