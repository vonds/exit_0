#!/bin/bash
# Challenge 33: Count the number of words in a user-specified file

read -p "Enter file name: " file
if [ -f "$file" ]; then
    wc -w < "$file"
else
    echo "File not found."
fi
