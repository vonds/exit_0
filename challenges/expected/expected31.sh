#!/bin/bash
# Challenge 31: Check if a number is even or odd

read -p "Enter a number: " num
if (( num % 2 == 0 )); then
    echo "Even"
else
    echo "Odd"
fi
