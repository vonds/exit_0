#!/bin/bash

# Lab 133: Networking Fundamentals — Investigate Port 443 Failure (Path + Firewall + Service) (4–8 prompts)
# Scenario: A web checkout endpoint is failing from this host only. DNS resolves, but TLS (443) won't connect.
# You must confirm resolution, test TCP reachability, identify whether the block is local firewall or service down,
# and fix the local firewall to allow outbound/inbound as needed for the test.
# Key skills: dig/getent, ping, nc, ss, firewall-cmd, curl, verification workflow.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 133: Networking Fundamentals — Fix 443 Connectivity"
LAB_ID="lab133"
LAB_XP=29500
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@rhel-lab133:~$ "

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
  center_text "From THIS server only, https://checkout.lab.example fails."
  center_text "Other servers can reach it. Your job is to isolate why and fix it."
  echo
  center_text "Goal: prove DNS works, show 443 is blocked locally, fix the firewall,"
  center_text "and verify HTTPS connectivity."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Confirm DNS resolution
  echo "  Step 1: Confirm checkout.lab.example resolves to an IP."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "getent hosts checkout.lab.example" && \
        "$cmd1" != "dig +short checkout.lab.example" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd1" == "dig +short checkout.lab.example" ]]; then
    echo "  203.0.113.20"
  else
    echo "  203.0.113.20   checkout.lab.example"
  fi
  echo

  # STEP 2: Test basic reachability (ICMP)
  echo "  Step 2: Test basic network reachability to the resolved IP."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "ping -c 2 203.0.113.20" && \
        "$cmd2" != "ping -c 2 checkout.lab.example" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  PING 203.0.113.20 (203.0.113.20) 56(84) bytes of data."
  echo "  64 bytes from 203.0.113.20: icmp_seq=1 ttl=52 time=18.4 ms"
  echo "  64 bytes from 203.0.113.20: icmp_seq=2 ttl=52 time=18.1 ms"
  echo
  echo "  --- ping statistics ---"
  echo "  2 packets transmitted, 2 received, 0% packet loss"
  echo

  # STEP 3: Test TCP 443 (fails)
  echo "  Step 3: Test TCP connectivity to port 443."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "nc -vz checkout.lab.example 443" && \
        "$cmd3" != "nc -vz 203.0.113.20 443" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  nc: connect to checkout.lab.example (203.0.113.20) port 443 (tcp) failed: Connection timed out"
  echo

  # STEP 4: Check local firewall policy (shows restrictive / missing https)
  echo "  Step 4: Check the active firewalld zone and its allowed services."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "sudo firewall-cmd --get-active-zones" && \
        "$cmd4" != "firewall-cmd --get-active-zones" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  public"
  echo "    interfaces: eth0"
  echo

  echo "  Step 5: List services allowed in the active zone (public)."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo firewall-cmd --zone=public --list-services" && \
        "$cmd5" != "firewall-cmd --zone=public --list-services" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  ssh dhcpv6-client"
  echo

  # STEP 6: Allow HTTPS service permanently + reload
  echo "  Step 6: Allow https in the public zone permanently, then reload firewalld."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo firewall-cmd --zone=public --add-service=https --permanent" && \
        "$cmd6" != "firewall-cmd --zone=public --add-service=https --permanent" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  success"
  echo

  echo "  Step 7: Reload firewalld to apply permanent changes."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "sudo firewall-cmd --reload" && \
        "$cmd7" != "firewall-cmd --reload" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  success"
  echo

  # STEP 8: Verify HTTPS now works
  echo "  Step 8: Verify HTTPS connectivity now succeeds."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "curl -I https://checkout.lab.example" && \
        "$cmd8" != "nc -vz checkout.lab.example 443" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  if [[ "$cmd8" == "nc -vz checkout.lab.example 443" ]]; then
    echo "  Connection to checkout.lab.example 443 port [tcp/https] succeeded!"
  else
    echo "  HTTP/2 200"
    echo "  server: nginx"
    echo "  content-type: text/html"
  fi
  echo

  print_success "Nice work."
  print_info "You solved a realistic 'HTTPS fails from one host' incident by:"
  print_info "- confirming DNS and basic reachability"
  print_info "- proving TCP/443 was the failing layer"
  print_info "- identifying a restrictive firewalld service set"
  print_info "- allowing https and reloading the firewall"
  print_info "- validating connectivity with curl/nc"
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
