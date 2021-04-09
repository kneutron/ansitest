#!/bin/bash

# REF: https://stackoverflow.com/questions/44114854/virtualbox-cannot-register-the-hard-disk-already-exists
# use $PWD/name.vdi if needed
VBoxManage internalcommands sethduuid "$1"
