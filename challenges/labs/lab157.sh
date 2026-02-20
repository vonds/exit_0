#!/bin/bash

# Lab 157: Docker Networking (Realistic Admin Workflow, condensed)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 157: Docker Networking (User-defined Bridge + Connectivity)"
LAB_ID="lab157"
LAB_XP=20000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT_ROOT="  root@lab157:~# "

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
  center_text "Ops ticket: 'Stand up an isolated Docker network for app containers."
  center_text "Create a user-defined bridge network, attach two containers, and verify"
  center_text "they can resolve each other by name. Then clean up everything.'"
  echo
  center_text "Press Enter to begin the lab..."
  read -r _
  draw_lab_ui

  # STEP 1: Evidence first (current networks)
  echo "  Step 1: List existing Docker networks."
  read -r -p "$PROMPT_ROOT" cmd1
  echo
  if [[ "$cmd1" != "docker network ls" ]]; then
    print_error "Incorrect."
    print_info "List Docker networks with: docker network ls"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  NETWORK ID     NAME      DRIVER    SCOPE"
  echo "  a1b2c3d4e5f6   bridge    bridge    local"
  echo "  b2c3d4e5f6a1   host      host      local"
  echo "  c3d4e5f6a1b2   none      null      local"
  echo

  # STEP 2: Create user-defined bridge network
  echo "  Step 2: Create a user-defined bridge network named appnet."
  read -r -p "$PROMPT_ROOT" cmd2
  echo
  if [[ "$cmd2" != "docker network create appnet" ]]; then
    print_error "Incorrect."
    print_info "Create it with: docker network create appnet"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  7aa1bb2cc3dd4ee5ff6677889900aabbccddeeff0011223344556677889900"
  echo

  # STEP 3: Verify network exists
  echo "  Step 3: Verify appnet exists."
  read -r -p "$PROMPT_ROOT" cmd3
  echo
  if [[ "$cmd3" != "docker network ls" ]]; then
    print_error "Incorrect."
    print_info "Run: docker network ls"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  NETWORK ID     NAME      DRIVER    SCOPE"
  echo "  a1b2c3d4e5f6   bridge    bridge    local"
  echo "  b2c3d4e5f6a1   host      host      local"
  echo "  c3d4e5f6a1b2   none      null      local"
  echo "  d4e5f6a1b2c3   appnet    bridge    local"
  echo

  # STEP 4: Launch two containers attached to appnet
  echo "  Step 4: Start two Alpine containers on appnet (names: app1 and app2)."
  echo "          They should stay running (use a sleep loop)."
  read -r -p "$PROMPT_ROOT" cmd4
  echo
  if [[ "$cmd4" != "docker run -d --name app1 --network appnet alpine:latest sleep 1d" ]]; then
    print_error "Incorrect."
    print_info "Start app1 with: docker run -d --name app1 --network appnet alpine:latest sleep 1d"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  111122223333444455556666777788889999aaaabbbbccccddddeeeeffff0000"
  echo
  read -r -p "$PROMPT_ROOT" cmd4b
  echo
  if [[ "$cmd4b" != "docker run -d --name app2 --network appnet alpine:latest sleep 1d" ]]; then
    print_error "Incorrect."
    print_info "Start app2 with: docker run -d --name app2 --network appnet alpine:latest sleep 1d"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  0000ffffeeeeddddccccbbbbaaaa999988887777666655554444333322221111"
  echo

  # STEP 5: Verify both containers are running
  echo "  Step 5: Verify both containers are running."
  read -r -p "$PROMPT_ROOT" cmd5
  echo
  if [[ "$cmd5" != "docker ps" ]]; then
    print_error "Incorrect."
    print_info "Use: docker ps"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  CONTAINER ID   IMAGE          COMMAND        STATUS          NAMES"
  echo "  111122223333   alpine:latest  \"sleep 1d\"    Up 3 seconds    app1"
  echo "  0000ffffeeee   alpine:latest  \"sleep 1d\"    Up 1 seconds    app2"
  echo

  # STEP 6: Verify name resolution + connectivity within appnet
  echo "  Step 6: From app1, ping app2 by container name (3 packets)."
  read -r -p "$PROMPT_ROOT" cmd6
  echo
  if [[ "$cmd6" != "docker exec -it app1 ping -c 3 app2" ]]; then
    print_error "Incorrect."
    print_info "Use: docker exec -it app1 ping -c 3 app2"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  PING app2 (172.19.0.3): 56 data bytes"
  echo "  64 bytes from 172.19.0.3: seq=0 ttl=64 time=0.12 ms"
  echo "  64 bytes from 172.19.0.3: seq=1 ttl=64 time=0.10 ms"
  echo "  64 bytes from 172.19.0.3: seq=2 ttl=64 time=0.11 ms"
  echo "  --- app2 ping statistics ---"
  echo "  3 packets transmitted, 3 packets received, 0% packet loss"
  echo

  # STEP 7: Inspect network details (evidence for ticket)
  echo "  Step 7: Inspect appnet to show attached containers."
  read -r -p "$PROMPT_ROOT" cmd7
  echo
  if [[ "$cmd7" != "docker network inspect appnet" ]]; then
    print_error "Incorrect."
    print_info "Use: docker network inspect appnet"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  ["
  echo "    {"
  echo "      \"Name\": \"appnet\","
  echo "      \"Driver\": \"bridge\","
  echo "      \"Containers\": {"
  echo "        \"111122223333...\": { \"Name\": \"app1\" },"
  echo "        \"0000ffffeeee...\": { \"Name\": \"app2\" }"
  echo "      }"
  echo "    }"
  echo "  ]"
  echo

  # STEP 8: Cleanup (containers + network)
  echo "  Step 8: Remove both containers in one command."
  read -r -p "$PROMPT_ROOT" cmd8
  echo
  if [[ "$cmd8" != "docker rm -f app1 app2" ]]; then
    print_error "Incorrect."
    print_info "Use: docker rm -f app1 app2"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  app1"
  echo "  app2"
  echo
  echo "  Step 9: Remove the appnet network."
  read -r -p "$PROMPT_ROOT" cmd9
  echo
  if [[ "$cmd9" != "docker network rm appnet" ]]; then
    print_error "Incorrect."
    print_info "Use: docker network rm appnet"
    read -r -p "Press Enter to try again..." _
    continue
  fi
  echo "  appnet"
  echo

  print_success "Nice work."
  print_info "You listed networks, created a user-defined bridge, attached containers, verified DNS-based name resolution,"
  print_info "captured evidence with network inspect, and cleaned up containers + network."
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
