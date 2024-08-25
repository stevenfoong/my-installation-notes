Raspberry pi install iptables  
```
apt-get install iptables-persistent
```
Save the iptables rules  
```
invoke-rc.d iptables-persistent save
```
enable IP forward  
```
sudo nano /etc/sysctl.conf
```
uncomment line  
```net.ipv4.ip_forward=1```
```
sudo sysctl -p
```
enable NAT at the openvpn client  
```
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i tun0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i eth0 -o tun0 -j ACCEPT
sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"
sudo iptables-restore < /etc/iptables.ipv4.nat
```
At the outgoing point add this to the client configuration  
```
iroute 0.0.0.0 128.0.0.0
```
At other client ad this will redirect all traffic to the other client that have iroute configure  
```
redirect-gateway def1
```
References:  
https://community.openvpn.net/openvpn/wiki/RoutedLans
