amazon-linux-extras install docker -y  
systemctl enable docker  
systemctl start docker  
curl -SL https://github.com/docker/compose/releases/download/v2.17.2/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose  
chmod +x /usr/local/bin/docker-compose  
 docker-compose version  
