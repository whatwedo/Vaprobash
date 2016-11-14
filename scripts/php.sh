#!/usr/bin/env bash

export LANG=C.UTF-8

PHP_TIMEZONE=$1
HHVM=$2
PHP_VERSION=$3
PHP_PATH="/etc/php/$PHP_VERSION"

if [[ $HHVM == "true" ]]; then

    echo ">>> Installing HHVM"

    # Get key and add to sources
    wget --quiet -O - http://dl.hhvm.com/conf/hhvm.gpg.key | sudo apt-key add -
    echo deb http://dl.hhvm.com/ubuntu trusty main | sudo tee /etc/apt/sources.list.d/hhvm.list

    # Update
    apt-get update

    # Install HHVM
    # -qq implies -y --force-yes
    apt-get install -qq hhvm

    # Start on system boot
    update-rc.d hhvm defaults

    # Replace PHP with HHVM via symlinking
    /usr/bin/update-alternatives --install /usr/bin/php php /usr/bin/hhvm 60

    service hhvm restart
else
    echo ">>> Installing PHP $PHP_VERSION"

    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C
    apt-get install -y language-pack-en-base
    add-apt-repository -y ppa:ondrej/php

    apt-key update
    apt-get update

    # Install PHP
    apt-get install -qq php$PHP_VERSION-cli php$PHP_VERSION-fpm php$PHP_VERSION-mysql php$PHP_VERSION-pgsql php$PHP_VERSION-sqlite php$PHP_VERSION-curl php$PHP_VERSION-gd php$PHP_VERSION-gmp php$PHP_VERSION-mcrypt php$PHP_VERSION-memcached php$PHP_VERSION-imagick php$PHP_VERSION-intl php$PHP_VERSION-common php$PHP_VERSION-cgi php$PHP_VERSION-imap php$PHP_VERSION-ldap php$PHP_VERSION-json php$PHP_VERSION-xml php$PHP_VERSION-mbstring

    # Set PHP FPM to listen on TCP instead of Socket
    sed -i "s/listen =.*/listen = 127.0.0.1:9000/" "${PHP_PATH}"/fpm/pool.d/www.conf

    # Set PHP FPM allowed clients IP address
    sed -i "s/;listen.allowed_clients/listen.allowed_clients/" "${PHP_PATH}"/fpm/pool.d/www.conf

    # Set run-as user for PHP-FPM processes to user/group "vagrant"
    # to avoid permission errors from apps writing to files
    sed -i "s/user = www-data/user = vagrant/" "${PHP_PATH}"/fpm/pool.d/www.conf
    sed -i "s/group = www-data/group = vagrant/" "${PHP_PATH}"/fpm/pool.d/www.conf

    sed -i "s/listen\.owner.*/listen.owner = vagrant/" "${PHP_PATH}"/fpm/pool.d/www.conf
    sed -i "s/listen\.group.*/listen.group = vagrant/" "${PHP_PATH}"/fpm/pool.d/www.conf
    sed -i "s/listen\.mode.*/listen.mode = 0666/" "${PHP_PATH}"/fpm/pool.d/www.conf

    # PHP Error Reporting Config
    sed -i "s/error_reporting = .*/error_reporting = E_ALL/" "${PHP_PATH}"/fpm/php.ini
    sed -i "s/display_errors = .*/display_errors = On/" "${PHP_PATH}"/fpm/php.ini

    # PHP Date Timezone
    sed -i "s/;date.timezone =.*/date.timezone = ${PHP_TIMEZONE/\//\\/}/" "${PHP_PATH}"/fpm/php.ini
    sed -i "s/;date.timezone =.*/date.timezone = ${PHP_TIMEZONE/\//\\/}/" "${PHP_PATH}"/cli/php.ini

    # PHP Upload Max Filesize
    sed -i "s/upload_max_filesize = .*/upload_max_filesize = 32M/" "${PHP_PATH}"/fpm/php.ini
    sed -i "s/post_max_size = .*/post_max_size = 32M/" "${PHP_PATH}"/fpm/php.ini

    # Restart FPM
    service php$PHP_VERSION-fpm restart
fi
