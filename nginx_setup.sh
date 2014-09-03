rpm -ivh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm
yum -y -q install nginx

mkdir -p /etc/nginx/sites-available
mkdir -p /etc/nginx/sites-enabled

cp -a /etc/nginx/nginx.conf{,.org}
mv /etc/nginx/cond.d/default.conf /etc/nginx/cond.d/default.conf.org 

cat <<EOF >/etc/nginx/nginx.conf
user nginx;
worker_processes 1;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}

http {

        include /etc/nginx/mime.types;
        default_type application/octet-stream;
        gzip on;
        gzip_disable "msie6";

        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;
        keepalive_timeout 65;
        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;

        include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/sites-enabled/*;
}

EOF

cat <<EOF >/etc/nginx/sites-available/tomcat
upstream tomcat {
  server 127.0.0.1:8080;
}

server {
  listen 80;
  access_log /var/log/nginx/tomcat_access.log;
  error_log  /var/log/nginx/tomcat_error.log;

  root /var/www/tomcat;

  # for Jenkins plugin upload
  client_max_body_size 20M;

  location / {
      proxy_redirect off;
      proxy_set_header Host \$host;
      proxy_set_header X-Real-IP \$remote_addr;
      proxy_set_header X-Forwaeded-Host \$host;
      proxy_set_header X-Forwaeded-Server \$host;
      proxy_set_header X-Forwerded-For \$proxy_add_x_forwarded_for;
      proxy_pass http://tomcat;
  }
}

EOF

mkdir -p /var/www/tomcat
ln -s /etc/nginx/sites-available/tomcat /etc/nginx/sites-enabled/tomcat

