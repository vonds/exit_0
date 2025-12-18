#!/bin/bash
# Challenge 37: Create a directory only if it does not already exist

read -p "Enter directory name: " dir
if [ ! -d "$dir" ]; then
    mkdir "$dir"
    echo "Directory created."
else
    echo "Directory already exists."
fi
