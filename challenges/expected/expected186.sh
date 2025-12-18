#!/bin/bash
# Challenge 186: incident simulation & log audit - Advanced Exercise

journalctl -u ssh.service --since "today"
