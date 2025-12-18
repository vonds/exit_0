#!/bin/bash
# Challenge 87: Extract all unique IP addresses from an Apache log file

awk '{print $1}' /var/log/apache2/access.log | sort | uniq
