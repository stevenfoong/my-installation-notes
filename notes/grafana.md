### Create data folder
```
mkdir -p /data/grafana
chown 472:472 /data/grafana
```
### Install grafana using docker
```
docker run -d --name=grafana -p 3000:3000  -v /data/grafana:/var/lib/grafana  grafana/grafana-oss
```
### Enter grafana container
```
docker exec -it grafana /bin/bash
```
### Get list of available plugins
```
grafana-cli plugins list-remote
```
### Install zabbix plugin
```
grafana-cli plugins install alexanderzobnin-zabbix-app
```

### Restart grafana after installing plugins
#### Exit the container if you are still in the container
```
exit
```
#### Restart the container
```
docker restart grafana
```
