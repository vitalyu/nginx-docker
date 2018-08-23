FROM nginx:1.14.0-alpine AS build

RUN apk add --no-cache \
        gcc \
		libc-dev \
		make \
		openssl-dev \
		pcre-dev \
		zlib-dev \
		linux-headers \
		curl \
		gnupg \
		libxslt-dev \
		gd-dev \
        geoip-dev \
        curl-dev \
        jansson-dev \
        git

RUN mkdir -p /opt/nginx/nginx_auth_accessfabric
WORKDIR /opt/nginx
RUN git clone https://github.com/ScaleFT/nginx_auth_accessfabric.git /opt/nginx/nginx_auth_accessfabric

RUN curl -SsL -o "libxjwt-1.0.3.tar.gz" "https://github.com/ScaleFT/libxjwt/releases/download/v1.0.3/libxjwt-1.0.3.tar.gz" \
    && tar -xzf "libxjwt-1.0.3.tar.gz" \
    && cd "libxjwt-1.0.3" \
    && ./configure \
    && make \
    && make install

# config required for binary compatability
# copy from https://github.com/nginxinc/docker-nginx/blob/master/stable/alpine/Dockerfile
RUN CONFIG="\
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
	" \
    && curl -SsL -o "nginx-1.14.0.tar.gz" "http://nginx.org/download/nginx-1.14.0.tar.gz" \
    && tar -xzf "nginx-1.14.0.tar.gz" \
    && cd "nginx-1.14.0" \
    && ./configure $CONFIG --add-dynamic-module=../nginx_auth_accessfabric \
    && make \
    && make install

RUN sed -i '1s|^|load_module modules/ngx_http_auth_accessfabric_module.so;|' /etc/nginx/nginx.conf


# final image - copy module from build image for reduced size
FROM nginx:1.14.0-alpine

RUN apk add --no-cache \
		libcurl \
        curl-dev \
        jansson-dev \
    && sed -i '1s|^|load_module modules/ngx_http_auth_accessfabric_module.so;|' /etc/nginx/nginx.conf

COPY --from=build /usr/local/lib/libxjwt.a /usr/local/lib/libxjwt.la /usr/local/lib/libxjwt.so.0.1.0 /usr/lib/
RUN ln -s /usr/lib/libxjwt.so.0.1.0 /usr/lib/libxjwt.so.0 \
    && ln -s /usr/lib/libxjwt.so.0.1.0 /usr/lib/libxjwt.so

COPY --from=build /opt/nginx/nginx-1.14.0/objs/ngx_http_auth_accessfabric_module.so /etc/nginx/modules/