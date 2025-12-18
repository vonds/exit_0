#!/bin/bash
# Challenge 40: Check if a given string is a palindrome

read -p "Enter a string: " str
reversed=$(echo "$str" | rev)
if [ "$str" == "$reversed" ]; then
    echo "Palindrome"
else
    echo "Not a palindrome"
fi
