#These are my Personal Docker Containers
Dockerfiles for quickies
Please login to your hub.docker.com account and create a private repo. In order to keep all your nginxplus builds in a single private repo, use the tags to update them. For example, my username is `0snug0`, I named my repo `private`, and I want to tag my nginx plus build as `plusbase`, I would have a full build tag as `0snug0/private:plusbase`

## How to use these files
### NGINX repos
In order to build a NGINX+ container, you must first put `nginx-repo.crt` and `nginx-repo.key` in the `myDocker/` directory.

### Build Image
> **NOTE:** You must always build plusbase image first

How to build from a specified `Dockerfile`:

```
# Run these in ~/myDocker/.
docker build -f ./Dockerfiles/plusbase.Dockerfile -t user/privateRepo:plusbase .
docker build -f ./Dockerfiles/nginxwaf.Dockerfile -t user/privateRepo:nginxwaf .
```

### Run Container
Examples of how to run:
```
docker run -dp 8000:80 --name base user/privateRepo:baseplus
docker run -dP --name nginxwaf user/privateRepo:nginxwaf
```

### Debug container
```
docker logs nginxwaf
```

## What the files mean
### Dockerfiles
* `baseplus.Dockerfile` - basic nginx plus container, uses `default.conf`
* `nginxwaf.Dockerfile` - plusbase with modsecurity installed, and [recommended](https://raw.githubusercontent.com/SpiderLabs/ModSecurity/master/modsecurity.conf-recommended) base config for modsec. Uses `conf.d/proxy-modsec1.conf` check `conf.d/proxy-modsec2.conf` under **conf.d files** below for more advanced uses
* `nginxwafcrs.Dockerfile` - nginxwaf with core rule sets and test set
* `nginxlua.Dockerfile` - experimental build with lua installed
* `nginxallmodules.Dockerfile` - all nginx plus modules installed

### conf.d/ files
* `default.conf` - default conf
* `lua.conf` - uses lua code
* `proxy-modsec1.conf` - basic modsec config, depending on `modsec/main.conf` you may not get all the rules
* `proxy-modsec2.conf` - example configuration for DDoS and Caching

### modsec/ files
* `rules/` - OWASP CRS FOSS rules
* `crs-setup.conf` - the setup for CRS rules
* `main1.conf` - `includes` for only basic setup
* `main2.conf` - `inculdes` for OWASP CRS rules
* `modsecurity.conf` - recommended configuration

Experementing with LUA
apt-get install luarocks
luarocks install luasocket