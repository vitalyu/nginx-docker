FROM vitalyu/nginx-docker:1.13.7
LABEL maintainer="Vitaly Uvarov <v.uvarov@dodopizza.com>"

# Step based on yosugi/cron-centos
RUN yum install -y crontabs
RUN    ( sed -i -e '/pam_loginuid.so/s/^/#/' /etc/pam.d/crond ) \
    && ( chmod 0644 /etc/crontab ) \
    && ( echo '@reboot root touch /cron_is_ok' >> /etc/crontab )
CMD crond
# -

RUN mkdir /wallarm-install
ADD ./centos-wallarm-module.sh /wallarm-install/centos-wallarm-module.sh
RUN /bin/bash /wallarm-install/centos-wallarm-module.sh && rm -rf /wallarm-install/
