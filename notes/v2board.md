```
docker exec -it v2board /bin/bash
cd v2board
./init.sh
cp .env .env.orig
sed 's/REDIS_HOST=127.0.0.1/REDIS_HOST=v2board-redis/' .env.orig > .env

php artisan config:cache
php artisan config:clear
php artisan cache:clear
```

```
docker run --restart=always --name xrayr -d -v ./config.yml:/etc/XrayR/config.yml -v ./custom_outbound.json:/etc/XrayR/custom_outbound.json -v ./route.json:/etc/XrayR/route.json --network=host xrayr:latest
```
https://zy.hn/2023/06/06/docker-compose-install-v2board/  
