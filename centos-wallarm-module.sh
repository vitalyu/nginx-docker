#!/bin/bash

set -e
BUILD_DIR=$(cd $(dirname $0) && pwd) # without ending /

##

yum install -y epel-release
rpm -i https://repo.wallarm.com/centos/wallarm-node/7/x86_64/Packages/wallarm-node-repo-1-2.el7.centos.noarch.rpm

##

cat >>/etc/yum.repos.d/wallarm-node.repo <<'EOL'

[wallarm-node-dodopizza]
name=Wallarm Custom Node Packages for Enterprise Linux 7 - $basearch
baseurl=http://repo.wallarm.com/centos/wallarm-node-dodopizza/7/$basearch
failovermethod=priority
enabled=1
gpgcheck=0
repo_gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-WALLARM-NODE
EOL

##

# yum --disablerepo "*" --enablerepo "wallarm-node-dodopizza" list available
# repoquery -l nginx-module-wallarm-dodopizza.x86_64

yum install -y wallarm-node nginx-module-wallarm-dodopizza.x86_64
yum -y --setopt tsflags= reinstall nginx-module-wallarm-dodopizza.x86_64 # By default, the CentOS containers are built using yum's nodocs option, which helps reduce the size of the image

##

yum clean all

##

echo -e "\nAll done!"
