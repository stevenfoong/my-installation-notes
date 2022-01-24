MYSQL need to initial before start using

Create the DB initialization script
docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --mysql > guac_initdb.sql

copy the guac_initdb.sql into the mysql data folder

then execute this within the docker
cat guac_initdb.sql | /usr/local/mariadb10/bin/mysql -u guacdb_user -p guacamole;
