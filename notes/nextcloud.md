mkdir -p /data/nextcloud/db  
mkdir -p /data/nextcloud/app  

docker network create -d bridge nextcloud  

Create db.env, generator a password  
```
MYSQL_PASSWORD=
MYSQL_DATABASE=nextcloud
MYSQL_USER=nextcloud
```
Create nextcloud.yml, generator a password  
```
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
      - MYSQL_ROOT_PASSWORD=
      - MARIADB_AUTO_UPGRADE=1
      - MARIADB_DISABLE_UPGRADE_BACKUP=1
    env_file:
      - db.env
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
      - db.env
    depends_on:
      - nextcloud-db
      - nextcloud-redis
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
      - nextcloud-db
      - nextcloud-redis
    networks:
      - nextcloud

  volumes:
    db: /data/nextcloud/db
    nextcloud: /data/nextcloud/app
  
  networks:
    nextcloud:
    ldap:
  
```
