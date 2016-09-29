FROM 0snug0/private:nginxwaf

# Add the conf.d files
ADD modsec/crs-setup.conf /etc/nginx/modsec/crs-setup.conf
ADD modsec/rules/ /etc/nginx/modsec/rules/
ADD modsec/main2.conf /etc/nginx/modsec/main.conf
ADD conf.d/proxy2.conf /etc/nginx/conf.d/proxy.conf

# Define working directory.
WORKDIR /etc/nginx

EXPOSE 80 443 8080

CMD ["nginx", "-g", "daemon off;"]