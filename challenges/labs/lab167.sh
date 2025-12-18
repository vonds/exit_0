#!/bin/bash

# Lab Security 5: TCP Wrappers, GPG, Shadow & Misc SSH

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab Security 5: TCP Wrappers, GPG, Shadow & Misc SSH"
LAB_ID="lab_sec_5"
LAB_XP=28600
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

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
    center_text "Practice TCP wrappers, GPG operations, /etc/shadow fields, and misc SSH."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Deny all xinetd-wrapped services to 192.168.1.0/24 in hosts.deny."
    read -p "  lab@security-5:~$ " cmd1
    echo
    [[ "$cmd1" != "echo 'ALL: 192.168.1.0/255.255.255.0' >> /etc/hosts.deny" ]] && {
        print_error "Append: ALL: 192.168.1.0/255.255.255.0"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  hosts.deny updated."
    echo

    echo "  Step 2: Specify wildcard that matches name/IP mismatch (echo keyword)."
    read -p "  lab@security-5:~$ " cmd2
    echo
    [[ "$cmd2" != "echo PARANOID" ]] && {
        print_error "Echo: PARANOID"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  PARANOID"
    echo

    echo "  Step 3: Note what libwrap provides (echo two words)."
    read -p "  lab@security-5:~$ " cmd3
    echo
    [[ "$cmd3" != "echo TCP Wrappers" ]] && {
        print_error "Echo: TCP Wrappers"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  TCP Wrappers"
    echo

    echo "  Step 4: Identify /etc/shadow field $1$ hash algorithm (echo the algo)."
    read -p "  lab@security-5:~$ " cmd4
    echo
    [[ "$cmd4" != "echo MD5" ]] && {
        print_error "Echo: MD5"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  MD5"
    echo

    echo "  Step 5: In /etc/shadow 'mail:*:15853:...' what does 15853 mean? (echo phrase)."
    read -p "  lab@security-5:~$ " cmd5
    echo
    [[ "$cmd5" != "echo 'days since 1970-01-01 of last password change'" ]] && {
        print_error "Echo exactly: days since 1970-01-01 of last password change"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Noted."
    echo

    echo "  Step 6: Quickly recover from corrupted shadow by restoring backup file."
    read -p "  lab@security-5:~$ " cmd6
    echo
    [[ "$cmd6" != "cp /etc/shadow- /etc/shadow" ]] && {
        print_error "Use: cp /etc/shadow- /etc/shadow"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Restored /etc/shadow from backup."
    echo

    echo "  Step 7: Create a GnuPG key pair (short form)."
    read -p "  lab@security-5:~$ " cmd7
    echo
    [[ "$cmd7" != "gpg --gen-key" ]] && {
        print_error "Use: gpg --gen-key"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  GPG key generation started."
    echo

    echo "  Step 8: Create a detached signature for file.tar.gz."
    read -p "  lab@security-5:~$ " cmd8
    echo
    [[ "$cmd8" != "gpg --detach-sig file.tar.gz" ]] && {
        print_error "Use: gpg --detach-sig <file>"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  file.tar.gz.sig created."
    echo

    echo "  Step 9: Create a normal (attached) signature for README."
    read -p "  lab@security-5:~$ " cmd9
    echo
    [[ "$cmd9" != "gpg --sign README" ]] && {
        print_error "Use: gpg --sign <file>"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  README.gpg created."
    echo

    echo "  Step 10: Specify output file for GPG operations (echo the long option)."
    read -p "  lab@security-5:~$ " cmd10
    echo
    [[ "$cmd10" != "echo --output" ]] && {
        print_error "Echo: --output"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  --output"
    echo

    echo "  Step 11: Name the GPG key manager agent (echo the daemon name)."
    read -p "  lab@security-5:~$ " cmd11
    echo
    [[ "$cmd11" != "echo gpg-agent" ]] && {
        print_error "Echo: gpg-agent"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  gpg-agent"
    echo

    echo "  Step 12: State classic public keyring file (echo filename)."
    read -p "  lab@security-5:~$ " cmd12
    echo
    [[ "$cmd12" != "echo pubring.gpg" ]] && {
        print_error "Echo: pubring.gpg"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  pubring.gpg"
    echo

    echo "  Step 13: State migration marker file for GPG 2.1+ (echo filename)."
    read -p "  lab@security-5:~$ " cmd13
    echo
    [[ "$cmd13" != "echo gpg-v21-migrated" ]] && {
        print_error "Echo: gpg-v21-migrated"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  gpg-v21-migrated"
    echo

    echo "  Step 14: Send a key to a keyserver (example KEYID ABCDEF01)."
    read -p "  lab@security-5:~$ " cmd14
    echo
    [[ "$cmd14" != "gpg --send-keys ABCDEF01" ]] && {
        print_error "Use: gpg --send-keys <KEYID>"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Sent key ABCDEF01."
    echo

    echo "  Step 15: Explain server host keys (echo a short, accurate phrase)."
    read -p "  lab@security-5:~$ " cmd15
    echo
    [[ "$cmd15" != "echo 'let clients verify server identity'" ]] && {
        print_error "Echo exactly: let clients verify server identity"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (Accepted.)"
    echo

    echo "  Step 16: Use sudo to safely edit files without giving the editor full root powers."
    read -p "  lab@security-5:~$ " cmd16
    echo
    [[ "$cmd16" != "sudoedit /etc/ssh/sshd_config" && "$cmd16" != "sudo -e /etc/ssh/sshd_config" ]] && {
        print_error "Use: sudoedit <file> (or sudo -e <file>)"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Opened securely."
    echo

    echo "  Step 17: State the SSH option to set a per-connection command port (echo flag)."
    read -p "  lab@security-5:~$ " cmd17
    echo
    [[ "$cmd17" != "echo -p" ]] && {
        print_error "Echo: -p"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  -p"
    echo

    echo "  Step 18: Use ssh -i to authenticate with a given key to example.org."
    read -p "  lab@security-5:~$ " cmd18
    echo
    [[ "$cmd18" != "ssh -i ~/.ssh/id_rsa user@example.org" ]] && {
        print_error "Use: ssh -i ~/.ssh/<key> user@host"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Authenticating..."
    echo

    echo "  Step 19: Use ssh to run a command by placing it after the host."
    read -p "  lab@security-5:~$ " cmd19
    echo
    [[ "$cmd19" != "ssh user@host 'uname -a'" ]] && {
        print_error "Example: ssh user@host 'uname -a'"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  (remote uname output)"
    echo

    echo "  Step 20: Change username on an existing account from 'old' to 'new'."
    read -p "  lab@security-5:~$ " cmd20
    echo
    [[ "$cmd20" != "usermod -l new old" ]] && {
        print_error "Use: usermod -l NEW OLD"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Username changed."
    echo

    print_success "Nice work!"
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
