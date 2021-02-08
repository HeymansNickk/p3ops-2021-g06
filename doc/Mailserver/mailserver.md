# Automatization mailserver

## Desired outcome

A working mailserver running Postfix, DoveCot, Spamassassasin and ClamAV. This all using the command: 'vagrant up (delta)'

## Requirements

- Host machine running Vagrant for host setup & Ansible for provisioning

## Background information
### Postfix
Postfix is an open source message transport agent which was developed as a more secure and easier to configire alternative to ,the popular, Sendmail. Sendmail is difficult to maintain and had multiple security breaches. Postfix was dessigned to process very large amounts of email traffic and serves 2 purposes: 
1) It’s responsible for transporting email messages from a mail client/mail user agent (MUA) to a remote SMTP server.
2) It’s also used to accept emails from other SMTP servers.
### Dovecot
Dovecot is an open source IMAP and POP3 email server for Linux systems which was written with security primarily in mind. It's fast, simple to set up, requires no special administration and it uses very little memory. 
### Spammassassin
Apache Spamassassin is a program used for mail spam filtering and uses a variety of spam-detection techniques to do so. The program can be integrated with the mail server to automatically filter all mail. It can also be run by individual users on their own mailbox and integrates with several mail programs. SpamAssassin is highly configurable; if used as a system-wide filter it can still be configured to support per-user preferences. 
### Clamav
ClamAV is an open source antivirus engine for detecting trojans, viruses, malware & other malicious threats.
### Centralized user management
Lightweight Directory Access Protocol (LDAP) is a mechanism for interacting with directory servers. It can be used for authentication and to exchange information users, systems, networks, services, and applications throughout the domain. A common use of LDAP is to provide a central place to store usernames and passwords. This allows many different applications and services to connect to the LDAP server to validate users (including the mailserver).


## manual steps
### ssl configuration
- openssl certs 
> openssl genrsa -des3 -out deltaMail.key 2048  
- chmod 600 on the .key file 
- generate a certificate sign request
> openssl req -new -key deltaMail.key -out deltaMail.csr
- request actual cert
> openssl x509 -req -days 365 -in deltaMail.csr -signkey deltaMail.key -out deltaMail.crt
- generate a nopass
> openssl rsa -in deltaMail.key -out deltaMail.key.nopass
- move nopass to key file
> mv deltaMail.key.nopass deltaMail.key
- create a certificate authority
> openssl req -new -x509 -extensions v3_ca -keyout cakey.pem -out cacert.pem -days 365
- Set permissions
> chmod 600 deltaMail.key

> chmod 600 cakey.pem
- Moving keys and certs into the right directory
> mv deltaMail.key /etc/ssl/private

> mv deltaMail.crt /etc/ssl/certs/

> mv cakey.pem /etc/ssl/private

> mv cacert.pem /etc/ssl/certs/

### Postfix configuration
- config file aanpassen
```
postconf -e "smtpd_tls_auth_only = no"
postconf -e "smtpd_use_tls = yes"
postconf -e "smtp_use_tls = yes"
postconf -e "smtpd_tls_key_file = /etc/ssl/private/deltaMail.key"
postconf -e "smtpd_tls_cert_file = /etc/ssl/private/deltaMail.crt"
postconf -e "smtpd_tls_CAfile = /etc/ssl/certs/cacert.pem"
virtual_alias_maps = hash:/etc/postfix/virtual
virtual_mailbox_domains = hash:/etc/postfix/virtual-mailbox-domains
virtual_mailbox_maps = hash:/etc/postfix/virtual-mailbox-users
virtual_transport = dovecot
dovecot_destination_recipient_limit = 1
```
### Dovecot configuration
- 10-ssl.conf aanpassen
```
ssl = required
ssl_cert = </etc/ssl/certs/deltaMail.crt
ssl_key = </etc/ssl/private
```
- 10-auth.conf aanpassen
> disable_plaintext_auth = yes
- 10-mail.conf aanpassen
```
mail_location = maildir:~/Maildir
#mail_location = maildir:~/mail/
mail_privileged_group = mail
```
### Clamav install
EPEL(Extra Packages for Enterprise Linux) repository is necessary to install Clamav.
> sudo yum install epel-release && yum update
 
Installing ClamAV.
> sudo yum install clamav-server clamav-data clamav-update clamav-filesystem clamav clamav-scanner-systemd clamav-devel clamav-lib clamav-server-systemd -y

