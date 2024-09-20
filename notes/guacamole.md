Generate the DB initial script
```
docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --mysql > guac_db.sql
```

Start the DB service  
Create the file named : guacamole.yml with the following codes:

```
version: '3.9'

networks:
  net_guacamole:
    name: net_guacamole
    external: true

services:
  guacdb:
    container_name: guacdb
    hostname: guacdb
    image: mysql/mysql-server:8.0.23-1.1.19
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: MariaDBRootPSW
      MYSQL_DATABASE: guacamole_db
      MYSQL_USER: guacamole_user
      MYSQL_PASSWORD: MariaDBUserPSW
    volumes:
      - /data/guacamole/mysql:/docker-entrypoint-initdb.d:ro
      - /data/guacamole/mysql/data:/var/lib/mysql/:rw
    networks:
      - net_guacamole
```

Start the DB container
```
docker compose -f guacamole.yml up -d
```

Copy the initial script into the cdb container
```
docker cp guac_db.sql guacdb:/guac_db.sql
```

Opening a shell and initializing the db:
```
docker exec -it guacdb bash
cat /guac_db.sql | /usr/bin/mysql -u root -p guacamole_db
exit
```

Stop the DB container
```
docker compose -f guacamole.yml down
```

Extend the guacamole.yml with the rest of the service
```

  guacd:
    image: guacamole/guacd:latest
    container_name: guacd
    hostname: guacd
    restart: unless-stopped
    volumes:
      - /data/guacamole/guacd/drive:/drive:rw
      - /data/guacamole/guacd/record:/record:rw
    networks:
      - net_guacamole

  guacamole:
    image: guacamole/guacamole:latest
    container_name: guacamole
    hostname: guacamole
    restart: unless-stopped
    depends_on:
      - guacd
      - guacdb
    environment:
      GUACD_HOSTNAME: guacd
      MYSQL_HOSTNAME: guacdb
      MYSQL_DATABASE: guacamole_db
      MYSQL_USER: guacamole_user
      MYSQL_PASSWORD: MariaDBUserPSW
    ports:
      - 8081:8080/tcp
    networks:
      - net_guacamole

```

Start all the service
```
docker compose -f guacamole.yml up -d
```

