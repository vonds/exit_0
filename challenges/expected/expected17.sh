#!/bin/bash
read -p "Enter filename: " file
if [ -r "$file" ]; then
  echo "File is readable."
else
  echo "File is not readable."
fi
