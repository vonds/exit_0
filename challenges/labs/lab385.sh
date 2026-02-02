#!/bin/bash

# Lab 385: SELinux Troubleshooting — Diagnose AVC Denials Using Logs Only (4–8 prompts)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 385: SELinux Troubleshooting — AVC Diagnosis via Logs Only"
LAB_ID="lab385"
LAB_XP=38500
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@rhel-lab385:~$ "

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
  center_text "A backend service api-gateway fails intermittently."
  center_text "You are NOT allowed to change SELinux mode."
  center_text "You must diagnose the root cause using LOGS ONLY."
  center_text "Your task is to identify the AVC denial and propose the correct fix."
  echo
  center_text "Restriction: Do NOT use setenforce."
  center_text "Goal: Identify WHAT is blocked and WHY."
  echo
  center_text "Press Enter to begin the lab..."
  read _
  draw_lab_ui

  # STEP 1: Confirm service failure
  echo "  Step 1: Check the status of the failing service."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" != "systemctl status api-gateway" && \
        "$cmd1" != "sudo systemctl status api-gateway" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  ● api-gateway.service - API Gateway"
  echo "       Loaded: loaded (/etc/systemd/system/api-gateway.service; enabled)"
  echo "       Active: failed (Result: exit-code)"
  echo "      Process: 2314 ExecStart=/usr/local/bin/api-gateway (code=exited, status=13)"
  echo "  Feb 01 22:14:09 rhel-lab385 api-gateway[2314]: ERROR: Cannot open /srv/api/config.yml"
  echo "  Feb 01 22:14:09 rhel-lab385 systemd[1]: api-gateway.service: Failed with result 'exit-code'."
  echo

  # STEP 2: Search for AVC denials in audit logs
  echo "  Step 2: Search audit logs for AVC denials related to the failure."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "sudo ausearch -m avc -ts recent" && \
        "$cmd2" != "ausearch -m avc -ts recent" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  ----"
  echo "  time->Sun Feb  1 22:14:09 2026"
  echo "  type=AVC msg=audit(1738466049.781:912): avc:  denied  { open read }"
  echo "      for  pid=2314 comm=\"api-gateway\""
  echo "      path=\"/srv/api/config.yml\""
  echo "      scontext=system_u:system_r:api_gateway_t:s0"
  echo "      tcontext=unconfined_u:object_r:default_t:s0"
  echo "      tclass=file permissive=0"
  echo "  ----"
  echo

  # STEP 3: Correlate AVC with systemd logs
  echo "  Step 3: Correlate the AVC with service logs in the journal."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "sudo journalctl -u api-gateway --since \"10 minutes ago\"" && \
        "$cmd3" != "journalctl -u api-gateway --since \"10 minutes ago\"" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  Feb 01 22:14:09 rhel-lab385 api-gateway[2314]: Starting API Gateway..."
  echo "  Feb 01 22:14:09 rhel-lab385 api-gateway[2314]: Loading config: /srv/api/config.yml"
  echo "  Feb 01 22:14:09 rhel-lab385 api-gateway[2314]: FATAL: permission denied"
  echo "  Feb 01 22:14:09 rhel-lab385 systemd[1]: api-gateway.service: Main process exited"
  echo

  # STEP 4: Inspect current SELinux context on the target file
  echo "  Step 4: Inspect the SELinux context of the blocked file."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "ls -Z /srv/api/config.yml" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  unconfined_u:object_r:default_t:s0 /srv/api/config.yml"
  echo

  # STEP 5: Determine the correct fix (no changes yet)
  echo "  Step 5: Based on logs only, identify the CORRECT fix."
  echo "  (You are not executing it — only diagnosing.)"
  echo
  center_text "Which action would resolve the denial?"
  center_text "1) Disable SELinux"
  center_text "2) Change file ownership"
  center_text "3) Correct the SELinux file context"
  center_text "4) Allow everything with a custom policy"
  echo
  read -p "  > " choice
  echo
  if [[ "$choice" != "3" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  print_success "Correct."
  print_info "The denial shows a type mismatch:"
  print_info "- service domain: api_gateway_t"
  print_info "- target type: default_t"
  print_info "The fix is to apply the proper SELinux file context"
  print_info "using semanage fcontext + restorecon (or restorecon if predefined)."
  echo

  # STEP 6: State the exact corrective command
  echo "  Step 6: State the correct command that would fix the labeling."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" != "sudo restorecon -Rv /srv/api" && \
        "$cmd6" != "restorecon -Rv /srv/api" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo "  restorecon reset /srv/api/config.yml context default_t -> api_gateway_conf_t"
  echo

  print_success "Well done."
  print_info "You diagnosed an SELinux failure using logs ONLY by:"
  print_info "- identifying the AVC denial"
  print_info "- correlating audit and service logs"
  print_info "- analyzing source and target contexts"
  print_info "- selecting the minimal, correct fix"
  print_info "This is exactly how SELinux issues are handled in production."
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
