#!/bin/bash

# Lab 312: LPIC-1 Ports Not Covered in Lab 311 (Plus Acronyms) – Objective 109.1
# Focus: Additional well-known TCP/UDP ports and the meanings of their service acronyms.
# Examples include: FTP-Data(20), Telnet(23), DHCP(67/68), TFTP(69/udp), SNMP(161/162),
# Syslog(514/tcp|udp), LDAPS(636), IMAPS(993), POP3S(995), SMTPS(465), Submission(587),
# NetBIOS(137–139), SMB/CIFS(445), NFS(2049), RPC/portmapper(111), Kerberos(88).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 312: LPIC-1 Ports (Set 2) & Acronyms"
LAB_ID="lab312"
LAB_XP=32000
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
  center_text "Drill additional LPIC-1 ports and expand the service acronyms."
  echo
  center_text "Press Enter to begin..."
  read _

  draw_lab_ui

  echo "  Step 1: Provide the TCP port used for FTP data channel."
  read -p "  lab@lab312:~$ " cmd1
  echo
  [[ "$cmd1" != "20" ]] && {
    print_error "Incorrect. Try again."
    read -p "Press Enter to retry..." _
    continue
  }

  echo "  Step 2: Query the services database for Telnet entries."
  read -p "  lab@lab312:~$ " cmd2
  echo
  [[ "$cmd2" != "grep -i '^telnet' /etc/services" && "$cmd2" != "grep -i telnet /etc/services" ]] && {
    print_error "Incorrect. Try again."
    read -p "Press Enter to retry..." _
    continue
  }
  echo "  telnet          23/tcp                 # Telnet"
  echo

  echo "  Step 3: What does Telnet stand for?"
  read -p "  lab@lab312:~$ " cmd3
  echo
  [[ "$cmd3" != "Telecommunication Network" && "$cmd3" != "telecommunication network" && "$cmd3" != "Teletype Network" && "$cmd3" != "teletype network" ]] && {
    print_error "Common expansions are 'Telecommunication Network' or 'Teletype Network'. Try again."
    read -p "Press Enter to retry..." _
    continue
  }

  echo "  Step 4: Provide the UDP port used by TFTP."
  read -p "  lab@lab312:~$ " cmd4
  echo
  [[ "$cmd4" != "69" ]] && {
    print_error "Incorrect. Try again."
    read -p "Press Enter to retry..." _
    continue
  }

  echo "  Step 5: What does TFTP stand for?"
  read -p "  lab@lab312:~$ " cmd5
  echo
  [[ "$cmd5" != "Trivial File Transfer Protocol" && "$cmd5" != "trivial file transfer protocol" ]] && {
    print_error "Incorrect. Try again."
    read -p "Press Enter to retry..." _
    continue
  }

  echo "  Step 6: Provide the server and client UDP ports used by DHCP."
  read -p "  lab@lab312:~$ " cmd6
  echo
  [[ "$cmd6" != "67,68" && "$cmd6" != "67 and 68" ]] && {
    print_error "Incorrect. Try again."
    read -p "Press Enter to retry..." _
    continue
  }

  echo "  Step 7: What does DHCP stand for?"
  read -p "  lab@lab312:~$ " cmd7
  echo
  [[ "$cmd7" != "Dynamic Host Configuration Protocol" && "$cmd7" != "dynamic host configuration protocol" ]] && {
    print_error "Incorrect. Try again."
    read -p "Press Enter to retry..." _
    continue
  }

  echo "  Step 8: Provide the UDP port used by SNMP agents for queries."
  read -p "  lab@lab312:~$ " cmd8
  echo
  [[ "$cmd8" != "161" ]] && {
    print_error "Incorrect. Try again."
    read -p "Press Enter to retry..." _
    continue
  }

  echo "  Step 9: Provide the UDP port used by SNMP traps."
  read -p "  lab@lab312:~$ " cmd9
  echo
  [[ "$cmd9" != "162" ]] && {
    print_error "Incorrect. Try again."
    read -p "Press Enter to retry..." _
    continue
  }

  echo "  Step 10: What does SNMP stand for?"
  read -p "  lab@lab312:~$ " cmd10
  echo
  [[ "$cmd10" != "Simple Network Management Protocol" && "$cmd10" != "simple network management protocol" ]] && {
    print_error "Incorrect. Try again."
    read -p "Press Enter to retry..." _
    continue
  }

  echo "  Step 11: Search the mapping file for syslog-related entries."
  read -p "  lab@lab312:~$ " cmd11
  echo
  [[ "$cmd11" != "grep -i '^syslog|^shell' /etc/services" && "$cmd11" != "grep -i syslog /etc/services" ]] && {
    print_error "Incorrect. Try again."
    read -p "Press Enter to retry..." _
    continue
  }
  echo "  syslog          514/udp"
  echo "  shell           514/tcp                 # remote shell"
  echo

  echo "  Step 12: Provide the port used by LDAPS."
  read -p "  lab@lab312:~$ " cmd12
  echo
  [[ "$cmd12" != "636" ]] && {
    print_error "Incorrect. Try again."
    read -p "Press Enter to retry..." _
    continue
  }

  echo "  Step 13: Expand the acronym LDAPS."
  read -p "  lab@lab312:~$ " cmd13
  echo
  [[ "$cmd13" != "LDAP over SSL/TLS" && "$cmd13" != "ldap over ssl/tls" && "$cmd13" != "Lightweight Directory Access Protocol over SSL/TLS" && "$cmd13" != "lightweight directory access protocol over ssl/tls" ]] && {
    print_error "Incorrect. Try again."
    read -p "Press Enter to retry..." _
    continue
  }

  echo "  Step 14: Provide the ports used by IMAPS and POP3S."
  read -p "  lab@lab312:~$ " cmd14
  echo
  [[ "$cmd14" != "993,995" && "$cmd14" != "993 and 995" ]] && {
    print_error "Incorrect. Try again."
    read -p "Press Enter to retry..." _
    continue
  }

  echo "  Step 15: Provide the TCP port commonly used for SMTP submission."
  read -p "  lab@lab312:~$ " cmd15
  echo
  [[ "$cmd15" != "587" ]] && {
    print_error "Incorrect. Try again."
    read -p "Press Enter to retry..." _
    continue
  }

  echo "  Step 16: Search for NetBIOS service entries in the mapping file."
  read -p "  lab@lab312:~$ " cmd16
  echo
  [[ "$cmd16" != "grep -i netbios /etc/services" ]] && {
    print_error "Incorrect. Try again."
    read -p "Press Enter to retry..." _
    continue
  }
  echo "  netbios-ns      137/udp"
  echo "  netbios-dgram   138/udp"
  echo "  netbios-ssn     139/tcp"
  echo

  echo "  Step 17: What does NetBIOS stand for?"
  read -p "  lab@lab312:~$ " cmd17
  echo
  [[ "$cmd17" != "Network Basic Input/Output System" && "$cmd17" != "network basic input/output system" ]] && {
    print_error "Incorrect. Try again."
    read -p "Press Enter to retry..." _
    continue
  }

  echo "  Step 18: Provide the TCP port used by SMB/CIFS over TCP/IP."
  read -p "  lab@lab312:~$ " cmd18
  echo
  [[ "$cmd18" != "445" ]] && {
    print_error "Incorrect. Try again."
    read -p "Press Enter to retry..." _
    continue
  }

  echo "  Step 19: Provide the TCP/UDP port used by NFS server."
  read -p "  lab@lab312:~$ " cmd19
  echo
  [[ "$cmd19" != "2049" ]] && {
    print_error "Incorrect. Try again."
    read -p "Press Enter to retry..." _
    continue
  }

  echo "  Step 20: Provide the port used by the RPC portmapper."
  read -p "  lab@lab312:~$ " cmd20
  echo
  [[ "$cmd20" != "111" ]] && {
    print_error "Incorrect. Try again."
    read -p "Press Enter to retry..." _
    continue
  }

  echo "  Step 21: Provide the TCP/UDP port used by Kerberos."
  read -p "  lab@lab312:~$ " cmd21
  echo
  [[ "$cmd21" != "88" ]] && {
    print_error "Incorrect. Try again."
    read -p "Press Enter to retry..." _
    continue
  }

  echo "  Step 22: Expand the acronym SMB."
  read -p "  lab@lab312:~$ " cmd22
  echo
  [[ "$cmd22" != "Server Message Block" && "$cmd22" != "server message block" ]] && {
    print_error "Incorrect. Try again."
    read -p "Press Enter to retry..." _
    continue
  }

  echo "  Step 23: Expand the acronym NFS."
  read -p "  lab@lab312:~$ " cmd23
  echo
  [[ "$cmd23" != "Network File System" && "$cmd23" != "network file system" ]] && {
    print_error "Incorrect. Try again."
    read -p "Press Enter to retry..." _
    continue
  }

  echo "  Step 24: Expand the acronym RPC."
  read -p "  lab@lab312:~$ " cmd24
  echo
  [[ "$cmd24" != "Remote Procedure Call" && "$cmd24" != "remote procedure call" ]] && {
    print_error "Incorrect. Try again."
    read -p "Press Enter to retry..." _
    continue
  }

  print_success "Excellent work!"
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
