#!/bin/bash
# Challenge 23: Read and print each line of a file (input.txt)

while IFS= read -r line; do echo "$line"; done < input.txt
