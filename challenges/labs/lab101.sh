#!/bin/bash

# Lab 101: Secure Secrets with Ansible Vault
# RHEL focus: realistic ansible-vault prompts/output, vault header format, playbook run output, and rekey prompts.
# Output style: ALL simulated command output is indented by at least 2 spaces.

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

PROMPT="lab@rhel-lab101:~$ > "

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "Scenario: You need to store secrets (database credentials, tokens) in Ansible"
  center_text "without committing them to Git in plain text."
  echo
  center_text "Press Enter to begin the lab..."
  read _

  draw_lab_ui

  # STEP 1
  echo "  Step 1: Create a new Vault-encrypted file for credentials."
  read -p "  $PROMPT" cmd1
  echo
  [[ "$cmd1" != "ansible-vault create secrets.yml" ]] && {
    print_error "Incorrect. Use: ansible-vault create secrets.yml"
    read -p "Press Enter to try again..." _
    continue
  }
  echo "  New Vault password:"
  echo "  Confirm New Vault password:"
  echo "    [opens editor: /usr/bin/vi]"
  echo
  echo "    --- secrets.yml (plaintext while editing, then encrypted on save) ---"
  echo "    db_user: appuser"
  echo "    db_pass: 'S3cure!ChangeMe'"
  echo "    db_host: 10.10.20.15"
  echo "    ---------------------------------------------------------------"
  echo
  echo "  Encryption successful"
  echo

  # STEP 2
  echo "  Step 2: View the encrypted file on disk (should be Vault 'ciphertext')."
  read -p "  $PROMPT" cmd2
  echo
  [[ "$cmd2" != "cat secrets.yml" ]] && {
    print_error "Incorrect. Use: cat secrets.yml"
    read -p "Press Enter to try again..." _
    continue
  }
  echo "  \$ANSIBLE_VAULT;1.1;AES256"
  echo "  32623833303731326132663561633131393331376634666334633638353735373539343239326664"
  echo "  6231663761623632313763613437386637613763643137370a633534343533393339393536306132"
  echo "  37333861653165306461666533636238633031656634383330316332363532343532326363306639"
  echo "  6164613762653330650a346631343733663036663764643535623839356166616335346530663465"
  echo "  6337"
  echo

  # STEP 3
  echo "  Step 3: Edit the Vault file securely."
  read -p "  $PROMPT" cmd3
  echo
  [[ "$cmd3" != "ansible-vault edit secrets.yml" ]] && {
    print_error "Incorrect. Use: ansible-vault edit secrets.yml"
    read -p "Press Enter to try again..." _
    continue
  }
  echo "  Vault password:"
  echo "    [opens editor: /usr/bin/vi]"
  echo "  Encryption successful"
  echo

  # STEP 4
  echo "  Step 4: View decrypted contents (prints plaintext to terminal)."
  read -p "  $PROMPT" cmd4
  echo
  [[ "$cmd4" != "ansible-vault view secrets.yml" ]] && {
    print_error "Incorrect. Use: ansible-vault view secrets.yml"
    read -p "Press Enter to try again..." _
    continue
  }
  echo "  Vault password:"
  echo "  db_user: appuser"
  echo "  db_pass: 'S3cure!ChangeMe'"
  echo "  db_host: 10.10.20.15"
  echo

  # STEP 5
  echo "  Step 5: Create a playbook that loads secrets.yml via vars_files."
  read -p "  $PROMPT" cmd5
  echo
  [[ "$cmd5" != "nano vault-playbook.yml" && "$cmd5" != "vim vault-playbook.yml" ]] && {
    print_error "Incorrect. Create or open vault-playbook.yml (nano or vim)."
    read -p "Press Enter to try again..." _
    continue
  }
  echo "    [editor saved vault-playbook.yml]"
  echo
  echo "    --- vault-playbook.yml (example) ---"
  echo "    - name: Test vault secrets"
  echo "      hosts: localhost"
  echo "      gather_facts: false"
  echo "      vars_files:"
  echo "        - secrets.yml"
  echo "      tasks:"
  echo "        - name: Show DB connection target"
  echo "          debug:"
  echo "            msg: \"DB={{ db_user }}@{{ db_host }}\""
  echo "    ----------------------------------"
  echo

  # STEP 6
  echo "  Step 6: Run the playbook using --ask-vault-pass."
  read -p "  $PROMPT" cmd6
  echo
  [[ "$cmd6" != "ansible-playbook vault-playbook.yml --ask-vault-pass" ]] && {
    print_error "Incorrect. Use: ansible-playbook vault-playbook.yml --ask-vault-pass"
    read -p "Press Enter to try again..." _
    continue
  }
  echo "  Vault password:"
  echo
  echo "  PLAY [Test vault secrets] ******************************************************"
  echo
  echo "  TASK [Show DB connection target] ***********************************************"
  echo "  ok: [localhost] => {"
  echo "      \"msg\": \"DB=appuser@10.10.20.15\""
  echo "  }"
  echo
  echo "  PLAY RECAP *********************************************************************"
  echo "  localhost                  : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0"
  echo

  # STEP 7
  echo "  Step 7: Rotate the vault password (rekey)."
  read -p "  $PROMPT" cmd7
  echo
  [[ "$cmd7" != "ansible-vault rekey secrets.yml" ]] && {
    print_error "Incorrect. Use: ansible-vault rekey secrets.yml"
    read -p "Press Enter to try again..." _
    continue
  }
  echo "  Vault password:"
  echo "  New Vault password:"
  echo "  Confirm New Vault password:"
  echo "  Rekey successful"
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
