# Test plan DNS Server

In this test plan we are going to set up the DNS server using vagrant and ansible the test provided wil make sure that the service is running and the zonfiles are configured as they should be. 

## Testing environment

Pull this complete repository to make sure you have all the files required for this test. You will also need [Vagrant](https://www.vagrantup.com/) and the latest version of [VirtualBox](https://www.virtualbox.org/) installed. Restart your device after installing the programs you did not have installed yet.

## Vagrant

Before continuing you should make sure there are no Vagrant environments remaining from any other tests. You can destroy these environments by going to their corresponding directories and opening a PowerShell command line there. You can do this by entering `powershell` in the address bar.


Enter `vagrant destroy -f` in the PowerShell command line to destroy the remaining environments.

Open a PowerShell command line in `/src/linux` and run the `vagrant up bravo` command which will bring up the DNS server. It will take a couple of minutes before the Vagrant environment is set up.

## Service 

Once the machine is up and running, use `vagrant ssh bravo` to connect to the machine. To ensure that the service is running perform the following command: `systemctl status named`. 

## Configuration file
If the service is running open `/etc/named.conf` in your favorite text editor. The following configuration blocks should be found in the file.
```
options {
  listen-on port 53 { 192.100.100.195; };
  listen-on-v6 port 53 { ::1; };
  directory   "/var/named";
  dump-file   "/var/named/data/cache_dump.db";
  statistics-file "/var/named/data/named_stats.txt";
  memstatistics-file "/var/named/data/named_mem_stats.txt";
  allow-query     { any; };

  recursion no;

  rrset-order { order random; };

  dnssec-enable True;
  dnssec-validation True;

  /* Path to ISC DLV key */
  bindkeys-file "/etc/named.iscdlv.key";

  managed-keys-directory "/var/named/dynamic";

  pid-file "/run/named/named.pid";
  session-keyfile "/run/named/session.key";
};

```

```
zone "CORONA2020.local" IN {
  type master;
  file "/var/named/CORONA2020.local";
  notify yes;
  allow-update { any; };
};

zone "100.100.192.in-addr.arpa" IN {
  type master;
  file "/var/named/100.100.192.in-addr.arpa";
  notify yes;
  allow-update { any; };
};
```
## Zonefiles
If the global config file is correctly configuered, the zone files should be checked to assure the right records have been added. The zone files can be found in `/var/named` under the name `CORONA.local` and `56.168.192.in-addr.arpa`. 
Open these in your favorite text editor.
The files should look like this:
### CORONA.local
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

### 56.168.192.in-addr.arpa
```
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

## Vagrant cleanup

When the test has concluded you should destroy the Vagrant environment by using the `vagrant destroy -f` command in your PowerShell command line.
<p>&nbsp;</p>
Authors: Wouter Borloo & Glenn Delanghe
