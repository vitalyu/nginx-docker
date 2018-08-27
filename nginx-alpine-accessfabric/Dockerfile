FROM golang AS gobuilder
LABEL maintainer="Vitaly Uvarov <v.uvarov@dodopizza.com>"

WORKDIR /build
COPY ./env-to-nginx.go /build/

RUN	go build -ldflags "-s -w" /build/env-to-nginx.go

###

FROM dodoreg.azurecr.io/nginx:1.15.2-alpine

COPY --from=gobuilder /build/env-to-nginx /
COPY ./nginx.conf.tmpl /etc/nginx/
COPY ./entrypoint.sh /

ENTRYPOINT ["sh", "/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]