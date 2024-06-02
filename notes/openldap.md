### Create the data folder
```
mkdir -p /data/openldap
chown 1001:1001 /data/openldap
```

### Launch the openldap container
```
docker run --detach --rm --name openldap \
  -p 1389:1389 \
  -v /data/openldap:/bitnami/openldap \
  --env LDAP_ADMIN_USERNAME=admin \
  --env LDAP_ADMIN_PASSWORD=adminpassword \
  --env LDAP_ROOT=dc=example,dc=org \
  --env LDAP_ADMIN_DN=cn=admin,dc=example,dc=org \
  bitnami/openldap:latest
```
