#!/bin/bash

# Lab 103: Managing Roles with ansible-galaxy

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 103: Managing Roles with ansible-galaxy"
LAB_ID="lab103"
LAB_XP=3500
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
    center_text "Scenario: You're building modular infrastructure with Ansible"
    center_text "and want to reuse or contribute community roles using ansible-galaxy."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Create a directory to hold your playbook and roles."
    read -p "  lab@lpic-lab103:~$ " cmd1
    echo
    [[ "$cmd1" != "mkdir -p galaxy_lab/roles && cd galaxy_lab" ]] && {
        print_error "Incorrect. Use: mkdir -p galaxy_lab/roles && cd galaxy_lab"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Directory 'galaxy_lab' created."
    echo "  roles directory created: galaxy_lab/roles"
    echo

    echo "  Step 2: Search for a community role to install (e.g., geerlingguy.nginx)."
    read -p "  lab@lpic-lab103:~/galaxy_lab$ " cmd2
    echo
    [[ "$cmd2" != "ansible-galaxy search nginx" ]] && {
        print_error "Incorrect. Use: ansible-galaxy search nginx"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Found 25 roles matching 'nginx'"
    echo "  "
    echo "  Name                                 Description"
    echo "  ----                                 -----------"
    echo "  geerlingguy.nginx                    Nginx for Linux."
    echo "  nginxinc.nginx                       Official NGINX role (install/config)."
    echo "  idealista.nginx_role                 Installs and configures Nginx."
    echo "  jdauphant.nginx                      Install and configures nginx"
    echo "  ..."
    echo

    echo "  Step 3: Install the role using ansible-galaxy."
    read -p "  lab@lpic-lab103:~/galaxy_lab$ " cmd3
    echo
    [[ "$cmd3" != "ansible-galaxy install geerlingguy.nginx" ]] && {
        print_error "Incorrect. Use: ansible-galaxy install geerlingguy.nginx"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Starting galaxy role install process"
    echo "  - downloading role 'nginx', owned by geerlingguy"
    echo "  - downloading role from https://github.com/geerlingguy/ansible-role-nginx/archive/refs/heads/master.tar.gz"
    echo "  - extracting geerlingguy.nginx to /home/lab/.ansible/roles/geerlingguy.nginx"
    echo "  - geerlingguy.nginx (master) was installed successfully"
    echo

    echo "  Step 4: Create a playbook to use the downloaded role."
    read -p "  lab@lpic-lab103:~/galaxy_lab$ " cmd4
    echo
    [[ "$cmd4" != "nano site.yml" && "$cmd4" != "vim site.yml" ]] && {
        print_error "Incorrect. Use: nano site.yml"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Sample playbook:"
    echo "  - hosts: all"
    echo "    become: true"
    echo "    roles:"
    echo "      - geerlingguy.nginx"
    echo

    echo "  Step 5: Run the playbook (use --syntax-check if needed)."
    read -p "  lab@lpic-lab103:~/galaxy_lab$ " cmd5
    echo
    [[ "$cmd5" != "ansible-playbook -i inventory.ini site.yml" ]] && {
        print_error "Incorrect. Use: ansible-playbook -i inventory.ini site.yml"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  PLAY [all] *********************************************************************"
    echo
    echo "  TASK [Gathering Facts] *********************************************************"
    echo "  ok: [target1]"
    echo
    echo "  TASK [geerlingguy.nginx : Include OS-specific variables] ************************"
    echo "  ok: [target1]"
    echo
    echo "  TASK [geerlingguy.nginx : Ensure nginx is installed] ****************************"
    echo "  changed: [target1]"
    echo
    echo "  TASK [geerlingguy.nginx : Copy nginx configuration in place.] *******************"
    echo "  changed: [target1]"
    echo
    echo "  TASK [geerlingguy.nginx : Ensure nginx is started and enabled at boot.] *********"
    echo "  changed: [target1]"
    echo
    echo "  PLAY RECAP *********************************************************************"
    echo "  target1                    : ok=6    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0"
    echo

    echo "  Step 6: Create a custom role using the init command."
    read -p "  lab@lpic-lab103:~/galaxy_lab$ " cmd6
    echo
    [[ "$cmd6" != "ansible-galaxy init roles/myrole" ]] && {
        print_error "Incorrect. Use: ansible-galaxy init roles/myrole"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  - Role roles/myrole was created successfully"
    echo "  - Created roles/myrole/tasks/main.yml"
    echo "  - Created roles/myrole/handlers/main.yml"
    echo "  - Created roles/myrole/defaults/main.yml"
    echo "  - Created roles/myrole/vars/main.yml"
    echo "  - Created roles/myrole/meta/main.yml"
    echo "  - Created roles/myrole/README.md"
    echo "  - Created roles/myrole/files/"
    echo "  - Created roles/myrole/templates/"
    echo "  - Created roles/myrole/tests/inventory"
    echo "  - Created roles/myrole/tests/test.yml"
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
