#!/bin/bash

# Lab 475: Rocky Linux 10 — SELinux & sysctl Tasks (RHCSA-Style)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 475: SELinux & sysctl Tasks (Rocky 10, RHCSA-Style)"
LAB_ID="lab475"
LAB_XP=46500
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"

[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@rhel-lab475:~$ "

draw_lab_ui() {
  clear
  center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
  center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
  echo
  echo
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
  center_text "A web app was deployed to /srv/web, and access is failing under SELinux."
  center_text "You must verify contexts, set a persistent file context rule, apply it,"
  center_text "check and set a required SELinux boolean persistently, and apply a persistent"
  center_text "sysctl change using /etc/sysctl.d with sysctl --system."
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  # STEP 1: SELinux mode
  echo "  Step 1: Confirm SELinux is enabled and report the current SELinux mode."
  read -p "$PROMPT" cmd1
  echo
  if [[ "$cmd1" == "getenforce" ]]; then
    echo "  Enforcing"
    echo
  elif [[ "$cmd1" == "sestatus" ]]; then
    echo "  SELinux status:                 enabled"
    echo "  SELinuxfs mount:                /sys/fs/selinux"
    echo "  SELinux root directory:         /etc/selinux"
    echo "  Loaded policy name:             targeted"
    echo "  Current mode:                   enforcing"
    echo "  Mode from config file:          enforcing"
    echo "  Policy MLS status:              enabled"
    echo "  Policy deny_unknown status:     allowed"
    echo "  Memory protection checking:     actual (secure)"
    echo "  Max kernel policy version:      33"
    echo
  else
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # STEP 2: httpd process context
  echo "  Step 2: Show the SELinux context for the running web server process (httpd)."
  read -p "$PROMPT" cmd2
  echo
  if [[ "$cmd2" != "ps -eZ | grep httpd" && "$cmd2" != "ps auxZ | grep httpd" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  system_u:system_r:httpd_t:s0     1042 ?        00:00:00 httpd"
  echo "  system_u:system_r:httpd_t:s0     1043 ?        00:00:00 httpd"
  echo "  system_u:system_r:httpd_t:s0     1044 ?        00:00:00 httpd"
  echo

  # STEP 3: directory context
  echo "  Step 3: Show the SELinux context for the web content directory /srv/web."
  read -p "$PROMPT" cmd3
  echo
  if [[ "$cmd3" != "ls -Zd /srv/web" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  unconfined_u:object_r:default_t:s0 /srv/web"
  echo

  # STEP 4: file context
  echo "  Step 4: Show the SELinux context for the file /srv/web/index.html."
  read -p "$PROMPT" cmd4
  echo
  if [[ "$cmd4" != "ls -Z /srv/web/index.html" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  unconfined_u:object_r:default_t:s0 /srv/web/index.html"
  echo

  # STEP 5: semanage fcontext
  echo "  Step 5: Add a persistent SELinux file context rule so ALL files under /srv/web use the httpd_sys_content_t type."
  read -p "$PROMPT" cmd5
  echo
  if [[ "$cmd5" != "sudo semanage fcontext -a -t httpd_sys_content_t '/srv/web(/.*)?'" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # STEP 6: restorecon apply
  echo "  Step 6: Apply the persistent SELinux file context mapping to /srv/web and its contents."
  read -p "$PROMPT" cmd6
  echo
  if [[ "$cmd6" == "sudo restorecon -Rv /srv/web" ]]; then
    echo "  Relabeled /srv/web from unconfined_u:object_r:default_t:s0 to unconfined_u:object_r:httpd_sys_content_t:s0"
    echo "  Relabeled /srv/web/index.html from unconfined_u:object_r:default_t:s0 to unconfined_u:object_r:httpd_sys_content_t:s0"
    echo
  elif [[ "$cmd6" == "sudo restorecon -RFv /srv/web" ]]; then
    echo "  Relabeled /srv/web from unconfined_u:object_r:default_t:s0 to unconfined_u:object_r:httpd_sys_content_t:s0"
    echo "  Relabeled /srv/web/index.html from unconfined_u:object_r:default_t:s0 to unconfined_u:object_r:httpd_sys_content_t:s0"
    echo
  else
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # STEP 7: verify file context
  echo "  Step 7: Verify the new SELinux type is now applied to /srv/web/index.html."
  read -p "$PROMPT" cmd7
  echo
  if [[ "$cmd7" != "ls -Z /srv/web/index.html" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  unconfined_u:object_r:httpd_sys_content_t:s0 /srv/web/index.html"
  echo

  # STEP 8: check boolean
  echo "  Step 8: Check whether the SELinux boolean that allows httpd to initiate outbound network connections is enabled."
  read -p "$PROMPT" cmd8
  echo
  if [[ "$cmd8" != "getsebool httpd_can_network_connect" && "$cmd8" != "sudo getsebool httpd_can_network_connect" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  httpd_can_network_connect --> off"
  echo

  # STEP 9: enable boolean persistently
  echo "  Step 9: Enable that SELinux boolean persistently (so it survives reboot)."
  read -p "$PROMPT" cmd9
  echo
  if [[ "$cmd9" != "sudo setsebool -P httpd_can_network_connect on" && "$cmd9" != "sudo setsebool -P httpd_can_network_connect 1" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  # STEP 10: verify boolean
  echo "  Step 10: Verify the boolean is now on."
  read -p "$PROMPT" cmd10
  echo
  if [[ "$cmd10" != "getsebool httpd_can_network_connect" && "$cmd10" != "sudo getsebool httpd_can_network_connect" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  httpd_can_network_connect --> on"
  echo

  # STEP 11: sysctl runtime
  echo "  Step 11: Set IPv4 forwarding at runtime using sysctl."
  read -p "$PROMPT" cmd11
  echo
  if [[ "$cmd11" != "sudo sysctl -w net.ipv4.ip_forward=1" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  net.ipv4.ip_forward = 1"
  echo

  # STEP 12: create sysctl.d file via tee
  echo "  Step 12: Create a persistent sysctl setting file at /etc/sysctl.d/99-lab465.conf using a single command that writes net.ipv4.ip_forward=1."
  read -p "$PROMPT" cmd12
  echo
  if [[ "$cmd12" != "echo 'net.ipv4.ip_forward=1' | sudo tee /etc/sysctl.d/99-lab465.conf" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  net.ipv4.ip_forward=1"
  echo

  # STEP 13: apply sysctl --system
  echo "  Step 13: Apply all persistent sysctl settings using the correct system-wide reload command."
  read -p "$PROMPT" cmd13
  echo
  if [[ "$cmd13" != "sudo sysctl --system" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  * Applying /usr/lib/sysctl.d/00-system.conf ..."
  echo "  * Applying /usr/lib/sysctl.d/10-default-yama-scope.conf ..."
  echo "  * Applying /usr/lib/sysctl.d/50-default.conf ..."
  echo "  * Applying /etc/sysctl.d/99-lab465.conf ..."
  echo "  net.ipv4.ip_forward = 1"
  echo "  * Applying /etc/sysctl.conf ..."
  echo

  # STEP 14: verify sysctl value
  echo "  Step 14: Verify net.ipv4.ip_forward is set to 1."
  read -p "$PROMPT" cmd14
  echo
  if [[ "$cmd14" != "sysctl net.ipv4.ip_forward" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  net.ipv4.ip_forward = 1"
  echo

  # STEP 15: record value to file
  echo "  Step 15: Record the current value of net.ipv4.ip_forward to /home/student/ip_forward.txt using a single command."
  read -p "$PROMPT" cmd15
  echo
  if [[ "$cmd15" != "sysctl net.ipv4.ip_forward > /home/student/ip_forward.txt" && \
        "$cmd15" != "sysctl net.ipv4.ip_forward | tee /home/student/ip_forward.txt > /dev/null" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi

  print_success "Excellent work."
  print_info "You completed RHCSA-style SELinux + sysctl tasks on Rocky Linux 10:"
  print_info "- verified SELinux mode and inspected process/file contexts"
  print_info "- set persistent SELinux file context with semanage fcontext + restorecon"
  print_info "- enabled and verified a required SELinux boolean persistently"
  print_info "- applied runtime and persistent sysctl using /etc/sysctl.d + sysctl --system"
  print_info "You earned $LAB_XP XP."
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
  read -p "  > " choice

  [[ "$choice" == "2" ]] && exit 0
done
