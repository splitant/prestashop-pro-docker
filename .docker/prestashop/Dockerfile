ARG PS_VERSION

FROM prestashop/base:${PS_VERSION}

ARG GROUP_ID
ARG USER_ID

RUN apt-get update \
	&& apt-get install -y curl \
        git \
        vim \
    && rm -rf /var/lib/apt/lists/*

RUN yes | pecl install xdebug-3.1.6 \
   && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
   && echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/xdebug.ini \
   && echo "xdebug.discover_client_host=0" >> /usr/local/etc/php/conf.d/xdebug.ini \
   && echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/xdebug.ini \
   && echo "xdebug.client_port=9003" >> /usr/local/etc/php/conf.d/xdebug.ini \
   && echo "xdebug.client_host=172.17.0.1" >> /usr/local/etc/php/conf.d/xdebug.ini

# SSL configuration
EXPOSE 443
RUN mkdir -p /var/www/.certs
RUN chown -R www-data:www-data /var/www/.certs

# PHP configuration
RUN sed -ie "s/post_max_size\ =\ 20M/post_max_size\ =\ 40M/g" /usr/local/etc/php/php.ini
RUN sed -ie "s/upload_max_filesize\ =\ 20M/upload_max_filesize\ =\ 40M/g" /usr/local/etc/php/php.ini
RUN sed -ie "s/memory_limit\ =\ 256M/memory_limit\ =\ 512M/g" /usr/local/etc/php/php.ini

RUN groupmod -g $GROUP_ID www-data \
  && usermod -u $USER_ID -g $GROUP_ID www-data

COPY .docker/prestashop/scripts/docker_run_git.sh /tmp/

RUN mkdir -p /var/www/.npm
RUN chown -R www-data:www-data /var/www/.npm
RUN mkdir -p /var/www/.composer
RUN chown -R www-data:www-data /var/www/.composer

# Node
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt install -y nodejs

# Install mailutils to make sendmail work
RUN apt install -y \
    apt-utils \
    mailutils

# Composer
RUN php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');" && php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer && rm -rf /tmp/composer-setup.php

CMD ["/tmp/docker_run_git.sh"]
