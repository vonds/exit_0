#!/bin/bash

# Lab 477: Rocky Linux 10 — Mock RHCSA Exam (Full Task Chain)
# Focus: archive + text processing, scripting, services, tuned, nice, swap, LVM, Stratis,
# cron, packages, firewall, routing, users/groups/sudoers, containers (Podman), skopeo.
#


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$ROOT_DIR/scripts/ui.sh" || { echo "Failed to source ui.sh"; exit 1; }
source "$ROOT_DIR/scripts/xp.sh" || { echo "Failed to source xp.sh"; exit 1; }

LAB_NAME="Lab 477: Mock RHCSA Exam — Full System Tasks (Rocky 10)"
LAB_ID="lab477"
LAB_XP=47700
LAB_TRACK_FILE="$ROOT_DIR/data/.lab_completions.json"

[ ! -f "$LAB_TRACK_FILE" ] && echo '{}' > "$LAB_TRACK_FILE"

PROMPT="  lab@rhel-lab477:~$ "

draw_lab_ui() {
  clear
  center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
  center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
  echo
  echo
}

record_lab_completion() {
  tmpfile=$(mktemp)
  jq --arg lab "$LAB_ID" '.[$lab] += 1 // 1' "$LAB_TRACK_FILE" > "$tmpfile" && mv "$tmpfile" "$LAB_TRACK_FILE"
}

get_lab_completion_count() {
  jq -r --arg lab "$LAB_ID" '.[$lab] // 0' "$LAB_TRACK_FILE"
}

# Accept a few common equivalents where RHCSA allows flexibility
is_one_of() {
  local got="$1"; shift
  for v in "$@"; do
    [[ "$got" == "$v" ]] && return 0
  done
  return 1
}

