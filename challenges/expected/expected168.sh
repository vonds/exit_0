#!/bin/bash
# Challenge 168: incident simulation & log audit - Advanced Exercise

journalctl -u ssh.service --since "today"