Get the antivirus signatures/defenitions
> sudo freshclam

Configuring SELinux
> sudo setsebool -P antivirus_can_scan_system 1

Clamav is now installed and can configure cronjobs to plan scans or it can run a quick scan using `clamdscan`.

### Spamassassin install
Install Spamassassin
> yum install spamassassin

Create the `spamfilter` group used by the user that will run the `spamassassin service`.
> groupadd spamfilter

Create new user `spamfilter` with a home directory of `/usr/local/spamassassin` and add it to the `spamfilter` group you just created.
> useradd -g spamfilter -s /bin/false -d /usr/local/spamassassin spamfilter

> chown spamfilter: /usr/local/spamassassin

Configure Spamassassin by editing the `/etc/spamassassin/local.cf` file and changing the following settings.
```
required_hits 5
report_safe 0
rewrite_header Subject [**SPAM**]
required_score 5.0
```
Next edit the `/etc/sysconfig/spamassassin` file.
```
SAHOME="/usr/local/spamassassin"
SPID_DIR="/var/run/spamassassin"
SUSER="spamfilter"
SPAMDOPTIONS="-d -c -m5 --username ${SUSER} -H ${SAHOME} -s ${SAHOME}/spamfilter.log"
```
Start and enable Spammassassin to run on startup. 
> systemctl start spammassassin

> systemctl enable spammassassin

Configuring Postfix to use spammassassin. 
Edit the `/etc/postfix/master.cf` file and edit the following lines:
```
smtp      inet  n       -       n       -       -       smtpd -o content_filter=spamassassin
spamassassin unix -     n       n       -       -       pipe user=spamfilter argv=/usr/bin/spamc -f -e  /usr/sbin/sendmail -oi -f ${sender} ${recipient}
```

Always restart a service after editing a configuration file.
> systemctl restart postfix

Spammassassin can be tested by sending an email with `XJS*C4JDBQADN1.NSBN3*2IDNEN*GTUBE-STANDARD-ANTI-UBE-TEST-EMAIL*C.34X ` as the subject. This will trigger spammassassin to flag the mail. The header of the email should look like this:
```
X-Spam-Flag: YES
X-Spam-Level: **************************************************
X-Spam-Status: Yes, score=1000.0 required=5.0 tests=GTUBE,RCVD_IN_DNSWL_NONE,
    TVD_SPACE_RATIO autolearn=no version=3.3.1
....
```
### Adding users 
``` yaml
yum install mailx
adduser bob
passwd vagrant
adduser ben
passwd vagrant
```

### Sending testmail
- Send mail from user Vagrant to root user 
> [ben@delta ~]$ sendmail bob@CORONA2020.local
> dit is een test
> .
- Read the mail
> [bob@delta ~] cd /mail/new
- ls om alle mails te zienen
- cat 'naam van de mail' om de mail te lezen


### Centralized user management
- Creating local users basad on LDAP queries to the domain controller.
Installing the correct packages.
- Joining a domain. *This does not work. I have added the "_ldap._tcp.dc._msdcs" service to the DNS server and the variables on the "bertvv.mailserver" role are correct.*
> realm join CORONA2020.local --user=vagrant


## Automated setup using Anisble
### Step-by-step plan

