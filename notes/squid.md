acl protected_api dstdomain '/etc/squid/protected_api.txt'
cache_peer 10.22.14.5 parent 3128 0 default no-query
cache_peer_access 10.22.14.5 allow protected_api
never_direct allow protected_api
