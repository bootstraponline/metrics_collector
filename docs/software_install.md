# Installing the Metrics Collector

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

Note that sudo must not be used with the bundle command.

`bundle install`

Install phantomas.

`sudo npm install -g phantomas`