#!/bin/bash
read -p "Enter something: " input
if [ -z "$input" ]; then
    echo "No input provided"
else
    echo "You entered: $input"
fi
