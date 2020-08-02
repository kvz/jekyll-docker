# jekyll-docker

It seems it may take some time before there are official Jekyll docker releases, so as an intermediary solution I forked this from <https://github.com/envygeeks/jekyll-docker> and pushed out 4.1.1 docker images under `kevinvz/jeyll:4.1.1`.

> I don't know Ruby or its ecosystem well, and will not have the time to maintain or support this, so use it as is (or probably even better, don't use it at all).

## Prerequisites for building

After a bit of trial and error, here's how I get from a ~vanilla Ubuntu 18.04 machine to building a Jekyll image.

### Ruby

First, use <https://github.com/postmodern/ruby-install> and <https://github.com/postmodern/chruby> to bootstrap Ruby 2.7

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
ruby-install ruby 2.7
# >>> Successfully installed ruby 2.7.1 into /home/kvz/.rubies/ruby-2.7.1
```

### Docker

```bash
echo '{
  "experimental": true
}' |sudo tee /etc/docker/daemon.json
sudo systemctl restart docker

docker login
```

### Deps

```bash
source /usr/local/share/chruby/chruby.sh
source /usr/local/share/chruby/auto.sh
chruby 2.7
echo "2.7" > ~/.ruby-version
# gem install docker-template #<-- probably bundle install actually takes care of this
bundle install
script/install
```

## Build

```bash
bundle exec docker-template build kevinvz/jekyll:4.1.1 --no-push --force --squash

cd jekyll-docker/repos/jekyll
docker push kevinvz/jekyll:4.1.1
# bundle exec docker-template push kevinvz/jekyll:4.1.1
```