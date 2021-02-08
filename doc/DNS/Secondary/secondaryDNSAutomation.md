# DNS Automation Research

## General

Research on how to use the dedicated config files so that the correct zones and records  
are added to the dns server on CentOS. Before reading this, I recommend reading the DNS  
research file.

## Versions

* CentOS: 8.2
* DNS: bertvv.bind

## Understanding the configuration file

* Example:
```
bind_zones:
  # Example of a primary zone (hosts: and name_servers: ares defined)
  - name: CORONA2020.local       # Domain name
    type: secondary
    allow_update: ['any']
    create_reverse_zones: true  # Skip creation of reverse zones
    primaries:
      - 192.100.100.195                # Primary server(s) for this zone
    name_servers:
      - bravo
      - golf
    hosts:
      - name: bravo
        ip: 192.100.100.195
        aliases:
          - dns
      - name: golf
        ip: 192.100.100.196
        # ipv6: 2001:db8::2
        aliases:
          - secDns
      # - name: mydomain.net.
      #   aliases:
      #     - name: sub01
      #       type: DNAME          # Example of a DNAME alias record
    networks:
      - '192.100.100'
```

Author: Glenn Delanghe
