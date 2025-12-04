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

Reference: local tunnels Useful commands  
https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/do-more-with-tunnels/local-management/tunnel-useful-commands/  

in case the cloudflared not able to reach CF, the cloudflared service will failed to start. then change the protocol might help  
  
Reference: Configure cloudflared parameters  
https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/configure-tunnels/cloudflared-parameters/  

Use this command to edit the cloudflared systemd config file.    
```
systemctl edit --full cloudflared.service
```
Add --protocol http2  
```
/usr/bin/cloudflared --protocol http2 --no-autoupdate tunnel run --token
```
You also can run the cloudflared manually in terminal to troubleshoot the issue.  
```
cloudflared --protocol http2 tunnel run --token
```
