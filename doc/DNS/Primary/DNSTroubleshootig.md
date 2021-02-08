# DNS Troubleshooting

## General

During the installation and configuration of the DNS server using ansible some problems came up.
The main problems were:
* Ansible: While installing ansible, it would download but not install
* Python: While installing pyhton, it would download but not install
* DNS config: While configuring DNS zones, the zones files were made but the zones were not added to the global dns config

## Ansible

### Problem
When running vagrant up, the machine would power up, CentOS was installed after which the ansible playbook should run.
So vagrant installs ansible, it would download but not install because of a non matching checksum in the files.
This problem would only occur sometimes and not on all host machines.

### Solutions
The solutions tried are the following:
* Rebooting pc (did not work)
* Reinstalling Vagrant (worked for a few times, and also tried this solution multiple times)
* When vagrant up would not install ansible, running vagrant provision would sometimes do it, sometimes only after the third try

So no solution actually really worked and so far no definitive solution was found, even after extensive researching.


## Python

### Problem
When running vagrant up, the machine would power up, CentOS was installed after which the ansible playbook should run.
So vagrant installs ansible, it would download python too but wouldn't install because of a non matching checksum in the files.
This problem would only occur sometimes.

### Solutions
The solution tried is the following:
* When vagrant up would not install ansible, running vagrant provision would sometimes do it, sometimes only after the third try

This only came up two times and then never occurred again.


## DNS Config

### Problem
When running the ansible playbook the dns zones and zone files are created. The creation of the zone files itself runs smooth but whenever
the forward lookup zone is to be added to the global dns config an error comes up. The error stated that there were no address-recors present
in the zone file.

#### Error message
```
TASK [robertdebock.dns : add zones to configuration] ***************************
fatal: [bravo]: FAILED! => {"changed": false, "checksum": "55910dc8dcf352b500eec0df70bc15b11da17487", "exit_status": 1, "msg": "failed to validate", "stderr": "_default/CORONA.local/IN: bad zone\n", "stderr_lines": ["_default/CORONA.local/IN: bad zone"], "stdout": "zone 2.0.10.in-addr.arpa/IN: loaded serial 1\nzone example.com/IN: loaded serial 1\nzone CORONA.local/IN: NS 'CORONA.local' has no address records (A or AAAA)\nzone CORONA.local/IN: not loaded due to errors.\n", "stdout_lines": ["zone 2.0.10.in-addr.arpa/IN: loaded serial 1", "zone example.com/IN: loaded serial 1", "zone CORONA.local/IN: NS 'CORONA.local' has no address records (A or AAAA)", "zone CORONA.local/IN: not loaded due to errors."]}
```

#### Zone file (bad)
```
$ORIGIN CORONA.local.
$TTL 86400
@       IN      SOA     CORONA.local.   hostmaster.CORONA.local. (
                        1 ; serial
                        3600 ; refresh
                        1800 ; retry
                        604800 ; expire
                        86400 ) ; minimum TTL

  IN NS CORONA.local.

  IN MX 10 mail.CORONA.local.

dm IN   A       10.0.2.193
www IN  A       10.0.2.195
mail IN A       10.0.2.196
sccm IN A       10.0.2.197
```

### Solution
No permanent solution was found yet.
The solution tried was using a template from the role maker where the needed records were added.
For some unknown reason this did work.

#### Zone file (good)
```
$ORIGIN CORONA.local.
$TTL 86400
@       IN      SOA     CORONA.local.   hostmaster.CORONA.local. (
                        1 ; serial
                        3600 ; refresh
                        1800 ; retry
                        604800 ; expire
                        86400 ) ; minimum TTL

  IN NS CORONA.local.

  IN MX 10 mail.CORONA.local.

@ IN    A       127.0.0.1

dm IN   A       10.0.2.193
www IN  A       10.0.2.195
mail IN A       10.0.2.196
sccm IN A       10.0.2.197
```


Author: Glenn Delanghe