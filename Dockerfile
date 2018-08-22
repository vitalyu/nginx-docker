FROM alpine
LABEL maintainer="Vitaly Uvarov <v.uvarov@dodopizza.com>"

WORKDIR /nginx-build
COPY ./alpine-build-nginx.sh /nginx-build/build.sh
RUN /bin/sh /nginx-build/build.sh
#&& rm -rf /nginx-build/

# forward request and error logs to docker log collector
RUN    ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80
EXPOSE 443

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]