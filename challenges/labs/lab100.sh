#!/bin/bash

# Lab 100: Agent-Based Configuration with ansible-pull

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 100: Agent-Based Configuration with ansible-pull"
LAB_ID="lab100"
LAB_XP=5500
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
    center_text "Scenario: You want Linux systems to self-configure by pulling"
    center_text "their desired state from a Git repository using ansible-pull."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Install Ansible and Git if not already installed."
    read -p "  lab@lpic-lab100:~$ " cmd1
    echo
    [[ "$cmd1" != "sudo apt install ansible git -y" && "$cmd1" != "sudo dnf install ansible git -y" && "$cmd1" != "sudo pacman -S ansible git" ]] && {
        print_error "Incorrect. Use: sudo dnf install ansible git -y"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Last metadata expiration check: 0:01:48 ago on Tue Dec 16 16:04:32 EST."
    echo "  Dependencies resolved."
    echo "  Installing:"
    echo "    ansible-core   noarch   2.15.8-1.el9"
    echo "    git            x86_64   2.43.0-1.el9"
    echo "  Complete!"
    echo

    echo "  Step 2: Clone the remote playbook repository."
    read -p "  lab@lpic-lab100:~$ " cmd2
    echo
    [[ "$cmd2" != "git clone https://github.com/example/ansible-lab100.git" ]] && {
        print_error "Incorrect. Use: git clone https://github.com/example/ansible-lab100.git"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Cloning into 'ansible-lab100'..."
    echo "  remote: Enumerating objects: 18, done."
    echo "  remote: Counting objects: 100% (18/18), done."
    echo "  remote: Compressing objects: 100% (12/12), done."
    echo "  remote: Total 18 (delta 4), reused 0 (delta 0)"
    echo "  Receiving objects: 100% (18/18), 6.21 KiB | 6.21 MiB/s, done."
    echo

    echo "  Step 3: View the main playbook."
    read -p "  lab@lpic-lab100:~$ " cmd3
    echo
    [[ "$cmd3" != "cat ansible-lab100/site.yml" && "$cmd3" != "less ansible-lab100/site.yml" ]] && {
        print_error "Incorrect. Use: cat ansible-lab100/site.yml"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  - hosts: localhost"
    echo "    become: true"
    echo "    tasks:"
    echo "      - name: Ensure nginx is installed"
    echo "        package:"
    echo "          name: nginx"
    echo "          state: present"
    echo

    echo "  Step 4: Run ansible-pull to apply the configuration locally."
    read -p "  lab@lpic-lab100:~$ " cmd4
    echo
    [[ "$cmd4" != "sudo ansible-pull -U https://github.com/example/ansible-lab100.git -i localhost site.yml" ]] && {
        print_error "Incorrect. Use: sudo ansible-pull -U https://github.com/example/ansible-lab100.git -i localhost site.yml"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Starting Ansible Pull at 2025-12-16 16:07:19"
    echo "  /usr/bin/ansible-pull -U https://github.com/example/ansible-lab100.git -i localhost site.yml"
    echo
    echo "  PLAY [localhost] ***************************************************************"
    echo
    echo "  TASK [Gathering Facts] *********************************************************"
    echo "  ok: [localhost]"
    echo
    echo "  TASK [Ensure nginx is installed] ************************************************"
    echo "  changed: [localhost]"
    echo
    echo "  PLAY RECAP *********************************************************************"
    echo "  localhost : ok=2  changed=1  unreachable=0  failed=0"
    echo

    echo "  Step 5: Schedule ansible-pull to run every 30 minutes."
    read -p "  lab@lpic-lab100:~$ " cmd5
    echo
    [[ "$cmd5" != "crontab -e" ]] && {
        print_error "Incorrect. Use: crontab -e"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Add the following line:"
    echo "  */30 * * * * /usr/bin/ansible-pull -U https://github.com/example/ansible-lab100.git -i localhost site.yml"
    echo

    echo "  Step 6: Create a log file for ansible-pull output."
    read -p "  lab@lpic-lab100:~$ " cmd6
    echo
    [[ "$cmd6" != "mkdir -p /var/log/ansible && touch /var/log/ansible/pull.log" ]] && {
        print_error "Incorrect. Use: mkdir -p /var/log/ansible && touch /var/log/ansible/pull.log"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Log directory created at /var/log/ansible/"
    echo "  Log file pull.log ready for output redirection."
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
