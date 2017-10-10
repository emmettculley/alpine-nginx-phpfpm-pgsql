FROM alpine:3.3
MAINTAINER Daniel McCoy <danielmccoy@gmail.com>

RUN apk --update add \
  nginx \
  php-fpm \
  php-pdo \
  php-json \
  php-openssl \
  php-pgsql \
  php-pdo_pgsql \
  php-mcrypt \
  php-sqlite3 \
  php-pdo_sqlite \
  php-ctype \
  php-zlib \
  php-xml \
  php-gd \
  curl \
  py-pip \
  php-curl \
  php-zip \
  php-dom \
  supervisor

ADD     build_pdftk.sh /bin/
ENV     VER_PDFTK=2.02

RUN apk --no-cache add --update unzip wget make fastjar gcc gcc-java g++ && \
  /bin/build_pdftk.sh && \
  apk del build-base unzip wget make fastjar && \
  rm -rf /var/cache/apk/* && \
  pdftk

# Configure supervisor
RUN pip install --upgrade pip && \
    pip install supervisor-stdout

RUN mkdir -p /etc/nginx
RUN mkdir -p /run/nginx
RUN mkdir -p /var/run/php-fpm
RUN mkdir -p /var/log/supervisor

RUN rm /etc/nginx/nginx.conf
ADD nginx.conf /etc/nginx/nginx.conf

RUN rm /etc/php/php-fpm.conf
ADD php-fpm.conf /etc/php/php-fpm.conf

VOLUME ["/var/www", "/etc/nginx/sites-enabled"]

ADD nginx-supervisor.ini /etc/supervisor.d/nginx-supervisor.ini
ENV TIMEZONE America/Los_Angeles

RUN ln -sf /dev/stderr /var/log/nginx/error.log
RUN ln -sf /dev/stdout /var/log/nginx/access.log

EXPOSE 80 9000

CMD ["/usr/bin/supervisord"]
