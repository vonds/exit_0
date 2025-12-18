#!/bin/bash
# Challenge 85: Generate a system report with hostname, uptime, disk usage

echo "Hostname: $(hostname)"
echo "Uptime: $(uptime -p)"
echo "Disk Usage:"
df -h
