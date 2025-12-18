#!/bin/bash
# Challenge 60: Accept a filename as argument and print its type (directory, file, etc.)

file="$1"
if [ -d "$file" ]; then
    echo "Directory"
elif [ -f "$file" ]; then
    echo "Regular file"
else
    echo "Other or does not exist"
fi
