# Accepted values: 8.1 - 8.0
# Octane only runs on PHP 8 and above
ARG PHP_VERSION=8.1

ARG COMPOSER_VERSION=latest

FROM composer:${COMPOSER_VERSION} AS vendor
WORKDIR /var/www/html
COPY composer* ./
RUN composer install \
  --no-interaction \
  --prefer-dist \
  --ignore-platform-reqs \
  --optimize-autoloader \
  --apcu-autoloader \
  --ansi \
  --no-scripts


FROM php:${PHP_VERSION}-cli-buster

LABEL maintainer="Jordan Jones <proxima.aust@gmail.com>"

ARG WWWUSER=1000
ARG WWWGROUP=1000
ARG TZ=UTC


ENV DEBIAN_FRONTEND=noninteractive \
    TERM=xterm-color

ENV ROOT=/var/www/html
WORKDIR $ROOT

SHELL ["/bin/bash", "-eou", "pipefail", "-c"]

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

RUN apt-get update; \
    apt-get upgrade -yqq; \
    pecl -q channel-update pecl.php.net; \
    apt-get install -yqq --no-install-recommends --show-progress \
          apt-utils \
          gnupg \
          gosu \
          git \
          curl \
          wget \
          libcurl4-openssl-dev \
          ca-certificates \
          supervisor \
          libmemcached-dev \
          libz-dev \
          libbrotli-dev \
          libpq-dev \
          libjpeg-dev \
          libpng-dev \
          libfreetype6-dev \
          libssl-dev \
          libwebp-dev \
          libmcrypt-dev \
          libonig-dev \
          libzip-dev zip unzip \
          libargon2-1 \
          libidn2-0 \
          libpcre2-8-0 \
          libpcre3 \
          libxml2 \
          libzstd1 \
          procps; \

docker-php-ext-install pdo_mysql; \

# Install zip
docker-php-ext-configure zip && docker-php-ext-install zip; \

# Install mbstring
docker-php-ext-install mbstring; \

# Installs GD extension
docker-php-ext-configure gd \
            --prefix=/usr \
            --with-jpeg \
            --with-webp \
            --with-freetype \
    && docker-php-ext-install gd; \


# Include OPcache for extra performance 
docker-php-ext-install opcache; \

# Install redis
pecl -q install -o -f redis \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis; \

docker-php-ext-install pcntl; \

# Installs BCMath
docker-php-ext-install bcmath; \

#Installs OpenSwoole
apt-get install -yqq --no-install-recommends --show-progress libc-ares-dev \
&& pecl -q install -o -f -D 'enable-openssl="yes" enable-http2="yes" enable-swoole-curl="yes" enable-mysqlnd="yes" enable-cares="yes"' openswoole \
&& docker-php-ext-enable openswoole; \

# Install Intl
apt-get install -yqq --no-install-recommends --show-progress zlib1g-dev libicu-dev g++ \
&& docker-php-ext-configure intl \
&& docker-php-ext-install intl; \

# Installs Memcached
pecl -q install -o -f memcached && docker-php-ext-enable memcached; \

# Install MySQL Client
apt-get install -yqq --no-install-recommends --show-progress default-mysql-client; \

# Install Pgsql extension
docker-php-ext-install pdo_pgsql; \

# Install Pgsql extension
docker-php-ext-install pgsql; \

# Clean up all source after
apt-get clean \
&& docker-php-source delete \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
&& rm /var/log/lastlog /var/log/faillog

RUN groupadd --force -g $WWWGROUP octane \
    && useradd -ms /bin/bash --no-log-init --no-user-group -g $WWWGROUP -u $WWWUSER octane

COPY . .
COPY --from=vendor ${ROOT}/vendor vendor

RUN mkdir -p \
  storage/framework/{sessions,views,cache} \
  storage/logs \
  bootstrap/cache \
  && chown -R octane:octane \
  storage \
  bootstrap/cache \
  && chmod -R ug+rwx storage bootstrap/cache

COPY deployment/octane/supervisord.app.conf /etc/supervisor/conf.d/
COPY deployment/octane/php.ini /usr/local/etc/php/conf.d/octane.ini
COPY deployment/octane/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

RUN chmod +x deployment/octane/entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["deployment/octane/entrypoint.sh"]

HEALTHCHECK --start-period=5s --interval=2s --timeout=5s --retries=8 CMD php artisan octane:status || exit 1
