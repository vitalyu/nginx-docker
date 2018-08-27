#!/bin/sh
/env-to-nginx -tmpl /etc/nginx/nginx.conf.tmpl > /etc/nginx/nginx.conf
exec "$@"