#!/bin/bash

# Lab Security 2: SSH Keys, Client Config, Forwarding

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab Security 2: SSH Keys, Client Config, Forwarding"
LAB_ID="lab_sec_2"
LAB_XP=8600
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
    center_text "Generate keys, configure clients, and practice forwarding."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Generate an RSA SSH key pair."
    read -p "  lab@security-2:~$ " cmd1
    echo
    [[ "$cmd1" != "ssh-keygen -t rsa" && "$cmd1" != "ssh-keygen" ]] && {
        print_error "Use: ssh-keygen -t rsa (or ssh-keygen if defaulting to RSA)"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 2: State the default RSA private key path."
    read -p "  lab@security-2:~$ " cmd2
    echo
    [[ "$cmd2" != "~/.ssh/id_rsa" ]] && {
        print_error "Answer via ~/.ssh/id_rsa"
        read -p "Press Enter to try again..." _
        continue
    }


    echo "  Step 3: Allow key-based login by appending a public key for current user."
    read -p "  lab@security-2:~$ " cmd3
    echo
    [[ "$cmd3" != "cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys" ]] && {
        print_error "Use: cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  authorized_keys updated."
    echo

    echo "  Step 4: Execute a single command 'uptime' on host 'web1' as 'deploy'."
    read -p "  lab@security-2:~$ " cmd4
    echo
    [[ "$cmd4" != "ssh deploy@web1 'uptime'" ]] && {
        print_error "Use: ssh user@host 'command'"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "   14:21:33 up 5 days,  3 users,  load average: 0.10, 0.06, 0.01"
    echo

    echo "  Step 5: Connect to example.com over SSH port 2222."
    read -p "  lab@security-2:~$ " cmd5
    echo
    [[ "$cmd5" != "ssh -p 2222 user@example.com" ]] && {
        print_error "Use: ssh -p 2222 user@example.com"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 6: Use a specific identity file to connect to git.example as alice."
    read -p "  lab@security-2:~$ " cmd6
    echo
    [[ "$cmd6" != "ssh -i ~/.ssh/id_ed25519 alice@git.example" ]] && {
        print_error "Use: ssh -i ~/.ssh/<key> user@host"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 7: Change login name using -l to connect as 'postgres' to db01."
    read -p "  lab@security-2:~$ " cmd7
    echo
    [[ "$cmd7" != "ssh -l postgres db01" ]] && {
        print_error "Use: ssh -l USER HOST"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 8: Create local forward 5150 -> www.example.com:80 through 'bastion'."
    read -p "  lab@security-2:~$ " cmd8
    echo
    [[ "$cmd8" != "ssh -L 5150:www.example.com:80 user@bastion" ]] && {
        print_error "Use: ssh -L local:dest:port user@jump"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Listening on 127.0.0.1:5150 ..."
    echo

    echo "  Step 9: Configure a remote forward exposing local 8080 on remote 9000."
    read -p "  lab@security-2:~$ " cmd9
    echo
    [[ "$cmd9" != "ssh -R 9000:localhost:8080 user@remote" ]] && {
        print_error "Use: ssh -R REMOTE:HOST:PORT user@remote"
        read -p "Press Enter to try again..." _
        continue
    }


    echo "  Step 10: Enable X11 forwarding when connecting to apps.example."
    read -p "  lab@security-2:~$ " cmd10
    echo
    [[ "$cmd10" != "ssh -X user@apps.example" ]] && {
        print_error "Use: ssh -X user@host"
        read -p "Press Enter to try again..." _
        continue
    }


    echo "  Step 11: List keys currently loaded into ssh-agent."
    read -p "  lab@security-2:~$ " cmd11
    echo
    [[ "$cmd11" != "ssh-add -l" ]] && {
        print_error "Use: ssh-add -l"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  4096 SHA256:... id_rsa (RSA)"
    echo

    echo "  Step 12: Add a key to ssh-agent."
    read -p "  lab@security-2:~$ " cmd12
    echo
    [[ "$cmd12" != "ssh-add ~/.ssh/id_rsa" ]] && {
        print_error "Use: ssh-add ~/.ssh/<key>"
        read -p "Press Enter to try again..." _
        continue
    }


    echo "  Step 13: Add a key to ssh-agent with a 1-hour lifetime."
    read -p "  lab@security-2:~$ " cmd13
    echo
    [[ "$cmd13" != "ssh-add -t 3600 ~/.ssh/id_rsa" ]] && {
        print_error "Use: ssh-add -t <seconds> <key>"
        read -p "Press Enter to try again..." _
        continue
    }


    echo "  Step 14: In client config, specify an identity file option name."
    read -p "  lab@security-2:~$ " cmd14
    echo
    [[ "$cmd14" != "IdentityFile" ]] && {
        print_error "Answer via IdentityFile"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 15: Specify system-wide known hosts file option name."
    read -p "  lab@security-2:~$ " cmd15
    echo
    [[ "$cmd15" != "GlobalKnownHostsFile" ]] && {
        print_error "Answer via echo GlobalKnownHostsFile"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 16: Specify per-user known hosts option name."
    read -p "  lab@security-2:~$ " cmd16
    echo
    [[ "$cmd16" != "UserKnownHostsFile" ]] && {
        print_error "Answer via UserKnownHostsFile"
        read -p "Press Enter to try again..." _
        continue
    }
    echo

    echo "  Step 17: Provide the path to the system-wide known hosts file."
    read -p "  lab@security-2:~$ " cmd17
    echo
    [[ "$cmd17" != "/etc/ssh/ssh_known_hosts" && "$cmd17" != "echo /etc/ssh/known_hosts" ]] && {
        print_error "/etc/ssh/ssh_known_hosts (or /etc/ssh/known_hosts if used)"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 18: Set number of missed keepalives before exit."
    read -p "  lab@security-2:~$ " cmd18
    echo
    [[ "$cmd18" != "ServerAliveCountMax" ]] && {
        print_error "Answer via echo ServerAliveCountMax"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  ServerAliveCountMax"
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
