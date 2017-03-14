Demo to show native JWT/OpenID connect support in NGINX Plus. It utilizes Google as the identity provider to provide SSO to a simple web application

## Prerequisites and Required Software

The following software needs to be installed on your laptop:

* Docker -- [Docker for Mac](https://www.docker.com/products/docker#/mac) is a good option
* Copy your NGINX Plus repo certificate and key to the nginxplus/ directory


## Setting up the demo

Go to the nginxplus directory from demo's home directory first

```
$ cd nginxplus
```
and type:
```
$ docker build -t kjwtdemo_nginxplus .
$ docker run --name nginx-jwt -d -p 80:80 kjwtdemo_nginxplus
```

This will set everthing and you would now have a docker container running NGINX Plus listening on port 80 on your Docker Host
```
$ docker ps
CONTAINER ID        IMAGE                COMMAND                  CREATED             STATUS              PORTS                                   NAMES
67a52f574f18        kjwtdemo_nginxplus   "nginx -g 'daemon off"   About an hour ago   Up About an hour    443/tcp, 0.0.0.0:80->80/tcp, 8080/tcp   nginx-jwt
```

## Running the demo

1. Open up a browser window and go to http://localhost. You would see a html page like below with a button to Login into your Google account
![alt text](https://cloud.githubusercontent.com/assets/1437560/18600893/dd36da66-7c14-11e6-9473-93edf6eecfde.png "Homepage with Google login")

1. Once you login using your Google account, you would see a page like this indicating that you have logged in
![alt text](https://cloud.githubusercontent.com/assets/1437560/18600897/e1628a4a-7c14-11e6-93a3-83280920a337.png "Homepage with Google login")

1. Now you can click on 'private area' which would redirect you to http://localhost/private/ and you would see an html page like this
![alt text](https://cloud.githubusercontent.com/assets/1437560/18600900/e3d21fca-7c14-11e6-9952-beb0036d694e.png  "Homepage with Google login")

1. If you click on the link 'Page Two' you woud see this page
![alt text](https://cloud.githubusercontent.com/assets/1437560/18600904/e66fc19c-7c14-11e6-94f5-642e2e1f88f4.png  "Homepage with Google login")

1. This shows that we were only able to access the URLs beginning with /private/ using a valid OpenID Connect token (JWT) from Google. The NGINX Plus config which was used to achieve this is below

```
server {
    listen 80;
    root /usr/share/nginx/docroot;

    # Requests to private area require a valid OpenID Connect token (JWT)
    #
    location /private/ {
        # JWT config
        deny all;
        satisfy any; # Require a passing auth_ module
        auth_jwt "Google OIDC" token=$cookie_auth_token; # Obtain JWT from cookie
        auth_jwt_key_file /etc/nginx/google_certs.jwk;

        error_page 401 = /401.html;                  # Custom error page for login message
        sub_filter '__JWT_EMAIL__' $jwt_claim_email; # Simple substitution for demo purposes
    }

    access_log /var/log/nginx/access.log auth;
    error_log  /var/log/nginx/error.log  info;
}
```

In case you get any error related to using an Unauthorized Javascript Origin or would like to use your own Google Client ID instead of mine (can be obtained from https://console.developers.google.com), you can replace the Client ID meta tag (google-signin-client_id) in docroot/index.html and rebuild the nginxplus docker image
