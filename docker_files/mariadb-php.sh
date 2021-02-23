#!/bin/bash

# turn on bash's job control
set -m

### Create database and use and set root password in docker container lamp-c7
mariadb -u root -e 'CREATE DATABASE flexisip;'
mariadb -u root -e 'CREATE USER 'flexisip'@localhost IDENTIFIED BY "password1234";'
mariadb -u root -e 'GRANT ALL PRIVILEGES ON flexisip.* TO 'flexisip'@'localhost' IDENTIFIED BY "password1234";'
mariadb -u root -e 'SET PASSWORD FOR 'root'@localhost = password("password1234");'

### Implement the below php commnds in docker container lamp-c7
php /opt/belledonne-communications/share/flexisip-account-manager/tools/create_tables.php
php artisan key:generate
#php artisan migrate:rollback
php artisan migrate
### set an account admin user {account_id}, in advance create user and use user's account_id 
php artisan accounts:set-admin 3
### start api server
php artisan serve --host 127.0.0.1 &
