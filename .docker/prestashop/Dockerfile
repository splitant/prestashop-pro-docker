ARG PS_VERSION

FROM prestashop/base:${PS_VERSION}

ARG GROUP_ID
ARG USER_ID

RUN apt-get update \
	&& apt-get install -y curl \
        git \
    && rm -rf /var/lib/apt/lists/*

RUN groupmod -g $GROUP_ID www-data \
  && usermod -u $USER_ID -g $GROUP_ID www-data

COPY .docker/prestashop/scripts/docker_run_git.sh /tmp/

RUN mkdir -p /var/www/.npm
RUN chown -R www-data:www-data /var/www/.npm
RUN mkdir -p /var/www/.composer
RUN chown -R www-data:www-data /var/www/.composer

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt install -y nodejs

# Install mailutils to make sendmail work
RUN apt install -y \
    apt-utils \
    mailutils

RUN php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');" && php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer && rm -rf /tmp/composer-setup.php

CMD ["/tmp/docker_run_git.sh"]