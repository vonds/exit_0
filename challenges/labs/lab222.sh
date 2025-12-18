#!/bin/bash

# Lab 222: AutoFS LDAP home dir mount (ldapuser2 only) — SIMULATED & SAFE
# SAFETY: This lab validates typed commands and prints canned outputs only.
#         No real LDAP, autofs, mounts, or config files are changed.
# Output policy: Show only realistic, canned command output. Silent steps print nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh"  || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh"  || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 222: AutoFS LDAP Home (ldapuser2)"
LAB_ID="lab222"
LAB_XP=24000
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"
[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

# Simulated parameters/resources (RFC 5737 test IP space)
LDAP_URI="ldap://ldap.example.com"
LDAP_BASE="dc=example,dc=com"
LDAP_AUTO_OU="ou=auto.home,${LDAP_BASE}"
NFS_SERVER="192.0.2.12"
AUTOFS_HOME="/home"
LDAP_KEY="ldapuser2"               # Only this user has an LDAP autofs entry
MNT_PATH="${AUTOFS_HOME}/${LDAP_KEY}"

# Simulated config files (stand-ins for real ones)
AUTO_MASTER_SIM="/tmp/auto.master.lab222"
AUTOFS_CONF_SIM="/tmp/autofs.conf.lab222"

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
  center_text "Goal: Configure AutoFS to mount ${MNT_PATH} on demand from ${NFS_SERVER} via an LDAP map entry."
  center_text "Only '${LDAP_KEY}' should resolve; other names under /home should not auto-mount."
  echo
  center_text "Press Enter to begin..."
  read _

  # Step 1: Verify autofs installed (SIMULATED)
  draw_lab_ui
  echo "  Step 1: Check that autofs is installed."
  echo "          Expected: rpm -q autofs   (RHEL-ish)   OR   dpkg -l autofs   (Debian/Ubuntu)"
  read -p "  lab@lab222:~$ " cmd1
  if [[ "$cmd1" == "rpm -q autofs" ]]; then
    echo "autofs-5.1.8-1.el9.x86_64"
  elif [[ "$cmd1" == "dpkg -l autofs" ]]; then
    echo "Desired=Unknown/Install/Remove/Purge/Hold"
    echo "| Status=Not/Inst/Conf-files/Unpacked/halF-conf/Half-inst/trig-aWait/Trig-pend"
    echo "|/ Err?=(none)/Reinst-required (Status,Err: uppercase=bad)"
    echo "ii  autofs  5.1.8-1ubuntu1  amd64  kernel-based automounter for Linux"
  else
    print_error "Use either: rpm -q autofs   OR   dpkg -l autofs"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 2: Verify LDAP client utilities (SIMULATED)
  echo "  Step 2: Check LDAP client tools."
  echo "          Expected: rpm -q openldap-clients   OR   dpkg -l ldap-utils"
  read -p "  lab@lab222:~$ " cmd2
  if [[ "$cmd2" == "rpm -q openldap-clients" ]]; then
    echo "openldap-clients-2.6.6-1.el9.x86_64"
  elif [[ "$cmd2" == "dpkg -l ldap-utils" ]]; then
    echo "Desired=Unknown/Install/Remove/Purge/Hold"
    echo "| Status=Not/Inst/Conf-files/Unpacked/halF-conf/Half-inst/trig-aWait/Trig-pend"
    echo "|/ Err?=(none)/Reinst-required (Status,Err: uppercase=bad)"
    echo "ii  ldap-utils  2.5.16+dfsg-0ubuntu1  amd64  OpenLDAP utilities"
  else
    print_error "Use either: rpm -q openldap-clients   OR   dpkg -l ldap-utils"
    read -p "Press Enter to try again..." _
    continue
  fi
  echo

  # Step 3: Configure autofs LDAP settings (SIMULATED autofs.conf)
  echo "  Step 3: Write (simulated) /etc/autofs.conf LDAP section."
  echo "          Expected:"
  echo "            cat <<'EOF' | sudo tee $AUTOFS_CONF_SIM"
  echo "            [ldap]"
  echo "            ldap_uri = $LDAP_URI"
  echo "            search_base = $LDAP_BASE"
  echo "            schema = rfc2307"
  echo "            EOF"
  read -p "  lab@lab222:~$ " cmd3a
  [[ "$cmd3a" != "cat <<'EOF' | sudo tee /tmp/autofs.conf.lab222" ]] && { print_error "Start the here-doc exactly as shown."; read -p "Press Enter to try again..." _; continue; }
  read -r line; [[ "$line" != "[ldap]" ]] && { print_error "Missing [ldap]"; read -p "Press Enter to try again..." _; continue; }
  read -r line; [[ "$line" != "ldap_uri = ldap://ldap.example.com" ]] && { print_error "ldap_uri line mismatch"; read -p "Press Enter to try again..." _; continue; }
  read -r line; [[ "$line" != "search_base = dc=example,dc=com" ]] && { print_error "search_base line mismatch"; read -p "Press Enter to try again..." _; continue; }
  read -r line; [[ "$line" != "schema = rfc2307" ]] && { print_error "schema line mismatch"; read -p "Press Enter to try again..." _; continue; }
  read -p "" eof_line
  [[ "$eof_line" != "EOF" ]] && { print_error "Terminate with EOF"; read -p "Press Enter to try again..." _; continue; }
  echo "[ldap]"
  echo "ldap_uri = ldap://ldap.example.com"
  echo "search_base = dc=example,dc=com"
  echo "schema = rfc2307"
  echo

  # Step 4: Add a master map entry pointing to LDAP (SIMULATED)
  echo "  Step 4: Point the master map at the LDAP subtree for homes."
  echo "          Expected: echo '/home ldap:${LDAP_AUTO_OU} --timeout=300' | sudo tee -a $AUTO_MASTER_SIM"
  read -p "  lab@lab222:~$ " cmd4
  [[ "$cmd4" != "echo '/home ldap:ou=auto.home,dc=example,dc=com --timeout=300' | sudo tee -a /tmp/auto.master.lab222" ]] && {
    print_error "Use exactly: echo '/home ldap:ou=auto.home,dc=example,dc=com --timeout=300' | sudo tee -a /tmp/auto.master.lab222"
    read -p "Press Enter to try again..." _
    continue
  }
  echo "/home ldap:ou=auto.home,dc=example,dc=com --timeout=300"
  echo

  # Step 5: Verify the LDAP map entry exists for ldapuser2 (SIMULATED)
  echo "  Step 5: Query LDAP for the '${LDAP_KEY}' automount entry."
  echo "          Expected: ldapsearch -x -LLL -H $LDAP_URI -b '$LDAP_AUTO_OU' 'cn=$LDAP_KEY'"
  read -p "  lab@lab222:~$ " cmd5
  [[ "$cmd5" != "ldapsearch -x -LLL -H ldap://ldap.example.com -b 'ou=auto.home,dc=example,dc=com' 'cn=ldapuser2'" ]] && {
    print_error "Use exactly: ldapsearch -x -LLL -H ldap://ldap.example.com -b 'ou=auto.home,dc=example,dc=com' 'cn=ldapuser2'"
    read -p "Press Enter to try again..." _
    continue
  }
  echo "dn: cn=ldapuser2,ou=auto.home,dc=example,dc=com"
  echo "objectClass: automount"
  echo "cn: ldapuser2"
  echo "automountInformation: -rw,soft,_netdev,vers=4 ${NFS_SERVER}:/home/ldapuser2"
  echo

  # Step 6: Enable/start autofs and check status (SIMULATED)
  echo "  Step 6: Enable and start autofs; then check status."
  echo "          Expected: sudo systemctl enable --now autofs"
  read -p "  lab@lab222:~$ " cmd6a
  [[ "$cmd6a" != "sudo systemctl enable --now autofs" ]] && { print_error "Use: sudo systemctl enable --now autofs"; read -p "Press Enter to try again..." _; continue; }
  echo
  echo "          Expected: systemctl status autofs"
  read -p "  lab@lab222:~$ " cmd6b
  [[ "$cmd6b" != "systemctl status autofs" ]] && { print_error "Use: systemctl status autofs"; read -p "Press Enter to try again..." _; continue; }
  echo "  ● autofs.service - Automounts filesystems on demand"
  echo "       Loaded: loaded (/lib/systemd/system/autofs.service; enabled; vendor preset: enabled)"
  echo "       Active: active (running) since Tue 2025-07-22 11:40:02 UTC; 6s ago"
  echo "     Main PID: 2451 (automount)"
  echo "        Tasks: 2 (limit: 32768)"
  echo "       Memory: 2.0M"
  echo "          CPU: 41ms"
  echo "       CGroup: /system.slice/autofs.service"
  echo "               └─2451 /usr/sbin/automount --pid-file /run/autofs.pid"
  echo

  # Step 7: Trigger mount by accessing /home/ldapuser2 (SIMULATED)
  echo "  Step 7: Access ${MNT_PATH} to trigger the automount."
  echo "          Expected: ls -la ${MNT_PATH}"
  read -p "  lab@lab222:~$ " cmd7
  [[ "$cmd7" != "ls -la /home/ldapuser2" ]] && { print_error "Use: ls -la /home/ldapuser2"; read -p "Press Enter to try again..." _; continue; }
  echo "total 28"
  echo "drwxr-xr-x  3 ldapuser2 ldapuser2  4096 Jul 22 11:40 ."
  echo "drwxr-xr-x  6 root      root       4096 Jul 22 11:40 .."
  echo "-rw-------  1 ldapuser2 ldapuser2  1024 Jul 22 11:40 .bash_history"
  echo "-rw-r--r--  1 ldapuser2 ldapuser2   220 Jul 22 11:40 .bash_logout"
  echo "-rw-r--r--  1 ldapuser2 ldapuser2  3771 Jul 22 11:40 .bashrc"
  echo "drwxr-xr-x  2 ldapuser2 ldapuser2  4096 Jul 22 11:40 Documents"
  echo

  # Step 8: Verify mount details (SIMULATED)
  echo "  Step 8: Verify using findmnt and mount."
  echo "          Expected: findmnt -T ${MNT_PATH}"
  read -p "  lab@lab222:~$ " cmd8a
  [[ "$cmd8a" != "findmnt -T /home/ldapuser2" ]] && { print_error "Use: findmnt -T /home/ldapuser2"; read -p "Press Enter to try again..." _; continue; }
  echo "TARGET         SOURCE                    FSTYPE OPTIONS"
  echo "/home/ldapuser2 ${NFS_SERVER}:/home/ldapuser2 nfs4   rw,relatime,vers=4.2,soft,_netdev"
  echo
  echo "          Expected: mount | grep '/home/ldapuser2'"
  read -p "  lab@lab222:~$ " cmd8b
  [[ "$cmd8b" != "mount | grep '/home/ldapuser2'" ]] && { print_error "Use: mount | grep '/home/ldapuser2'"; read -p "Press Enter to try again..." _; continue; }
  echo "${NFS_SERVER}:/home/ldapuser2 on /home/ldapuser2 type nfs4 (rw,relatime,vers=4.2,soft,proto=tcp,timeo=600,retrans=2,sec=sys,_netdev,addr=${NFS_SERVER})"
  echo

  # Step 9: Confirm other names do NOT auto-mount (SIMULATED)
  echo "  Step 9: Try another user home (no LDAP map entry)."
  echo "          Expected: ls -la /home/otheruser"
  read -p "  lab@lab222:~$ " cmd9
  [[ "$cmd9" != "ls -la /home/otheruser" ]] && { print_error "Use: ls -la /home/otheruser"; read -p "Press Enter to try again..." _; continue; }
  echo "ls: cannot access '/home/otheruser': No such file or directory"
  echo

  # Step 10: (Bonus) Show active maps and simulated configs (SIMULATED)
  echo "  Step 10 (bonus): Show active automount maps."
  echo "           Expected: sudo automount -m"
  read -p "  lab@lab222:~$ " cmd10a
  [[ "$cmd10a" != "sudo automount -m" ]] && { print_error "Use: sudo automount -m"; read -p "Press Enter to try again..." _; continue; }
  echo "Mount point: /home"
  echo "    type: indirect (LDAP)"
  echo "    map: ${LDAP_AUTO_OU}"
  echo "    entries:"
  echo "        ${LDAP_KEY} -> -rw,soft,_netdev,vers=4 ${NFS_SERVER}:/home/${LDAP_KEY}"
  echo
  echo "           Review simulated configs."
  echo "           Expected: cat $AUTO_MASTER_SIM"
  read -p "  lab@lab222:~$ " cmd10b
  [[ "$cmd10b" != "cat /tmp/auto.master.lab222" ]] && { print_error "Use: cat /tmp/auto.master.lab222"; read -p "Press Enter to try again..." _; continue; }
  echo "/home ldap:ou=auto.home,dc=example,dc=com --timeout=300"
  echo
  echo "           Expected: cat $AUTOFS_CONF_SIM"
  read -p "  lab@lab222:~$ " cmd10c
  [[ "$cmd10c" != "cat /tmp/autofs.conf.lab222" ]] && { print_error "Use: cat /tmp/autofs.conf.lab222"; read -p "Press Enter to try again..." _; continue; }
  echo "[ldap]"
  echo "ldap_uri = ldap://ldap.example.com"
  echo "search_base = dc=example,dc=com"
  echo "schema = rfc2307"
  echo

  print_success "Nice work! AutoFS via LDAP mounts /home/${LDAP_KEY} on demand and ignores unknown names."
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
