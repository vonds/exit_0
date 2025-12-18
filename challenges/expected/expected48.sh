#!/bin/bash
# Challenge 48: Sort a file alphabetically and save the output to a new file

read -p "Enter filename: " fname
sort "$fname" > sorted_"$fname"
echo "Sorted file saved as sorted_$fname"
