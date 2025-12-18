#!/bin/bash

# Lab 261: Podman inspect ubi8/httpd — check exposed ports — SIMULATED & SAFE
# SAFETY: Validates typed commands and prints canned outputs only. No real images/containers are pulled or run.
# Output policy: Only show realistic, canned command output. Silent steps print nothing.
# Formatting policy: Every simulated command OUTPUT line begins with exactly two spaces.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 261: Podman inspect ubi8/httpd (ports)"
LAB_ID="lab261"
LAB_XP=21620
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

IMAGE="registry.access.redhat.com/ubi8/httpd-24"

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
  center_text "Goal: Pull ${IMAGE}, inspect its metadata to find exposed ports, and verify with Podman tooling (SIMULATED)."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Confirm Podman is available
  draw_lab_ui
  echo "  Step 1: Show Podman version."
  read -p "  lab@lab261:~$ " cmd1
  if [[ "$cmd1" == "podman --version" ]]; then
    echo "  podman version 4.8.2"
  else
    print_error "Hint: Use podman --version."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 2: Pull the UBI8 httpd image (simulated)
  echo "  Step 2: Pull the httpd image from Red Hat registry."
  read -p "  lab@lab261:~$ " cmd2
  if [[ "$cmd2" == "podman pull ${IMAGE}" ]]; then
    echo "  Trying to pull ${IMAGE}..."
    echo "  Getting image source signatures"
    echo "  Copying blob  sha256:1a2b3c...  5.2 MiB / 5.2 MiB"
    echo "  Copying blob  sha256:4d5e6f...  69.0 MiB / 69.0 MiB"
    echo "  Writing manifest to image destination"
    echo "  Storing signatures"
    echo "  ${IMAGE}"
  else
    print_error "Hint: Use podman pull ${IMAGE}"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 3: List images and confirm presence
  echo "  Step 3: List images and confirm the httpd image is present."
  read -p "  lab@lab261:~$ " cmd3
  if [[ "$cmd3" == "podman images" || "$cmd3" == "podman image ls" ]]; then
    echo "  REPOSITORY                                      TAG         IMAGE ID      CREATED       SIZE"
    echo "  ${IMAGE%:*}                                  latest      7f1a9c3d2a10  2 weeks ago   227 MB"
  else
    print_error "Hint: Use podman images."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 4: Inspect exposed ports via Go template
  echo "  Step 4: Inspect the image to see which ports are exposed."
  read -p "  lab@lab261:~$ " cmd4
  if [[ "$cmd4" == "podman inspect --format \"{{json .Config.ExposedPorts}}\" ${IMAGE}" ]]; then
    echo "  {\"8080/tcp\":{}}"
  elif [[ "$cmd4" == "podman inspect ${IMAGE} | jq '.[0].Config.ExposedPorts'" ]]; then
    echo "  {"
    echo "    \"8080/tcp\": {}"
    echo "  }"
  else
    print_error "Hint: Try --format '{{json .Config.ExposedPorts}}' or pipe to jq '.[0].Config.ExposedPorts'."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 5: Inspect labels that hint at service exposure
  echo "  Step 5: Inspect image labels related to service exposure."
  read -p "  lab@lab261:~$ " cmd5
  if [[ "$cmd5" == "podman inspect --format \"{{json .Config.Labels}}\" ${IMAGE}" ]]; then
    echo "  {\"io.k8s.description\":\"Apache HTTP Server\","
    echo "   \"io.openshift.expose-services\":\"8080:http\","
    echo "   \"name\":\"ubi8/httpd-24\"}"
  elif [[ "$cmd5" == "podman inspect ${IMAGE} | jq '.[0].Config.Labels'" ]]; then
    echo "  {"
    echo "    \"io.k8s.description\": \"Apache HTTP Server\","
    echo "    \"io.openshift.expose-services\": \"8080:http\","
    echo "    \"name\": \"ubi8/httpd-24\""
    echo "  }"
  else
    print_error "Hint: Use --format '{{json .Config.Labels}}' or pipe to jq '.[0].Config.Labels'."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 6 (optional): Demonstrate runtime port mapping visibility
  echo "  Step 6 (optional): Run a disposable container with random host port and show mapping."
  read -p "  lab@lab261:~$ " cmd6a
  if [[ -z "$cmd6a" ]]; then
    :
  elif [[ "$cmd6a" == "podman run --rm -d -P ${IMAGE}" ]]; then
    echo "  9c1b2f3a4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t1u2v3w"
    echo
    echo "  Step 6 (verify): Show the published ports for the last container."
    read -p "  lab@lab261:~$ " cmd6b
    if [[ "$cmd6b" == "podman ps --format \"{{.Ports}}\"" || "$cmd6b" == "podman port -l" ]]; then
      echo "  8080/tcp -> 0.0.0.0:49153"
    else
      print_error "Hint: Use 'podman port -l' or 'podman ps --format \"{{.Ports}}\"'."
      read -p "Press Enter to try again..." _
      continue
    fi
  else
    print_error "Hint: Press Enter to skip, or run: podman run --rm -d -P ${IMAGE}"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  print_success "Nice work! You pulled the UBI8 httpd image, inspected its exposed ports (8080/tcp), and reviewed labels/port mappings (simulated)."
  print_info "You earned $LAB_XP XP for completing this lab."
  award_xp $LAB_XP
  XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON"); export XP; export LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've successfully completed this lab $completion_count time(s)."
  echo
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " post_choice
  [[ "$post_choice" == "2" ]] && exit 0
done
