FROM alpine:latest

MAINTAINER Paul Schoenfelder <paulschoenfelder@gmail.com>
# Modification France

LABEL \
  # Location of the STI scripts inside the image
  io.openshift.s2i.scripts-url=image:///usr/libexec/s2i \
  # DEPRECATED: This label will be kept here for backward compatibility
  io.s2i.scripts-url=image:///usr/libexec/s2i

ENV \
  # DEPRECATED: Use above LABEL instead, because this will be removed in future versions.
  STI_SCRIPTS_URL=image:///usr/libexec/s2i \
  # Path to be used in other layers to place s2i scripts into
  STI_SCRIPTS_PATH=/usr/libexec/s2i \
  # HOME is not set by default, but is needed by some applications
  HOME=/opt/app-root/src \
  PATH=/opt/app-root/src/bin:/opt/app-root/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:$PATH \
  REFRESHED_AT=2016-04-7T14:27

# Environments
ENV TIMEZONE=Europe/Paris \
    PHP_MEMORY_LIMIT=256M \
    MAX_UPLOAD=100M \
    PHP_MAX_FILE_UPLOAD=200 \
    PHP_MAX_POST=100M

RUN mkdir -p ${HOME} && \
    mkdir -p /usr/libexec/s2i && \
    adduser -s /bin/sh -u 1001 -G root -h ${HOME} -S -D default && \
    chown -R 1001:0 /opt/app-root && \
    echo 'http://nl.alpinelinux.org/alpine/v3.5/community' >> /etc/apk/repositories && \
    echo "http://nl.alpinelinux.org/alpine/v3.5/releases" >> /etc/apk/repositories && \
    echo "http://nl.alpinelinux.org/alpine/v3.5/main" >> /etc/apk/repositories && \
    apk -U upgrade && \
    apk add --no-cache --update  \
        bash \
        curl \ 
        wget \
        tar \
        unzip \
        findutils \
        git \
        gettext \
        gdb \
        lsof \
        patch \
        caddy \
        # ajout
        libcurl \
        libxml2 \
        libxslt \
        openssl-dev \
        zlib-dev \
        make \
        automake \ 
        gcc \ 
        g++ \ 
        binutils-gold \
        linux-headers \
        paxctl \
        libgcc \
        libstdc++ \
        python \
        gnupg \
        ncurses-libs \
        # fin ajout
        ca-certificates \
        php7 \
        php7-xml \
        php7-xsl \
        php7-pdo_mysql \
        php7-mcrypt \
        php7-curl \
        php7-json \
        php7-fpm \
        php7-phar \
        php7-openssl \
        php7-session \
        php7-ctype \
        php7-opcache \
        php7-dom \    
        php7-gd \
        php7-intl \
        php7-imap \
        php7-mysqlnd \    
        php7-pdo \
        php7-pdo_mysql \
        php7-posix \
        php7-session \
        php7-xml \
        php7-mbstring && \
        update-ca-certificates --fresh && \
    rm -rf /var/cache/apk/* && \
    sed -i "s|;*date.timezone =.*|date.timezone = ${TIMEZONE}|i" /etc/php7/php.ini && \
    sed -i "s|;*memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|i" /etc/php7/php.ini && \
    sed -i "s|;*upload_max_filesize =.*|upload_max_filesize = ${MAX_UPLOAD}|i" /etc/php7/php.ini && \
    sed -i "s|;*max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|i" /etc/php7/php.ini && \
    sed -i "s|;*post_max_size =.*|post_max_size = ${PHP_MAX_POST}|i" /etc/php7/php.ini && \
    sed -i "s|;*cgi.fix_pathinfo=.*|cgi.fix_pathinfo= 0|i" /etc/php7/php.ini

# Copy executable utilities
ADD basefs /

RUN ln -s /usr/bin/php7 /usr/bin/php && \
    ln -s /usr/sbin/php-fpm7 /usr/sbin/php-fpm

RUN fix-permissions /opt/app-root && \
    fix-permissions /opt/bin/start.sh && \
    fix-permissions /usr/libexec/s2i && \
    chown -R 1001:0 /opt/app-root && \
    chown -R 1001:0 /opt/bin/start.sh && \
    chown -R 1001:0 /usr/libexec/s2i && \
    chmod +x /usr/libexec/s2i/assemble && \
    chmod +x /usr/libexec/s2i/run && \
    chmod +x /opt/bin/start.sh

EXPOSE 8080

# Directory with the sources is set as the working directory so all STI scripts
# can execute relative to this path
WORKDIR ${HOME}

USER 1001

CMD ["base-usage"]

# Set labels used in OpenShift to describe the builder images
LABEL io.k8s.description="PHP 7 with Caddy Server on Alpine" \
      io.k8s.display-name="php7-caddy-alpine" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,php,php7,caddy,alpine" \
      io.openshift.min-memory="1Gi" \
      io.openshift.min-cpu="1" \
      io.openshift.non-scalable="false"
