FROM php:7.3-cli-stretch

# Install git, the php image doesn't have installed
RUN apt-get update -yqq \
    && apt-get install git -yqq \
    && apt-get install wget git curl libcurl4-openssl-dev unzip zlib1g-dev libmcrypt-dev libxml2-dev libxslt-dev libjpeg-dev libpng-dev libfreetype6-dev libxslt-dev libzip-dev mysql-client -yqq

# Install Latest sodium
RUN wget https://download.libsodium.org/libsodium/releases/LATEST.tar.gz && tar xvzf LATEST.tar.gz && cd libsodium-stable && ./configure && make && make check && make install && cd ../ && rm -rf LATEST.tar.gz libsodium-stable \
    && apt-get update -yqq

# Install PHP Extensions
RUN docker-php-ext-install xsl sodium pdo_mysql zip bcmath curl xml mbstring xsl json soap sockets \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && echo "" >> "$PHP_INI_DIR/php.ini" \
    && echo "max_execution_time = 240" >> "$PHP_INI_DIR/php.ini" \
    && echo "memory_limit = 1024M" >> "$PHP_INI_DIR/php.ini"


RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/man /usr/share/doc /usr/share/doc-base

# Install composer
RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
    && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
    # Make sure we're installing what we think we're installing!
    && php -r "if (hash_file('sha384', '/tmp/composer-setup.php') !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" \
    && php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer --snapshot \
    && rm -f /tmp/composer-setup.*

COPY pipe /
ENTRYPOINT ["/pipe.sh"]