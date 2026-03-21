#!/bin/bash

# Lab 189: Building a Basic Sysinfo Script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 189: Building a Basic Sysinfo Script"
LAB_ID="lab189"
LAB_XP=24000
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
    center_text "Scenario: You need a simple script that reports basic host information."
    center_text "You will create a script that prints the hostname, kernel release, and logged-in users."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Create the directory where the script will be stored."
    read -p "  lab@lpic-lab189:~$ " cmd1
    echo
    [[ "$cmd1" != "mkdir -p /root/bin" ]] && {
        print_error "Incorrect. Use: mkdir -p /root/bin"
        read -p "Press Enter to try again..." _
        continue
    }

    echo "  Step 2: Open the script file in vim."
    read -p "  lab@lpic-lab189:~$ " cmd2
    echo
    [[ "$cmd2" != "vim /root/bin/sysinfo.sh" ]] && {
        print_error "Incorrect. Use: vim /root/bin/sysinfo.sh"
        read -p "Press Enter to try again..." _
        continue
    }
    echo '  -- INSERT --'
    echo '  #!/bin/bash'
    echo '  echo "Hostname: $(hostname)"'
    echo '  echo "Kernel: $(uname -r)"'
    echo '  echo "Logged-in users:"'
    echo '  who'
    echo

    echo "  Step 3: Make the script executable."
    read -p "  lab@lpic-lab189:~$ " cmd3
    echo
    [[ "$cmd3" != "chmod +x /root/bin/sysinfo.sh" ]] && {
        print_error "Incorrect. Use: chmod +x /root/bin/sysinfo.sh"
        read -p "Press Enter to try again..." _
        continue
    }
 
    echo "  Step 4: Run the script."
    read -p "  lab@lpic-lab189:~$ " cmd4
    echo
    [[ "$cmd4" != "/root/bin/sysinfo.sh" ]] && {
        print_error "Incorrect. Use: /root/bin/sysinfo.sh"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Hostname: server1.example.com"
    echo "  Kernel: 5.14.0-427.24.1.el9_4.x86_64"
    echo "  Logged-in users:"
    echo "  root     pts/0        $(date +'%b %e %H:%M') (10.0.2.2)"
    echo

    echo "  Step 5: Display the script contents to verify its logic."
    read -p "  lab@lpic-lab189:~$ " cmd5
    echo
    [[ "$cmd5" != "cat /root/bin/sysinfo.sh" ]] && {
        print_error "Incorrect. Use: cat /root/bin/sysinfo.sh"
        read -p "Press Enter to try again..." _
        continue
    }
    echo '  #!/bin/bash'
    echo '  echo "Hostname: $(hostname)"'
    echo '  echo "Kernel: $(uname -r)"'
    echo '  echo "Logged-in users:"'
    echo '  who'
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