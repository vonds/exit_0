#!/bin/bash

# Lab 74: Rolling Back Patches and Updates
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 74: Rolling Back Patches and Updates"
LAB_ID="lab74"
LAB_XP=2250
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
    center_text "Scenario: A recent update caused issues. You must roll back to a working version."
    center_text "You will practice rollback on four distro families: RHEL (rpm, yum), Debian (apt), and Arch (pacman)."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: RHEL system using rpm directly."
    echo "  The bash shell was updated and is unstable. In the current directory you have:"
    echo "    bash-5.1.rpm (an older, known-good version)."
    echo "  Use rpm to install this older package version even though a newer one is already installed."
    read -p "  lab@lpic-lab74:~$ " cmd1
    echo
    [[ "$cmd1" != "rpm -Uvh --oldpackage bash-5.1.rpm" ]] && {
        print_error "Incorrect. Review rpm options for installing an older package version from bash-5.1.rpm and try again."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Preparing...    ################################# [100%]"
    echo "  Updating / installing..."
    echo "    1: bash-5.1  ################################# [100%]"
    echo

    echo "  Step 2: RHEL system using yum."
    echo "  Yesterday's yum update broke an application. You want to revert everything done by"
    echo "  the most recent yum transaction. Use yum's history feature to undo the last transaction."
    read -p "  lab@lpic-lab74:~$ " cmd2
    echo
    [[ "$cmd2" != "yum history undo last" ]] && {
        print_error "Incorrect. Use yum's history subcommand to undo the most recent transaction."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Loaded plugins: fastestmirror"
    echo "  Undoing transaction 33..."
    echo "  Reverting installed/erased/updated packages..."
    echo

    echo "  Step 3: Debian/Ubuntu system using apt."
    echo "  A newer bash version introduced a regression. You need to downgrade bash to:"
    echo "    version 5.1-2ubuntu3"
    echo "  Use apt to install that specific version of bash by pinning it to that version number."
    read -p "  lab@lpic-lab74:~$ " cmd3
    echo
    [[ "$cmd3" != "sudo apt install bash=5.1-2ubuntu3" ]] && {
        print_error "Incorrect. Use apt to install bash and explicitly set it to version 5.1-2ubuntu3."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Reading package lists... Done"
    echo "  The following packages will be downgraded:"
    echo "    bash"
    echo

    echo "  Step 4: Arch Linux system using pacman."
    echo "  A recent bash upgrade is causing problems. In the cache directory you have:"
    echo "    /var/cache/pacman/pkg/bash-5.1.pkg.tar.zst"
    echo "  Use pacman to install this cached package file, which will downgrade bash."
    read -p "  lab@lpic-lab74:~$ " cmd4
    echo
    [[ "$cmd4" != "sudo pacman -U /var/cache/pacman/pkg/bash-5.1.pkg.tar.zst" ]] && {
        print_error "Incorrect. Use pacman with -U on the cached package under /var/cache/pacman/pkg/."
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  :: Processing package changes..."
    echo "  :: Downgrading bash..."
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
