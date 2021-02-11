### XMLRPC Server + Flexisip-Account-Manager working on CentOS7 Docker Container.

### Test Docker Environment for deploying the production CentOS System

---

## 1. Build CentOS7 Base Image with working systemd
```
$ cd dockerfiles/centos7_systemd_base_image
$ $ docker build --rm -t local/c7-systemd .
```
Confirm this image
```
$ docker images
REPOSITORY  local/c7-systemd 
```

## 2. Build LAMP Server image besed on local/c7-systemd
```
$ docker-compose -f docker-compose.lamp.yml build
```

## 3. Build Flexisip SIP Server image besed on local/c7-systemd
```
$ docker-compose -f docker-compose.flexisip.yml build
``` 

## 4. How to run above images

Create shared volume for mariadb database
```
$ docker volume create mariadb
```

CentOS7 LAMP Server start by docker-compose.lamp.yml
If you don't run containers under Ubuntu host, move `"MAKE_TEMP=/tmp/$(mktemp -d)"` and delete `"- ${MAKE_TEMP}:/run"` in docker-compose file.
```
$ MAKE_TEMP=/tmp/$(mktemp -d) docker-compose -f docker-compose.lamp.yml up -d
```

CentOS7 Flexisip SIP Server start by docker-compose.flexisip.yml
If you don't run containers under Ubuntu host, move `"MAKE_TEMP=/tmp/$(mktemp -d)"` and delete `"- ${MAKE_TEMP}:/run"` in docker-compose file.
```
$ MAKE_TEMP=/tmp/$(mktemp -d) docker-compose -f docker-compose.flexisip.yml up -d
```

If you want to deploy on the production CentOS system, check the following dockerfiles

`docker_files/lamp-c7`
`docker_files/flexisip-c7`

## 5. Set mariadb root password
For login to phpmyadmin by "root" admin user, set password in mariadb console.
```
$ mariadb
>MariaDB [(none)]> set password for 'root'@localhost = password("password1234");
```

## 6. Create database for flexisip
In phpmyadmin or mariadb console, create user "flexisip" with the same database "flexisip", password "password1234"


## 7. Modify the following files and create table for flexisip

Input DB_USER, DB_PASSWORD and DB_NAME defined by the above.

`etc/flexisip-account-manager/db.conf`
```
/*
 * The database username.
 *
 * Default value: flexisip_rw
 */
define("DB_USER", "root");

/*
 * The database user's password.
 *
 * Default value:
 */
define("DB_PASSWORD", "password1234");

/*
 * The name of the database.
 *
 * Default value: flexisip
 */
define("DB_NAME", "flexisip");
```
Implement the following script to make flexisip table
```
$ php /opt/belledonne-communications/share/flexisip-account-manager/tools/create_tables.php
```


