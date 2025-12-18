#!/bin/bash
# Challenge 44: Create a menu system that allows the user to choose between options

echo "1) Say Hello"
echo "2) Show Date"
echo "3) Exit"
read -p "Choose: " choice
case "$choice" in
    1) echo "Hello!" ;;
    2) date ;;
    3) echo "Goodbye!" ;;
    *) echo "Invalid option" ;;
esac
