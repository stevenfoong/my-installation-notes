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
