```
git clone https://github.com/openmicroscopy/apacheds-docker.git  
cd apacheds-docker  
sed -i 's/openmicroscopy/example/g' ome.ldif ./instance/config.ldif ./instance/ads-contextentry.decoded
sed -i 's/dc=org/dc=com/g' ome.ldif ./instance/config.ldif ./instance/ads-contextentry.decoded
sed -i 's/dc: org/dc: com/g' ome.ldif ./instance/config.ldif ./instance/ads-contextentry.decoded
cd ..  
docker build -t example/apacheds:2.0.0.AM26 apacheds-docker
```
