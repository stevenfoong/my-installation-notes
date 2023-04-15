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

amazon-linux-extras install mate-desktop1.x  
amazon-linux-extras install java-openjdk11  
yum install xterm  

wget https://dlcdn.apache.org/directory/studio/2.0.0.v20210717-M17/ApacheDirectoryStudio-2.0.0.v20210717-M17-linux.gtk.x86_64.tar.gz
tar -zxvf ApacheDirectoryStudio-2.0.0.v20210717-M17-linux.gtk.x86_64.tar.gz

cd ApacheDirectoryStudio  
./ApacheDirectoryStudio  
```


default login  
id: uid=admin,ou=system  
password: secret

Change the admin password 
Create additional admin account for other module
