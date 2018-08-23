#!/bin/bash

# ------------------------------------------------------------------
# Project: Alpine NGINX build script
# Maintainer: Vitaly Uvarov [v.uvarov@dodopizza.com]
# ------------------------------------------------------------------
set -e
BUILD_DIR=$(cd $(dirname $0) && pwd) # without ending /

##

NGINX_VERSION="nginx-1.13.11"
PCRE_VERSION="pcre-8.41"
ZLIB_VERSION="zlib-1.2.11"
OPENSSL_VERSION="openssl-1.0.2m"

##

echo -e "\n++ Installing packages\n"

yum install -y epel-release wget git 
yum install -y openssl-devel geoip-devel

YUM_HISTORY_ID=$( yum history | sed -n 4p | awk '{print $1}' )

yum install -y gcc gcc-c++ autoconf make automake libtool

##

echo -e "\n++ The PCRE library – required by NGINX Core and Rewrite modules and provides support for regular expressions\n"

cd "${BUILD_DIR}"
wget "ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/${PCRE_VERSION}.tar.gz"
tar -zxf "${PCRE_VERSION}.tar.gz"
cd "${PCRE_VERSION}"
autoreconf -f -i
./configure
make
make install

##

echo -e "\n++ The zlib library – required by NGINX Gzip module for headers compression\n"

cd "${BUILD_DIR}"
wget "http://zlib.net/${ZLIB_VERSION}.tar.gz"
tar -zxf "${ZLIB_VERSION}.tar.gz"
cd "${ZLIB_VERSION}"
./configure
make
make install

##

echo -e "\n++ The OpenSSL library – required by NGINX SSL modules to support the HTTPS protocol\n"

cd "${BUILD_DIR}"
wget "https://www.openssl.org/source/${OPENSSL_VERSION}.tar.gz"
tar -zxf "${OPENSSL_VERSION}.tar.gz"
cd "${OPENSSL_VERSION}"
./config
make test
make install

# If the old version is still displayed or installed before, please make a copy of openssl bin file :
mv /usr/bin/openssl{,.old} || true
ln -s /usr/local/ssl/bin/openssl /usr/bin/openssl

openssl version


##
## NGINX
##


echo -e "\n++ Building ModSecurity \n"
# https://www.nginx.com/blog/compiling-and-installing-modsecurity-for-open-source-nginx/
# https://github.com/SpiderLabs/ModSecurity/tree/v3/master
cd "${BUILD_DIR}"
git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity modsecurity
cd "modsecurity"
git submodule init && git submodule update
./build.sh
./configure
make
make install

##

echo -e "\n++ Downloading NGINX source files\n"
cd "${BUILD_DIR}"
wget "http://nginx.org/download/${NGINX_VERSION}.tar.gz"
tar -zxf "${NGINX_VERSION}.tar.gz"

##

echo -e "\n++ Cloning ModSecurity Connector \n"
git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git

# echo -e "\n++ Building ModSecurity Connector as dynamic module \n"
# cd "${NGINX_VERSION}"
# ./configure --with-compat --add-dynamic-module="${BUILD_DIR}/ModSecurity-nginx"
# make modules
# install -d /nginx_http_modsecurity_module
# cp objs/ngx_http_modsecurity_module.so /nginx_http_modsecurity_module/

##

echo -e "\n++ Cloning nginx-module-vts\n"

cd "${BUILD_DIR}"
git clone https://github.com/vozlt/nginx-module-vts.git

##

echo -e "\n++ Cloning ngx_dynamic_upstream module\n"

cd "${BUILD_DIR}"
git clone https://github.com/cubicdaiya/ngx_dynamic_upstream.git

##

echo -e "\n++ Cloning nginx-rtmp-module module\n"

cd "${BUILD_DIR}"
git clone https://github.com/arut/nginx-rtmp-module.git

##

echo -e "\n++ Preparing user, group and folders\n"

adduser --home-dir /var/lib/nginx --shell /sbin/nologin nginx

install -d /etc/nginx/ 	-o nginx -g nginx
install -d /var/log/nginx/ -o nginx -g nginx

##

echo -e "\n++ Building NGINX \n"

cd "${BUILD_DIR}"
wget "http://nginx.org/download/${NGINX_VERSION}.tar.gz"
tar -zxf "${NGINX_VERSION}.tar.gz"
cd "${NGINX_VERSION}"

./configure \
--user=nginx  \
--group=nginx \
--prefix=/etc/nginx \
--sbin-path=/usr/sbin/nginx \
--conf-path=/etc/nginx/nginx.conf \
--pid-path=/var/run/nginx.pid \
--lock-path=/var/run/nginx.lock \
--http-log-path=/var/log/nginx/access.log \
--error-log-path=/var/log/nginx/error.log \
--with-pcre="${BUILD_DIR}/pcre-8.41" \
--with-zlib="${BUILD_DIR}/zlib-1.2.11" \
--with-http_v2_module \
--with-http_ssl_module \
--with-http_geoip_module \
--with-http_stub_status_module \
--with-stream \
--add-module="${BUILD_DIR}/nginx-module-vts" \
--add-module="${BUILD_DIR}/ngx_dynamic_upstream" \
--add-module="${BUILD_DIR}/nginx-rtmp-module" \
--add-module="${BUILD_DIR}/ModSecurity-nginx"

make
make install

##

echo -e "\n++ Adding ModSecurity recomended configs to /etc/nginx/ \n"

install -d /etc/nginx/modsec.d
wget -P /etc/nginx/modsec.d/ https://raw.githubusercontent.com/SpiderLabs/ModSecurity/master/modsecurity.conf-recommended
mv /etc/nginx/modsec.d/modsecurity.conf-recommended /etc/nginx/modsec.d/modsecurity.conf

sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/nginx/modsec.d/modsecurity.conf

##

echo -e "\nInstalling to systemd\n"
# https://www.nginx.com/resources/wiki/start/topics/examples/systemd/

echo "[Unit]
Description=The nginx HTTP and reverse proxy server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/var/run/nginx.pid
# Nginx will fail to start if /var/run/nginx.pid already exists but has the wrong
# SELinux context. This might happen when running `nginx -t` from the cmdline.
# https://bugzilla.redhat.com/show_bug.cgi?id=1268621
ExecStartPre=/usr/bin/rm -f /var/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/bin/kill -s HUP \$MAINPID
KillSignal=SIGQUIT
TimeoutStopSec=5
KillMode=process
PrivateTmp=true

[Install]
WantedBy=multi-user.target" > /lib/systemd/system/nginx.service

##

echo -e "\nCreating logrotate job\n"

echo "/var/log/nginx/*.log {
    create 0644 nginx nginx
    daily
    rotate 10
    missingok
    notifempty
    compress
    delaycompress
    sharedscripts
    postrotate
        /bin/kill -USR1 \`cat /var/run/nginx.pid 2>/dev/null\` 2>/dev/null || true
    endscript
}" > /etc/logrotate.d/nginx || true

##

echo -e "\Rollback installed packages"

# yum history -y undo ${YUM_HISTORY_ID} || true
yum clean all

##

echo -e "\nAll done!"
