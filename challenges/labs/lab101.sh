#!/bin/bash

# Lab 101: Secure Secrets with Ansible Vault

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 101: Secure Secrets with Ansible Vault"
LAB_ID="lab101"
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
    center_text "Scenario: You want to store secrets (like database credentials)"
    center_text "securely in Ansible without exposing them in plain text."
    echo
    center_text "Press Enter to begin the lab..."
    read _

    draw_lab_ui
    echo "  Step 1: Create a new Ansible Vault-encrypted file for credentials."
    read -p "  lab@lpic-lab101:~$ " cmd1
    echo
    [[ "$cmd1" != "ansible-vault create secrets.yml" ]] && {
        print_error "Incorrect. Use: ansible-vault create secrets.yml"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Vault file created. You can enter credentials inside this file."
    echo "  Example content:"
    echo "  db_user: root"
    echo "  db_pass: secret123"
    echo

    echo "  Step 2: View the encrypted file."
    read -p "  lab@lpic-lab101:~$ " cmd2
    echo
    [[ "$cmd2" != "cat secrets.yml" ]] && {
        print_error "Incorrect. Use: cat secrets.yml to view the encrypted contents"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  You should see encrypted gibberish (AES256)."
    echo

    echo "  Step 3: Edit the file securely using Ansible Vault."
    read -p "  lab@lpic-lab101:~$ " cmd3
    echo
    [[ "$cmd3" != "ansible-vault edit secrets.yml" ]] && {
        print_error "Incorrect. Use: ansible-vault edit secrets.yml"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Now you can safely edit without decrypting manually."
    echo

    echo "  Step 4: Decrypt the file temporarily to view contents."
    read -p "  lab@lpic-lab101:~$ " cmd4
    echo
    [[ "$cmd4" != "ansible-vault view secrets.yml" ]] && {
        print_error "Incorrect. Use: ansible-vault view secrets.yml"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Contents decrypted and printed to terminal."
    echo

    echo "  Step 5: Use the secrets file in a playbook."
    echo "  Ensure secrets.yml is loaded as a vars_file."
    read -p "  lab@lpic-lab101:~$ " cmd5
    echo
    [[ "$cmd5" != "nano vault-playbook.yml" && "$cmd5" != "vim vault-playbook.yml" ]] && {
        print_error "Incorrect. Create or open vault-playbook.yml"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Example playbook:"
    echo "- hosts: localhost"
    echo "  become: yes"
    echo "  vars_files:"
    echo "    - secrets.yml"
    echo "  tasks:"
    echo "    - name: Show DB user"
    echo "      debug:"
    echo "        msg: \"User is {{ db_user }}\""
    echo

    echo "  Step 6: Run the playbook using --ask-vault-pass."
    read -p "  lab@lpic-lab101:~$ " cmd6
    echo
    [[ "$cmd6" != "ansible-playbook vault-playbook.yml --ask-vault-pass" ]] && {
        print_error "Incorrect. Use: ansible-playbook vault-playbook.yml --ask-vault-pass"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Playbook executed with secrets loaded securely."
    echo

    echo "  Step 7: Change the vault password."
    read -p "  lab@lpic-lab101:~$ " cmd7
    echo
    [[ "$cmd7" != "ansible-vault rekey secrets.yml" ]] && {
        print_error "Incorrect. Use: ansible-vault rekey secrets.yml"
        read -p "Press Enter to try again..." _
        continue
    }
    echo "  Vault password has been changed."
    echo

    echo "  Step 8: Optional – encrypt multiple files with --vault-id support."
    echo "  Example: Use separate passwords for dev and prod."
    echo "  vault-dev.yml and vault-prod.yml can be used with:"
    echo "  ansible-playbook site.yml --vault-id dev@prompt --vault-id prod@prompt"
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
