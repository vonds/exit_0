#!/bin/bash

# Lab 68: SCP - Secure Copy Protocol

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 68: SCP - Secure Copy Protocol"
LAB_ID="lab68"
LAB_XP=1600
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
    center_text "Scenario:"
    center_text "Scenario: You need to securely transfer files between local and remote systems."
    center_text "You will practice using the 'scp' command to upload and download files."
    echo
    echo
    center_text "Press Enter to begin the lab..."
    read _

    # STEP 1
    draw_lab_ui
    echo "  Step 1:"
    echo "    Upload the local file 'testfile.txt' (in your current directory)"
    echo "    to the remote backup directory on the server at 192.168.1.50,"
    echo "    using the user 'labuser'."
    echo
    read -p "  lab@lpic-lab68:~$ " cmd1
    echo
    if [[ "$cmd1" != "scp testfile.txt labuser@192.168.1.50:/home/labuser/remote_dir" ]]; then
        print_error "Incorrect. You need to copy 'testfile.txt' to /home/labuser/remote_dir on 192.168.1.50 as user 'labuser'."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  testfile.txt                                 100%   12KB  120.0KB/s   00:00"
    echo

    # STEP 2
    echo "  Step 2:"
    echo "    A file named 'remote.txt' now exists in the remote directory:"
    echo "    /home/labuser/remote_dir"
    echo "    Download 'remote.txt' from the remote directory"
    echo "    to your current local directory."
    echo
    read -p "  lab@lpic-lab68:~$ " cmd2
    echo
    if [[ "$cmd2" != "scp labuser@192.168.1.50:/home/labuser/remote_dir/remote.txt ." ]]; then
        print_error "Incorrect. You need to copy 'remote.txt' from /home/labuser/remote_dir on 192.168.1.50 into the current directory."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  remote.txt                                   100%    8KB   80.0KB/s   00:00"
    echo

    # STEP 3
    echo "  Step 3:"
    echo "    You have a local directory named 'mydir/' in your current directory."
    echo "    Recursively copy the entire 'mydir' directory to the same remote"
    echo "    backup directory on 192.168.1.50 as user 'labuser'."
    echo
    read -p "  lab@lpic-lab68:~$ " cmd3
    echo
    if [[ "$cmd3" != "scp -r mydir labuser@192.168.1.50:/home/labuser/remote_dir" ]]; then
        print_error "Incorrect. You need to recursively copy 'mydir/' to /home/labuser/remote_dir on 192.168.1.50."
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  mydir/file1.txt                              100%    1KB   10.0KB/s   00:00"
    echo "  mydir/file2.txt                              100%    1KB   10.0KB/s   00:00"
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
