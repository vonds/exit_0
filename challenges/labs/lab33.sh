#!/bin/bash

# Lab 33: Environment Variables and Shell Configuration

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 33: Environment Variables and Shell Configuration"
LAB_ID="lab33"
LAB_XP=20000
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
    center_text "Scenario: A developer reports that the PROJECT_ROOT environment variable"
    center_text "does not persist across terminal sessions. Your task is to confirm the"
    center_text "issue and ensure the variable is loaded in all new sessions."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Check if PROJECT_ROOT is set in the current session."
    read -p "  lab@lpic-lab33:~$ " cmd1
    echo
    [[ "$cmd1" != "printenv PROJECT_ROOT" && "$cmd1" != "env | grep PROJECT_ROOT" ]] && {
        print_error "Incorrect. Try using: printenv PROJECT_ROOT or env | grep PROJECT_ROOT"
        read -p "Press Enter to try again..." _
        continue
    }
    [[ "$cmd1" == "printenv PROJECT_ROOT" ]] && echo "  /home/dev/project"
    [[ "$cmd1" == "env | grep PROJECT_ROOT" ]] && echo "  PROJECT_ROOT=/home/dev/project"
    echo

    echo "  Step 2: Check if PROJECT_ROOT is defined in ~/.bashrc."
    read -p "  lab@lpic-lab33:~$ " cmd2
    echo
    [[ "$cmd2" != "grep PROJECT_ROOT ~/.bashrc" ]] && {
        print_error "Incorrect. Use: grep PROJECT_ROOT ~/.bashrc"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  PROJECT_ROOT is not currently set in ~/.bashrc."
    echo

    echo "  Step 3: Add the export command to ~/.bashrc to persist the variable."
    read -p "  lab@lpic-lab33:~$ " cmd3
    echo
    [[ "$cmd3" != "echo 'export PROJECT_ROOT=/home/dev/project' >> ~/.bashrc" ]] && {
        print_error "Incorrect. Use: echo 'export PROJECT_ROOT=/home/dev/project' >> ~/.bashrc"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 4: Reload the .bashrc file to apply the change immediately."
    read -p "  lab@lpic-lab33:~$ " cmd4
    echo
    [[ "$cmd4" != "source ~/.bashrc" ]] && {
        print_error "Incorrect. Use: source ~/.bashrc"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 5: Verify that PROJECT_ROOT is now available in the environment."
    read -p "  lab@lpic-lab33:~$ " cmd5
    echo
    [[ "$cmd5" != "printenv PROJECT_ROOT" && "$cmd5" != "env | grep PROJECT_ROOT" ]] && {
        print_error "Incorrect. Try using: printenv PROJECT_ROOT or env | grep PROJECT_ROOT"
        read -p "Press Enter to try again..." _
        continue
    }
    [[ "$cmd5" == "printenv PROJECT_ROOT" ]] && echo "  /home/dev/project"
    [[ "$cmd5" == "env | grep PROJECT_ROOT" ]] && echo "  PROJECT_ROOT=/home/dev/project"
    echo

    echo "  Step 6: Confirm that the PROJECT_ROOT export line was saved in ~/.bashrc."
    read -p "  lab@lpic-lab33:~$ " cmd6
    echo
    [[ "$cmd6" != "grep PROJECT_ROOT ~/.bashrc" ]] && {
        print_error "Incorrect. Use: grep PROJECT_ROOT ~/.bashrc"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  export PROJECT_ROOT=/home/dev/project"
    echo


    print_success "Well done!"
    print_info "You earned $LAB_XP XP for completing the environment variable persistence lab."
    award_xp $LAB_XP
    XP=$(jq '.XP' "$SAVE_JSON")
    LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
    export XP
    export LEVEL
    record_lab_completion

    completion_count=$(get_lab_completion_count)
    echo
    print_info "You've successfully completed this lab $completion_count time(s)."
    echo
    center_text "Would you like to:"
    center_text "1) Retry this lab"
    center_text "2) Return to Sysadmin Lab Menu"
    echo
    read -p "  > " post_choice

    [[ "$post_choice" == "2" ]] && exit 0
done
