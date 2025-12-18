#!/bin/bash
# Live filter for critical system logs

LOG_FILE="/var/log/syslog"
[ ! -f "$LOG_FILE" ] && LOG_FILE="/var/log/messages"

echo "Searching for CRITICAL entries in $LOG_FILE..."
grep -Ei "error|fail|panic|denied|segfault|crash" "$LOG_FILE" | tail -n 20
