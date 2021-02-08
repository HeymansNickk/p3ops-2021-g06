# Test plan Webserver

## Testing environment

In this test we are going to set up the web server using vagrant and ansible. This test will check if you can complete the configuration correctly. And will check if all the necessary services are running. The

## Vagrant

Before testing the web server, we need to set up the webserver using vagrant. Navigate to the github repository, the src folder, linux, and then enter the following command:

> vagrant up charlie

This command will create the web server and provision the webserver.

## Connect to the web server

Once the webserver is done with the provisioning process, enter the following command to connect to the remote server.

> vagrant ssh charlie

## Check if the follwing services are running

### Check if Nginx is running

Check if Nginx is running with the following command:

> systemctl status nginx

### Check if php is running

Check if php is running with the following command:

> systemctl status php-fpm

### Check if postgres is running

Check if postgres is running with the following command:

> systemctl status postgresql

## Check if the database has initialized properly

To check if the database has been initialized correctly, run the following commands:

```bash
su - postgres
psql
\l+
```
In the output of the final command, you can see the database drupal. This means that the database has been initialized successfully.

## Check if the drupal page shows

To see if the webserver is running correctly, you can surf to the following website: 192.168.56.15

If everythin is correctly installed, you should see the following screen.

![WorkingDrupal](https://websitesetup.org/wp-content/uploads/2019/02/drupal-installation-step-1-768x418.jpg)

## Installing drupal

- If everything is working as expected, then you can click save and continue.
- Next choose the demo installation profile
- Click save and continue
- Enter the following:

> Database type: postgresql
> Databse username: drupal
> Databse password: drupal

- Click save and continue, drupal will now be installed
- Enter the following for "Configure site"

> Site name: test
> Site email: test@example.com
> Username: test
> Password: test
> Confirm password: test
> Email address: test@example.com

- Click save and continue
- You have now successfully configured drupal and ready to use drupal
