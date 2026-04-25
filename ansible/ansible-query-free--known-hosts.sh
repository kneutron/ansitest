#!/bin/bash

ansible rhel8 -a "free -h"
ansible rhel9 -a "free -h"
ansible debian -a "free -h"


