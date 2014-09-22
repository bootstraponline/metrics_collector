# Installing the Metrics Collector

Install Ruby/Node using the [phusion passenger-docker guidelines](https://github.com/phusion/passenger-docker) as shown below:

- Ruby is from the    [brightbox ruby-ng PPA](https://launchpad.net/~brightbox/+archive/ubuntu/ruby-ng)
- Node.JS is from the [chris-lea node.js PPA](https://launchpad.net/~chris-lea/+archive/ubuntu/node.js/)

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

Install [required headers](https://github.com/phusion/passenger-docker/blob/a85d29719ce0439305c03e51918b633ca182aca9/image/devheaders.sh) for nokogiri, sqlite, passenger as shown below:

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

Note that sudo must not be used with the bundle command.

`bundle install`

Install phantomas.

`npm install --global phantomas`

# Starting the server with passenger

- `nohup` - keeps the process running after we've exited
- `sudo -b` - runs passenger start in the background

```
Only the 'root' user can run this program on port 80. You are currently running
as 'myusername'. Please re-run this program with root privileges with the
following command:

  nohup sudo -b passenger start --port 80 --user=myusername > /dev/null 2>&1;

Don't forget the '--user' part! That will make Phusion Passenger Standalone drop
root privileges and switch to 'myusername' after it has obtained port 80.
```
