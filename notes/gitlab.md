git clone using ssh from gitlab with different ssh port number  
```
git clone ssh://git@123.123.123.123:8022/project-or-group/repo-name.git
```  

You will need to create a self sign cert , if you plan to use reverse proxy and let the reverse proxy to handle the cert. you will also need to rename all three files with the domain name of gitlab
```
mkdir -p /data/gitlab/config/ssl
cd /data/gitlab/config/ssl
openssl genrsa -out tls.key 2048
openssl req -new -key tls.key -out cert.csr
openssl x509 -in cert.csr -out tls.crt -req -signkey tls.key -days 3650
```
