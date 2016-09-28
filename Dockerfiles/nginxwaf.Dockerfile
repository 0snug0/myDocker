FROM 0snug0/private:plusbase

RUN wget http://pp.nginx.com/defan/NWA-397/nginx-plus-module-modsecurity_0.1.2-1~xenial_amd64.deb -O /root/modsec.deb
RUN dpkg -i /root/modsec.deb

# Load mod_sec module in nginx conf
RUN sed -i '/error_log/iload_module "modules/ngx_http_modsecurity_module.so";' /etc/nginx/nginx.conf

# Add the conf.d files
RUN rm -rf /etc/nginx/conf.d/default.conf
ADD conf.d/proxy1.conf /etc/nginx/conf.d/proxy.conf
ADD modsec/main1.conf /etc/nginx/modsec/main.conf
ADD modsec/modsecurity.conf /etc/nginx/modsec/modsecurity.conf

# Define working directory.
WORKDIR /etc/nginx

EXPOSE 80 443 8080

CMD ["nginx", "-g", "daemon off;"]