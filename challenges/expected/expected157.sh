#!/bin/bash
# Challenge 157: Ansible scripting - Advanced Exercise

echo -e "- hosts: localhost\n  tasks:\n    - name: Ensure tree is installed\n      package:\n        name: tree\n        state: present" > install_tree.yml
