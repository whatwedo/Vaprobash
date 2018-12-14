#!/usr/bin/env bash

echo ">>> Installing MariaDB"

[[ -z $1 ]] && { echo "!!! MariaDB root password not set. Check the Vagrant file."; exit 1; }

# default version
MARIADB_VERSION='10.1'

if [ ! -z "$3" ]; then
    MARIADB_VERSION="$3"
fi

# Import repo key
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db

# Add repo for MariaDB
sudo add-apt-repository "deb [arch=amd64,i386] http://mirrors.accretive-networks.net/mariadb/repo/$MARIADB_VERSION/ubuntu trusty main"

# Update
sudo apt-get update

# Install MariaDB without password prompt
# Set username to 'root' and password to 'mariadb_root_password' (see Vagrantfile)
sudo debconf-set-selections <<< "maria-db-$MARIADB_VERSION mysql-server/root_password password $1"
sudo debconf-set-selections <<< "maria-db-$MARIADB_VERSION mysql-server/root_password_again password $1"

# Install MariaDB
# -qq implies -y --force-yes
sudo apt-get install -qq mariadb-server

# Disable binary logs
sed -i 's/log_bin/#log_bin/g' /etc/mysql/my.cnf && \
sed -i 's/expire_logs_days/#expire_logs_days/g' /etc/mysql/my.cnf && \
sed -i 's/max_binlog_size/#max_binlog_size/g' /etc/mysql/my.cnf && \
sed -i 's/#innodb_log_file_size.*/innodb_log_file_size\=256M/g' /etc/mysql/my.cnf
service mysql restart

# Make Maria connectable from outside world without SSH tunnel
if [ $2 == "true" ]; then
    # enable remote access
    # setting the mysql bind-address to allow connections from everywhere
    sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

    # adding grant privileges to mysql root user from everywhere
    # thx to http://stackoverflow.com/questions/7528967/how-to-grant-mysql-privileges-in-a-bash-script for this
    MYSQL=`which mysql`

    Q1="GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY '$1' WITH GRANT OPTION;"
    Q2="FLUSH PRIVILEGES;"
    SQL="${Q1}${Q2}"

    $MYSQL -uroot -p$1 -e "$SQL"

    service mysql restart
fi

# Add .my.ini file
cat <<EOT >> ~/.my.cnf
[client]
user=root
password="$1"

[mysql]
user=root
password="$1"

[mysqldump]
user=root
password="$1"

[mysqldiff]
user=root
password="$1"
EOT
chmod 600 ~/.my.cnf
cp ~/.my.cnf /home/vagrant
chown vagrant:vagrant /home/vagrant/.my.cnf
chmod 600 /home/vagrant/.my.cnf
