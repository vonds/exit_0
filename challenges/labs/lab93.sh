#!/bin/bash

# Lab 93: Opening Image Files from the Command Line
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 93: Opening Image Files from the Command Line"
LAB_ID="lab93"
LAB_XP=2750
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
    center_text "Scenario: You want to view or open image files using the Linux command line."
    center_text "You'll learn to use terminal and GUI image viewers."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Confirm image file exists in current directory."
    read -p "  lab@lpic-lab93:~$ " cmd1
    echo
    [[ "$cmd1" != "ls *.jpg" && "$cmd1" != "ls *.png" && "$cmd1" != "ls *.jpeg" ]] && {
        print_error "Incorrect. Try listing .jpg or .png images using ls"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Image file located."
    echo

    echo "  Step 2: Install a standard GUI image viewer."
    read -p "  lab@lpic-lab93:~$ " cmd2
    echo
    [[ "$cmd2" != "sudo apt install feh -y" && "$cmd2" != "sudo dnf install feh -y" && "$cmd2" != "sudo pacman -S feh" ]] && {
        print_error "Incorrect. Use: sudo apt install feh -y (or dnf/pacman equivalent)"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  feh installed successfully."
    echo

    echo "  Step 3: Open an image with feh viewer."
    read -p "  lab@lpic-lab93:~$ " cmd3
    echo
    [[ "$cmd3" != "feh image.jpg" && "$cmd3" != "feh image.png" ]] && {
        print_error "Incorrect. Use: feh image.jpg (or .png)"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  feh launched and displayed the image."
    echo

    echo "  Step 4: Install terminal-based image preview tool (optional)."
    read -p "  lab@lpic-lab93:~$ " cmd4
    echo
    [[ "$cmd4" != "sudo apt install viu -y" && "$cmd4" != "sudo pacman -S viu" && "$cmd4" != "cargo install viu" ]] && {
        print_error "Incorrect. Try installing viu with apt, pacman, or cargo"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  viu installed."
    echo

    echo "  Step 5: Open image inline in terminal (if supported)."
    read -p "  lab@lpic-lab93:~$ " cmd5
    echo
    [[ "$cmd5" != "viu image.jpg" && "$cmd5" != "viu image.png" ]] && {
        print_error "Incorrect. Use: viu image.jpg"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  viu displayed image in terminal if terminal supports it."
    echo

    echo "  Step 6: Open image using xdg-open."
    read -p "  lab@lpic-lab93:~$ " cmd6
    echo
    [[ "$cmd6" != "xdg-open image.jpg" && "$cmd6" != "xdg-open image.png" ]] && {
        print_error "Incorrect. Use: xdg-open image.jpg"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Image opened using the default GUI application."
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
    print_info "You have completed this lab $completion_count time(s)."
    echo
    center_text "Would you like to:"
    center_text "1) Retry this lab"
    center_text "2) Return to Sysadmin Lab Menu"
    echo
    read -p "  > " post_choice

    [[ "$post_choice" == "2" ]] && exit 0
done
