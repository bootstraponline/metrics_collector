# Optional Firewall

Setup firewall rules based on this [linode article](https://library.linode.com/securing-your-server)

`nano /etc/iptables.firewall.rules`

Make sure to adjust the http server ports and the random ssh port.

```
*filter
 
#  Allow all loopback (lo0) traffic and drop all traffic to 127/8 that doesn't use lo0
-A INPUT -i lo -j ACCEPT
-A INPUT -d 127.0.0.0/8 -j REJECT
 
#  Accept all established inbound connections
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
 
#  Allow all outbound traffic - you can modify this to only allow certain traffic
-A OUTPUT -j ACCEPT

#  Allow HTTP and HTTPS connections from port 3000
-A INPUT -p tcp --dport 3000 -j ACCEPT
 
#  Allow SSH connections
#
#  The -dport number should be the same port number you set in sshd_config
#
-A INPUT -p tcp -m state --state NEW --dport 123RandomPort321 -j ACCEPT

#  Log iptables denied calls
-A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables denied: " --log-level 7

#  Drop all other inbound - default deny unless explicitly allowed policy
-A INPUT -j DROP
-A FORWARD -j DROP

COMMIT
```

Activate the rules. Make sure you can still login & the web service works.

`iptables-restore < /etc/iptables.firewall.rules`

If everything is working then auto load the rules on startup.

```
nano /etc/network/if-pre-up.d/firewall

#!/bin/sh
/sbin/iptables-restore < /etc/iptables.firewall.rules
chmod +x /etc/network/if-pre-up.d/firewall
```