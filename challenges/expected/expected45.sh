#!/bin/bash
# Challenge 45: Rename all files in current directory to lowercase

for file in *; do
    mv "$file" "$(echo "$file" | tr 'A-Z' 'a-z')" 2>/dev/null
done
echo "Renamed all files to lowercase."
