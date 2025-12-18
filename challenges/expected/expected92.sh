#!/bin/bash
# Challenge 92: Create a simple log rotation script for app.log

mv app.log app.log.bak
touch app.log
echo "Rotated app.log"
