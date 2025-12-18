#!/bin/bash
# Challenge 38: Read a list of numbers from a file and print their sum

sum=0
while read -r number; do
    sum=$((sum + number))
done < numbers.txt
echo "Total: $sum"
