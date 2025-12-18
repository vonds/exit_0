#!/bin/bash
# Challenge 58: Read a CSV file and print each row's second column

while IFS=',' read -r col1 col2 rest; do
    echo "$col2"
done < data.csv
