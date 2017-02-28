FROM ubuntu:xenial

# Set the debconf frontend to Noninteractive
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update && apt-get install -y -q wget apt-transport-https lsb-release ca-certificates libcurl3 libgeoip1 libxml2
RUN printf "deb https://plus-pkgs.nginx.com/ubuntu `lsb_release -cs` nginx-plus\n" > /etc/apt/sources.list.d/nginx-plus.list

# Download certificate and key from the customer portal (https://cs.nginx.com)
# and copy to the build context
ADD nginx-repo.crt /etc/ssl/nginx/
ADD nginx-repo.key /etc/ssl/nginx/

# Get other files required for installation
RUN wget -q -O - http://nginx.org/keys/nginx_signing.key | apt-key add -
RUN wget -q -O /etc/apt/apt.conf.d/90nginx https://cs.nginx.com/static/files/90nginx

# Install NGINX Plus
RUN apt-get update && apt-get install -y nginx-plus
RUN apt-get install -y nginx-plus-module-modsecurity
RUN dpkg -s nginx-plus-module-modsecurity | grep Version

# Load mod_sec module in nginx conf
RUN sed -i '/error_log/iload_module "modules/ngx_http_modsecurity_module.so";' /etc/nginx/nginx.conf

# Add the conf.d files
RUN rm -rf /etc/nginx/conf.d/default.conf
ADD conf.d/proxy-modsec1.conf /etc/nginx/conf.d/proxy.conf
ADD modsec/main2.conf /etc/nginx/modsec/main.conf
RUN wget https://raw.githubusercontent.com/SpiderLabs/ModSecurity/master/modsecurity.conf-recommended -O /etc/nginx/modsec/modsecurity.conf

#ADD modsec/modsecurity.conf /etc/nginx/modsec/modsecurity.conf
ADD modsec/crs-setup.conf /etc/nginx/modsec/crs-setup.conf
ADD modsec/rules/ /etc/nginx/modsec/rules/

# forward request logs to Docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME ["/var/log/nginx"]


# Define working directory.
WORKDIR /etc/nginx

EXPOSE 80 443 8080

CMD ["nginx", "-g", "daemon off;"]