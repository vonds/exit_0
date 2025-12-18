#!/bin/bash
# Challenge 159: incident simulation & log audit - Advanced Exercise

journalctl -u ssh.service --since "today"
