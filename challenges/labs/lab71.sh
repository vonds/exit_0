#!/bin/bash

# Lab 71: System Updates and Repos (rpm, yum, apt, pacman)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 71: System Updates and Repos"
LAB_ID="lab71"
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
    center_text "Scenario: You need to install and update software using various package managers."
    center_text "You will use rpm, yum, apt, and pacman to inspect, install, and update packages."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Query the RPM package (sample.rpm) to see what's inside."
    read -p "  lab@lpic-lab71:~$ " cmd1
    echo
    [[ "$cmd1" != "rpm -qpi sample.rpm" ]] && {
        print_error "Incorrect. Use: rpm -qpi sample.rpm"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Name        : sample"
    echo "  Version     : 1.0"
    echo "  Summary     : Example RPM package"
    echo "  Description : This is a sample RPM for training purposes."
    echo

    echo "  Step 2: Install the nano package using yum."
    read -p "  lab@lpic-lab71:~$ " cmd2
    echo
    [[ "$cmd2" != "sudo yum install -y nano" ]] && {
        print_error "Incorrect. Use: sudo yum install -y nano"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Loaded plugins: fastestmirror"
    echo "  Resolving Dependencies"
    echo "  --> Running transaction check"
    echo "  --> Installing : nano-2.9.8-1.el7.x86_64"
    echo "  Installed:"
    echo "    nano.x86_64 0:2.9.8-1.el7"
    echo "  Complete!"
    echo

    echo "  Step 3: Update all packages on a Debian-based system."
    read -p "  lab@lpic-lab71:~$ " cmd3
    echo
    [[ "$cmd3" != "sudo apt update && sudo apt upgrade -y" ]] && {
        print_error "Incorrect. Use: sudo apt update && sudo apt upgrade -y"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Hit:1 http://deb.debian.org/debian stable InRelease"
    echo "  Reading package lists... Done"
    echo "  Building dependency tree"
    echo "  Reading state information... Done"
    echo "  Upgrading..."
    echo "  Fetched 12.3 MB in 5s (2,360 kB/s)"
    echo "  Done."
    echo

    echo "  Step 4: List available repositories on a yum-based system."
    read -p "  lab@lpic-lab71:~$ " cmd4
    echo
    [[ "$cmd4" != "yum repolist" ]] && {
        print_error "Incorrect. Use: yum repolist"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Loaded plugins: fastestmirror"
    echo "  repo id                  repo name                                 status"
    echo "  base/7/x86_64            CentOS-7 - Base                           10,019"
    echo "  updates/7/x86_64         CentOS-7 - Updates                        1,002"
    echo "  extras/7/x86_64          CentOS-7 - Extras                           500"
    echo

    echo "  Step 5: Install the neofetch package on an Arch-based system using pacman."
    read -p "  lab@lpic-lab71:~$ " cmd5
    echo
    [[ "$cmd5" != "sudo pacman -S neofetch" ]] && {
        print_error "Incorrect. Use: sudo pacman -S neofetch"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  resolving dependencies..."
    echo "  looking for conflicting packages..."
    echo
    echo "  Packages (1) neofetch-7.1.0-2"
    echo
    echo "  Total Installed Size:  0.20 MiB"
    echo "  :: Proceed with installation? [Y/n] y"
    echo "  (1/1) checking keys in keyring"
    echo "  (1/1) verifying package integrity"
    echo "  (1/1) loading package files"
    echo "  (1/1) checking for file conflicts"
    echo "  (1/1) installing neofetch"
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
