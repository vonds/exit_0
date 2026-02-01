#!/bin/bash

# Lab 141: RHCSA System Services — Mail Alias + Postfix Queue + Time/Journal Workflow

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 141: RHCSA System Services — Mail + Time + journald Workflow"
LAB_ID="lab141"
LAB_XP=29500
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@lab141:~$ "

record_lab_completion() {
    tmpfile=$(mktemp)
    jq --arg lab "$LAB_ID" '.[$lab] += 1 // 1' "$LAB_TRACK_FILE" > "$tmpfile" && mv "$tmpfile" "$LAB_TRACK_FILE"
}
get_lab_completion_count() {
    jq -r --arg lab "$LAB_ID" '.[$lab] // 0' "$LAB_TRACK_FILE"
}
draw_lab_ui() {
    clear
    center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
    center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
    echo
    echo
}

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Scenario:"
    center_text "Ops wants all root mail forwarded to two addresses. A queued message needs inspection."
    center_text "You will update /etc/aliases, rebuild the aliases database, verify Postfix,"
    center_text "inspect the mail queue, view a message with postcat, then confirm time/journal signals."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui

    # STEP 1: Edit /etc/aliases (terminal command, not trivia)
    echo "  Step 1: Open /etc/aliases to add a root forwarding alias."
    read -p "$PROMPT" cmd1
    echo
    if [[ "$cmd1" != "sudo nano /etc/aliases" && \
          "$cmd1" != "nano /etc/aliases" && \
          "$cmd1" != "sudo vi /etc/aliases" && \
          "$cmd1" != "vi /etc/aliases" && \
          "$cmd1" != "sudo vim /etc/aliases" && \
          "$cmd1" != "vim /etc/aliases" ]]; then
        print_error "Incorrect. Use an editor to modify /etc/aliases."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  (Edit file: /etc/aliases)"
    echo "  (Add this line inside the file:)"
    echo "  root: admin@example.com, webmaster@example.com"
    echo

    # STEP 2: Rebuild aliases DB
    echo "  Step 2: Rebuild the aliases database so Postfix picks up the change."
    read -p "$PROMPT" cmd2
    echo
    if [[ "$cmd2" != "sudo newaliases" && "$cmd2" != "newaliases" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  /etc/aliases: 86 aliases, longest 52 bytes, 948 bytes total"
    echo

    # STEP 3: Verify Postfix is running
    echo "  Step 3: Confirm Postfix is active."
    read -p "$PROMPT" cmd3
    echo
    if [[ "$cmd3" != "systemctl is-active postfix" && "$cmd3" != "sudo systemctl is-active postfix" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  active"
    echo

    # STEP 4: Inspect the mail queue
    echo "  Step 4: Show the Postfix mail queue."
    read -p "$PROMPT" cmd4
    echo
    if [[ "$cmd4" != "mailq" && "$cmd4" != "postqueue -p" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  -Queue ID-  --Size-- ----Arrival Time---- -Sender/Recipient-------"
    echo "  A1B2C3D4E5*     1468 Sun Jan 25 07:10:41  root@lab141"
    echo "                                           admin@example.com"
    echo "  -- 2 Kbytes in 1 Request."
    echo

    # STEP 5: View a queued message with postcat (real terminal command)
    echo "  Step 5: View the contents of the queued message A1B2C3D4E5."
    read -p "$PROMPT" cmd5
    echo
    if [[ "$cmd5" != "sudo postcat -q A1B2C3D4E5" && "$cmd5" != "postcat -q A1B2C3D4E5" ]]; then
        print_error "Incorrect. Use postcat to view a queued message by ID."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  *** ENVELOPE RECORDS active ***"
    echo "  message_size:           1468"
    echo "  message_arrival_time:   Sun Jan 25 07:10:41 2026"
    echo "  sender:                 root@lab141"
    echo "  recipient:              admin@example.com"
    echo "  *** MESSAGE CONTENTS active ***"
    echo "  Received: by lab141 (Postfix, from userid 0)"
    echo "          id A1B2C3D4E5; Sun, 25 Jan 2026 07:10:41 -0500 (EST)"
    echo "  From: root@lab141"
    echo "  To: admin@example.com"
    echo "  Subject: RHCSA-LAB141 queued test"
    echo "  Date: Sun, 25 Jan 2026 07:10:41 -0500"
    echo
    echo "  This is a queued test message."
    echo

    # STEP 6: List time zones (real command)
    echo "  Step 6: List available time zones."
    read -p "$PROMPT" cmd6
    echo
    if [[ "$cmd6" != "timedatectl list-timezones | head -n 5" ]]; then
        print_error "Incorrect. Use timedatectl and limit output with head."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  Africa/Abidjan"
    echo "  Africa/Accra"
    echo "  Africa/Addis_Ababa"
    echo "  Africa/Algiers"
    echo "  Africa/Asmara"
    echo

    # STEP 7: Show current time zone and local time (single command)
    echo "  Step 7: Show current local time and time zone."
    read -p "$PROMPT" cmd7
    echo
    if [[ "$cmd7" != "timedatectl" && "$cmd7" != "timedatectl status" ]]; then
        print_error "Incorrect. Use timedatectl."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  Local time: Sun 2026-01-25 07:16:09 EST"
    echo "  Universal time: Sun 2026-01-25 12:16:09 UTC"
    echo "  RTC time: Sun 2026-01-25 12:16:09"
    echo "  Time zone: America/New_York (EST, -0500)"
    echo "  System clock synchronized: yes"
    echo "  NTP service: active"
    echo "  RTC in local TZ: no"
    echo

    # STEP 8: Provide chrony config path using a terminal command (not trivia)
    echo "  Step 8: Display the path of the active chrony configuration file."
    read -p "$PROMPT" cmd8
    echo
    if [[ "$cmd8" != "ls -l /etc/chrony.conf" ]]; then
        print_error "Incorrect. Use ls -l to show the file path and metadata."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  -rw-r--r--. 1 root root 1247 Jan 25 06:58 /etc/chrony.conf"
    echo

    # STEP 9: Display only kernel messages from the journal
    echo "  Step 9: Display only kernel messages from the systemd journal (last 5)."
    read -p "$PROMPT" cmd9
    echo
    if [[ "$cmd9" != "journalctl -k -n 5" && "$cmd9" != "sudo journalctl -k -n 5" ]]; then
        print_error "Incorrect. Use journalctl -k with -n."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  Jan 25 06:58:21 lab141 kernel: Linux version 6.6.7 (builder@ci) ..."
    echo "  Jan 25 06:58:24 lab141 kernel: x86/fpu: Supporting XSAVE feature 0x001: 'x87 floating point registers'"
    echo "  Jan 25 06:58:31 lab141 kernel: e1000e 0000:00:03.0 eth0: Link is Up 1000 Mbps Full Duplex"
    echo "  Jan 25 07:02:14 lab141 kernel: IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready"
    echo "  Jan 25 07:12:03 lab141 kernel: audit: type=1100 audit(1737807123.911:219): pid=1 uid=0 auid=4294967295 msg='unit=postfix comm=\"systemd\"'"
    echo

    # STEP 10: Verify root alias line exists (quick verification)
    echo "  Step 10: Verify the root alias line exists in /etc/aliases."
    read -p "$PROMPT" cmd10
    echo
    if [[ "$cmd10" != "grep '^root:' /etc/aliases" && "$cmd10" != "sudo grep '^root:' /etc/aliases" ]]; then
        print_error "Incorrect. Use grep to verify the alias line."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  root: admin@example.com, webmaster@example.com"
    echo

    print_success "Great job!"
    print_info "Workflow completed:"
    print_info "- Updated /etc/aliases, rebuilt alias DB with newaliases, verified Postfix"
    print_info "- Inspected queue and viewed a queued message with postcat"
    print_info "- Verified time zone state and reviewed kernel logs with journalctl -k"
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
