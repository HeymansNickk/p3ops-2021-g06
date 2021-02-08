# Automatization webserver

## Desired outcome

A working webserver running PostgreSQL, Php, Nginx and Drupal. This all using the command: 'vagrant up (charlie)'

## Requirements

- Host machine running Vagrant for host setup & Ansible for provisioning

## Step-by-step plan

1. Pull the following from [Github](https://github.com/bertvv/ansible-skeleton.git)
2. In the vagrant-hosts.yml, create a host, see the example below

```Yaml
    - name: charlie
      ip: 10.0.2.195
```

3. Next, go to ansile/site.yml and past the following code. This will install the following services:

    - A basic setup for a linux box
    - A postgresql database
    - A webservice: Nginx
    - Php
    - Drupal service
    - A server monitoring tool

```yaml
- hosts: charlie
  become: true
  vars_files:
    - host_vars/charlie.yml
  roles:
    - bertvv.rh-base
    - geerlingguy.postgresql
    - geerlingguy.nginx
    - geerlingguy.php
    - geerlingguy.php-mysql
    - geerlingguy.composer
    - geerlingguy.drush
    - geerlingguy.drupal

- hosts: all
  tasks:
    - name: install Cockpit
      package:
        name:
          - cockpit
          - cockpit-dashboard
    - name: Ensure Cockpit is running
      service:
        name: cockpit.socket
        state: started
        enabled: true
    - name: Allow traffic to Cockpit dashboard through the firewall
      firewalld:
        port: 9090/tcp
        state: enabled
        permanent: true
```

4. Create the following file, charlie.yml, in /ansible/host_vars. In this file you are able to make changes to certain variables for the roles you will install.

```yaml
# charlie.yml
---
php_mysql_package:
  - php-mysqlnd

rhbase_install_packages:
  - git

drupal_deploy: true
drupal_build_composer: false
drupal_build_composer_project: false
drupal_deploy_repo: "https://github.com/amazeeio/drupal-example.git"
drupal_deploy_version: master
drupal_deploy_update: false
drupal_deploy_dir: "/var/www/drupal"
drupal_deploy_accept_hostkey: false
drupal_deploy_composer_install: false
drupal_install_site: true
```

5. After this, go to the command line and type: ('vagrant up --no-provision charlie'). This will initialize the box, without provisioning it.
6. When the box has initiated, type in the following command: ('vagrant ssh charlie'). This will create a ssh connection to the web-server box.
7. In the box, type the following commands:

> cd /vagrant
> ./dependencies.sh

8. These commands wil download the roles you need to set up the web-server.
9. After this, run the following command on the host machine, this will provision the box.

> vagrant provision charlie

10. If you want to delete the box, use the following command:

> vagrant destroy charlie

Author: Michiel Vanreybrouck