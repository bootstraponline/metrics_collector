# Required Setup

Enable Ubuntu [automatic security updates](https://help.ubuntu.com/community/AutomaticSecurityUpdates).

```
sudo apt-get install unattended-upgrades ;\
sudo dpkg-reconfigure -plow unattended-upgrades
```

Create a random user/password. Add the user to the sudoers file.

```
adduser randomUserName

password:
randomPassword

usermod -a -G sudo randomUserName
```

Upload your public key to `~/.ssh` Public keys are on github in the form of [github.com/username.keys](https://github.com/bootstraponline.keys)

```
# example scp command
scp -P 123RandomPort321 -r randomUserName@1.2.3.4:/home/randomUserName/metrics_collector .

# if the key is already on the digital ocean server then you can copy it from root
mkdir /home/randomUserName/.ssh
cp /root/.ssh/authorized_keys /home/randomUserName/.ssh/authorized_keys
chown -R randomUserName:randomUserName /home/randomUserName/
```

Configure the ssh daemon.

`nano /etc/ssh/sshd_config`

Disable password authentication.

```
AllowUsers randomUserName@1.2.3.*

PermitRootLogin no 
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM no
Port 123RandomPort321
```

Restart the ssh. In a new terminal, try to ssh in. If ssh is not setup correctly and you're rejected, then fix the config using the first terminal.

```
service ssh restart

ssh 1.2.3.4 -l randomUserName -p 123RandomPort321
```

Docker/discourse requires a slightly different command with PAM disabled.

Note that disabling the PAM will require a [slight change in docker access for discourse](https://meta.discourse.org/t/launcher-ssh-app-failed-due-to-pam-configuration/17317).
use `/var/discourse$ sudo ./launcher enter app` instead of `ssh app`

Install fail 2 ban.

`apt-get install fail2ban`

Make sure to create a [swap file](http://www.nbrogi.me/2014/08/digital-ocean-droplet-crashing/).

Install Ruby/Node using the [phusion passenger-docker guidelines](https://github.com/phusion/passenger-docker).

Ruby is from the [brightbox ruby-ng PPA](https://launchpad.net/~brightbox/+archive/ubuntu/ruby-ng)

```
sudo add-apt-repository ppa:brightbox/ruby-ng ;\
sudo add-apt-repository ppa:chris-lea/node.js ;\
\
sudo apt-get update ;\
sudo apt-get upgrade -y ;\
sudo apt-get dist-upgrade -y ;\
\
sudo apt-get install -y git build-essential
```

Install [required headers](https://github.com/phusion/passenger-docker/blob/a85d29719ce0439305c03e51918b633ca182aca9/image/devheaders.sh) for nokogiri, sqlite, passenger

```
sudo apt-get install -y libxml2-dev libxslt1-dev libsqlite3-dev zlib1g-dev libcurl4-openssl-dev libssl-dev libpcre3-dev ;\
sudo apt-get install -y ruby2.1 ruby2.1-dev nodejs
```

Disable documentation for gem install.

```
sudo -i
echo "gem: --no-ri --no-rdoc" > /etc/gemrc

sudo gem install rake bundler
```

Passenger from brightbox ppa is out of date. install via rubygems instead.

`sudo gem install passenger`

Clone the metrics collector repository

`git clone https://github.com/bootstraponline/metrics_collector.git`

`cd` into the metrics collector and install the dependencies using bundler.

```
# don't use sudo with bundle command
bundle install
```

Install phantomas.

`sudo npm install -g phantomas`

Other commands

```
sudo poweroff
sudo reboot
```

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
