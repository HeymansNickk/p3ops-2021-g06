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
        aliases:
          - dc
      - name: bravo
        ip: 192.100.100.195
        aliases:
          - dns
      - name: charlie
        ip: 192.100.100.198
        aliases:
          - www
      - name: delta
        ip: 192.100.100.199
        aliases:
          - mail
      - name: echo
        ip: 192.100.100.200
        aliases:
          - sccm
      - name: golf
        ip: 192.100.100.196
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
```

The code above will generate two zone files, a forward one and a reverse one.  
Next to adding it in that config file it will create the following zone files:

### Forward zone

```
; Zone file for CORONA2020.local
;
; Ansible managed
;

$ORIGIN CORONA2020.local.
$TTL 1W

@ IN SOA bravo.CORONA2020.local. hostmaster.CORONA2020.local. (
  1606127972
  1D
  1H
  1W
  1D )

                           IN  NS     bravo.CORONA2020.local.
                           IN  NS     golf.CORONA2020.local.

@                          IN  MX     10  delta.CORONA2020.local.


alfa                       IN  A      192.100.100.194
dc                         IN  CNAME  alfa
bravo                      IN  A      192.100.100.195
dns                        IN  CNAME  bravo
charlie                    IN  A      192.100.100.198
www                        IN  CNAME  charlie
delta                      IN  A      192.100.100.199
mail                       IN  CNAME  delta
echo                       IN  A      192.100.100.200
sccm                       IN  CNAME  echo
golf                       IN  A      192.100.100.196
secDns                     IN  CNAME  golf
work                       IN  A      192.100.100.0
guest                      IN  A      192.100.100.128
```
### Reverse zone

```
; Hash: 9f44bc092fc1d8f8beb05c92b8a5481a 1606127972
; Reverse zone file for CORONA2020.local
;
; Ansible managed
;

$TTL 1W
$ORIGIN 100.100.192.in-addr.arpa.

@ IN SOA bravo.CORONA2020.local. hostmaster.CORONA2020.local. (
  1606127972
  1D
  1H
  1W
  1D )

                       IN  NS   bravo.CORONA2020.local.
                       IN  NS   golf.CORONA2020.local.

194                    IN  PTR  alfa.CORONA2020.local.
195                    IN  PTR  bravo.CORONA2020.local.
198                    IN  PTR  charlie.CORONA2020.local.
199                    IN  PTR  delta.CORONA2020.local.
200                    IN  PTR  echo.CORONA2020.local.
196                    IN  PTR  golf.CORONA2020.local.
0                      IN  PTR  work.CORONA2020.local.
128                    IN  PTR  guest.CORONA2020.local.
```

#### Terminology

| Term    | Explanation                                                                                                                                                                        |
| ---     | ---                                                                                                                                                                                |
| TTL     | This is short for Time-To-Live                                                                                                                                                     |
| IN      | This implies the Internet                                                                                                                                                          |
| SOA     | This is short for the Start of Authority. Basically, it defines the authoritative name server, in this case, CORONA.local and contact information – hostmaster.2.0.10.in-addr.arpa |
| NS      | This is short for Name Server                                                                                                                                                      |
| A       | This is an A record                                                                                                                                                                |
| PTR     | Short for Pointer                                                                                                                                                                  |
| Serial  | This is the attribute used by the DNS server to ensure that contents of a specific zone file are updated                                                                           |
| Refresh | Defines the number of times that a slave DNS server should transfer a zone from the master                                                                                         |
| Retry   | Defines the number of times that a slave should retry a non-responsive zone transfer                                                                                               |
| Expire  | Specifies the duration a slave server should wait before responding to a client query when the Master is unavailable                                                               |
| Minimum | This is responsible for setting the minimum TTL for a zone                                                                                                                         |
| MX      | This is the Mail exchanger record                                                                                                                                                  |

Author: Glenn Delanghe
