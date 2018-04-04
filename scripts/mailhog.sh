#!/usr/bin/env bash

echo ">>> Installing Mailhog"

# Test if PHP is installed
php -v > /dev/null 2>&1
PHP_IS_INSTALLED=$1
PHP_VERSION=0 && [[ $PHP_IS_INSTALLED -eq 0 ]] && PHP_VERSION=`php -v | tac | tail -n 1 | cut -d " " -f 2 | cut -c 1-3`
PHP_PATH="/etc/php/$PHP_VERSION"

# Test if Apache is installed
apache2 -v > /dev/null 2>&1
APACHE_IS_INSTALLED=$?

sudo curl -L https://github.com/mailhog/MailHog/releases/download/v1.0.0/MailHog_linux_amd64 -o /usr/bin/mailhog
sudo curl -L https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64 -o /usr/bin/mhsendmail
sudo chmod +x /usr/bin/mailhog
sudo chmod +x /usr/bin/mhsendmail

# Make it start on boot
sudo tee /etc/init/mailhog.conf <<EOL
description "MailHog"

start on runlevel [2345]
stop on runlevel [!2345]

respawn

exec /usr/bin/env /usr/bin/mailhog
EOL

# Start Mailcatcher
sudo service mailhog start

if [[ $PHP_IS_INSTALLED -eq 0 ]]; then
	# Make php use it to send mail
    echo "sendmail_path = /usr/bin/env /usr/bin/mhsendmail" | sudo tee "${PHP_PATH}"/mods-available/mailhog.ini
    
    sudo phpenmod mailhog
    sudo service php$PHP_VERSION-fpm restart
fi

if [[ $APACHE_IS_INSTALLED -eq 0 ]]; then
	sudo service apache2 restart
fi
