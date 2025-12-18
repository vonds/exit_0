#!/bin/bash
# Challenge 177: incident simulation & log audit - Advanced Exercise

journalctl -u ssh.service --since "today"
