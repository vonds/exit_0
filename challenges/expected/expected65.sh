#!/bin/bash
# Challenge 65: Find all files owned by the current user in /var/log

find /var/log -user "$USER" 2>/dev/null
