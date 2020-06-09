# jekyll-docker

Forked from <https://github.com/envygeeks/jekyll-docker>.

## Ruby

First, use <https://github.com/postmodern/ruby-install> and <https://github.com/postmodern/chruby> to bootstrap Ruby 2.6

```bash
cd /tmp
wget -O chruby-0.3.9.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz
tar -xzvf chruby-0.3.9.tar.gz
cd chruby-0.3.9/
sudo make install
sudo ./scripts/setup.sh
```

```bash
wget -O ruby-install-0.7.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.7.0.tar.gz
tar -xzvf ruby-install-0.7.0.tar.gz
cd ruby-install-0.7.0/
sudo make install
```

```bash
ruby-install ruby 2.6
# >>> Successfully installed ruby 2.6.6 into /home/kvz/.rubies/ruby-2.6.6
```

## Docker

```bash
echo '{
  "experimental": true
}' |sudo tee /etc/docker/daemon.json
sudo systemctl restart docker
```

## Build

```bash
source /usr/local/share/chruby/chruby.sh
source /usr/local/share/chruby/auto.sh
chruby 2.6
echo "2.6" > ~/.ruby-version
# gem install docker-template
bundle install

./script/build kvz/jekyll:4.1.0
bundle exec docker-template push kvz/jekyll:4.1.0
```