while true; do
  draw_lab_ui
  center_title "$LAB_NAME"
  echo
  center_text "Scenario:"
  center_text "You are completing a Rocky Linux 10 mock RHCSA exam."
  center_text "All tasks must be completed using correct admin commands and exact config entries."
  echo
  center_text "Press Enter to begin..."
  read _
  draw_lab_ui

  # ------------------------------------------------------------
  # SECTION A: Archive + grep redirection
  # ------------------------------------------------------------

  echo "  Task 1: Create a compressed archive /home/riley/backup.star.gz from /home/riley/records (all contents)."
  read -p "$PROMPT" cmd1
  echo
  if ! is_one_of "$cmd1" \
      "tar -czf /home/riley/backup.star.gz -C /home/riley records" \
      "sudo tar -czf /home/riley/backup.star.gz -C /home/riley records"; then
    print_error "Incorrect. Use tar to create gzip archive of /home/riley/records into /home/riley/backup.star.gz."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Task 2: Extract lines containing 'passed' from /home/riley/scoreboard into /home/riley/passed.txt."
  read -p "$PROMPT" cmd2
  echo
  if ! is_one_of "$cmd2" \
      "grep passed /home/riley/scoreboard > /home/riley/passed.txt" \
      "grep -i passed /home/riley/scoreboard > /home/riley/passed.txt" \
      "sudo grep passed /home/riley/scoreboard > /home/riley/passed.txt" \
      "sudo grep -i passed /home/riley/scoreboard > /home/riley/passed.txt"; then
    print_error "Incorrect. Use grep + output redirection."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Task 3: Extract lines containing 'failed' from /home/riley/scoreboard into /home/riley/failed.txt."
  read -p "$PROMPT" cmd3
  echo
  if ! is_one_of "$cmd3" \
      "grep failed /home/riley/scoreboard > /home/riley/failed.txt" \
      "grep -i failed /home/riley/scoreboard > /home/riley/failed.txt" \
      "sudo grep failed /home/riley/scoreboard > /home/riley/failed.txt" \
      "sudo grep -i failed /home/riley/scoreboard > /home/riley/failed.txt"; then
    print_error "Incorrect. Use grep + output redirection."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # ------------------------------------------------------------
  # SECTION B: Script 1 — item cleaner
  # ------------------------------------------------------------

  echo "  Task 4: Create /home/riley/asset_cleaner.sh using vim."
  read -p "$PROMPT" cmd4
  echo
  if ! is_one_of "$cmd4" "vim /home/riley/asset_cleaner.sh" "vi /home/riley/asset_cleaner.sh" "sudo vim /home/riley/asset_cleaner.sh" "sudo vi /home/riley/asset_cleaner.sh"; then
    print_error "Incorrect. Open the script file for editing."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (vim opened)"
  echo

  echo "  Task 5: Type the FULL script content exactly as required (then save/exit)."
  echo "          This script must:"
  echo "          - loop through files in /home/riley/items/"
  echo "          - echo \"Cleaning file \$name\" and append to /home/riley/clean.log"
  echo "          - delete each file"
  echo "          Paste the script NOW (single paste; end with an empty line):"
  script1=""
  while IFS= read -r line; do
    [[ -z "$line" ]] && break
    script1+="$line"$'\n'
  done

  expected_script1=$(cat <<'EOF'
#!/bin/bash
for f in /home/riley/items/*; do
  name=$(basename "$f")
  echo "Cleaning file $name" >> /home/riley/clean.log
  rm -f "$f"
done
EOF
)

  if [[ "$script1" != "$expected_script1"$'\n' && "$script1" != "$expected_script1" ]]; then
    print_error "Script content mismatch. Make sure paths, echo text, and log append are exact."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo
  echo "  (save and exit the editor)"
  echo

  echo "  Task 6: Make the script executable."
  read -p "$PROMPT" cmd6
  echo
  if ! is_one_of "$cmd6" "chmod +x /home/riley/asset_cleaner.sh" "sudo chmod +x /home/riley/asset_cleaner.sh"; then
    print_error "Incorrect. Use chmod +x."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Task 7: Run the script."
  read -p "$PROMPT" cmd7
  echo
  if ! is_one_of "$cmd7" "/home/riley/asset_cleaner.sh" "bash /home/riley/asset_cleaner.sh" "sudo /home/riley/asset_cleaner.sh" "sudo bash /home/riley/asset_cleaner.sh"; then
    print_error "Incorrect. Execute the script."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # ------------------------------------------------------------
  # SECTION C: Script 2 — archiver (bzip2, absolute paths, files only)
  # ------------------------------------------------------------

  echo "  Task 8: Create /home/riley/archiver.sh using vim."
  read -p "$PROMPT" cmd8
  echo
  if ! is_one_of "$cmd8" "vim /home/riley/archiver.sh" "vi /home/riley/archiver.sh" "sudo vim /home/riley/archiver.sh" "sudo vi /home/riley/archiver.sh"; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (vim opened)"
  echo

  echo "  Task 9: Type the FULL script content (absolute paths; files only; no /opt/materials directory entry)."
  echo "          Paste the script NOW (single paste; end with an empty line):"
  script2=""
  while IFS= read -r line; do
    [[ -z "$line" ]] && break
    script2+="$line"$'\n'
  done

  expected_script2=$(cat <<'EOF'
#!/bin/bash
tar -cjf /home/riley/asset_backup.tar.bz2 -P /opt/materials/*
EOF
)

  if [[ "$script2" != "$expected_script2"$'\n' && "$script2" != "$expected_script2" ]]; then
    print_error "Script content mismatch. Must use tar -cjf with -P and /opt/materials/*."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo
  echo "  (save and exit the editor)"
  echo

  echo "  Task 10: Make archiver.sh executable."
  read -p "$PROMPT" cmd10
  echo
  if ! is_one_of "$cmd10" "chmod +x /home/riley/archiver.sh" "sudo chmod +x /home/riley/archiver.sh"; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Task 11: Run archiver.sh."
  read -p "$PROMPT" cmd11
  echo
  if ! is_one_of "$cmd11" "/home/riley/archiver.sh" "bash /home/riley/archiver.sh" "sudo /home/riley/archiver.sh" "sudo bash /home/riley/archiver.sh"; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # ------------------------------------------------------------
  # SECTION D: Script 3 — httpd enable check
  # ------------------------------------------------------------

  echo "  Task 12: Create /home/riley/status.sh using vim."
  read -p "$PROMPT" cmd12
  echo
  if ! is_one_of "$cmd12" "vim /home/riley/status.sh" "vi /home/riley/status.sh" "sudo vim /home/riley/status.sh" "sudo vi /home/riley/status.sh"; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (vim opened)"
  echo

  echo "  Task 13: Type the FULL script content exactly as required."
  echo "          Paste the script NOW (single paste; end with an empty line):"
  script3=""
  while IFS= read -r line; do
    [[ -z "$line" ]] && break
    script3+="$line"$'\n'
  done

  expected_script3=$(cat <<'EOF'
#!/bin/bash
if systemctl is-enabled httpd.service >/dev/null 2>&1; then
  echo "httpd.service is enabled."
else
  echo "httpd.service is disabled. Enabling httpd.service."
  sudo systemctl enable httpd.service
fi
EOF
)

  if [[ "$script3" != "$expected_script3"$'\n' && "$script3" != "$expected_script3" ]]; then
    print_error "Script content mismatch. Messages and enable command must match."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo
  echo "  (save and exit the editor)"
  echo

  echo "  Task 14: Make status.sh executable."
  read -p "$PROMPT" cmd14
  echo
  if ! is_one_of "$cmd14" "chmod +x /home/riley/status.sh" "sudo chmod +x /home/riley/status.sh"; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Task 15: Run status.sh."
  read -p "$PROMPT" cmd15
  echo
  if ! is_one_of "$cmd15" "/home/riley/status.sh" "bash /home/riley/status.sh"; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  httpd.service is disabled. Enabling httpd.service."
  echo "  Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service."
  echo

  # ------------------------------------------------------------
  # SECTION E: tuned + default target + renice
  # ------------------------------------------------------------

  echo "  Task 16: Save ONLY the active tuned profile name to /home/riley/active.txt."
  read -p "$PROMPT" cmd16
  echo
  if ! is_one_of "$cmd16" \
      "tuned-adm active | awk '{print \$NF}' > /home/riley/active.txt" \
      "sudo tuned-adm active | awk '{print \$NF}' > /home/riley/active.txt" \
      "tuned-adm active | sed 's/^Current active profile: //' > /home/riley/active.txt" \
      "sudo tuned-adm active | sed 's/^Current active profile: //' > /home/riley/active.txt"; then
    print_error "Incorrect. You must save only the profile name (not the full sentence) into active.txt."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (saved)"
  echo

  echo "  Task 17: Set the active tuned profile to throughput-performance."
  read -p "$PROMPT" cmd17
  echo
  if ! is_one_of "$cmd17" "sudo tuned-adm profile throughput-performance" "tuned-adm profile throughput-performance"; then
    print_error "Incorrect. Use tuned-adm profile throughput-performance."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (profile set)"
  echo

  echo "  Task 18: Save the default systemd target to /home/riley/default.txt."
  read -p "$PROMPT" cmd18
  echo
  if ! is_one_of "$cmd18" "systemctl get-default > /home/riley/default.txt" "sudo systemctl get-default > /home/riley/default.txt"; then
    print_error "Incorrect. Use systemctl get-default with redirection."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (saved)"
  echo

  echo "  Task 19: Set sshd process niceness to 10."
  read -p "$PROMPT" cmd19
  echo
  if ! is_one_of "$cmd19" "sudo renice 10 -p \$(pidof sshd)" "sudo renice -n 10 -p \$(pidof sshd)"; then
    print_error "Incorrect. Use renice on the sshd PID."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  28202 (process ID) old priority 0, new priority 10"
  echo

  # ------------------------------------------------------------
  # SECTION F: Swap file (/swap_file)
  # ------------------------------------------------------------

  echo "  Task 20: Create a 1G file at /swap_file."
  read -p "$PROMPT" cmd20
  echo
  if ! is_one_of "$cmd20" "sudo fallocate -l 1G /swap_file" "sudo dd if=/dev/zero of=/swap_file bs=1M count=1024"; then
    print_error "Incorrect. Use fallocate (preferred) or dd to create a 1G file."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Task 21: Set permissions so root has rw, and group/others have no permissions."
  read -p "$PROMPT" cmd21
  echo
  if ! is_one_of "$cmd21" "sudo chmod 600 /swap_file"; then
    print_error "Incorrect. Use chmod 600 /swap_file."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Task 22: Make the file swap space."
  read -p "$PROMPT" cmd22
  echo
  if ! is_one_of "$cmd22" "sudo mkswap /swap_file"; then
    print_error "Incorrect. Use mkswap /swap_file."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Setting up swapspace version 1, size = 1024 MiB (1073737728 bytes)"
  echo "  no label, UUID=6f8d0b9a-0c54-4f50-aef9-bae9d2f51a1c"
  echo

  echo "  Task 23: Activate the swap space."
  read -p "$PROMPT" cmd23
  echo
  if ! is_one_of "$cmd23" "sudo swapon /swap_file"; then
    print_error "Incorrect. Use swapon /swap_file."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Task 24: Edit /etc/fstab and add the swap entry."
  read -p "$PROMPT" cmd24
  echo
  if ! is_one_of "$cmd24" "sudo vim /etc/fstab" "sudo vi /etc/fstab"; then
    print_error "Incorrect. Open /etc/fstab in an editor."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (vim opened)"
  echo

  echo "  Type the swap line EXACTLY (then save/exit):"
  read -p "  > " fstab_swap
  if [[ "$fstab_swap" != "/swap_file none swap defaults 0 0" ]]; then
    print_error "Incorrect fstab swap line."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo
  echo "  (saved)"
  echo

  # ------------------------------------------------------------
  # SECTION G: Partition removal + LVM + XFS + fstab mount
  # ------------------------------------------------------------

  echo "  Task 25: Delete partition /dev/vdb1 using a non-interactive command."
  read -p "$PROMPT" cmd25
  echo
  if ! is_one_of "$cmd25" "sudo parted -s /dev/vdb rm 1"; then
    print_error "Incorrect. Use: sudo parted -s /dev/vdb rm 1"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Task 26: Create a physical volume on /dev/vdb."
  read -p "$PROMPT" cmd26
  echo
  if [[ "$cmd26" != "sudo pvcreate /dev/vdb" ]]; then
    print_error "Incorrect. Use pvcreate /dev/vdb."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Physical volume \"/dev/vdb\" successfully created."
  echo

  echo "  Task 27: Create volume group volume1 with /dev/vdb."
  read -p "$PROMPT" cmd27
  echo
  if [[ "$cmd27" != "sudo vgcreate volume1 /dev/vdb" ]]; then
    print_error "Incorrect. Use vgcreate volume1 /dev/vdb."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Volume group \"volume1\" successfully created"
  echo

  echo "  Task 28: Create logical volume storage using 100%FREE in volume1."
  read -p "$PROMPT" cmd28
  echo
  if [[ "$cmd28" != "sudo lvcreate -n storage -l 100%FREE volume1" ]]; then
    print_error "Incorrect. Use lvcreate -n storage -l 100%FREE volume1."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Logical volume \"storage\" created."
  echo

  echo "  Task 29: Create an XFS filesystem on /dev/volume1/storage."
  read -p "$PROMPT" cmd29
  echo
  if [[ "$cmd29" != "sudo mkfs.xfs /dev/volume1/storage" ]]; then
    print_error "Incorrect. Use mkfs.xfs /dev/volume1/storage."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  meta-data=/dev/mapper/volume1-storage isize=512    agcount=4, agsize=..."
  echo "  data     =                       bsize=4096   blocks=..., imaxpct=25"
  echo "  naming   =version 2              bsize=4096   ascii-ci=0, ftype=1"
  echo "  log      =internal log           bsize=4096   blocks=..., version=2"
  echo "  realtime =none                   extsz=4096   blocks=0, rtextents=0"
  echo

  echo "  Task 30: Create mount point /storage."
  read -p "$PROMPT" cmd30
  echo
  if [[ "$cmd30" != "sudo mkdir -p /storage" ]]; then
    print_error "Incorrect. Use mkdir -p /storage."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Task 31: Edit /etc/fstab and add the XFS mount entry."
  read -p "$PROMPT" cmd31
  echo
  if ! is_one_of "$cmd31" "sudo vim /etc/fstab" "sudo vi /etc/fstab"; then
    print_error "Incorrect. Open /etc/fstab."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (vim opened)"
  echo

  echo "  Type the XFS mount line EXACTLY (then save/exit):"
  read -p "  > " fstab_xfs
  if [[ "$fstab_xfs" != "/dev/volume1/storage /storage xfs defaults 0 0" ]]; then
    print_error "Incorrect fstab XFS line."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo
  echo "  (saved)"
  echo

  echo "  Task 32: Mount the filesystem now."
  read -p "$PROMPT" cmd32
  echo
  if ! is_one_of "$cmd32" "sudo mount /storage" "sudo mount -a"; then
    print_error "Incorrect. Use mount /storage (or mount -a)."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # ------------------------------------------------------------
  # SECTION H: Stratis pool + fs + fstab options + mount
  # ------------------------------------------------------------

  echo "  Task 33: Create a Stratis pool named starpool on /dev/vde."
  read -p "$PROMPT" cmd33
  echo
  if [[ "$cmd33" != "sudo stratis pool create starpool /dev/vde" ]]; then
    print_error "Incorrect. Use stratis pool create starpool /dev/vde."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Task 34: Create a Stratis filesystem named starpool_fs on pool starpool."
  read -p "$PROMPT" cmd34
  echo
  if [[ "$cmd34" != "sudo stratis filesystem create starpool starpool_fs" ]]; then
    print_error "Incorrect. Use stratis filesystem create starpool starpool_fs."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Task 35: Create mount point /starpool."
  read -p "$PROMPT" cmd35
  echo
  if [[ "$cmd35" != "sudo mkdir -p /starpool" ]]; then
    print_error "Incorrect. Use mkdir -p /starpool."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Task 36: Get the UUID of the Stratis filesystem (starpool_fs)."
  read -p "$PROMPT" cmd36
  echo
  if [[ "$cmd36" != "sudo stratis filesystem list" ]]; then
    print_error "Incorrect. Use: sudo stratis filesystem list"
    read -p "Press Enter to retry..." _
    continue
  fi
  STRATIS_UUID="8a1b2c3d-4e5f-6789-abcd-0123456789ab"
  echo "  Pool Name   Name         Used     Created            Device                UUID"
  echo "  starpool    starpool_fs  546 MiB  Jan 15 2026 23:58  /dev/stratis/starpool $STRATIS_UUID"
  echo

  echo "  Task 37: Edit /etc/fstab and add the Stratis mount entry with required options."
  read -p "$PROMPT" cmd37
  echo
  if ! is_one_of "$cmd37" "sudo vim /etc/fstab" "sudo vi /etc/fstab"; then
    print_error "Incorrect. Open /etc/fstab."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (vim opened)"
  echo

  echo "  Type the Stratis fstab line EXACTLY (then save/exit)."
  echo "  (Must include x-systemd.requires=stratisd.service):"
  read -p "  > " fstab_stratis
  if [[ "$fstab_stratis" != "UUID=$STRATIS_UUID /starpool xfs defaults,x-systemd.requires=stratisd.service 0 0" ]]; then
    print_error "Incorrect Stratis fstab line."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo
  echo "  (saved)"
  echo

  echo "  Task 38: Mount the Stratis filesystem now."
  read -p "$PROMPT" cmd38
  echo
  if ! is_one_of "$cmd38" "sudo mount /starpool" "sudo mount -a"; then
    print_error "Incorrect. Use mount /starpool (or mount -a)."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # ------------------------------------------------------------
  # SECTION I: root cron nightly updates
  # ------------------------------------------------------------

  echo "  Task 39: Open root crontab editor."
  read -p "$PROMPT" cmd39
  echo
  if [[ "$cmd39" != "sudo crontab -e" ]]; then
    print_error "Incorrect. Use sudo crontab -e."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (editor opened)"
  echo

  echo "  Task 40: Type the cron line for daily midnight yum update (auto yes):"
  read -p "  (type the exact cron line): " cron_line
  if [[ "$cron_line" != "0 0 * * * yum -y update" ]]; then
    print_error "Incorrect cron entry."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (save and exit the editor)"
  echo

  # ------------------------------------------------------------
  # SECTION J: nginx install + enable at boot
  # ------------------------------------------------------------

  echo "  Task 41: Install nginx using yum."
  read -p "$PROMPT" cmd41
  echo
  if ! is_one_of "$cmd41" "sudo yum install nginx -y" "sudo dnf install nginx -y"; then
    print_error "Incorrect. Install nginx with yum/dnf."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Last metadata expiration check: 0:02:13 ago on Thu 15 Jan 2026 11:59:10 PM UTC."
  echo "  Dependencies resolved."
  echo "  Installed: nginx"
  echo

  echo "  Task 42: Enable nginx to run at boot (and start it now)."
  read -p "$PROMPT" cmd42
  echo
  if ! is_one_of "$cmd42" "sudo systemctl enable --now nginx" "sudo systemctl enable nginx && sudo systemctl start nginx"; then
    print_error "Incorrect. Enable nginx (and start it)."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Created symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /usr/lib/systemd/system/nginx.service."
  echo

  # ------------------------------------------------------------
  # SECTION K: hosts resolution + firewall http service
  # ------------------------------------------------------------

  echo "  Task 43: Edit /etc/hosts and add hostname mapping: skyforge.com -> 1.2.3.4"
  read -p "$PROMPT" cmd43
  echo
  if ! is_one_of "$cmd43" "sudo vim /etc/hosts" "sudo vi /etc/hosts"; then
    print_error "Incorrect. Open /etc/hosts."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (vim opened)"
  echo

  echo "  Type the hosts line EXACTLY (then save/exit):"
  read -p "  > " hosts_line
  if [[ "$hosts_line" != "1.2.3.4         skyforge.com" ]]; then
    print_error "Incorrect /etc/hosts line."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo
  echo "  (saved)"
  echo

  echo "  Task 44: Add http service to public zone (runtime)."
  read -p "$PROMPT" cmd44
  echo
  if [[ "$cmd44" != "sudo firewall-cmd --zone=public --add-service=http" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  success"
  echo

  echo "  Task 45: Make the http service change permanent."
  read -p "$PROMPT" cmd45
  echo
  if [[ "$cmd45" != "sudo firewall-cmd --zone=public --add-service=http --permanent" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  success"
  echo

  echo "  Task 46: Reload firewalld to apply permanent rules."
  read -p "$PROMPT" cmd46
  echo
  if [[ "$cmd46" != "sudo firewall-cmd --reload" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  success"
  echo

  # ------------------------------------------------------------
  # SECTION L: routes to file
  # ------------------------------------------------------------

  echo "  Task 47: Save default route information to /home/riley/routes.txt."
  read -p "$PROMPT" cmd47
  echo
  if ! is_one_of "$cmd47" "ip route show default > /home/riley/routes.txt" "sudo ip route show default > /home/riley/routes.txt"; then
    print_error "Incorrect. Use ip route show default with redirection."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (saved)"
  echo

  # ------------------------------------------------------------
  # SECTION M: user + wheel + passwordless sudo
  # ------------------------------------------------------------

  echo "  Task 48: Create user skyforge (default options)."
  read -p "$PROMPT" cmd48
  echo
  if [[ "$cmd48" != "sudo useradd skyforge" ]]; then
    print_error "Incorrect. Use sudo useradd skyforge."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Task 49: Add user skyforge to wheel group."
  read -p "$PROMPT" cmd49
  echo
  if [[ "$cmd49" != "sudo usermod -aG wheel skyforge" ]]; then
    print_error "Incorrect. Use sudo usermod -aG wheel skyforge."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Task 50: Configure passwordless sudo for wheel via /etc/sudoers.d/wheel_nopasswd using visudo."
  read -p "$PROMPT" cmd50
  echo
  if [[ "$cmd50" != "sudo visudo -f /etc/sudoers.d/wheel_nopasswd" ]]; then
    print_error "Incorrect. Use sudo visudo -f /etc/sudoers.d/wheel_nopasswd."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  (editor opened)"
  echo

  echo "  Type the sudoers line EXACTLY (then save/exit):"
  read -p "  > " sudoers_line
  if [[ "$sudoers_line" != "%wheel ALL=(ALL) NOPASSWD: ALL" ]]; then
    print_error "Incorrect sudoers line."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo
  echo "  (saved)"
  echo

  # ------------------------------------------------------------
  # SECTION N: group superfriends + membership + primary group
  # ------------------------------------------------------------

  echo "  Task 51: Create group superfriends."
  read -p "$PROMPT" cmd51
  echo
  if [[ "$cmd51" != "sudo groupadd superfriends" ]]; then
    print_error "Incorrect. Use sudo groupadd superfriends."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Task 52: Add skyforge user to group superfriends (supplementary)."
  read -p "$PROMPT" cmd52
  echo
  if [[ "$cmd52" != "sudo usermod -aG superfriends skyforge" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Task 53: Change skyforge user's default (primary) group to superfriends."
  read -p "$PROMPT" cmd53
  echo
  if [[ "$cmd53" != "sudo usermod -g superfriends skyforge" ]]; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # ------------------------------------------------------------
  # SECTION O: directory + html file
  # ------------------------------------------------------------

  echo "  Task 54: Create directory /home/riley/skyforge and file skyforge.html containing the word SkyForge."
  read -p "$PROMPT" cmd54
  echo
  if ! is_one_of "$cmd54" "mkdir -p /home/riley/skyforge && echo SkyForge > /home/riley/skyforge/skyforge.html" "sudo mkdir -p /home/riley/skyforge && echo SkyForge | sudo tee /home/riley/skyforge/skyforge.html >/dev/null"; then
    print_error "Incorrect. Must create dir and write SkyForge into the file."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  # ------------------------------------------------------------
  # SECTION P: Podman nginx container with bind mount (:Z) + curl verification
  # ------------------------------------------------------------

  echo "  Task 55: Run detached nginx container named my_web, map localhost 1026->80,"
  echo "          mount /home/riley/skyforge to /usr/share/nginx/html with SELinux option."
  read -p "$PROMPT" cmd55
  echo
  if [[ "$cmd55" != "sudo podman run -d --name my_web -p 1026:80 -v /home/riley/skyforge:/usr/share/nginx/html:Z docker.io/library/nginx" ]]; then
    print_error "Incorrect. Use podman run with -d, --name my_web, -p 1026:80, and -v ...:Z."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  3f2c9a8d7b1e6c4a2f0d9b8c7e6a5d4c3b2a1f0e9d8c7b6a5f4e3d2c1b0a9f8e"
  echo

  echo "  Task 56: Verify curl returns SkyForge from localhost:1026/skyforge.html."
  read -p "$PROMPT" cmd56
  echo
  if [[ "$cmd56" != "curl localhost:1026/skyforge.html" ]]; then
    print_error "Incorrect. Use curl localhost:1026/skyforge.html"
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  SkyForge"
  echo

  # ------------------------------------------------------------
  # SECTION Q: skopeo inspect + sync
  # ------------------------------------------------------------

  echo "  Task 57: Install skopeo."
  read -p "$PROMPT" cmd57
  echo
  if ! is_one_of "$cmd57" "sudo yum install skopeo -y" "sudo dnf install skopeo -y"; then
    print_error "Incorrect."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  Installed: skopeo"
  echo

  echo "  Task 58: Inspect docker://docker.io/library/nginx and save output to /home/riley/nginx.txt."
  read -p "$PROMPT" cmd58
  echo
  if [[ "$cmd58" != "sudo skopeo inspect docker://docker.io/library/nginx > /home/riley/nginx.txt" ]]; then
    print_error "Incorrect. Use skopeo inspect with output redirection."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Task 59: Create directory /home/riley/nginx."
  read -p "$PROMPT" cmd59
  echo
  if [[ "$cmd59" != "mkdir -p /home/riley/nginx" && "$cmd59" != "sudo mkdir -p /home/riley/nginx" ]]; then
    print_error "Incorrect. Use mkdir -p /home/riley/nginx."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo

  echo "  Task 60: Sync docker.io/library/nginx:latest to local directory /home/riley/nginx."
  read -p "$PROMPT" cmd60
  echo
  if [[ "$cmd60" != "sudo skopeo sync --src docker --dest dir docker.io/library/nginx:latest /home/riley/nginx" ]]; then
    print_error "Incorrect. Use skopeo sync with --src docker --dest dir."
    read -p "Press Enter to retry..." _
    continue
  fi
  echo "  INFO[0000] Tag presence check                            imagename=\"docker.io/library/nginx:latest\" tagged=true"
  echo "  INFO[0000] Copying image ref 1/1                         from=\"docker://docker.io/library/nginx:latest\" to=\"dir:/home/riley/nginx/nginx:latest\""
  echo "  Getting image source signatures"
  echo "  Copying blob 57f0dd1befe2 done"
  echo "  Copying blob 119d43eec815 done"
  echo "  Copying blob 700146c8ad64 done"
  echo "  Copying config 4af177a024 done"
  echo "  Writing manifest to image destination"
  echo "  INFO[0002] Synced 1 images from 1 sources"
  echo

  print_success "Mock RHCSA exam chain completed."
  print_info "You covered: tar/grep/redirection, scripting, systemd, tuned, renice,"
  print_info "swap + fstab, LVM + XFS + fstab, Stratis + fstab options, cron,"
  print_info "nginx install + enable, /etc/hosts, firewall-cmd, routes, users/groups/sudoers,"
  print_info "podman nginx with :Z bind mount, curl verification, and skopeo inspect/sync."
  print_info "You earned $LAB_XP XP for completing this lab."
  award_xp $LAB_XP

  XP=$(jq '.XP' "$SAVE_JSON")
  LEVEL=$(jq '.LEVEL' "$SAVE_JSON")
  export XP
  export LEVEL
  record_lab_completion

  completion_count=$(get_lab_completion_count)
  echo
  print_info "You've successfully completed this lab $completion_count time(s)."
  echo
  center_text "Would you like to:"
  center_text "1) Retry this lab"
  center_text "2) Return to Sysadmin Lab Menu"
  echo
  read -p "  > " choice

  [[ "$choice" == "2" ]] && exit 0
done
