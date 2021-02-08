# Using postgresql with wordpress

## installation guide

- Git clone the pg4wp repo in the wp-content directory

> git clone <https://github.com/gmercey/PG4WP.git>

- Rename the PG4WP directory to pg4wp

> mv /var/www/wordpress/wp-content/PG4WP /var/www/wordpress/wp-content/pg4wp

- Copy the db.php file to the wp-content directory

> mv /var/www/wordpress/wp-content/

- install the php-psql connector:

> yum install php-pgsql

- Restart Nginx

> systemctl restart nginx

- Restart Postgresql

> systemctl restart postgresql

- Continue the wordpress installation

## drupal

Installing drupal

- wget drupal latest version
- install php-psql connector
- change configuration file nginx
- install postgresql
- create user and database
- SE LINUX 

```bash
setsebool -P httpd_can_network_connect 1
setsebool -P httpd_can_network_connect_db 1
semanage fcontext -a -t httpd_sys_rw_content_t 'files'
setsebool -P httpd_unified 1
```
