### STAGE 1 - Building modules

FROM nginx:1.13.7-alpine AS builder
LABEL maintainer="Vitaly Uvarov <v.uvarov@dodopizza.com>"

RUN     apk add --no-cache \
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

WORKDIR /opt/

ENV NGINX_VERSION="1.13.7"

# Building ScaleFT/libxjwt
RUN     cd "${WORKDIR}" \
        && wget -q https://github.com/ScaleFT/libxjwt/releases/download/v1.0.3/libxjwt-1.0.3.tar.gz \
        && tar -xz -f ./libxjwt-1.0.3.tar.gz \
        && cd "libxjwt-1.0.3" \
        && ./configure \
        && make \
        && make install

# Cloning ScaleFT/nginx_auth_accessfabric
RUN     cd "${WORKDIR}" \
        && git clone https://github.com/ScaleFT/nginx_auth_accessfabric.git

# Cloning nginx-module-vts
RUN     cd "${WORKDIR}" \
        && git clone https://github.com/vozlt/nginx-module-vts.git

# Cloning ngx_dynamic_upstream module
RUN     cd "${WORKDIR}" \
        && git clone https://github.com/cubicdaiya/ngx_dynamic_upstream.git

# Building NGINX
RUN     cd "${WORKDIR}" && export WORKDIR=$(pwd) \
        && wget -q "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" \
        && tar -zxf "nginx-${NGINX_VERSION}.tar.gz" \
        && cd "nginx-${NGINX_VERSION}" \
        \
        # Configure like in nginx-alpine original image
        && ./configure \
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
            --add-dynamic-module="${WORKDIR}/nginx-module-vts" \
            --add-dynamic-module="${WORKDIR}/ngx_dynamic_upstream" \
            --add-dynamic-module="${WORKDIR}/nginx_auth_accessfabric" \
        && make \
        && make install


### STAGE 2 - Copying modules and running nginx

FROM nginx:1.13.7-alpine AS runner

RUN     apk add --no-cache \
            curl-dev \
            jansson-dev

COPY --from=builder /usr/local/lib/libxjwt.a /usr/local/lib/libxjwt.la /usr/local/lib/libxjwt.so.0.1.0 /usr/lib/
RUN ln -s /usr/lib/libxjwt.so.0.1.0 /usr/lib/libxjwt.so.0 \
    && ln -s /usr/lib/libxjwt.so.0.1.0 /usr/lib/libxjwt.so

COPY --from=builder /usr/lib/nginx/modules/* /usr/lib/nginx/modules/

RUN     sed -i '1s|^| \
            load_module modules/ngx_http_vhost_traffic_status_module.so; \n \
            load_module modules/ngx_dynamic_upstream_module.so; \n \
            load_module modules/ngx_http_auth_accessfabric_module.so; \n \
        |' /etc/nginx/nginx.conf