#!/bin/bash
# Challenge 195: incident simulation & log audit - Advanced Exercise

journalctl -u ssh.service --since "today"
