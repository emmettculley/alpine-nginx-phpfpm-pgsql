FROM alpine:latest
MAINTAINER Eric Ball <eball@ccctechcenter.org>

RUN apk --update --no-cache add \
  nginx \
  php7 \
  php7-fpm \
  php7-pdo \
  php7-json \
  php7-openssl \
  php7-pgsql \
  php7-pdo_pgsql \
  php7-mcrypt \
  php7-sqlite3 \
  php7-pdo_sqlite \
  php7-ctype \
  php7-zlib \
  php7-xml \
  php7-gd \
  curl \
  py-pip \
  php7-curl \
  php7-zip \
  php7-dom \
  php7-simplexml \
  php7-tokenizer \
  php7-xmlwriter \
  php7-session \
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
RUN mkdir -p /var/run/php7-fpm
RUN mkdir -p /var/log/supervisor

RUN rm -f /etc/nginx/nginx.conf
ADD nginx.conf /etc/nginx/nginx.conf

RUN rm -f /etc/php7/php-fpm.conf
ADD php-fpm.conf /etc/php7/php-fpm.conf

RUN rm -f /etc/php7/php.ini
ADD php.ini /etc/php7/php.ini

VOLUME ["/var/www", "/etc/nginx/sites-enabled"]

ADD nginx-supervisor.ini /etc/supervisor.d/nginx-supervisor.ini
ENV TIMEZONE America/Los_Angeles

RUN ln -sf /dev/stderr /var/log/nginx/error.log
RUN ln -sf /dev/stdout /var/log/nginx/access.log

EXPOSE 80 9000

CMD ["/usr/bin/supervisord"]
