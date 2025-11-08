# Build the Unbound Docker iamge #
  
1. Git clone the unbound docker image from this repo [MatthewVance/unbound-docker](https://github.com/MatthewVance/unbound-docker/tree/master)  
2. Duplicate the latest version folder and rename it accordingly.  
3. Base on the info from this link
[UNBOUND Download link](https://nlnetlabs.nl/projects/unbound/download/)
modify these variable in the Dockerfile accordingly  
```
ENV NAME=unbound \
    UNBOUND_VERSION=1.24.1 \
    UNBOUND_SHA256=7f2b1633e239409619ae0527f67878b0f33ae0ec0ee5a3a51c042c359ba1eeab \
    UNBOUND_DOWNLOAD_URL=https://nlnetlabs.nl/downloads/unbound/unbound-1.24.1.tar.gz
```  
Remember to change this line accordingly.  
```
   cd unbound-1.24.1 && \
```
4. Build the unbound docker image. Tag the image version accordingly.  
```
docker build -t unbound:1.24.1 .
```

# Configure Unbound to resolve local domain #  
Modify the config file /data/unbound/opt/unbound/etc/unbound/unbound.conf, assuming your config is here.  
  
Remark these lines    
```
auto-trust-anchor-file: "var/root.key"

harden-algo-downgrade: yes
harden-unknown-additional: yes
harden-below-nxdomain: yes
harden-dnssec-stripped: yes
harden-glue: yes
harden-large-queries: yes
```
  
Add these lines in the server block  
```

    private-domain: payment.local
    private-domain: "xyz.ap-northeast-1.rds.amazonaws.com."

    do-ip6: no
    prefer-ip4: yes

```
  
Add these lines at the bottom of the file  
```
auth-zone:
    name: "payment.local." 
    zonefile: "/opt/unbound/etc/unbound/zones/payment.local.zone" 
    for-upstream: yes       
    for-downstream: no
```
  
Create the zone file here /data/unbound/opt/unbound/etc/unbound/zones/payment.local.zone  
```
$TTL 3600      ; Default TTL of 1 hour
$ORIGIN payment.local. ; The zone origin
; SOA Record
@       IN SOA  ns1.payment.local. admin.payment.local. (
                  2025110801 ; Serial (YYYYMMDDnn) - Increment on every change
                  10800      ; Refresh (3 hours)
                  3600       ; Retry (1 hour)
                  604800     ; Expire (1 week)
                  3600 )     ; Minimum TTL (1 hour)

; NS Records (Name Server)
@       IN NS   ns1.payment.local.

; A Records (Host Records)
ns1     IN A    10.1.1.1

db      IN CNAME db.xyz.ap-northeast-1.rds.amazonaws.com.
redis   IN A 10.1.1.1
rabbitmq        IN A 10.1.1.1
mssql   IN A 10.1.1.1
linux01 IN A 10.1.1.1



; Example PTR Record (for reverse lookup - often handled separately or via a stub zone)
; If you need reverse lookups for a specific subnet (e.g., 192.168.1.0/24 in in-addr.arpa.1.168.192.in-addr.arpa)
; you would typically configure that as a separate auth-zone or use local-data-ptr.

```
  
Use this command to spin up the docker image.  
```
docker run --name=my-unbound --volume=/data/unbound/opt/unbound/etc/unbound:/opt/unbound/etc/unbound/ --publish=53:53/tcp --publish=53:53/udp --restart=unless-stopped --detach=true unbound:1.24.1
```
  
