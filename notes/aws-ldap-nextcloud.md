## This installation steps is to install Nextcloud with Ldap authentication on AWS linux.
Minimum 4GB RAM, 8GB RAM is recommended  

### This setup will use Cloudflare Zero Trust Tunnel to reach all container, that why no port expose except the ldap port

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

Modify the self service portal configuration. Remember to replace the bind passowrd, the ldap suffix and keyphrase.

```
docker exec portal sed -i 's/$ldap_url = "ldap:\/\/localhost";/$ldap_url = "ldap:\/\/ldap:3389";/g' /var/www/conf/config.inc.php
docker exec portal sed -i 's/$ldap_binddn = "cn=manager,dc=example,dc=com";/$ldap_binddn = "cn=Directory Manager";/g' /var/www/conf/config.inc.php
docker exec portal sed -i "s/$ldap_bindpw = 'secret';/$ldap_bindpw = 'password';/g" /var/www/conf/config.inc.php
docker exec portal sed -i 's/$ldap_base = "dc=example,dc=com";/$ldap_base = "dc=example,dc=com";/g' /var/www/conf/config.inc.php
docker exec portal sed -i 's/$keyphrase = "secret";/$keyphrase = "longersecret";/g' /var/www/conf/config.inc.php

```

### Install Cloudflare tunnel to access the LAM and self service portal
Remember to replace the cloudflare tunnel token

```
cat << EOF > cf-tunnel.yml
version: "3.8"
services:
  cloudflared:
    image: cloudflare/cloudflared:latest
    container_name: cf-tunnel
    restart: unless-stopped
    networks:
      - ldap
      - nextcloud
    command: tunnel --no-autoupdate run --token 

networks:
  ldap:
    name: ldap
    external: true
  nextcloud:
    name: nextcloud
    external: true

EOF

 docker-compose -f cf-tunnel.yml up -d
 
```

### Configure LDAP Account Manager
-> LAM configuration -> Edit server profiles  
Default password for lam profile is lam  
- Server address : ldap://ldap:3389
- Tree suffix : dc=example, dc=com (change accordingly)
- List of valid users: cn=Directory Manager
- Profile passwor - New Password: (Generate a complex password)
- Profile passwor - Reenter Password: (Enter the same complex password)
- Account types - Users - LDAP suffix: ou=people,dc=example,dc=com
- Account types - Groups - LDAP suffix: ou=groups,dc=example,dc=com
- Module settings - Personal - Hidden options uncheck Display name

Click Save button

Try to login and create a new user account.

These fields is mandatory 
- Personal - First name
- Personal - Last name
- Personal - Display Name (This is the login name) 
- Unix - User name (Same as Display Name)
- Unix - Common name (Same as Display Name)

Try to change new user account password.

### Install Nextcloud

Replace the MYSQL_PASSWORD with complex password

```
cat << EOF > nc-db.env
MYSQL_PASSWORD=password
MYSQL_DATABASE=nextcloud
MYSQL_USER=nextcloud
EOF

```

Replace the MYSQL_ROOT_PASSWORD with complex password
domain name for the collabora should be change accordingly , it should be the domain name of the nextcloud server

```
cat << EOF > nextcloud.yml
version: '3'

services:
  db:
    container_name: nextcloud-db
    image: mariadb:10.6
    command: --transaction-isolation=READ-COMMITTED --log-bin=binlog --binlog-format=ROW
    restart: unless-stopped
    volumes:
      - db:/var/lib/mysql:Z
    environment:
      - MYSQL_ROOT_PASSWORD=password
      - MARIADB_AUTO_UPGRADE=1
      - MARIADB_DISABLE_UPGRADE_BACKUP=1
    env_file:
      - nc-db.env
    networks:
      - nextcloud

  redis:
    container_name: nextcloud-redis
    image: redis:alpine
    restart: unless-stopped
    networks:
      - nextcloud

  app:
    container_name: nextcloud-app
    image: nextcloud:apache
    restart: unless-stopped
    volumes:
      - nextcloud:/var/www/html:z
    environment:
      - MYSQL_HOST=nextcloud-db
      - REDIS_HOST=nextcloud-redis
    env_file:
      - nc-db.env
    depends_on:
      - db
      - redis
    networks:
      - nextcloud
      - ldap
      
  cron:
    container_name: nextcloud-cron
    image: nextcloud:apache
    restart: unless-stopped
    volumes:
      - nextcloud:/var/www/html:z
    entrypoint: /cron.sh
    depends_on:
      - db
      - redis
    networks:
      - nextcloud
  
  collabora:
    container_name: nextcloud-collabora
    image: collabora/code
    restart: unless-stopped
    environment:
      - domain=cloud.example.com
    networks:
      - nextcloud
  
volumes:
  db: 
    driver: local
    driver_opts:
      o: bind
      type: none
      device: /data/nextcloud/db
      
  nextcloud:
    driver: local
    driver_opts:
      o: bind
      type: none
      device: /data/nextcloud/app
  
networks:
  nextcloud:
    name: nextcloud
    external: true

  ldap:
    name: ldap
    external: true
  

EOF

```

```
docker-compose -f nextcloud.yml up -d

```
add the following line into /data/nextcloud/app/config/config.php to fix the user not redirect after successful login

```
'overwriteprotocol' => 'https',
```
Restart Nextcloud
```
docker restart nextcloud-app

```

Browse the nextcloud URL  
Create the nextcloud admin account to continue.  
Once the initial installation completed, process to install LDAP authentication modules.  

### Configure Nextcloud LDAP authentication
-> Click on top right user account icon -> Apps  
Search for LDAP user and group backend and Enable it  
-> Click on top right user account icon -> Administration settings -> LDAP/AD integration  
- Host: ldap
- Port: 3389
- User DN: cn=Directory Manager
- Password: password (Change accordingly)
- Save Credentials
- Base DN: dc=exmaple,dc=com (Change accordingly)
- Continue
- Verify settings and count users (It should show the number of user account in ldap)
- Continue
- Type a user name into Test Loginname box and click verify settings
- Continue
- Only these object classes: posixGroup
- Verify settings and count groups (It should show the number of group in ldap)
-> Click on top right user account icon -> Users
All users account will be list here

### Configure Nextcloud office
-> Click on top right user account icon -> Administration settings -> Nextcloud Office  
Enter the domain name of the collabora server into URL (and Port) of Collabora Online-server box and click Save  

In order to verify the Nextcloud office is working, click files icon at the top  
Then click the plus icon and select New Document or New spreadsheet.  
If you able to see the New spreadsheet editor screen , then the Nextcloud office is working fine.  

You can proceed to verify the Nextcloud office real-time co-authoring by sharing a word or spreadsheet with another user and try to open/edit the file at the same time  
# The End
