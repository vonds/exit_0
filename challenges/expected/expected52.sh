#!/bin/bash
# Challenge 52: Display the most frequent word in a text file

read -p "Enter file: " f
tr -s ' ' '\n' < "$f" | sort | uniq -c | sort -nr | head -n 1
