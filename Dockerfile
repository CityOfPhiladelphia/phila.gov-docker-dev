FROM php:7.4-fpm

# ENV WORDPRESS_VERSION 4.9.8
# ENV WORDPRESS_SHA1 0945bab959cba127531dceb2c4fed81770812b4f
# ENV NGINX_VERSION 1.15.7-1~stretch
# ENV NGINX_GPGKEY 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62
ENV NODE_VERSION=16.3.0

ENV php_opcache /usr/local/etc/php/conf.d/opcache-recommended.ini
ENV fpm_conf /usr/local/etc/php-fpm.d/www.conf
ENV fpm_conf_docker /usr/local/etc/php-fpm.d/zz-docker.conf
ENV PHP_MEMORY_LIMIT=128M

ENV TZ=America/New_York

RUN mkdir -p /phila.gov/wp/wp-content/themes/phila.gov-theme/node_modules

ENV PATH /phila.gov/wp/wp-content/themes/phila.gov-theme/node_modules/.bin:$PATH

# php extensions
RUN \ 
  printf '\e[33mSetting up PHP (best programming language ever!)\e[0m\n' \
  && apt-get update \
	apt-get install -y --no-install-recommends \
# Ghostscript is required for rendering PDF previews
		ghostscript \
	; \
	rm -rf /var/lib/apt/lists/*

# install the PHP extensions we need (https://make.wordpress.org/hosting/handbook/handbook/server-environment/#php-extensions)
RUN set -ex; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libfreetype6-dev \
		libicu-dev \
		libjpeg-dev \
		libmagickwand-dev \
		libpng-dev \
		libwebp-dev \
		libzip-dev \
	; \
	\
	docker-php-ext-configure gd \
		--with-freetype \
		--with-jpeg \
		--with-webp \
	; \
	docker-php-ext-install -j "$(nproc)" \
		bcmath \
		exif \
		gd \
		intl \
		mysqli \
		zip \
	; \
# https://pecl.php.net/package/imagick
	pecl install imagick-3.6.0; \
	docker-php-ext-enable imagick; \
	rm -r /tmp/pear; 
  
  RUN \
  printf '\e[33mSetting up PHP (best programming language ever!)\e[0m\n' \
  && apt-get update \
  # php settings
  && { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=1'; \
  } > ${php_opcache} \
  # php-fpm settings
  && sed -i \
  -e "s/listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm.sock/g" \
  -e "s/;listen.owner = www-data/listen.owner = www-data/g" \
  -e "s/;listen.group = www-data/listen.group = www-data/g" \
  -e "s/;listen.mode = 0660/listen.mode = 0660/g" \
  ${fpm_conf} \
  # undo the oddly-placed zz-docker.conf setting in upstream image
  && sed -i -e "s/listen = 9000/;listen = 9000/g" ${fpm_conf_docker} \
  # nginx
  && printf '\e[33mWhat about installing NGINX\e[0m\n' \
  && apt-get install --no-install-recommends --no-install-suggests -q -y gnupg2 dirmngr wget apt-transport-https lsb-release ca-certificates \
  && set -x \
  && apt-get install nginx -y \
  # increase PHP memory limit
  && cd /usr/local/etc/php/conf.d/ && \
  echo 'memory_limit = -1' >> /usr/local/etc/php/conf.d/docker-php-ram-limit.ini \
  # && \
  # NGINX_GPGKEY=${NGINX_GPGKEY}; \
  # found=''; \
  # for server in \
  #   ha.pool.sks-keyservers.net \
  #   hkp://keyserver.ubuntu.com:80 \
  #   hkp://p80.pool.sks-keyservers.net:80 \
  #   pgp.mit.edu \
  # ; do \
  #   echo "Fetching GPG key $NGINX_GPGKEY from $server"; \
  #   apt-key adv --batch --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$NGINX_GPGKEY" && found=yes && break; \
  # done; \
  # test -z "$found" && echo >&2 "error: failed to fetch GPG key $NGINX_GPGKEY" && exit 1; \
  # echo "deb http://nginx.org/packages/mainline/debian/ stretch nginx" >> /etc/apt/sources.list \
  # && apt-get update \
  # && apt-get install -y nginx=${NGINX_VERSION} \
  \
  # supervisor
  && printf '\e[33mInstalling Supervisor, you know, we need it\e[0m\n' \
  && apt-get install -y --no-install-recommends --no-install-suggests supervisor \
  # # install wordpress (upstream image puts it in wrong location)
  # RUN curl -o wordpress.tar.gz -fSL "https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz" \
  #   && echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c - \
  #   && tar -xzf wordpress.tar.gz -C /usr/src/ \
  #   && rm wordpress.tar.gz \
  #   && chown -R www-data:www-data /usr/src/wordpress \
  #   && mv /usr/src/wordpress/* /var/www/html/
  # Test setting the timezone
  && printf '\e[33mSetting the correct (and perfect) timezone =)\e[0m\n' \
  && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
  # wp cli
  && printf '\e[33mEveryone loves Wordpress CLI(?)\e[0m\n' \
  && set -ex \
  && curl -sS https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar > /usr/local/bin/wp \
  && chmod 755 /usr/local/bin/wp \
  # node.js
  && apt-get install -y \
    npm \
    python3 \
    python-dev \
    python3-pip \
    python-setuptools \
    groff \
    less \
  # aws-cli
  && pip install awscli \
  # unzip (for private plugins)
  && printf '\e[33mCan you believe it\? we also need UNZIP\e[0m\n' \
  && apt-get install -y unzip \
  # forward request and error logs to docker log collector
  && printf '\e[33mSomething about docker logs, well... I have no idea =/\e[0m\n' \
  && ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log \
  && ln -sf /dev/stderr /var/log/php7.0-fpm.log \
  #Installing vim for futher in-server file editor
  && printf '\e[33mNice old reliable VIM! yep, we need it too\e[0m\n' \
  && apt-get install -y vim \
  # Lets download the phila.gov from git
  && printf '\e[33mBecause live would not be perfect without GIT\e[0m\n' \
  && apt-get install -y git \
  && printf '\e[33mMho Fix for mysql client =), Thanks Mho!\e[0m\n' \
  && apt-get install default-mysql-client -y \
  && printf '\e[33mClean up a little bit\e[0m\n' \
  && apt-get autoremove \
  && apt-get clean 

WORKDIR /
COPY ./scripts /scripts
COPY ./nginx /etc/nginx
COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf

#ADD php.ini /usr/local/etc/php.ini


ENTRYPOINT [ "/scripts/entrypoint.sh" ]
CMD [ "start" ]
