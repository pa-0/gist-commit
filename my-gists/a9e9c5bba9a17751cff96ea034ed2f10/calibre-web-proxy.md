# Reverse Proxy Calibre-Web Container with Different Base URL

When using Calibre-Web from Docker, [the most popular container](
https://github.com/Technosoft2000/docker-calibre-web) doesn't offer
an obvious way to set up a reverse proxy under a different base URL.
It's simple to do by writing a request header in your reverse proxy
config, as demonstrated below.

## Apache

```apache
<Location "/calibre/">
	ProxyPass http://127.0.0.1:8083/
	RequestHeader add X-Script-Name "/calibre"
</Location>
```

## Nginx

```nginx
location /calibre/ {
    proxy_set_header X-Script-Name /calibre/;
    proxy_pass http://127.0.0.1:8083;
}
```

