FROM gpmidi/centos-6.5

RUN yum install -y ca-certificates wget

# Download certificate and key from the customer portal (https://cs.nginx.com)
# and copy to the build context
ADD nginx-repo.crt /etc/ssl/nginx/
ADD nginx-repo.key /etc/ssl/nginx/

# Get other files required for installation
RUN wget -P /etc/yum.repos.d/ https://cs.nginx.com/static/files/nginx-plus-6.repo


# Install NGINX Plus
RUN yum install -y nginx-plus

# forward request logs to Docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME ["/var/log/nginx"]

# Define working directory.
WORKDIR /etc/nginx

EXPOSE 80 443 8080

CMD ["nginx", "-g", "daemon off;"]