#!/bin/bash
# Challenge 47: Find all files larger than 1MB in the current directory and subdirectories

find . -type f -size +1M
