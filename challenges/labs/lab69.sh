#!/bin/bash

# Lab 69: Remote Synchronization with rsync

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 69: Remote Synchronization with rsync"
LAB_ID="lab69"
LAB_XP=1600
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

LOCAL_DIR="project_files"
REMOTE_USER="student"
REMOTE_HOST="remote.server.com"
REMOTE_PATH="/home/student/backup/"

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
    center_text "Scenario: You are backing up a local project directory to a remote server."
    center_text "You will use rsync to transfer, synchronize, and compare files."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Use rsync to copy the local directory 'project_files' to the remote server."
    echo "  Remote target: student@remote.server.com:/home/student/backup/"
    read -p "  lab@lpic-lab69:~$ " cmd1
    echo
    if [[ "$cmd1" != "rsync -avz project_files student@remote.server.com:/home/student/backup/" ]]; then
        print_error "Incorrect. Use: rsync -avz project_files student@remote.server.com:/home/student/backup/"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  sending incremental file list"
    echo "  project_files/"
    echo "  project_files/index.html"
    echo "  project_files/config.yaml"
    echo "  sent 2,048 bytes  received 64 bytes  4,224.00 bytes/sec"
    echo "  total size is 1,984  speedup is 0.92"
    echo

    echo "  Step 2: Perform a dry run of the sync process to preview changes."
    echo "  Remote target: student@remote.server.com:/home/student/backup/"
    read -p "  lab@lpic-lab69:~$ " cmd2
    echo
    if [[ "$cmd2" != "rsync -avzn project_files student@remote.server.com:/home/student/backup/" ]]; then
        print_error "Incorrect. Use: rsync -avzn project_files student@remote.server.com:/home/student/backup/"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  (DRY RUN) sending incremental file list"
    echo "  project_files/new_file.txt"
    echo "  (DRY RUN) total size is 512  speedup is 1.00"
    echo

    echo "  Step 3: Synchronize the remote backup directory back to the local 'project_files' directory."
    read -p "  lab@lpic-lab69:~$ " cmd3
    echo
    if [[ "$cmd3" != "rsync -avz student@remote.server.com:/home/student/backup/ project_files" ]]; then
        print_error "Incorrect. Use: rsync -avz student@remote.server.com:/home/student/backup/ project_files"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  receiving incremental file list"
    echo "  project_files/new_file.txt"
    echo "  sent 128 bytes  received 2,048 bytes  4,352.00 bytes/sec"
    echo "  total size is 512  speedup is 0.94"
    echo

    print_success "Lab complete."
    print_info "You earned $LAB_XP XP for completing this lab."
    award_xp "$LAB_XP"
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
