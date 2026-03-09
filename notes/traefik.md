traefik  

traefik.frontend.auth.basic.users:

echo $(htpasswd -nbB username "password") | sed -e s/\\$/\\$\\$/g
