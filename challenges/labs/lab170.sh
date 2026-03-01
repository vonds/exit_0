#!/bin/bash

# Lab 170: Practical Local Accounts with Ansible (No Directory Sync)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 170: Practical Local Accounts with Ansible"
LAB_ID="lab170"
LAB_XP=42000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

record_lab_completion() {
    tmpfile=$(mktemp)
    jq --arg lab "$LAB_ID" '.[$lab] = ((.[$lab] // 0) + 1)' "$LAB_TRACK_FILE" > "$tmpfile" && mv "$tmpfile" "$LAB_TRACK_FILE"
}

get_lab_completion_count() {
    jq -r --arg lab "$LAB_ID" '.[$lab] // 0' "$LAB_TRACK_FILE"
}

draw_lab_ui() {
    clear
    center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
    center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
    echo
    echo
}

PROMPT="  lab@lab170:~$ "

while true; do
    draw_lab_ui
    center_title "$LAB_NAME"
    echo
    center_text "Scenario: Instead of building LDAP/AD sync for external servers,"
    center_text "you manage local accounts consistently using Ansible."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui

    echo "  Step 1: Confirm Ansible is installed and show the version."
    read -p "$PROMPT" cmd1
    echo
    if [[ "$cmd1" != "ansible --version" ]]; then
        print_error "Incorrect. Try again."
        print_info "Expected: ansible --version"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  ansible [core 2.16.3]"
    echo "  python version = 3.11.2"
    echo "  jinja version = 3.1.2"
    echo "  libyaml = True"
    echo

    echo "  Step 2: Create a minimal inventory file named hosts.ini."
    echo "          Use an editor (nano/vim/vi) or redirect with cat."
    read -p "$PROMPT" cmd2
    echo
    if [[ "$cmd2" != "nano hosts.ini" && "$cmd2" != "vim hosts.ini" && "$cmd2" != "vi hosts.ini" && "$cmd2" != "cat > hosts.ini" ]]; then
        print_error "Incorrect. Try again."
        print_info "Expected: nano hosts.ini  (or vim/vi hosts.ini, or cat > hosts.ini)"
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  Step 3: Test connectivity to all hosts with the ping module."
    read -p "$PROMPT" cmd3
    echo
    if [[ "$cmd3" != "ansible all -i hosts.ini -m ping" && "$cmd3" != "ansible -i hosts.ini all -m ping" ]]; then
        print_error "Incorrect. Try again."
        print_info "Expected: ansible all -i hosts.ini -m ping"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  ext1 | SUCCESS => {\"changed\": false, \"ping\": \"pong\"}"
    echo "  ext2 | SUCCESS => {\"changed\": false, \"ping\": \"pong\"}"
    echo

    echo "  Step 4: Create a playbook named users.yml to manage local users and groups."
    read -p "$PROMPT" cmd4
    echo
    if [[ "$cmd4" != "nano users.yml" && "$cmd4" != "vim users.yml" && "$cmd4" != "vi users.yml" && "$cmd4" != "cat > users.yml" ]]; then
        print_error "Incorrect. Try again."
        print_info "Expected: nano users.yml  (or vim/vi users.yml, or cat > users.yml)"
        read -p "Press Enter to try again..." _
        continue
    fi

    echo "  --- users.yml ---"
    echo "  ---"
    echo "  - name: Manage local users on external systems"
    echo "    hosts: external"
    echo "    become: true"
    echo
    echo "    tasks:"
    echo "      - name: Ensure ops group exists"
    echo "        group:"
    echo "          name: ops"
    echo "          state: present"
    echo
    echo "      - name: Ensure dev1 user exists"
    echo "        user:"
    echo "          name: dev1"
    echo "          groups: ops"
    echo "          append: yes"
    echo "          shell: /bin/bash"
    echo "          state: present"
    echo "          create_home: yes"
    echo
    echo "      - name: Ensure dev2 user exists"
    echo "        user:"
    echo "          name: dev2"
    echo "          groups: ops"
    echo "          append: yes"
    echo "          shell: /bin/bash"
    echo "          state: present"
    echo "          create_home: yes"
    echo

    echo "  Step 5: Syntax-check the playbook."
    read -p "$PROMPT" cmd5
    echo
    if [[ "$cmd5" != "ansible-playbook -i hosts.ini users.yml --syntax-check" && \
          "$cmd5" != "ansible-playbook --syntax-check -i hosts.ini users.yml" ]]; then
        print_error "Incorrect. Try again."
        print_info "Expected: ansible-playbook -i hosts.ini users.yml --syntax-check"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  playbook: users.yml"
    echo

    echo "  Step 6: Run the playbook using privilege escalation."
    read -p "$PROMPT" cmd6
    echo
    if [[ "$cmd6" != "ansible-playbook -i hosts.ini users.yml -b" && \
          "$cmd6" != "ansible-playbook -i hosts.ini users.yml --become" && \
          "$cmd6" != "sudo ansible-playbook -i hosts.ini users.yml" ]]; then
        print_error "Incorrect. Try again."
        print_info "Expected: ansible-playbook -i hosts.ini users.yml -b"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  PLAY [external] ********************************************************************"
    echo
    echo "  TASK [Gathering Facts] **************************************************************"
    echo "  ok: [ext1]"
    echo "  ok: [ext2]"
    echo
    echo "  TASK [Ensure ops group exists] ******************************************************"
    echo "  changed: [ext1]"
    echo "  changed: [ext2]"
    echo
    echo "  TASK [Ensure dev1 exists] ***********************************************************"
    echo "  changed: [ext1]"
    echo "  changed: [ext2]"
    echo
    echo "  TASK [Ensure dev2 exists] ***********************************************************"
    echo "  changed: [ext1]"
    echo "  changed: [ext2]"
    echo
    echo "  TASK [Ensure ops group membership] **************************************************"
    echo "  changed: [ext1]"
    echo "  changed: [ext2]"
    echo
    echo "  PLAY RECAP ***************************************************************************"
    echo "  ext1 : ok=5 changed=4 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0"
    echo "  ext2 : ok=5 changed=4 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0"
    echo

    echo "  Step 7: Re-run the playbook to confirm idempotency (should show mostly ok= and changed=0)."
    read -p "$PROMPT" cmd7
    echo
    if [[ "$cmd7" != "ansible-playbook -i hosts.ini users.yml -b" && \
          "$cmd7" != "ansible-playbook -i hosts.ini users.yml --become" && \
          "$cmd7" != "sudo ansible-playbook -i hosts.ini users.yml" ]]; then
        print_error "Incorrect. Try again."
        print_info "Expected: ansible-playbook -i hosts.ini users.yml -b"
        read -p "Press Enter to try again..." _
        continue
    fi
    echo "  PLAY [external] ********************************************************************"
    echo
    echo "  TASK [Gathering Facts] **************************************************************"
    echo "  ok: [ext1]"
    echo "  ok: [ext2]"
    echo
    echo "  TASK [Ensure ops group exists] ******************************************************"
    echo "  ok: [ext1]"
    echo "  ok: [ext2]"
    echo
    echo "  TASK [Ensure dev1 exists] ***********************************************************"
    echo "  ok: [ext1]"
    echo "  ok: [ext2]"
    echo
    echo "  TASK [Ensure dev2 exists] ***********************************************************"
    echo "  ok: [ext1]"
    echo "  ok: [ext2]"
    echo
    echo "  TASK [Ensure ops group membership] **************************************************"
    echo "  ok: [ext1]"
    echo "  ok: [ext2]"
    echo
    echo "  PLAY RECAP ***************************************************************************"
    echo "  ext1 : ok=5 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0"
    echo "  ext2 : ok=5 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0"
    echo

    echo "  Step 8: Verify on one host that users and group exist."
    read -p "$PROMPT" cmd8
    echo
    if [[ "$cmd8" != "ansible ext1 -i hosts.ini -b -m command -a 'id dev1'" && \
          "$cmd8" != "ansible ext1 -i hosts.ini --become -m command -a 'id dev1'" && \
          "$cmd8" != "ansible ext2 -i hosts.ini -b -m command -a 'getent group ops'" && \
          "$cmd8" != "ansible ext2 -i hosts.ini --become -m command -a 'getent group ops'" ]]; then
        print_error "Incorrect. Try again."
        print_info "Expected one of the example ad-hoc commands."
        read -p "Press Enter to try again..." _
        continue
    fi
    if [[ "$cmd8" == *"id dev1"* ]]; then
        echo "  ext1 | CHANGED | rc=0 >>"
        echo "  uid=1001(dev1) gid=1001(dev1) groups=1001(dev1),1003(ops)"
    else
        echo "  ext2 | CHANGED | rc=0 >>"
        echo "  ops:x:1003:dev1,dev2"
    fi
    echo

    print_success "Nice work!"
    print_info "You built an inventory, validated connectivity, wrote a user-management playbook,"
    print_info "ran it with privilege escalation, and confirmed idempotency."
    print_info "You earned $LAB_XP XP for completing this lab."
    award_xp $LAB_XP

    XP=$(jq '.XP' "$SAVE_JSON"); LEVEL=$(jq '.LEVEL' "$SAVE_JSON"); export XP; export LEVEL
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