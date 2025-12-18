#!/bin/bash

# Lab 121: Configure APT Repositories (/etc/apt/sources.list and sources.list.d)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 121: Configure APT Repositories"
LAB_ID="lab121"
LAB_XP=3100
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

# helper matchers
is_update_cmd() {
  [[ "$1" == "sudo apt update" || "$1" == "apt update" || "$1" == "sudo apt-get update" || "$1" == "apt-get update" ]]
}

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Scenario: You must audit and modify APT repositories."
    center_text "Inspect /etc/apt/sources.list, manage entries in sources.list.d, update indexes, and verify."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Show active (non-comment) lines in /etc/apt/sources.list."
    read -p "  lab@lpic-lab121:~$ " cmd1
    echo
    if [[ "$cmd1" != "grep -E '^[^#]' /etc/apt/sources.list" && "$cmd1" != "awk 'NF && $1!~/^#/' /etc/apt/sources.list" ]]; then
        print_error "Incorrect. Example: grep -E '^[^#]' /etc/apt/sources.list"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "deb http://archive.ubuntu.com/ubuntu jammy main restricted"
    echo "deb http://archive.ubuntu.com/ubuntu jammy-updates main restricted"
    echo "deb http://security.ubuntu.com/ubuntu jammy-security main restricted"
    echo

    echo "  Step 2: List any additional repo snippet files under /etc/apt/sources.list.d."
    read -p "  lab@lpic-lab121:~$ " cmd2
    echo
    if [[ "$cmd2" != "ls -1 /etc/apt/sources.list.d" ]]; then
        print_error "Incorrect. Use: ls -1 /etc/apt/sources.list.d"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "graphics-drivers-ppa.list"
    echo "docker.list"
    echo

    echo "  Step 3: Back up the main sources list before editing."
    read -p "  lab@lpic-lab121:~$ " cmd3
    echo
    if [[ "$cmd3" != "sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak" ]]; then
        print_error "Incorrect. Use: sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Backup created: /etc/apt/sources.list.bak"
    echo

    echo "  Step 4: Comment out any cdrom lines in /etc/apt/sources.list."
    read -p "  lab@lpic-lab121:~$ " cmd4
    echo
    if [[ "$cmd4" != "sudo sed -i 's/^deb cdrom/#deb cdrom/' /etc/apt/sources.list" && "$cmd4" != "sudo sed -i 's/^\\s*deb cdrom/# &/' /etc/apt/sources.list" ]]; then
        print_error "Incorrect. Example: sudo sed -i 's/^deb cdrom/#deb cdrom/' /etc/apt/sources.list"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "cdrom lines commented (if present)."
    echo

    echo "  Step 5: Add a custom repo snippet to sources.list.d."
    echo "          Add: deb http://archive.ubuntu.com/ubuntu jammy universe"
    read -p "  lab@lpic-lab121:~$ " cmd5
    echo
    if [[ "$cmd5" != "echo 'deb http://archive.ubuntu.com/ubuntu jammy universe' | sudo tee /etc/apt/sources.list.d/custom.list" ]]; then
        print_error "Incorrect. Use: echo 'deb http://archive.ubuntu.com/ubuntu jammy universe' | sudo tee /etc/apt/sources.list.d/custom.list"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "deb http://archive.ubuntu.com/ubuntu jammy universe"
    echo

    echo "  Step 6: Refresh the package index to load the new repository metadata."
    read -p "  lab@lpic-lab121:~$ " cmd6
    echo
    if ! is_update_cmd "$cmd6"; then
        print_error "Incorrect. Use: apt update   or   apt-get update"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Hit:1 http://archive.ubuntu.com/ubuntu jammy InRelease"
    echo "Get:2 http://archive.ubuntu.com/ubuntu jammy/universe amd64 Packages [8.2 MB]"
    echo "Reading package lists... Done"
    echo "Building dependency tree"
    echo "Reading state information... Done"
    echo "All packages are up to date."
    echo

    echo "  Step 7: Verify that 'jammy/universe' now appears in APT policy output."
    read -p "  lab@lpic-lab121:~$ " cmd7
    echo
    if [[ "$cmd7" != "apt-cache policy | head -n 30" && "$cmd7" != "apt-cache policy" ]]; then
        print_error "Incorrect. Example: apt-cache policy"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "500 http://archive.ubuntu.com/ubuntu jammy/universe amd64 Packages"
    echo "     release v=22.04,o=Ubuntu,a=jammy,n=jammy,l=Ubuntu,c=universe,b=amd64"
    echo

    echo "  Step 8: Disable the custom repo by commenting its line."
    read -p "  lab@lpic-lab121:~$ " cmd8
    echo
    if [[ "$cmd8" != "sudo sed -i 's/^deb /#deb /' /etc/apt/sources.list.d/custom.list" ]]; then
        print_error "Incorrect. Use: sudo sed -i 's/^deb /#deb /' /etc/apt/sources.list.d/custom.list"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Custom repo commented out."
    echo

    echo "  Step 9: Update indexes again to reflect the disabled repo."
    read -p "  lab@lpic-lab121:~$ " cmd9
    echo
    if ! is_update_cmd "$cmd9"; then
        print_error "Incorrect. Use: apt update   or   apt-get update"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Reading package lists... Done"
    echo "Building dependency tree"
    echo "Reading state information... Done"
    echo

    echo "  Step 10: Restore the original /etc/apt/sources.list from the backup."
    read -p "  lab@lpic-lab121:~$ " cmd10
    echo
    if [[ "$cmd10" != "sudo mv /etc/apt/sources.list.bak /etc/apt/sources.list" ]]; then
        print_error "Incorrect. Use: sudo mv /etc/apt/sources.list.bak /etc/apt/sources.list"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "Restored /etc/apt/sources.list from backup."
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
