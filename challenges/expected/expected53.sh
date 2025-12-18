#!/bin/bash
# Challenge 53: Write a script to extract all valid email addresses from a file

grep -E -o "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" input.txt
