#!/bin/bash
read -p "Enter a filename: " filename
if [ ! -f "$filename" ]; then
    touch "$filename"
    echo "File '$filename' created."
else
    echo "File '$filename' already exists."
fi
