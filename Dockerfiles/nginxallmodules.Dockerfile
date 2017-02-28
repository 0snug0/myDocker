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
RUN apt-get install -y nginx-plus-module-lua nginx-plus-module-geoip nginx-plus-module-geoip2 nginx-plus-module-headers-more nginx-plus-module-image-filter nginx-plus-module-modsecurity nginx-plus-module-ndk nginx-plus-module-njs nginx-plus-module-passenger nginx-plus-module-perl nginx-plus-module-rtmp nginx-plus-module-set-misc nginx-plus-module-xslt

RUN sed -i '/error_log/iload_module "modules/ndk_http_module.so";' /etc/nginx/nginx.conf
RUN sed -i '/error_log/iload_module "modules/ngx_http_lua_module.so";' /etc/nginx/nginx.conf
RUN sed -i '/error_log/iload_module "modules/ngx_http_geoip_module.so";' /etc/nginx/nginx.conf
RUN sed -i '/error_log/iload_module "modules/ngx_stream_geoip_module.so";' /etc/nginx/nginx.conf
RUN sed -i '/error_log/iload_module "modules/ngx_http_geoip2_module.so";' /etc/nginx/nginx.conf
RUN sed -i '/error_log/iload_module "modules/ngx_http_headers_more_filter_module.so";' /etc/nginx/nginx.conf
RUN sed -i '/error_log/iload_module "modules/ngx_http_image_filter_module.so";' /etc/nginx/nginx.conf
RUN sed -i '/error_log/iload_module "modules/ngx_http_modsecurity_module.so";' /etc/nginx/nginx.conf
RUN sed -i '/error_log/iload_module "modules/ngx_http_js_module.so";' /etc/nginx/nginx.conf
RUN sed -i '/error_log/iload_module "modules/ngx_stream_js_module.so";' /etc/nginx/nginx.conf
RUN sed -i '/error_log/iload_module "modules/ngx_http_passenger_module.so";' /etc/nginx/nginx.conf
RUN sed -i '/error_log/iload_module "modules/ngx_http_perl_module.so";' /etc/nginx/nginx.conf
RUN sed -i '/error_log/iload_module "modules/ngx_rtmp_module.so";' /etc/nginx/nginx.conf
RUN sed -i '/error_log/iload_module "modules/ngx_http_set_misc_module.so";' /etc/nginx/nginx.conf
RUN sed -i '/error_log/iload_module "modules/ngx_http_xslt_filter_module.so";' /etc/nginx/nginx.conf


# forward request logs to Docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME ["/var/log/nginx"]

# Define working directory.
WORKDIR /etc/nginx

EXPOSE 80 443 8080

CMD ["nginx", "-g", "daemon off;"]