#!/bin/bash

ansible all -i /etc/ansible/hosts -m setup -a " filter=*ipv4_addr* "


exit;

facts:
        "ansible_fqdn": "win11vm-mini3",
        "ansible_hostname": "win11vm-mini3",
        "ansible_interfaces": [
            {
                "connection_name": "HOnet",
                "default_gateway": "192.168.56.1",
                "dns_domain": null,
                "interface_index": 18,
                "interface_name": "Red Hat VirtIO Ethernet Adapter #4",
                "ipv4": {
                    "address": "192.168.56.13",
                    "prefix": "24"
                },
                "ipv6": {
                    "address": "fe80::95ee:ddec:d742:3c21%18",
                    "prefix": "64"
                },
                "macaddress": "BC:24:11:82:FF:29",
                "mtu": 1500,
                "speed": 10000
            },
            {
                "connection_name": "eth2p5",
                "default_gateway": "172.16.25.1",
                "dns_domain": null,
                "interface_index": 10,
                "interface_name": "Red Hat VirtIO Ethernet Adapter #5",
                "ipv4": {
                    "address": "172.16.25.71",
                    "prefix": "24"
                },
                "ipv6": {
                    "address": "fe80::373:1711:6a4e:2979%10",
                    "prefix": "64"
                },
                "macaddress": "BC:24:11:7F:19:42",
                "mtu": 1500,
                "speed": 10000
            }
        ],
        "ansible_ip_addresses": [
            "fe80::95ee:ddec:d742:3c21%18",
            "192.168.56.13",
            "fe80::373:1711:6a4e:2979%10",
            "172.16.25.71"
        ],
 