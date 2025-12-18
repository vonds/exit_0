#!/bin/bash
# Challenge 100: Simulate restoring a backup tar.gz to /tmp/restore

mkdir -p /tmp/restore
tar -xzf backup.tar.gz -C /tmp/restore
echo "Backup restored to /tmp/restore"
