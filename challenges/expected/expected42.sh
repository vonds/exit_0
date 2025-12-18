#!/bin/bash
# Challenge 42: Create a backup of all .txt files into a backup directory

mkdir -p backup
cp *.txt backup/ 2>/dev/null
echo "Backup complete."
