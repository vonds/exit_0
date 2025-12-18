#!/bin/bash

# Lab 96: Running Containers with Podman

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 96: Running Containers with Podman"
LAB_ID="lab96"
LAB_XP=4500
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
    center_text "Scenario: You need to run, inspect, and manage containers using Podman."
    center_text "This lab covers container lifecycle, image management, and volume mounts."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Install Podman."
    read -p "  lab@lpic-lab96:~$ " cmd1
    echo
    [[ "$cmd1" != "sudo apt install podman -y" && "$cmd1" != "sudo dnf install podman -y" && "$cmd1" != "sudo pacman -S podman" ]] && {
        print_error "Incorrect. Use: sudo apt install podman -y (or dnf/pacman equivalent)"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Podman installed successfully."
    echo

    echo "  Step 2: Check Podman version and confirm it works without root."
    read -p "  lab@lpic-lab96:~$ " cmd2
    echo
    [[ "$cmd2" != "podman --version" ]] && {
        print_error "Incorrect. Use: podman --version"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Podman version displayed and non-root support confirmed."
    echo

    echo "  Step 3: Pull a base image such as alpine."
    read -p "  lab@lpic-lab96:~$ " cmd3
    echo
    [[ "$cmd3" != "podman pull alpine" ]] && {
        print_error "Incorrect. Use: podman pull alpine"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Alpine image pulled successfully."
    echo

    echo "  Step 4: Run a named container interactively from the alpine image."
    echo "          (Use the name: lab-alpine)"
    read -p "  lab@lpic-lab96:~$ " cmd4
    echo
    [[ "$cmd4" != "podman run --name lab-alpine -it alpine /bin/sh" ]] && {
        print_error "Incorrect. Use: podman run --name lab-alpine -it alpine /bin/sh"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Alpine container 'lab-alpine' started interactively."
    echo

    echo "  Step 5: Exit the container and verify it's stopped."
    read -p "  lab@lpic-lab96:~$ " cmd5
    echo
    [[ "$cmd5" != "podman ps -a" ]] && {
        print_error "Incorrect. Use: podman ps -a"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Container 'lab-alpine' listed in stopped state."
    echo

    echo "  Step 6: Restart the stopped container by name."
    read -p "  lab@lpic-lab96:~$ " cmd6
    echo
    [[ "$cmd6" != "podman start lab-alpine" ]] && {
        print_error "Incorrect. Use: podman start lab-alpine"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Container 'lab-alpine' started."
    echo

    echo "  Step 7: View the logs of the container."
    read -p "  lab@lpic-lab96:~$ " cmd7
    echo
    [[ "$cmd7" != "podman logs lab-alpine" ]] && {
        print_error "Incorrect. Use: podman logs lab-alpine"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Logs for 'lab-alpine' displayed."
    echo

    echo "  Step 8: Mount a host directory as a volume inside a container."
    echo "          (Use ~/data on the host and /data in the container.)"
    read -p "  lab@lpic-lab96:~$ " cmd8
    echo
    [[ "$cmd8" != "podman run -v ~/data:/data -it alpine /bin/sh" ]] && {
        print_error "Incorrect. Use: podman run -v ~/data:/data -it alpine /bin/sh"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Host directory ~/data mounted into /data in the container."
    echo

    echo "  Step 9: Inspect the container details in JSON format."
    read -p "  lab@lpic-lab96:~$ " cmd9
    echo
    [[ "$cmd9" != "podman inspect lab-alpine" ]] && {
        print_error "Incorrect. Use: podman inspect lab-alpine"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  JSON configuration data for 'lab-alpine' displayed."
    echo

    echo "  Step 10: Clean up and remove container and image."
    read -p "  lab@lpic-lab96:~$ " cmd10
    echo
    [[ "$cmd10" != "podman rm -a && podman rmi -a" ]] && {
        print_error "Incorrect. Use: podman rm -a && podman rmi -a"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  All containers and images removed."
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
