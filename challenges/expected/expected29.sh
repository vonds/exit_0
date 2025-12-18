#!/bin/bash
# Challenge 29: Prompt the user until they type 'yes'

until [ "$answer" == "yes" ]; do read -p "Type yes to continue: " answer; done
