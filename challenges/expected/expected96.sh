#!/bin/bash
# Challenge 96: Backup user's home directory excluding Downloads

tar --exclude="$HOME/Downloads" -czf home_backup.tar.gz "$HOME"
