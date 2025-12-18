#!/bin/bash
read -p "Enter directory name: " dir
if [ -d "$dir" ]; then
  echo "Directory exists."
else
  echo "Directory does not exist."
fi
