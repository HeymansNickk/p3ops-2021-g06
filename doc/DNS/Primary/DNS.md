# CentOS 8 DNS Research

## General

* How to install and configure a DNS Server on CentOs 8

## Manual install and basic configuration of the service

### Install

The installation of the DNS Server is done by running following command.

```
dnf install bind bind-utils
```

### Basic configuration of the service

Performing following commands will make sure the server is running and will run when the system boots.
```
systemctl start named
systemctl enable named
```

To check if the server is running, use the command below.
```
systemctl status named
```

## Configuration of the DNS Server itself

### Basic

In this part the configuration of the DNS Server itself will be explained.

* Before changing anything, make a copy of the config file.
```
cp /etc/named.conf  /etc/named.bak
```

* Open the config file using your preferred editor for example vim.
```
vim /etc/named.conf
```

* Make sure next lines are commented out to enable the server to listen to all IPs.
* Also make sure the IP-address in listen-on port 53 is set to the desired IP.
```
listen-on port 53 { 192.100.100.195; }; 
listen-on-v6 port 53 { ::1; };
```

* Adjust allow-query parameter to the desired subnetwork.
```
allow-query { localhost; 192.100.100.0/24; }
```

* Copy the following configuration to the bottom of the config file.
```
//forward zone
zone "CORONA2020.local" IN {
     type master;
     file "/var/named/CORONA2020.local";
     allow-update { none; };
     allow-query { any; };
};

//backward zone
zone "100.100.192.in-addr.arpa" IN {
     type master;
     file "/var/named/100.100.192.in-addr.apra";
     allow-update { none; };
     allow-query { any; };
};
```

#### Terminology

| Term           | Explanation                                                     |
| ---            | ---                                                             |
| type           | States the role of the server (master --> authoritative server) |
| file           | Points to the forward/reverse zone file of the domain           |
| allow-update   | Defines the host systems allowed to forward Dynamic DNS updates |


## Creating DNS zone files

### Creating a forward DNS zone file

First the creation of a forward DNS zone file is needed, once it is created the following should be in the file (file name: CORONA2020.local).

```
$ORIGIN CORONA2020.local.
$TTL 86400
@ IN SOA dns-primary.CORONA.local. admin.CORONA.local. (
                                                2020011800 ;Serial
                                                3600 ;Refresh
                                                1800 ;Retry
                                                604800 ;Expire
                                                86400 ;Minimum TTL
)

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


### Creating a reverse DNS zone file

First the creation of a reverse DNS zone file is needed, once it is created the following should be in the file (file name: 100.100.192.in-addr.arpa).


```:w

$ORIGIN 100.100.192.in-addr-arpa.
$TTL 86400
@ IN SOA bravo.CORONA.local. admin.CORONA.local. (
                                            2020011800 ;Serial
                                            3600 ;Refresh
                                            1800 ;Retry
                                            604800 ;Expire
                                            86400 ;Minimum TTL
)

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

### Further configuration

The files now need to have the necessary permissions, this is done by the following commands.

```
chown named:named /var/named/CORONA2020.local
chown named:named /var/named/100.100.192.in-addr.apra
```

Check the files for syntax:

```
named-checkconf
named-checkzone CORONA.local /var/named/CORONA2020.local
named-checkzone 192.168.43.35 /var/named/100.100.192.in-addr.arpa
```

Last restart the server and add DNS service on the firewall.

```
systemctl restart named
firewall-cmd  --add-service=dns --zone=public  --permanent
firewall-cmd --reload
```

Author: Glenn Delanghe
