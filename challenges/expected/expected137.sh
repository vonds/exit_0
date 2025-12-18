#!/bin/bash
# Challenge 137: Automation with Ansible & Python

echo -e "- hosts: localhost\n  tasks:\n    - name: Create file\n      file:\n        path: /tmp/demo.txt\n        state: touch" > playbook.yml
