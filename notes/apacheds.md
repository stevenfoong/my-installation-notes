```
git clone https://github.com/openmicroscopy/apacheds-docker.git  
cd apacheds-docker  
sed -i 's/openmicroscopy/example/g' ome.ldif ./instance/config.ldif ./instance/ads-contextentry.decoded
sed -i 's/dc=org/dc=com/g' ome.ldif ./instance/config.ldif ./instance/ads-contextentry.decoded
sed -i 's/dc: org/dc: com/g' ome.ldif ./instance/config.ldif ./instance/ads-contextentry.decoded
cd ..  
docker build -t example/apacheds:2.0.0.AM26 apacheds-docker  

docker network create -d bridge ldap  
mkdir -p /data/ldap  
docker run --name ldap -d -p 389:10389 --network="ldap" -v /data/ldap:/var/lib/apacheds copaybo/apacheds:2.0.0.AM26
```


default login  
id: uid=admin,ou=system  
password: secret
