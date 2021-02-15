### XMLRPC Server + Flexisip-Account-Manager working on CentOS7 Docker Container.

### Test Docker Environment for deploying the production CentOS System

---

## 1. Build CentOS7 Base Image with working systemd
```
$ cd dockerfiles/centos7_systemd_base_image
$ docker build --rm -t local/c7-systemd .
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

---

If you want to deploy on the production CentOS system, check the following dockerfiles

`docker_files/lamp-c7`

`docker_files/flexisip-c7`

Implement the commands **COPY, RUN and ENV** lines in your Linux OS terminal.

---

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

## 8. Load Custom Settings by XMLRPC Server(Provisioning)

To active the override remote provisioning, "REMOTE_PROVISIONING_OVERWRITE_ALL" should be set to "True"

`/etc/flexisip-account-manager/provisioning.conf`
```
define("REMOTE_PROVISIONING_OVERWRITE_ALL", True);
```

By Creating the following `default.rc`, this is transformed automatically to provisioning XML file format by 
accessing : `https://sip.example.cpm/flexisip-account-manager/provisioning.php` .

In this case, you should input this URL as provisioning URL into Linphone Android "Remote Setting" menu.

`/opt/belledonne-communications/share/flexisip-account-manager/xmlrpc/default.rc`
```
#
#This file shall not contain path referencing package name, in order to be portable when app is renamed.
#Paths to resources must be set from LinphoneManager, after creating LinphoneCore.
[assistant]
domain=sip.example.com
xmlrpc_url=https://sip.example.com/flexisip-account-manager/xmlrpc.php
```
OR

You can create own provisioning file by XML format like the below;

`/opt/belledonne-communications/share/flexisip-account-manager/xmlrpc/custom_provisioning.xml`
```
<?xml version="1.0" encoding="UTF-8"?>
<config xmlns="http://www.linphone.org/xsds/lpconfig.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.linphone.org/xsds/lpconfig.xsd lpconfig.xsd">
	<section name="assistant">
		<entry name="domain" overwrite="true">sip.example.com</entry>
		<entry name="xmlrpc_url" overwrite="true">https://sip.example.com/flexisip-account-manager/xmlrpc.php</entry>
	</section>
</config>
```
In this case, you should input the below URL as provisioning URL into Linphone Android "Remote Setting" menu.
`https://sip.example.cpm/flexisip-account-manager/custom_provisioning.xml`

Please see also the following reference about provisioning;
https://wiki.linphone.org/xwiki/wiki/public/view/Lib/Features/Remote%20Provisioning/

## 9. Flexisip-Account-Manager Web Frontend

Modify the following file to access localhost database.

`/etc/flexisip-account-manager/fleiapi.env`
```
.....
.....
# Local FlexiAPI database
DB_DATABASE=/var/opt/belledonne-communications/flexiapi/storage/db.sqlite

# External FlexiSIP database
DB_EXTERNAL_DRIVER=mysql
DB_EXTERNAL_HOST=127.0.0.1
DB_EXTERNAL_PORT=3306
#DB_EXTERNAL_DATABASE=/var/opt/belledonne-communications/flexiapi/storage/external.db.sqlite
DB_EXTERNAL_DATABASE=flexisip
DB_EXTERNAL_USERNAME=root
DB_EXTERNAL_PASSWORD=password1234
.....
.....
# SMTP and emails
MAIL_DRIVER=smtp
MAIL_HOST=smtp.XXXXX
MAIL_PORT=XXXX
MAIL_USERNAME=XXXXXXXX
MAIL_PASSWORD=XXXXXXXX
MAIL_FROM_ADDRESS=from@example.com
MAIL_FROM_NAME="${APP_NAME}"
MAIL_ALLOW_SELF_SIGNED=false
MAIL_VERIFY_PEER=true
MAIL_VERIFY_PEER_NAME=true
MAIL_SIGNATURE="The Example Team"

# OVH SMS API variables
OVH_APP_KEY=
OVH_APP_SECRET=
OVH_APP_ENDPOINT=ovh-eu
OVH_APP_CONSUMER_KEY=
OVH_APP_SENDER=

# Google reCaptcha v2 parameters
NOCAPTCHA_SECRET=XXXXXXXXXXXXXXXXXXXX
NOCAPTCHA_SITEKEY=XXXXXXXXXXXXXXXXXXX
```

Implement the following php artisan command in
'/opt/belledonne-communications/share/flexisip-account-manager/flexiapi`
```
$ cd /opt/belledonne-communications/share/flexisip-account-manager/flexiapi
$ chown -R apache:apache /opt/belledonne-communications/share/flexisip-account-manager/flexiapi
$ php artisan key:generate
$ php artisan migrate:rollback
$ php artisan migrate
```

As not exist server.php in /opt/belledonne-communications/share/flexisip-account-manager/flexiapi directory
make it.
`/opt/belledonne-communications/share/flexisip-account-manager/flexiapi/server.php`
```
<?php

/**
 * Laravel - A PHP Framework For Web Artisans
 *
 * @package  Laravel
 * @author   Taylor Otwell <taylor@laravel.com>
 */

$uri = urldecode(
    parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH)
);

// This file allows us to emulate Apache's "mod_rewrite" functionality from the
// built-in PHP web server. This provides a convenient way to test a Laravel
// application without having installed a "real" web server software here.
if ($uri !== '/' && file_exists(__DIR__.'/public'.$uri)) {
    return false;
}

require_once __DIR__.'/public/index.php';

```

Start flexisip-account-manager server:
```
$ php artisan serve --host 127.0.0.1
```
Access

`http://localhost:8000`

If you try latest version frontend, download it from github and copy it into this directory;
`/opt/belledonne-communications/share/flexisip-account-manager/flexiapi`

**Github**
'https://gitlab.linphone.org/BC/public/flexisip-account-manager/tree/master/flexiapi'

![flexiapi create and manage account](/images/flexiapi001.png)

![flexiapi register new account](/images/flexiapi002.png)

![flexiapi register by email](/images/flexiapi003.png)

![flexiapi register by phone](/images/flexiapi004.png)

![flexiapi login](/images/account.png)

![flexiapi login](/images/account_database.png)













