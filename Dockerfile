FROM php:7.2-fpm

RUN if [ -z "$AWS_ACCESS_KEY_ID" ] \
  || [ -z "$AWS_SECRET_ACCESS_KEY" ] \
  || [ -z "$AWS_DEFAULT_REGION" ] \
  || [ -z "$PHILA_DB_PATH" ] \
  || [ -z "$PHILA_DB_FILE" ]; then \
  echo 'Environment variables must be specified. Exiting.'; exit 1; \
fi

# ENV WORDPRESS_VERSION 4.9.8
# ENV WORDPRESS_SHA1 0945bab959cba127531dceb2c4fed81770812b4f
ENV NGINX_VERSION 1.15.1-1~stretch
ENV NGINX_GPGKEY 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62
ENV NODE_VERSION 8

ENV php_opcache /usr/local/etc/php/conf.d/opcache-recommended.ini
ENV fpm_conf /usr/local/etc/php-fpm.d/www.conf
ENV fpm_conf_docker /usr/local/etc/php-fpm.d/zz-docker.conf

# php extensions
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    libjpeg-dev \
    libpng-dev \
  && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
  && docker-php-ext-install gd mysqli opcache zip

# php settings
RUN { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=1'; \
  } > ${php_opcache}

# php-fpm settings
RUN sed -i \
  -e "s/listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm.sock/g" \
  -e "s/;listen.owner = www-data/listen.owner = www-data/g" \
  -e "s/;listen.group = www-data/listen.group = www-data/g" \
  -e "s/;listen.mode = 0660/listen.mode = 0660/g" \
  ${fpm_conf} \
# undo the oddly-placed zz-docker.conf setting in upstream image
&& sed -i -e "s/listen = 9000/;listen = 9000/g" ${fpm_conf_docker}

# nginx
RUN apt-get update \
  && apt-get install -y gnupg apt-transport-https \
  && echo "deb https://nginx.org/packages/mainline/debian/ stretch nginx" >> /etc/apt/sources.list.d/nginx.list \
  && APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ${NGINX_GPGKEY} \
  && apt-get update \
  && apt-get install -y nginx=${NGINX_VERSION}

# supervisor
RUN apt-get update \
  && apt-get install -y --no-install-recommends --no-install-suggests supervisor

# # install wordpress (upstream image puts it in wrong location)
# RUN curl -o wordpress.tar.gz -fSL "https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz" \
#   && echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c - \
#   && tar -xzf wordpress.tar.gz -C /usr/src/ \
#   && rm wordpress.tar.gz \
#   && chown -R www-data:www-data /usr/src/wordpress \
#   && mv /usr/src/wordpress/* /var/www/html/

# Test setting the timezone
ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# wp cli
RUN set -ex \
  && curl -sS https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar > /usr/local/bin/wp \
  && chmod 755 /usr/local/bin/wp

# node.js
RUN apt-get update \
  && apt-get install -y gnupg build-essential \
  && set -ex \
  && curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
  && apt-get install -y nodejs

# aws-cli
RUN apt-get update && \
  apt-get install -y \
    python \
    python-dev \
    python-pip \
    python-setuptools \
    groff \
    less \
  && pip install awscli

# unzip (for private plugins)
RUN apt-get update \
  && apt-get install -y unzip

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log \
  && ln -sf /dev/stderr /var/log/php7.0-fpm.log

# Installing vim for futher in-server file editor
RUN apt-get update && apt-get install -y vim;

# install
# COPY ./phila.gov/wp /var/www/html/

# Lets download the phila.gov from git
RUN apt-get install -y git

WORKDIR /
COPY ./scripts /scripts
COPY ./nginx /etc/nginx
COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf

ENTRYPOINT [ "/scripts/entrypoint.sh" ]
CMD [ "start" ]
