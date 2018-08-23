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
	gcc \
	gnupg \
	gd-dev \
	libc-dev \
	make \
	linux-headers \
	libressl-dev \
	pcre-dev \
	zlib-dev \
	geoip-dev \
	libxslt-dev \
    curl-dev \
    jansson-dev \
	wget \
	curl \
	git

# apk add --no-cache --virtual .build-deps \
# 	libcurl \
# 	curl-dev \
#     gcc \
# 	g++ \
# 	make \
# 	automake \
# 	autoconf \
# 	libtool \
# 	libc-dev \
# 	linux-headers \
# 	gnupg \
# 	gd-dev \
# 	libressl-dev \
# 	libxslt-dev \
#     curl \
# 	wget \
# 	git \
# 	pcre-dev \
# 	zlib-dev \
# 	geoip-dev

#apk add --no-cache openssl-dev # since alpine > 3.4 openssl conflicts with libressl ()

apk add --no-cache \
	libcurl \
    openssl \
	pcre \
	zlib \
	geoip \
	jansson-dev

##

openssl version

#

echo -e "\n++ Building ScaleFT/libxjwt \n"

cd "${BUILD_DIR}"
wget -q https://github.com/ScaleFT/libxjwt/releases/download/v1.0.3/libxjwt-1.0.3.tar.gz
tar -xz -f ./libxjwt-1.0.3.tar.gz
cd "libxjwt-1.0.3"
./configure
# automake --add-missing
make
make install

echo -e "\n++ Cloning nginx_auth_accessfabric\n"

cd "${BUILD_DIR}"
git clone https://github.com/ScaleFT/nginx_auth_accessfabric.git
# wget -q -O nginx_auth_accessfabric.tar.gz https://github.com/ScaleFT/nginx_auth_accessfabric/archive/v1.0.0.tar.gz
# tar -xz -f ./nginx_auth_accessfabric.tar.gz
# mv "nginx_auth_accessfabric-1.0.0" "nginx_auth_accessfabric"

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
install -d /var/cache/nginx -o nginx -g nginx

##

echo -e "\n++ Building NGINX \n"

cd "${BUILD_DIR}"
wget -q "http://nginx.org/download/${NGINX_VERSION}.tar.gz"
tar -zxf "${NGINX_VERSION}.tar.gz"
cd "${NGINX_VERSION}"

./configure \
		--prefix=/etc/nginx \
		--sbin-path=/usr/sbin/nginx \
		--modules-path=/usr/lib/nginx/modules \
		--conf-path=/etc/nginx/nginx.conf \
		--error-log-path=/var/log/nginx/error.log \
		--http-log-path=/var/log/nginx/access.log \
		--pid-path=/var/run/nginx.pid \
		--lock-path=/var/run/nginx.lock \
		--http-client-body-temp-path=/var/cache/nginx/client_temp \
		--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
		--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
		--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
		--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
		--user=nginx \
		--group=nginx \
		--with-http_ssl_module \
		--with-http_realip_module \
		--with-http_addition_module \
		--with-http_sub_module \
		--with-http_dav_module \
		--with-http_flv_module \
		--with-http_mp4_module \
		--with-http_gunzip_module \
		--with-http_gzip_static_module \
		--with-http_random_index_module \
		--with-http_secure_link_module \
		--with-http_stub_status_module \
		--with-http_auth_request_module \
		--with-http_xslt_module=dynamic \
		--with-http_image_filter_module=dynamic \
		--with-http_geoip_module=dynamic \
		--with-threads \
		--with-stream \
		--with-stream_ssl_module \
		--with-stream_ssl_preread_module \
		--with-stream_realip_module \
		--with-stream_geoip_module=dynamic \
		--with-http_slice_module \
		--with-mail \
		--with-mail_ssl_module \
		--with-compat \
		--with-file-aio \
		--with-http_v2_module \
--add-module="${BUILD_DIR}/nginx-module-vts" \
--add-module="${BUILD_DIR}/ngx_dynamic_upstream" \
--add-dynamic-module="${BUILD_DIR}/nginx_auth_accessfabric"

make
make install


sed -i '1s|^| \
            load_module modules/ngx_http_vhost_traffic_status_module.so; \n \
            load_module modules/ngx_dynamic_upstream_module.so; \n \
            load_module modules/ngx_http_auth_accessfabric_module.so; \n \
        |' /etc/nginx/nginx.conf

##

echo -e "\Rollback installed packages"

apk del .build-deps

##

echo -e "\nAll done!"