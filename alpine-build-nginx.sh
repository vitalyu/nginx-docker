#!/bin/sh

# ------------------------------------------------------------------
# Project: Alpine NGINX build script
# Maintainer: Vitaly Uvarov [v.uvarov@dodopizza.com]
# ------------------------------------------------------------------
set -e
BUILD_DIR=$(cd $(dirname $0) && pwd) # without ending /

##

NGINX_VERSION="nginx-1.15.2"
# PCRE_VERSION="pcre-8.41"
# ZLIB_VERSION="zlib-1.2.11"
# OPENSSL_VERSION="openssl-1.0.2m"

##

echo -e "\n++ Installing packages\n"

apk add --no-cache --virtual .build-deps \
	libcurl curl-dev \
    gcc g++ \
	make automake autoconf libtool \
	libc-dev \
	linux-headers \
	gnupg \
	libxslt-dev \
	gd-dev \
    curl wget -q git \
	libressl-dev \
	pcre-dev \
	zlib-dev \
	geoip-dev

#apk add --no-cache openssl-dev # since alpine > 3.4 openssl conflicts with libressl ()

apk add --no-cache \
    openssl \
	pcre \
	zlib \
	geoip

##

openssl version

##
## ScaleFT
##

# echo -e "\n++ Install requirements \n"
# apk add --no-cache \
# 	libcurl curl-dev 
# 	# curl-dbg alpine-sdk
# #

echo -e "\n++ Building ScaleFT/libxjwt \n"

cd "${BUILD_DIR}"
#git clone https://github.com/akheron/jansson.git
wget -q http://www.digip.org/jansson/releases/jansson-2.10.tar.gz
tar -xz -f ./jansson-2.10.tar.gz
cd "jansson-2.10"
autoreconf -i
./configure
make
make install

#

echo -e "\n++ Building ScaleFT/libxjwt \n"

cd "${BUILD_DIR}"
# git clone https://github.com/ScaleFT/libxjwt.git
wget -q https://github.com/ScaleFT/libxjwt/releases/download/v1.0.3/libxjwt-1.0.3.tar.gz
tar -xz -f ./libxjwt-1.0.3.tar.gz
cd "libxjwt-1.0.3"
./configure
automake --add-missing
make
make install

echo -e "\n++ Cloning nginx_auth_accessfabric\n"

cd "${BUILD_DIR}"
# git clone https://github.com/ScaleFT/nginx_auth_accessfabric.git
wget -q -O nginx_auth_accessfabric.tar.gz https://github.com/ScaleFT/nginx_auth_accessfabric/archive/v1.0.0.tar.gz
tar -xz -f ./nginx_auth_accessfabric.tar.gz
mv "nginx_auth_accessfabric-1.0.0" "nginx_auth_accessfabric"
cd "nginx_auth_accessfabric"

##
## NGINX
##

echo -e "\n++ Cloning nginx-module-vts\n"

cd "${BUILD_DIR}"
git clone https://github.com/vozlt/nginx-module-vts.git

##

echo -e "\n++ Cloning ngx_dynamic_upstream module\n"

cd "${BUILD_DIR}"
git clone https://github.com/cubicdaiya/ngx_dynamic_upstream.git

##

echo -e "\n++ Preparing user, group and folders\n"

adduser -D -h /var/lib/nginx -s /sbin/nologin nginx
install -d /etc/nginx/ -o nginx -g nginx
install -d /var/log/nginx/ -o nginx -g nginx

##

echo -e "\n++ Building NGINX \n"

cd "${BUILD_DIR}"
wget -q "http://nginx.org/download/${NGINX_VERSION}.tar.gz"
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
--with-http_v2_module \
--with-http_ssl_module \
--with-http_geoip_module \
--with-http_stub_status_module \
--with-stream \
--add-module="${BUILD_DIR}/nginx-module-vts" \
--add-module="${BUILD_DIR}/ngx_dynamic_upstream" \
--add-module="${BUILD_DIR}/nginx_auth_accessfabric"

make
make install

##

echo -e "\Rollback installed packages"

# apk del .build-deps

##

echo -e "\nAll done!"