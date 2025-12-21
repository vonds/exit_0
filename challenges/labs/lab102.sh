#!/bin/bash

# Lab 102: Managing Dynamic Inventories in Ansible

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 102: Managing Dynamic Inventories in Ansible"
LAB_ID="lab102"
LAB_XP=4750
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
    center_text "Scenario: You want Ansible to dynamically discover target hosts"
    center_text "from sources like scripts, clouds, or container orchestration systems."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Create a Python script to simulate a dynamic inventory source."
    read -p "  lab@lpic-lab102:~$ " cmd1
    echo
    [[ "$cmd1" != "nano dyn_inventory.py" && "$cmd1" != "vim dyn_inventory.py" ]] && {
        print_error "Incorrect. Use: nano dyn_inventory.py"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Script content should include:"
    echo '  #!/usr/bin/env python3'
    echo '  import json'
    echo '  print(json.dumps({'
    echo '    "web": { "hosts": ["web1.local", "web2.local"] },'
    echo '    "_meta": { "hostvars": {} }'
    echo '  }))'
    echo

    echo "  Step 2: Make the inventory script executable."
    read -p "  lab@lpic-lab102:~$ " cmd2
    echo
    [[ "$cmd2" != "chmod +x dyn_inventory.py" ]] && {
        print_error "Incorrect. Use: chmod +x dyn_inventory.py"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  chmod: changing permissions of 'dyn_inventory.py': 1000:1000"
    echo

    echo "  Step 3: Query the dynamic inventory using ansible-inventory."
    read -p "  lab@lpic-lab102:~$ " cmd3
    echo
    [[ "$cmd3" != "ansible-inventory -i dyn_inventory.py --list" ]] && {
        print_error "Incorrect. Use: ansible-inventory -i dyn_inventory.py --list"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  {"
    echo "    \"_meta\": {"
    echo "      \"hostvars\": {}"
    echo "    },"
    echo "    \"all\": {"
    echo "      \"children\": ["
    echo "        \"ungrouped\","
    echo "        \"web\""
    echo "      ]"
    echo "    },"
    echo "    \"web\": {"
    echo "      \"hosts\": ["
    echo "        \"web1.local\","
    echo "        \"web2.local\""
    echo "      ]"
    echo "    }"
    echo "  }"
    echo

    echo "  Step 4: Create a playbook to target the dynamic 'web' group."
    read -p "  lab@lpic-lab102:~$ " cmd4
    echo
    [[ "$cmd4" != "nano dyn_playbook.yml" && "$cmd4" != "vim dyn_playbook.yml" ]] && {
        print_error "Incorrect. Use: nano dyn_playbook.yml"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Sample content:"
    echo "  - hosts: web"
    echo "    gather_facts: false"
    echo "    tasks:"
    echo "      - name: Ping web group hosts"
    echo "        ping:"
    echo

    echo "  Step 5: Run the playbook using the dynamic inventory script."
    read -p "  lab@lpic-lab102:~$ " cmd5
    echo
    [[ "$cmd5" != "ansible-playbook -i dyn_inventory.py dyn_playbook.yml" ]] && {
        print_error "Incorrect. Use: ansible-playbook -i dyn_inventory.py dyn_playbook.yml"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  PLAY [web] *********************************************************************"
    echo
    echo "  TASK [Ping web group hosts] ****************************************************"
    echo "  ok: [web1.local] => {"
    echo "      \"ansible_facts\": {},"
    echo "      \"changed\": false,"
    echo "      \"ping\": \"pong\""
    echo "  }"
    echo "  ok: [web2.local] => {"
    echo "      \"ansible_facts\": {},"
    echo "      \"changed\": false,"
    echo "      \"ping\": \"pong\""
    echo "  }"
    echo
    echo "  PLAY RECAP *********************************************************************"
    echo "  web1.local                 : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0"
    echo "  web2.local                 : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0"
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
