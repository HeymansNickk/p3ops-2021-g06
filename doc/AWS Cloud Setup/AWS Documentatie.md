# Installing Servers on AWS Virtual machine

## DNS

### Setting up a virtual machine

Log in on your AWS console and configure your virtual machine to be using Centos8 or similiar Redhat build. After deploying your virtual machine, generate a host key through the AWS web panel and launch the machine. You can now SSH/FTP into the machine using your preferred FTP/SSH client or console.

### Installing Ansible

`sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm`

`sudo yum install ansible`

### Installing DNS Role and RH-Base

`ansible-galaxy install bertvv.bind`

`ansible-galaxy install bertvv.rh-base`

Create a site.yml file in the .ansible folder and configure.

```
# site.yml
---
- hosts: localhost
  become: true
  vars_files: host_vars/bravo.yml
  roles:
    - bertvv.rh-base
    - bertvv.bind
```

Create a folder "host_vars" and create "bravo.yml" like below:

```
# host_vars/bravo.yml
---
rhbase_firewall_allow_ports: [53/tcp, 53/udp, 389/tcp, 389/udp, 137/tcp, 137/udp, 138/udp, 139/tcp, 3268/tcp, 1512/tcp, 1512/udp]

bind_listen_ipv4: ['192.100.100.195']

bind_allow_query: ['any']

bind_zones:
  - name: CORONA2020.local       # Domain name
    type: primary
    allow_update: ['any']
    create_reverse_zones: true  # Skip creation of reverse zones
    primaries:
      - 192.100.100.195                # Primary server(s) for this zone
    name_servers:
      - bravo
      - golf
    hosts:
      - name: alfa
        ip: 192.100.100.194
        # ipv6: 2001:db8::1
        aliases:
          - dc
      - name: bravo
        ip: 192.100.100.195
        aliases:
          - dns
      - name: charlie
        ip: 192.100.100.198
        # ipv6: 2001:db8::2
        aliases:
          - www
      - name: delta
        ip: 192.100.100.199
        # ipv6: 2001:db8::2
        aliases:
          - mail
      - name: echo
        ip: 192.100.100.200
        # ipv6: 2001:db8::2
        aliases:
          - sccm
      - name: golf
        ip: 192.100.100.196
        # ipv6: 2001:db8::2
        aliases:
          - secDns
      - name: work             # This IP is in another subnet, will result in
        ip: 192.100.100.0             #   multiple reverse zones
      - name: guest
        ip: 192.100.100.128
    networks:
      - '192.100.100'
    mail_servers:
      - name: delta
        preference: 10
    services:
      - name: _ldap._tcp.dc._msdcs
        target: alfa
        port: 53
```

Start the ansible playbook by executing the following command.

`ansible-playbook site.yml`


Author: Dries Melkebeke

