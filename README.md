### XMLRPC Server + Flexisip-Account-Manager working on CentOS7 Docker Container.

### Test Docker Environment for deploying the production CentOS System

---

**1. Build CentOS7 Base Image with working systemd**
```
$ cd dockerfiles/centos7_systemd_base_image
$ $ docker build --rm -t local/c7-systemd .
```
Confirm this image
```
$ docker images
REPOSITORY  local/c7-systemd 
```

**2. Build LAMP Server image besed on local/c7-systemd**
```
$ docker-compose -f docker-compose.lamp.yml build
```

**3. Build Flexisip SIP Server image besed on local/c7-systemd**
```
$ docker-compose -f docker-compose.flexisip.yml build
``` 

**4. How to run above images
On Ubuntu Host
```
$ docker run -ti -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /tmp/$(mktemp -d):/run --network host --name lamp-c7 centos7environment_lamp-c7 
$ docker run -ti -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /tmp/$(mktemp -d):/run --network host --name flexisip-c7 centos7environment_flexisip-c7 
```

Others Linux OS
```
$ docker run -ti -v /sys/fs/cgroup:/sys/fs/cgroup:ro --network host --name lamp-c7 centos7environment_lamp-c7
$ docker run -ti -v /sys/fs/cgroup:/sys/fs/cgroup:ro --network host --name flexisip-c7 centos7environment_flexisip-c7
```

If you want to deploy on the production CentOS system, check the following dockerfile

`docker_files/lamp-c7`
`docker_files/flexisip-c7`





