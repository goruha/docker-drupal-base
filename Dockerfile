# from https://www.drupal.org/requirements/php#drupalversions
FROM alpine:edge

RUN echo 'http://alpine.gliderlabs.com/alpine/edge/main' > /etc/apk/repositories && \
    echo 'http://alpine.gliderlabs.com/alpine/edge/community' >> /etc/apk/repositories && \
    echo 'http://alpine.gliderlabs.com/alpine/edge/testing' >> /etc/apk/repositories && \
    apk update && apk add --update \
      curl \
      gzip \
      mysql-client \
      php5 \
      php5-fpm \
      php5-xml \
      php5-ctype \
      php5-ftp \
      php5-gd \
      php5-json \
      php5-posix \
      php5-curl \
      php5-dom \
      php5-pdo \
      php5-pdo_mysql \
      php5-sockets \
      php5-zlib \
      php5-mcrypt \
      php5-mysqli \
      php5-sqlite3 \
      php5-bz2 \
      php5-phar \
      php5-openssl \
      php5-posix \
      php5-zip \
      php5-calendar \
      php5-iconv \
      php5-imap \
      php5-soap \
      php5-dev \
      php5-pear \
      php5-redis \
      php5-exif \
      php5-xsl \
      php5-ldap \
      php5-bcmath \
      zip \
      nginx \
	  && rm -rf /var/cache/apk/*

RUN export S6_OVERLAY_VER=1.17.2.0  && \
    curl https://s3.amazonaws.com/wodby-releases/s6-overlay/v${S6_OVERLAY_VER}/s6-overlay-amd64.tar.gz | tar xz -C /

RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

    # Configure php.ini
RUN    sed -i \
        -e "s/^expose_php.*/expose_php = Off/" \
        -e "s/^;date.timezone.*/date.timezone = UTC/" \
        -e "s/^memory_limit.*/memory_limit = -1/" \
        -e "s/^max_execution_time.*/max_execution_time = 300/" \
        -e "s/^post_max_size.*/post_max_size = 512M/" \
        -e "s/^upload_max_filesize.*/upload_max_filesize = 512M/" \
        -e "s@^;sendmail_path.*@sendmail_path = /usr/sbin/sendmail -t -i -S opensmtpd:25@" \
        -e "s@^;mbstring.http_input.*@mbstring.http_input = pass@" \
        -e "s@^;mbstring.http_output.*@mbstring.http_output = pass@" \
        /etc/php5/php.ini

        # Install drush
RUN  php -r "readfile('https://s3.amazonaws.com/files.drush.org/drush.phar');" > /usr/local/bin/drush && \
     chmod +x /usr/local/bin/drush

     # Install Drupal Console
RUN  curl https://drupalconsole.com/installer -o /usr/local/bin/drupal && \
     chmod +x /usr/local/bin/drupal

# copy our scripts to the image
COPY rootfs /

# default entrypoint, never overright it
ENTRYPOINT ["/init"]

RUN mkdir /drupal && chmod -R 777 /drupal

RUN rm -rf /var/www/html && ln -s /drupal/www /var/www/html

WORKDIR /drupal

ENV DRUPAL_DATABASE drupal
ENV DRUPAL_DATABASE_HOST db
ENV DRUPAL_DATABASE_USER root
ENV DRUPAL_DATABASE_PASSWORD root

