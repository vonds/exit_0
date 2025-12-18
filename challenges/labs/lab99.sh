#!/bin/bash

# Lab 99: Creating and Using Ansible Roles (Production-Ready Structure)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 99: Creating and Using Ansible Roles"
LAB_ID="lab99"
LAB_XP=6250
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
    center_text "Scenario: You're managing a growing set of Ansible playbooks."
    center_text "It's time to switch to roles for cleaner, reusable, production-grade structure."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Create a new Ansible role named 'nginx'."
    read -p "  lab@lpic-lab99:~$ " cmd1
    echo
    [[ "$cmd1" != "ansible-galaxy init nginx" ]] && {
        print_error "Incorrect. Use: ansible-galaxy init nginx"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  - Role nginx was created successfully"
    echo "  - nginx/"
    echo "    ├── defaults/main.yml"
    echo "    ├── files/"
    echo "    ├── handlers/main.yml"
    echo "    ├── meta/main.yml"
    echo "    ├── tasks/main.yml"
    echo "    ├── templates/"
    echo "    ├── tests/"
    echo "    └── vars/main.yml"
    echo

    echo "  Step 2: Create a task to install nginx."
    read -p "  lab@lpic-lab99:~$ " cmd2
    echo
    [[ "$cmd2" != "nano nginx/tasks/main.yml" && "$cmd2" != "vim nginx/tasks/main.yml" ]] && {
        print_error "Incorrect. Edit nginx/tasks/main.yml using nano or vim"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Task defined using the package module."
    echo

    echo "  Step 3: Add a handler to restart nginx if needed."
    read -p "  lab@lpic-lab99:~$ " cmd3
    echo
    [[ "$cmd3" != "nano nginx/handlers/main.yml" && "$cmd3" != "vim nginx/handlers/main.yml" ]] && {
        print_error "Incorrect. Edit nginx/handlers/main.yml"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Handler 'restart nginx' registered."
    echo

    echo "  Step 4: Create an HTML template for the web page."
    read -p "  lab@lpic-lab99:~$ " cmd4
    echo
    [[ "$cmd4" != "nano nginx/templates/index.html.j2" && "$cmd4" != "vim nginx/templates/index.html.j2" ]] && {
        print_error "Incorrect. Edit nginx/templates/index.html.j2"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Template uses ansible_hostname fact."
    echo

    echo "  Step 5: Deploy the template using the role."
    read -p "  lab@lpic-lab99:~$ " cmd5
    echo
    [[ "$cmd5" != "nano nginx/tasks/main.yml" && "$cmd5" != "vim nginx/tasks/main.yml" ]] && {
        print_error "Incorrect. Modify nginx/tasks/main.yml"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Template task added with handler notification."
    echo

    echo "  Step 6: Create a site playbook using the nginx role."
    read -p "  lab@lpic-lab99:~$ " cmd6
    echo
    [[ "$cmd6" != "nano site.yml" && "$cmd6" != "vim site.yml" ]] && {
        print_error "Incorrect. Create site.yml using nano or vim"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Role included under 'roles:' section."
    echo

    echo "  Step 7: Run the role-based playbook."
    read -p "  lab@lpic-lab99:~$ " cmd7
    echo
    [[ "$cmd7" != "ansible-playbook -i ~/inventory site.yml" ]] && {
        print_error "Incorrect. Use: ansible-playbook -i ~/inventory site.yml"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  PLAY [web] *********************************************************************"
    echo
    echo "  TASK [Gathering Facts] *********************************************************"
    echo "  ok: [192.168.122.10]"
    echo
    echo "  TASK [nginx : Install nginx] ***************************************************"
    echo "  changed: [192.168.122.10]"
    echo
    echo "  TASK [nginx : Deploy custom index.html] ****************************************"
    echo "  changed: [192.168.122.10]"
    echo
    echo "  RUNNING HANDLER [nginx : restart nginx] ****************************************"
    echo "  changed: [192.168.122.10]"
    echo
    echo "  PLAY RECAP *********************************************************************"
    echo "  192.168.122.10 : ok=4  changed=3  unreachable=0  failed=0"
    echo

    echo "  Step 8: Validate role structure and syntax with ansible-lint."
    read -p "  lab@lpic-lab99:~$ " cmd8
    echo
    [[ "$cmd8" != "ansible-lint site.yml" ]] && {
        print_error "Incorrect. Use: ansible-lint site.yml"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Passed: 0 failures, 0 warnings"
    echo "  Role follows recommended best practices."
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
