#These are my Personal Docker Containers
Dockerfiles for quickies
Please login to your hub.docker.com account and create a private repo. In order to keep all your nginxplus builds in a single private repo, use the tags to update them. For example, my username is `0snug0`, I named my repo `private`, and I want to tag my nginx plus build as `plusbase`, I would have a full build tag as `0snug0/private:plusbase`

How to build from a `specified Dockerfile`:
```
# Run these in ~/myDocker/.
docker build -f ./Dockerfiles/plusbase.Dockerfile -t user/privateRepo:plusbase .
docker build -f ./Dockerfiles/nginxwaf.Dockerfile -t user/privateRepo:nginxwaf .
```

How to run:
```
docker run -dP --name nginxwaf user/privateRepo:nginxwaf
```

How to debug if container won't start (assuming you're in `./myDocker/`)
```
docker run -dP -v $(pwd)/log:/var/log/nginx --name nginxwaf user/privateRepo:nginxwaf
cat var/log/error.log
```

## What the files mean
* `plusbase.Dockerfile` - basic nginx plus container, no configs are done here
* `nginxwaf.Dockerfile` - plusbase with modsecurity installed, and [recommended](https://raw.githubusercontent.com/SpiderLabs/ModSecurity/master/modsecurity.conf-recommended) base config for modsec.
* `nginxwafcrs.Dockerfile` - nginxwaf with crs 