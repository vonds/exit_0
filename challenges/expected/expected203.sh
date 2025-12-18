#!/bin/bash
# Generate a triage report with critical system data

echo "SYSTEM TRIAGE REPORT — $(date)"

echo -e "\n Disk Usage:"
df -h

echo -e "\n Memory Usage:"
free -h

echo -e "\n  Top CPU Processes:"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 10

echo -e "\n Active Network Connections:"
ss -tulwn | grep -v "127.0.0.1"

echo -e "\n System Load and Uptime:"
uptime

echo -e "\n Last 20 System Logs:"
journalctl -n 20 --no-pager 2>/dev/null || tail -n 20 /var/log/syslog

echo -e "\n Triage complete."
