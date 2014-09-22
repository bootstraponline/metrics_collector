# Account Provisioning / Security

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

Disabling PAM requires a [slight change in docker access for discourse](https://meta.discourse.org/t/launcher-ssh-app-failed-due-to-pam-configuration/17317). Use `/var/discourse$ sudo ./launcher enter app` instead of `ssh app`

Install fail 2 ban.

`apt-get install fail2ban`

Make sure to create a [swap file](http://www.nbrogi.me/2014/08/digital-ocean-droplet-crashing/).

Commands for power off / reboot.

```
sudo poweroff
sudo reboot
```