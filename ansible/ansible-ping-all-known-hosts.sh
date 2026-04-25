#!/bin/bash

ansible all -m ping

echo "For now, edit /etc/ansible/hosts and comment out the ones that aren't responding / or power them on before patching"
