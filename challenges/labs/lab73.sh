#!/bin/bash

# Lab 73: Advanced Package Management (rpm, dpkg, pacman)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 73: Advanced Package Management"
LAB_ID="lab73"
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
    center_text "Scenario: You're tasked with advanced troubleshooting of installed packages."
    center_text "You'll query, verify, and force package installs using rpm, dpkg, and pacman."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Use rpm to verify a package's integrity (e.g., bash)."
    read -p "  lab@lpic-lab75:~$ " cmd1
    echo
    [[ "$cmd1" != "rpm -V bash" ]] && {
        print_error "Incorrect. Use: rpm -V bash"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  S.5....T.  c /etc/bashrc"
    echo

    echo "  Step 2: Use dpkg to query installed files for bash."
    read -p "  lab@lpic-lab75:~$ " cmd2
    echo
    [[ "$cmd2" != "dpkg -L bash" ]] && {
        print_error "Incorrect. Use: dpkg -L bash"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  /."
    echo "  /bin"
    echo "  /bin/bash"
    echo "  /usr/share/doc/bash"
    echo

    echo "  Step 3: Force install a package with rpm (e.g., test.rpm)."
    read -p "  lab@lpic-lab75:~$ " cmd3
    echo
    [[ "$cmd3" != "rpm -ivh --force test.rpm" ]] && {
        print_error "Incorrect. Use: rpm -ivh --force test.rpm"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Preparing...                          ################################# [100%]"
    echo "  Updating / installing..."
    echo "     1:test.rpm                        ################################# [100%]"
    echo

    echo "  Step 4: Use pacman to check for broken packages."
    read -p "  lab@lpic-lab75:~$ " cmd4
    echo
    [[ "$cmd4" != "pacman -Qk" ]] && {
        print_error "Incorrect. Use: pacman -Qk"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  bash: 0 missing files"
    echo "  coreutils: 0 missing files"
    echo

    echo "  Step 5: Reinstall a package with pacman (e.g., bash)."
    read -p "  lab@lpic-lab75:~$ " cmd5
    echo
    [[ "$cmd5" != "sudo pacman -S bash --noconfirm" ]] && {
        print_error "Incorrect. Use: sudo pacman -S bash --noconfirm"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  :: Retrieving packages..."
    echo "  :: bash-5.2.15-1-x86_64 downloaded"
    echo "  :: Installing bash..."
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
