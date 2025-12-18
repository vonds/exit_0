#!/bin/bash

# Lab 98: Installing, Configuring, and Managing Ansible

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 98: Installing, Configuring, and Managing Ansible"
LAB_ID="lab98"
LAB_XP=5750
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
    center_text "Scenario: You need to deploy and configure Ansible to automate server tasks."
    center_text "This lab covers installation, inventory config, ad-hoc usage, and YAML playbooks."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Install Ansible using your package manager."
    read -p "  lab@lpic-lab98:~$ " cmd1
    echo
    [[ "$cmd1" != "sudo apt install ansible -y" && "$cmd1" != "sudo dnf install ansible -y" && "$cmd1" != "sudo pacman -S ansible" ]] && {
        print_error "Incorrect. Use: sudo apt install ansible -y (or dnf/pacman equivalent)"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  [sudo] password for lab:"
    echo "  Last metadata expiration check: 0:02:11 ago on Tue 16 Dec 2025 03:02:11 PM EST."
    echo "  Dependencies resolved."
    echo "  ============================================================================="
    echo "   Package              Arch   Version                 Repository        Size"
    echo "  ============================================================================="
    echo "  Installing:"
    echo "   ansible-core         noarch  2.15.8-1.el9            appstream        2.5 M"
    echo "   ansible              noarch  8.5.0-1.el9             appstream        1.2 M"
    echo "  Installing dependencies:"
    echo "   python3-jinja2       noarch  2.11.3-4.el9            appstream        233 k"
    echo "   python3-yaml         x86_64  5.4.1-6.el9             appstream        205 k"
    echo "  Transaction Summary"
    echo "  ============================================================================="
    echo "  Install  4 Packages"
    echo "  Complete!"
    echo "  Ansible installed successfully."
    echo

    echo "  Step 2: Verify Ansible installation and version."
    read -p "  lab@lpic-lab98:~$ " cmd2
    echo
    [[ "$cmd2" != "ansible --version" ]] && {
        print_error "Incorrect. Use: ansible --version"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  ansible [core 2.15.8]"
    echo "    config file = /etc/ansible/ansible.cfg"
    echo "    configured module search path = ['/home/lab/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']"
    echo "    ansible python module location = /usr/lib/python3.9/site-packages/ansible"
    echo "    ansible collection location = /home/lab/.ansible/collections:/usr/share/ansible/collections"
    echo "    executable location = /usr/bin/ansible"
    echo "    python version = 3.9.18 (main, Oct  3 2025, 10:22:11) [GCC 11.4.1 20230605 (Red Hat 11.4.1-2)]"
    echo

    echo "  Step 3: Create an inventory file with a group of managed hosts."
    read -p "  lab@lpic-lab98:~$ " cmd3
    echo
    [[ "$cmd3" != "nano ~/inventory" && "$cmd3" != "vim ~/inventory" ]] && {
        print_error "Incorrect. Create the inventory file using nano or vim"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Create ~/inventory with:"
    echo "  [web]"
    echo "  192.168.122.10"
    echo
    echo "  [db]"
    echo "  192.168.122.11"
    echo

    echo "  Step 4: Run an ad-hoc ping to confirm connectivity."
    read -p "  lab@lpic-lab98:~$ " cmd4
    echo
    [[ "$cmd4" != "ansible all -i ~/inventory -m ping" ]] && {
        print_error "Incorrect. Use: ansible all -i ~/inventory -m ping"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  192.168.122.10 | SUCCESS => {"
    echo "      \"ansible_facts\": {"
    echo "          \"discovered_interpreter_python\": \"/usr/libexec/platform-python\""
    echo "      },"
    echo "      \"changed\": false,"
    echo "      \"ping\": \"pong\""
    echo "  }"
    echo "  192.168.122.11 | SUCCESS => {"
    echo "      \"ansible_facts\": {"
    echo "          \"discovered_interpreter_python\": \"/usr/libexec/platform-python\""
    echo "      },"
    echo "      \"changed\": false,"
    echo "      \"ping\": \"pong\""
    echo "  }"
    echo

    echo "  Step 5: Write a playbook to install nginx on web hosts."
    read -p "  lab@lpic-lab98:~$ " cmd5
    echo
    [[ "$cmd5" != "nano install_nginx.yml" && "$cmd5" != "vim install_nginx.yml" ]] && {
        print_error "Incorrect. Create install_nginx.yml using nano or vim"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Sample playbook:"
    echo "  - name: Install nginx"
    echo "    hosts: web"
    echo "    become: yes"
    echo "    tasks:"
    echo "      - name: Install nginx"
    echo "        package:"
    echo "          name: nginx"
    echo "          state: present"
    echo

    echo "  Step 6: Run the playbook against the web group."
    read -p "  lab@lpic-lab98:~$ " cmd6
    echo
    [[ "$cmd6" != "ansible-playbook -i ~/inventory install_nginx.yml" ]] && {
        print_error "Incorrect. Use: ansible-playbook -i ~/inventory install_nginx.yml"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  PLAY [Install nginx] ***********************************************************"
    echo
    echo "  TASK [Gathering Facts] *********************************************************"
    echo "  ok: [192.168.122.10]"
    echo
    echo "  TASK [Install nginx] ***********************************************************"
    echo "  changed: [192.168.122.10]"
    echo
    echo "  PLAY RECAP *********************************************************************"
    echo "  192.168.122.10              : ok=2  changed=1  unreachable=0  failed=0  skipped=0  rescued=0  ignored=0"
    echo

    echo "  Step 7: Add a task to ensure nginx is started and enabled."
    read -p "  lab@lpic-lab98:~$ " cmd7
    echo
    [[ "$cmd7" != "nano install_nginx.yml" && "$cmd7" != "vim install_nginx.yml" ]] && {
        print_error "Incorrect. Edit the playbook file to add service task"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Add this task under tasks:"
    echo "      - name: Ensure nginx is running"
    echo "        service:"
    echo "          name: nginx"
    echo "          state: started"
    echo "          enabled: yes"
    echo

    echo "  Step 8: Re-run the updated playbook."
    read -p "  lab@lpic-lab98:~$ " cmd8
    echo
    [[ "$cmd8" != "ansible-playbook -i ~/inventory install_nginx.yml" ]] && {
        print_error "Incorrect. Use: ansible-playbook -i ~/inventory install_nginx.yml"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  PLAY [Install nginx] ***********************************************************"
    echo
    echo "  TASK [Gathering Facts] *********************************************************"
    echo "  ok: [192.168.122.10]"
    echo
    echo "  TASK [Install nginx] ***********************************************************"
    echo "  ok: [192.168.122.10]"
    echo
    echo "  TASK [Ensure nginx is running] *************************************************"
    echo "  changed: [192.168.122.10]"
    echo
    echo "  PLAY RECAP *********************************************************************"
    echo "  192.168.122.10              : ok=3  changed=1  unreachable=0  failed=0  skipped=0  rescued=0  ignored=0"
    echo

    echo "  Step 9: Use ansible facts to gather information about the hosts."
    read -p "  lab@lpic-lab98:~$ " cmd9
    echo
    [[ "$cmd9" != "ansible all -i ~/inventory -m setup" ]] && {
        print_error "Incorrect. Use: ansible all -i ~/inventory -m setup"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  192.168.122.10 | SUCCESS => {"
    echo "      \"ansible_facts\": {"
    echo "          \"ansible_distribution\": \"Rocky\","
    echo "          \"ansible_distribution_major_version\": \"9\","
    echo "          \"ansible_default_ipv4\": {"
    echo "              \"address\": \"192.168.122.10\""
    echo "          },"
    echo "          \"ansible_hostname\": \"web1\""
    echo "      },"
    echo "      \"changed\": false"
    echo "  }"
    echo "  192.168.122.11 | SUCCESS => {"
    echo "      \"ansible_facts\": {"
    echo "          \"ansible_distribution\": \"Rocky\","
    echo "          \"ansible_distribution_major_version\": \"9\","
    echo "          \"ansible_default_ipv4\": {"
    echo "              \"address\": \"192.168.122.11\""
    echo "          },"
    echo "          \"ansible_hostname\": \"db1\""
    echo "      },"
    echo "      \"changed\": false"
    echo "  }"
    echo

    echo "  Step 10: Clean up by removing nginx from web hosts."
    read -p "  lab@lpic-lab98:~$ " cmd10
    echo
    [[ "$cmd10" != "ansible web -i ~/inventory -m package -a 'name=nginx state=absent' -b" ]] && {
        print_error "Incorrect. Use: ansible web -i ~/inventory -m package -a 'name=nginx state=absent' -b"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  192.168.122.10 | CHANGED => {"
    echo "      \"changed\": true,"
    echo "      \"msg\": \"Removed: nginx\""
    echo "  }"
    echo
    echo "  Nginx removed from all web hosts."
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
