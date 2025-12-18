#!/bin/bash

# Lab 67: FTP - File Transfer Protocol

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "❌ Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "❌ Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 67: FTP - File Transfer Protocol"
LAB_ID="lab67"
LAB_XP=19430
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
    center_text "You need to upload and download files from an FTP server for system backups."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Connect to the FTP server."
    read -p "  lab@lpic-lab67:~\$ " cmd1
    echo
    [[ "$cmd1" != "ftp ftp.lpic-server.org" ]] && {
        print_error "Incorrect. Use: ftp ftp.lpic-server.org"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Connected to ftp.lpic-server.org."
    echo "  220 (vsFTPd 3.0.3)"
    echo "  Name (ftp.lpic-server.org:lab):"

    echo
    echo "  Step 2: Log in using anonymous user."
    read -p "  Name: " user
    [[ "$user" != "anonymous" ]] && {
        print_error "Incorrect username. Use: anonymous"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  331 Please specify the password."

    read -p "  Password: " pass
    echo "  230 Login successful."
    echo "  Remote system type is UNIX."
    echo "  Using binary mode to transfer files."

    echo
    echo "  Step 3: List files on the server."
    read -p "  ftp> " cmd2
    [[ "$cmd2" != "ls" ]] && {
        print_error "Incorrect. Use: ls"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  -rw-r--r--   1 ftp  ftp        1048576 Jan 01 12:00 backup.tar.gz"
    echo "  -rw-r--r--   1 ftp  ftp          20480 Jan 01 12:01 readme.txt"

    echo
    echo "  Step 4: Download the file 'readme.txt'."
    read -p "  ftp> " cmd3
    [[ "$cmd3" != "get readme.txt" ]] && {
        print_error "Incorrect. Use: get readme.txt"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  local: readme.txt remote: readme.txt"
    echo "  200 PORT command successful. Consider using PASV."
    echo "  150 Opening BINARY mode data connection."
    echo "  226 Transfer complete."

    echo
    echo "  Step 5: Upload a local file named 'report.log'."
    read -p "  ftp> " cmd4
    [[ "$cmd4" != "put report.log" ]] && {
        print_error "Incorrect. Use: put report.log"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  local: report.log remote: report.log"
    echo "  200 PORT command successful."
    echo "  150 Opening BINARY mode data connection."
    echo "  226 Transfer complete."

    echo
    echo "  Step 6: Close the FTP connection."
    read -p "  ftp> " cmd5
    [[ "$cmd5" != "bye" && "$cmd5" != "quit" ]] && {
        print_error "Incorrect. Use: bye or quit"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  221 Goodbye."
    echo

    print_success "Excellent! You completed all FTP operations successfully."
    print_info "You earned $LAB_XP XP for completing this lab!"
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON")
    LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
    export XP
    export LEVEL
    record_lab_completion

    completion_count=$(get_lab_completion_count)
    echo
    print_info "You've completed this lab $completion_count time(s)."
    echo
    center_text "Would you like to:"
    center_text "1) Retry this lab"
    center_text "2) Return to Sysadmin Lab Menu"
    echo
    read -p "  > " post_choice

    [[ "$post_choice" == "2" ]] && exit 0
done
