#!/bin/bash
# Challenge 69: Create a cron job that runs a script every day at midnight

echo "0 0 * * * /path/to/script.sh" | crontab -
