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
    image: mariadb:latest
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ‘MariaDBRootPSW’
      MYSQL_DATABASE: ‘guacamole_db’
      MYSQL_USER: ‘guacamole_user’
      MYSQL_PASSWORD: ‘MariaDBUserPSW’
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
cat /guac_db.sql | mysql -u root -p guacamole_db
exit
```
