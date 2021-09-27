FROM composer:2.0.11 AS composer
FROM php:8.0.3-fpm
RUN apt-get -y update && apt-get -y upgrade && apt-get install -y \
    libzip-dev \
    unzip \
    git \
    vim \
    libpng-dev \
    supervisor \
    cron \
    htop
RUN pecl install redis-5.3.3 \
    && pecl install xdebug-3.0.3 \
    && pecl install apcu-5.1.20 \
    && docker-php-ext-enable redis xdebug apcu

RUN apt-get install -y libmagickwand-dev --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /usr/src/php/ext/imagick; \
    curl -fsSL https://github.com/Imagick/imagick/archive/06116aa24b76edaf6b1693198f79e6c295eda8a9.tar.gz | tar xvz -C "/usr/src/php/ext/imagick" --strip 1; \
    docker-php-ext-install imagick;

COPY --from=composer /usr/bin/composer /usr/bin/composer

WORKDIR /app

RUN docker-php-ext-install bcmath opcache zip pdo_mysql
RUN docker-php-ext-install gd pcntl

RUN echo "PHP_INI_DIR=$PHP_INI_DIR" >> /tmp/php_ini_dir.log
RUN cp "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
RUN echo "memory_limit=-1" >> "$PHP_INI_DIR/php.ini"

RUN echo "access.log=/dev/null" >> /usr/local/etc/php-fpm.d/www.conf

COPY ./ops/local/lottery_web/all/php/conf.d/xdebug.ini $PHP_INI_DIR/conf.d/
COPY ./ops/local/lottery_web/all/supervisor_php/conf.d/ /etc/supervisor/conf.d/
COPY ./ops/local/lottery_web/all/php.sh /

RUN sed -i "s/pm\s=.*$/pm=static/g" /usr/local/etc/php-fpm.d/www.conf && \
    sed -i "s/pm\.max_children\s=.*$/pm\.max_children=5/g" /usr/local/etc/php-fpm.d/www.conf && \
    sed -i "s/upload_max_filesize\s=.*$/upload_max_filesize=16M/g" $PHP_INI_DIR/php.ini && \
    sed -i "s/post_max_size\s=.*$/post_max_size=16M/g" $PHP_INI_DIR/php.ini && \
    sed -i "s/max_file_uploads\s=.*$/max_file_uploads=2/g" $PHP_INI_DIR/php.ini

RUN echo "\n \
export LS_OPTIONS='--color=auto' \n \
alias ls='ls \$LS_OPTIONS'\n \
alias ll='ls \$LS_OPTIONS -l'\n \
alias l='ls \$LS_OPTIONS -lA'\n \
alias rm='rm -i'\n \
alias cp='cp -i'\n \
alias mv='mv -i'" >> ~/.bashrc

CMD bash /php.sh
