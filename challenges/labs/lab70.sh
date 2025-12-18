#!/bin/bash

# Lab 70: Downloading Files with wget

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 70: Downloading Files with wget"
LAB_ID="lab70"
LAB_XP=1250
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
    center_text "Scenario: You need to download a software package from the internet."
    center_text "You will use the 'wget' command to fetch files and monitor download status."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Use wget to download the file from https://example.com/sample.tar.gz."
    read -p "  lab@lpic-lab70:~$ " cmd1
    echo
    [[ "$cmd1" != "wget https://example.com/sample.tar.gz" ]] && {
        print_error "Incorrect. Use: wget https://example.com/sample.tar.gz"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  --2025-01-01 10:00:00--  https://example.com/sample.tar.gz"
    echo "  Resolving example.com (example.com)... 93.184.216.34"
    echo "  Connecting to example.com... connected."
    echo "  HTTP request sent, awaiting response... 200 OK"
    echo "  Length: 10240 (10K) [application/x-gzip]"
    echo "  Saving to: ‘sample.tar.gz’"
    echo "  sample.tar.gz        100%[===================>]  10.00K  --.-KB/s   in 0.02s"
    echo

    echo "  Step 2: Download the same file and save it with a custom filename."
    read -p "  lab@lpic-lab70:~$ " cmd2
    echo
    [[ "$cmd2" != "wget -O custom.tar.gz https://example.com/sample.tar.gz" ]] && {
        print_error "Incorrect. Use: wget -O custom.tar.gz https://example.com/sample.tar.gz"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Saving to: ‘custom.tar.gz’"
    echo "  custom.tar.gz      100%[===================>]  10.00K  --.-KB/s   in 0.02s"
    echo

    echo "  Step 3: Resume a partially downloaded file."
    read -p "  lab@lpic-lab70:~$ " cmd3
    echo
    [[ "$cmd3" != "wget -c https://example.com/sample.tar.gz" ]] && {
        print_error "Incorrect. Use: wget -c https://example.com/sample.tar.gz"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Resuming download of ‘sample.tar.gz’."
    echo "  HTTP request sent, awaiting response... 206 Partial Content"
    echo "  Length: 10240 (remaining: 2048)"
    echo "  sample.tar.gz        100%[+++++++++++++++++++]  2.00K  --.-KB/s   in 0.01s"
    echo

    echo "  Step 4: Download in the background."
    read -p "  lab@lpic-lab70:~$ " cmd4
    echo
    [[ "$cmd4" != "wget -b https://example.com/sample.tar.gz" ]] && {
        print_error "Incorrect. Use: wget -b https://example.com/sample.tar.gz"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Continuing in background, pid 12345."
    echo "  Output will be written to ‘wget-log’."
    echo

    print_success "Lab complete."
    print_info "You earned $LAB_XP XP for completing this lab."
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
