# CentOS 8 DNS Research

## General

* How to install and configure a secondary(redundant) DNS Server on CentOs 8

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
* Also ensure the IP-address on the listen-port 53 is set to the desired IP.
```
listen-on port 53 { 192.100.100.196; }; 
listen-on-v6 port 53 { ::1; };
```

* Adjust allow-query parameter to the desired subnetwork.
```
allow-query { any; }
```

* Copy the following configuration to the bottom of the config file.
```
//forward zone
zone "CORONA2020.local" IN {
     type slave;
     masters { 192.100.100.195; };
     file "/var/named/secondary/CORONA2020.local";
};

//backward zone
zone "100.100.192.in-addr.arpa" IN {
     type slave;
     masters { 192.100.100.195; };
     file "/var/named/secondary/100.100.192.in-addr.arpa";
};
```

Last restart the server and add DNS service on the firewall.

```
systemctl restart named
firewall-cmd  --add-service=dns --zone=public  --permanent
firewall-cmd --reload
```

Author: Glenn Delanghe
