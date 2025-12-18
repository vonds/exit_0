#!/bin/bash

echo "DISK USAGE SUMMARY"
df -h /

echo
echo "TOP 10 LARGEST DIRECTORIES IN ROOT (/)"
du -h --max-depth=1 / 2>/dev/null | sort -hr | head -n 10

echo
echo "FILES OVER 100MB"
find / -type f -size +100M -exec ls -lh {} \; 2>/dev/null | awk '{ print $NF ": " $5 }' | head -n 10
