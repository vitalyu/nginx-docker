FROM nginx:1.15.2-alpine AS BUILDER
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
ARG NGINX_VERSION="nginx-1.15.2"

# Building ScaleFT/libxjwt
RUN     cd "${WORKDIR}" \
        && wget -q https://github.com/ScaleFT/libxjwt/releases/download/v1.0.3/libxjwt-1.0.3.tar.gz \
        && tar -xz -f ./libxjwt-1.0.3.tar.gz \
        && cd "libxjwt-1.0.3" \
        && ./configure \
        && make \
        && make install

# Cloning nginx-module-vts
RUN     cd "${WORKDIR}" \
        && git clone https://github.com/vozlt/nginx-module-vts.git

# Cloning ngx_dynamic_upstream module
RUN     cd "${WORKDIR}" \
        && git clone https://github.com/cubicdaiya/ngx_dynamic_upstream.git

# Building NGINX
RUN     cd "${WORKDIR}" \
        && wget "http://nginx.org/download/${NGINX_VERSION}.tar.gz" \
        && tar -zxf "${NGINX_VERSION}.tar.gz" \
        && cd "${NGINX_VERSION}" \
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
        make && \
        make install