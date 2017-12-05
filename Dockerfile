FROM centos:7.4.1708
MAINTAINER Vitaly Uvarov <v.uvarov@dodopizza.com>

RUN mkdir /nginx-build
ADD ./centos-build-nginx.sh /nginx-build/build.sh
RUN /nginx-build/build.sh

# forward request and error logs to docker log collector
RUN    ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80
EXPOSE 443

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]