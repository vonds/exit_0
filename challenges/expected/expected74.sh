#!/bin/bash
# Challenge 74: Find the top 5 largest files in /

find / -type f -exec du -h {} + 2>/dev/null | sort -rh | head -n 5
