FROM vitalyu/nginx-docker:1.13.7
LABEL maintainer="Vitaly Uvarov <v.uvarov@dodopizza.com>"

RUN mkdir /wallarm-install
ADD ./centos-wallarm-module.sh /wallarm-install/centos-wallarm-module.sh
RUN yum install -y deltarpm && /bin/bash /wallarm-install/centos-wallarm-module.sh && rm -rf /wallarm-install/