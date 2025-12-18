#!/bin/bash
# Challenge 70: Show processes sorted by memory usage

ps aux --sort=-%mem | head
