#!/bin/bash
# Challenge 94: Write a system health script that checks CPU load > 1

load=$(awk '{print $1}' /proc/loadavg)
if (( $(echo "$load > 1.0" | bc -l) )); then
    echo "High load: $load"
else
    echo "Load normal"
fi
