# NGINX with SSL, GEOIP, STREAM, VTS, DYNAMIC UPSTREAM, RTMP modules

## Notes
* You can run `centos-build-nginx.sh` localy on your CentOS 7 (7.4 tested) to compile NGINX (run script from root)

## Latest build with:

```
NGINX_VERSION="nginx-1.13.7"
PCRE_VERSION="pcre-8.41"
ZLIB_VERSION="zlib-1.2.11"
OPENSSL_VERSION="openssl-1.0.2m"
```

## Modules
* [http_v2_module]( https://nginx.ru/ru/docs/http/ngx_http_v2_module.html )
* [http_stub_status_module]( https://nginx.ru/ru/docs/http/ngx_http_stub_status_module.html )
* [http_ssl_module]( https://nginx.ru/en/docs/http/ngx_http_ssl_module.html )
* [http_geoip_module]( https://nginx.ru/en/docs/http/ngx_http_geoip_module.html )
* [stream module]( https://nginx.ru/en/docs/stream/ngx_stream_core_module.html )
* [nginx-module-vts]( https://github.com/vozlt/nginx-module-vts )
* [ngx_dynamic_upstream]( https://github.com/cubicdaiya/ngx_dynamic_upstream )
* [nginx-rtmp-module]( https://github.com/arut/nginx-rtmp-module )
