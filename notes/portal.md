### Create data folder
```
mkdir -p /data/portal
```
### Download the config file
```
docker run --detach --name portal ltbproject/self-service-password:1.6
docker cp portal:/var/www/conf/config.inc.php /data/portal/
docker cp portal:/var/www/templates/menu.tpl /data/portal/
docker rm -f portal
```
### Launch the container
```
docker run --detach --name portal \
  -p 8080:80 \
  -v /data/portal/config.inc.php:/var/www/conf/config.inc.php:ro \
  -v /data/portal/menu.tpl:/var/www/templates/menu.tpl:ro \
  ltbproject/self-service-password:1.6
```

#### Add LDAP configuration in /data/portal/config.inc.php
#### Add/Modify the menu in /data/portal/menu.tpl
