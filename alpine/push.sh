#!/bin/bash
REPO=dodoreg.azurecr.io/nginx
TAG=1.15.2-alpine
cd $(cd $(dirname $0) && pwd)
#docker login dodoreg.azurecr.io
docker build --rm -f ./Dockerfile -t ${REPO}:${TAG} .
docker push ${REPO}