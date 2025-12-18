#!/bin/bash

# Lab 254: Generate RSA SSH keypair, copy pubkey to client, login — SIMULATED & SAFE
# SAFETY: Validates typed commands and prints canned outputs only. No real keys/hosts are touched.
# Output policy: Only show realistic, canned command output. Silent steps print nothing.
# Formatting policy: Every simulated command OUTPUT line begins with exactly two spaces.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 254: SSH keypair → copy → login"
LAB_ID="lab254"
LAB_XP=21340
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated identities/paths/hosts (NOT your real system)
LOCAL_USER="labuser"
LOCAL_HOME="/home/${LOCAL_USER}"
SSH_DIR="${LOCAL_HOME}/.ssh"
KEY_PRIV="${SSH_DIR}/id_rsa"
KEY_PUB="${SSH_DIR}/id_rsa.pub"
KEY_COMMENT="lab254@host"
REMOTE_USER="student"
REMOTE_HOST="client1"
REMOTE_IP="192.0.2.10"   # TEST-NET-1 example address
FINGERPRINT="SHA256:1rV2q1Wg3hZ0m6n8Yz+AbCdEfGhIjKlMnOpQrStUvWx ${KEY_COMMENT}"
DATE_STR="Jul 22 14:05"

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
  center_text "Goal: Generate a 4096-bit RSA keypair, install the public key on ${REMOTE_USER}@${REMOTE_HOST},"
  center_text "and confirm passwordless SSH works — with realistic simulated outputs."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Generate RSA keypair (non-interactive). ssh-keygen prints status.
  draw_lab_ui
  echo "  Step 1: Create a 4096-bit RSA keypair with a helpful comment."
  read -p "  lab@lab254:~$ " cmd1
  if [[ "$cmd1" == "ssh-keygen -t rsa -b 4096 -C \"${KEY_COMMENT}\" -N \"\" -f ${KEY_PRIV}" ]]; then
    echo "  Generating public/private rsa key pair."
    echo "  Your identification has been saved in ${KEY_PRIV}."
    echo "  Your public key has been saved in ${KEY_PUB}."
    echo "  The key fingerprint is:"
    echo "  ${FINGERPRINT}"
    echo "  The key's randomart image is:"
    echo "  +---[RSA 4096]----+"
    echo "  |   . .o=+        |"
    echo "  |  . + oE+.       |"
    echo "  |   = +.+o .      |"
    echo "  |  o * o..o       |"
    echo "  |   o o .S .      |"
    echo "  |    .  . .       |"
    echo "  |                 |"
    echo "  |                 |"
    echo "  |                 |"
    echo "  +----[SHA256]-----+"
  else
    print_error "Hint: Use ssh-keygen with -t rsa -b 4096, set empty passphrase (-N \"\"), and -f ${KEY_PRIV}."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 2: Display the public key (typical preview before copying)
  echo "  Step 2: Show the public key you’ll install on the remote host."
  read -p "  lab@lab254:~$ " cmd2
  if [[ "$cmd2" == "cat ${KEY_PUB}" ]]; then
    echo "  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9cYwzVg0n+2YgVnGg1vYgH3oU0yX8s9qf6y8zq8rZqWw3l1z9q3Sg0u4V8yH7z3P+T0p6m7k3t5k2a9iQF8kz5VwqU5w2QmR6r4K9vOZl3eYx4b9d2g1c0mJpZb6lP7aNwqJp2m4QY3hQ2+uJmW0cZfOqv3J0m2b4y6gI4hZ ${KEY_COMMENT}"
  else
    print_error "Hint: Use cat ${KEY_PUB} to view the line you’ll copy."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 3: Install the public key on remote host with ssh-copy-id
  echo "  Step 3: Copy the public key to ${REMOTE_USER}@${REMOTE_HOST}."
  read -p "  lab@lab254:~$ " cmd3
  if [[ "$cmd3" == "ssh-copy-id -i ${KEY_PUB} ${REMOTE_USER}@${REMOTE_HOST}" || "$cmd3" == "ssh-copy-id ${REMOTE_USER}@${REMOTE_HOST}" ]]; then
    echo "  /usr/bin/ssh-copy-id: INFO: Source of key(s): \"${KEY_PUB}\""
    echo "  The authenticity of host '${REMOTE_HOST} (${REMOTE_IP})' can't be established."
    echo "  ECDSA key fingerprint is SHA256:AbCdEfGhIjKlMnOpQrStUvWxYz0123456789abcd."
    echo "  Are you sure you want to continue connecting (yes/no/[fingerprint])? yes"
    echo "  /usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed"
    echo "  ${REMOTE_USER}@${REMOTE_HOST}'s password: "
    echo "  Number of key(s) added: 1"
    echo "  Now try logging into the machine, with:   \"ssh ${REMOTE_USER}@${REMOTE_HOST}\""
    echo "  and check to make sure that only the key(s) you wanted were added."
  else
    print_error "Hint: Use ssh-copy-id (optionally with -i ${KEY_PUB}) to install your key."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 4: Test passwordless SSH login
  echo "  Step 4: Verify that SSH works without a password prompt."
  read -p "  lab@lab254:~$ " cmd4
  if [[ "$cmd4" == "ssh ${REMOTE_USER}@${REMOTE_HOST} hostname" ]]; then
    echo "  ${REMOTE_HOST}"
  elif [[ "$cmd4" == "ssh ${REMOTE_USER}@${REMOTE_HOST}" ]]; then
    echo "  Last login: ${DATE_STR} from 192.0.2.50"
    echo "  ${REMOTE_USER}@${REMOTE_HOST}:~$ exit"
    echo "  logout"
    echo "  Connection to ${REMOTE_HOST} closed."
  else
    print_error "Hint: Try ssh ${REMOTE_USER}@${REMOTE_HOST} (or run a simple remote command like hostname)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 5 (optional): Show that the key line exists remotely (authorized_keys)
  echo "  Step 5 (optional): Confirm the key is present in authorized_keys."
  read -p "  lab@lab254:~$ " cmd5
  if [[ "$cmd5" == "ssh ${REMOTE_USER}@${REMOTE_HOST} 'tail -n 1 ~/.ssh/authorized_keys'" || "$cmd5" == "" ]]; then
    [[ -n "$cmd5" ]] && echo "  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9cYwzVg0n+2YgVnGg1vYgH3oU0yX8s9qf6y8zq8rZqWw3l1z9q3Sg0u4V8yH7z3P+T0p6m7k3t5k2a9iQF8kz5VwqU5w2QmR6r4K9vOZl3eYx4b9d2g1c0mJpZb6lP7aNwqJp2m4QY3hQ2+uJmW0cZfOqv3J0m2b4y6gI4hZ ${KEY_COMMENT}"
  else
    print_error "Hint: You can remotely view ~/.ssh/authorized_keys (or press Enter to skip)."
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  print_success "Great job! You generated an RSA keypair, installed the public key on ${REMOTE_HOST}, and verified SSH login (simulated)."
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
