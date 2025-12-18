#!/bin/bash
# Challenge 90: Create a menu that shows memory, CPU load, or quits

echo "1) Memory usage"
echo "2) CPU Load"
echo "3) Quit"
read -p "Choose an option: " opt
case "$opt" in
    1) free -h ;;
    2) uptime ;;
    3) echo "Bye!" ;;
    *) echo "Invalid option" ;;
esac