1. Pull the following from [Github](https://github.com/bertvv/ansible-skeleton.git)
2. In the vagrant-hosts.yml, create a host, see the example below

```Yaml
    - name: delta
      ip: 192.168.56.196

```

3. Next, go to ansile/site.yml and past the following code. This will install the following services:

    - A basic setup for a linux box
    - The mailserver role:
      - Postfix role
      - Dovecot role
      - spamassassing
      - Clamav

```yaml
- hosts: mail
  become: true
  roles:
    - bertvv.rh-base
    - bertvv.mailserver
  post_tasks:
    - name: Remove the NAT default gateway on eth1
      shell: nmcli con modify "System eth1" ipv4.never-default true
    - name: Configure default gateway on eth1
      shell: nmcli con modify "System eth1" ipv4.never-default false
    - name: Add default gateway
      shell: nmcli con modify "System eth1" ipv4.gateway 192.100.100.193
    - name: Restart network service
      systemd:
        name: network.service
        state: restarted
```
4. Create the following file, delta.yml, in /ansible/host_vars. In this file you are able to make changes to certain variables for the roles you will install.

```yaml
# delta.yml
---
rhbase_install_packages:
  - git
  - vim
  - mailx
  - telnet 
  - epel-release

rhbase_remove_packages:
  - sendmail

rhbase_selinux_booleans:
  - antivirus_can_scan_system 

rhbase_firewall_allow_services:
  - imap
  - imaps
  - pop3
  - pop3s
  - smtp
  - smtps
  - smtp-submission
  - http
  - https

rhbase_firewall_allow_ports:
  - 587/tcp
  - 465/tcp
  - 110/tcp
  - 143/tcp
  

rhbase_users:
  - name: nick1
    password: '$1$RigxC3EO$k4ePwLDA1QqSPPqOezYb60' #Vagrant
    groups:
      - vagrant
  - name: nick2
    password: '$1$RigxC3EO$k4ePwLDA1QqSPPqOezYb60' #Vagrant
    groups:
      - vagrant


postfix_myhostname: 'delta.CORONA2020.local'
postfix_mydomain: 'CORONA2020.local'
#postfix_home_mailbox: 'Maildir/'
postfix_mynetwork: 192.100.100.192/27
postfix_ldap: true
ldap_fqdn1: alfa.CORONA2020.local
ldap_ou: CORONA2020
ldap_dcname: alfa
ldap_domainname: CORONA2020
ldap_root_domain: local

```

5. After this, go to the command line and type: ('vagrant up --no-provision delta'). This will initialize the box, without provisioning it.

6. When the box has initiated, type in the following command: ('vagrant ssh delta'). This will create a ssh connection to the mailserver box.
7. In the box, type the following commands:

> cd /vagrant/scrips
> ./dependencies.sh

8. These commands wil download the roles needed to set up the mailserver.
9. After this, run the following command on the host machine, this will provision the box.

> vagrant provision delta

10. If you want to delete the box, use the following command:

> vagrant destroy delta


## Looking at the logs
The logs can be found in '/var/log/maillog' and show the email being sent and received.
```
[root@delta new]# tail -f /var/log/maillog
Nov  9 12:33:17 delta postfix/smtpd[13743]: connect from localhost[::1]
Nov  9 12:33:37 delta postfix/smtpd[13743]: E03742BFC3: client=localhost[::1]
Nov  9 12:33:49 delta postfix/cleanup[13747]: E03742BFC3: message-id=<20201109123337.E03742BFC3@mail.CORONA2020.local>
Nov  9 12:33:49 delta postfix/qmgr[13648]: E03742BFC3: from=<vagrant@CORONA2020.local>, size=356, nrcpt=1 (queue active)
Nov  9 12:33:49 delta postfix/local[13748]: E03742BFC3: to=<postfixuser@CORONA2020.local>, orig_to=<postfixuser>, relay=local, delay=15, delays=15/0.01/0/0, dsn=2.0.0, status=sent (delivered to maildir)
Nov  9 12:33:49 delta postfix/qmgr[13648]: E03742BFC3: removed
Nov  9 12:33:51 delta postfix/smtpd[13743]: disconnect from localhost[::1] ehlo=1 mail=1 rcpt=1 data=1 quit=1 commands=5
Nov  9 12:37:11 delta postfix/anvil[13745]: statistics: max connection rate 1/60s for (smtp:::1) at Nov  9 12:33:17
Nov  9 12:37:11 delta postfix/anvil[13745]: statistics: max connection count 1 for (smtp:::1) at Nov  9 12:33:17
Nov  9 12:37:11 delta postfix/anvil[13745]: statistics: max cache size 1 at Nov  9 12:33:17
```

Author: Nick Heymans
### Resources
- https://www.linuxtechi.com/install-configure-postfix-mailserver-centos-8/
- https://www.osradar.com/how-to-install-dovecot-on-centos-8/
- https://www.redhat.com/sysadmin/install-configure-postfix
- https://www.datamounts.com/set-postfix-mail-server-dovecot-roundcube-centos-7/
- https://www.gonscak.sk/?p=643
- https://www.tecmint.com/configure-postfix-and-dovecot-with-virtual-domain-users-in-linux/
- https://www.linuxbabe.com/redhat/run-your-own-email-server-centos-postfix-smtp-server
- https://www.digitalocean.com/community/tutorials/how-to-set-up-a-postfix-e-mail-server-with-dovecot
- https://github.com/bertvv/ansible-role-mailserver
- https://github.com/bertvv/ansible-role-rh-base
- https://www.youtube.com/watch?v=WCo7dwtgprg
- https://www.youtube.com/watch?v=XqLgbn1NXTg&t=683s