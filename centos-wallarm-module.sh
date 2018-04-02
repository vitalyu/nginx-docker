#!/bin/bash

set -e
BUILD_DIR=$(cd $(dirname $0) && pwd) # without ending /

##



yum clean all

##

echo -e "\nAll done!"
