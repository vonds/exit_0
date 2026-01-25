#!/bin/bash

# Lab 140: RHCSA System Services — Printer Access + Postfix Queue + Journald Cleanup Workflow
# Workflow: grant printer admin rights, verify CUPS, enable sharing, restart service,
# review journal usage, vacuum old journals, then triage Postfix queue and remove a stuck message.
# RHCSA Focus: usermod/groups, systemctl, cupsctl/lpstat, journalctl, postqueue/mailq/postsupper.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 140: RHCSA System Services — CUPS Access + Mail Queue + Journald Workflow"
LAB_ID="lab140"
LAB_XP=29500
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@lab140:~$ "

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
    center_text "A new helpdesk tech needs printer admin rights. Printing should be shared on the LAN."
    center_text "Meanwhile, the mail queue has a stuck item and the journal is growing."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui

    # STEP 1: Add user to lpadmin (with sudo)
    echo "  Step 1: Grant printer administration rights to the account named 'Hamzah'."
    read -p "$PROMPT" cmd1
    echo
    if [[ "$cmd1" != "sudo usermod -aG lpadmin Hamzah" && "$cmd1" != "usermod -aG lpadmin Hamzah" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 2: Verify user group membership
    echo "  Step 2: Verify that 'Hamzah' is now in the lpadmin group."
    read -p "$PROMPT" cmd2
    echo
    if [[ "$cmd2" != "id Hamzah" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  uid=1002(Hamzah) gid=1002(Hamzah) groups=1002(Hamzah),4(lpadmin)"
    echo

    # STEP 3: Confirm CUPS is running
    echo "  Step 3: Verify the CUPS service is running."
    read -p "$PROMPT" cmd3
    echo
    if [[ "$cmd3" != "systemctl is-active cups" && "$cmd3" != "sudo systemctl is-active cups" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  active"
    echo

    # STEP 4: Enable printer sharing for all locally configured printers
    echo "  Step 4: Enable printer sharing for all locally configured printers via CUPS."
    read -p "$PROMPT" cmd4
    echo
    if [[ "$cmd4" != "sudo cupsctl --share-printers" && "$cmd4" != "cupsctl --share-printers" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 5: Restart CUPS to ensure settings are applied
    echo "  Step 5: Restart the CUPS service."
    read -p "$PROMPT" cmd5
    echo
    if [[ "$cmd5" != "sudo systemctl restart cups" && "$cmd5" != "systemctl restart cups" && \
          "$cmd5" != "sudo systemctl restart cups.service" && "$cmd5" != "systemctl restart cups.service" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi

    # STEP 6: Verify printers are present (real workflow verification)
    echo "  Step 6: List configured printers."
    read -p "$PROMPT" cmd6
    echo
    if [[ "$cmd6" != "lpstat -p" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  printer Office_Printer is idle.  enabled since Sun 25 Jan 2026 06:41:14 AM EST"
    echo

    # STEP 7: Check journal disk usage
    echo "  Step 7: Show total disk space consumed by systemd journal files."
    read -p "$PROMPT" cmd7
    echo
    if [[ "$cmd7" != "journalctl --disk-usage" && "$cmd7" != "sudo journalctl --disk-usage" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  Archived and active journals take up 96.0M in the file system."
    echo

    # STEP 8: Vacuum journals older than 5 days
    echo "  Step 8: Purge archived journal files older than five days."
    read -p "$PROMPT" cmd8
    echo
    if [[ "$cmd8" != "sudo journalctl --vacuum-time=5d" && "$cmd8" != "journalctl --vacuum-time=5d" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  Vacuuming done, freed 24.0M of archived journals on disk."
    echo

    # STEP 9: Check mail queue
    echo "  Step 9: Inspect the Postfix mail queue."
    read -p "$PROMPT" cmd9
    echo
    if [[ "$cmd9" != "mailq" && "$cmd9" != "postqueue -p" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  -Queue ID-  --Size-- ----Arrival Time---- -Sender/Recipient-------"
    echo "  7C9A0F12B3*     1740 Sun Jan 25 06:59:37  alerts@example.com"
    echo "                                           ops@example.com"
    echo "                                           (connect to mx.example.com[203.0.113.25]:25: Connection timed out)"
    echo "  -- 2 Kbytes in 1 Request."
    echo

    # STEP 10: Remove the stuck message (specific queue id, realistic)
    echo "  Step 10: Delete the stuck message with queue ID 7C9A0F12B3."
    read -p "$PROMPT" cmd10
    echo
    if [[ "$cmd10" != "sudo postsuper -d 7C9A0F12B3" && "$cmd10" != "postsuper -d 7C9A0F12B3" ]]; then
        print_error "Incorrect. Try again."
        read -p "Press Enter to retry..." _
        continue
    fi
    echo "  postsuper: Deleted: 1 message"
    echo

    print_success "Nice work!"
    print_info "Workflow completed:"
    print_info "- Granted printer admin rights and verified group membership"
    print_info "- Enabled CUPS printer sharing, restarted service, verified printers"
    print_info "- Checked journald disk usage and vacuumed old archives"
    print_info "- Inspected Postfix queue and removed a stuck message with postsuper"
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
