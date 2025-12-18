#!/bin/bash
# Challenge 84: Set file permissions to rw-r--r-- for all .conf files in /etc

sudo find /etc -type f -name "*.conf" -exec chmod 644 {} +
