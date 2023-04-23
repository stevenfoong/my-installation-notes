podman exec -ti zulip-pod-0-zulip bash

su zulip && cd /home/zulip/
$(find ./ -name manage.py) generate_realm_creation_link

output

```
root@zulip-pod-0:/# su zulip && cd /home/zulip/
zulip@zulip-pod-0:~$ $(find ./ -name manage.py) generate_realm_creation_link
Please visit the following secure single-use link to register your 
new Zulip organization:

    https://localhost.localdomain:8443/new/4t1f3r0qet4eu0z0phyork8a

```


Zelip API Doc  
https://zulip.com/api/send-message  

https://chat.example.com/api/v1/server_settings  

Reference:  
https://gist.github.com/flavienbwk/c6fcb5d0ab9ec01eab88cbd9fb2edfb8  
