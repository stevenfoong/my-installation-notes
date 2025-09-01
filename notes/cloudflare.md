```
curl -X PATCH "https://api.cloudflare.com/client/v4/zones/ZONE_ID/settings/ipv6" \
     -H "X-Auth-Email: EMAIL" \
     -H "X-Auth-Key: GLOBAL_API_KEY" \
     -H "Content-Type: application/json" \
     --data '{"value":"off"}'
```

```
docker run --name cf-tunnel -d --restart unless-stopped cloudflare/cloudflared:latest tunnel --no-autoupdate run --token XYZ
```

```
docker run --name cf-nas-tunnel -d --restart unless-stopped -p 445:445 cloudflare/cloudflared:latest access tcp --hostname nas.xyz.com --
url 172.17.0.3:445
```
