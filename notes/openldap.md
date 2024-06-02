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
  --env LDAP_CONFIG_ADMIN_ENABLED=yes \
  --env LDAP_CONFIG_ADMIN_USERNAME=configadmin \
  --env LDAP_CONFIG_ADMIN_PASSWORD=configadminpassword \
  bitnami/openldap:latest
```

### To enable user change his own password
#### Create the ldif file
```
vim /data/openldap/modify-acl.ldif
```
```
dn: olcDatabase={2}mdb,cn=config
changetype: modify
add: olcAccess
olcAccess: to attrs=userPassword
  by self write
  by anonymous auth
  by dn.exact="cn=cn=admin,dc=example,dc=org" write
  by * none

dn: olcDatabase={2}mdb,cn=config
changetype: modify
add: olcAccess
olcAccess: to *
  by self write
  by dn.exact="cn=cn=admin,dc=example,dc=org" write
  by * read
```
#### Commit into openldap configuration
```
docker exec -it openldap /bin/bash
```
```
ldapmodify -Y EXTERNAL -H ldapi:/// -f modify-acl.ldif
```
