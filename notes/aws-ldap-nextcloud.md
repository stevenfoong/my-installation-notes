## This installation steps is to install Nextcloud with Ldap authentication on AWS linux.

Minimum 4GB RAM, 8GB RAM is recommended  

### Install Docker service
Remember to change the docker compose version

```
amazon-linux-extras install docker -y
systemctl enable docker
systemctl start docker
docker ps -a
curl -SL https://github.com/docker/compose/releases/download/v2.17.2/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version

```

#### Create Docker network

```
docker network create -d bridge ldap
docker network create -d bridge nextcloud

```

### Create data folder

```
mkdir -p /data/ldap
mkdir -p /data/nextcloud/app
mkdir -p /data/nextcloud/db
mkdir -p /data/lam/config

```

### Install DS389

```
cat << EOF > ds389.yml
version: '3.9'

networks:
  ldap:
    name: ldap
    external: true
    
services:
  ldap:
    image: 389ds/dirsrv:2.2
    container_name: ldap
    restart: unless-stopped
    networks:
      - ldap
    ports:
      - "389:3389"
    volumes:
      - /data/ldap:/data
EOF

```

```
docker-compose -f ds389.yml up -d
docker logs ldap 2>&1 |grep "Set cn=Directory Manager password"

```
Record the Directory Manager password and keep it safe.  
  
Now let launch the terminal from the container    
```
docker exec -it ldap /bin/bash

```
Execute this command within the container. Remember to change the suffix
```
dsconf localhost backend create --suffix dc=example,dc=com --be-name userRoot  
exit

```

Add the line into /data/ldap/config/container.inf. Remember to change the suffix
```
echo "basedn = dc=example,dc=com" >> /data/ldap/config/container.inf

```

Now let launch the terminal from the container again    
```
docker exec -it ldap /bin/bash

```
Execute this command within the container. Remember to change the suffix
```
dsidm localhost initialise  
exit

```





### Install Apache Directory Studio
This step is optional. You can skip if you don't need GUI ldap administration tool.  

```
amazon-linux-extras install mate-desktop1.x -y
amazon-linux-extras install java-openjdk11 -y 
yum install xterm -y

```

Login as ecs-user and make sure X11 forwarding is available

```
wget https://dlcdn.apache.org/directory/studio/2.0.0.v20210717-M17/ApacheDirectoryStudio-2.0.0.v20210717-M17-linux.gtk.x86_64.tar.gz
tar -zxvf ApacheDirectoryStudio-2.0.0.v20210717-M17-linux.gtk.x86_64.tar.gz
cd ApacheDirectoryStudio  
./ApacheDirectoryStudio  

```
Create new ldap connection.  
Connection name: Local ldap  
Hostname: 127.0.0.1  
Port: 389  

Click Next button  

Bind DN or User: cn=Directory Manager  
Bind password: [Password that you found in the docker logs]  

Click Finish button  

If you configure correctly, you should be able to connect the ldap server.  

### Install Ldap Account manager (LAM) and self service portal

```
cat << EOF > ldap-mgmt.yml
version: '3.9'

networks:
  ldap:
    name: ldap
    external: true
    
services:
  ldap-mgmt:
    image: ghcr.io/ldapaccountmanager/lam:stable
    container_name: ldap-mgmt
    restart: unless-stopped
    environment:
      - LAM_SKIP_PRECONFIGURE=true
    networks:
      - ldap
    volumes:
      - /data/lam/config:/var/lib/ldap-account-manager/config
    
  portal:
    image: ltbproject/self-service-password:1.5
    container_name: portal
    restart: unless-stopped
    networks: 
      - ldap

EOF
docker-compose -f ldap-mgmt.yml up -d

```

