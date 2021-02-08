# DNS Troubleshooting A Records

## General

During the installation and configuration of the DNS server using ansible the 'lack of A-records' in the zone files kept stopping the installation.

## A records not found

### Problem
When running the ansible playbook the next error kept showing up. This error was partly received when manually performing the __named-checkzone CORONA.local. /var/named/CORONA.local__ command.


#### Error message
```
TASK [bertvv.bind : add zones to configuration] ***************************
fatal: [bravo]: FAILED! => {"changed": false, "checksum": "55910dc8dcf352b500eec0df70bc15b11da17487", "exit_status": 1, "msg": "failed to validate", "stderr": "_default/CORONA.local/IN: bad zone\n", "stderr_lines": ["_default/CORONA.local/IN: bad zone"], "stdout": "zone 2.0.10.in-addr.arpa/IN: loaded serial 1\nzone example.com/IN: loaded serial 1\nzone CORONA.local/IN: NS 'CORONA.local' has no address records (A or AAAA)\nzone CORONA.local/IN: not loaded due to errors.\n", "stdout_lines": ["zone 2.0.10.in-addr.arpa/IN: loaded serial 1", "zone example.com/IN: loaded serial 1", "zone CORONA.local/IN: NS 'CORONA.local' has no address records (A or AAAA)", "zone CORONA.local/IN: not loaded due to errors."]}
```

### Solution
The solution to this problem was extensive research about DNS-zone files. Research showed that the error didn't actually mean there were no A-records at all but that there was one A-record lacking.
The actual solution was to add an A-record for the DNS-server itself to the zone files.
This solved the problem and therefor the installation of the DNS-server could be completed successfully.


Author: Glenn Delanghe