#!/bin/bash
# Challenge 148: Log & Error Troubleshooting
sudo find /var/log -type f -exec grep -i "critical" {} + 2>/dev/null