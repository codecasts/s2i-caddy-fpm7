## Source to Image pour Openshift

[![](https://images.microbadger.com/badges/image/docprof/s2i-php7.svg)](https://microbadger.com/images/docprof/s2i-php7 "Get your own image badge on microbadger.com")

Openshift s2i image mise à jour.

- Alpine Linux
- PHP-FPM 7
- Caddy


For custom entry file or another public directory, change the etc/caddy/caddy.conf file to reflect your needs


Build: 
```
make build
```

Release
```
make release
```

Test
```
make test
```

Special thanks to https://github.com/bitwalker/s2i-alpine-base that made the base s2i image with alpine that runs on openshift.

