traefik  

```sudo apt install apache2-utils```

traefik.frontend.auth.basic.users:

echo $(htpasswd -nbB username "password") | sed -e s/\\$/\\$\\$/g
