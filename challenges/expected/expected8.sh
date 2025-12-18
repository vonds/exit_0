#!/bin/bash
read -p "Enter filename: " file
wc -l < "$file"
