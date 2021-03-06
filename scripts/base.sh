#!/usr/bin/env bash

# optimize apt sources to select best mirror
perl -pi -e 's@^\s*(deb(\-src)?)\s+http://us.archive.*?\s+@\1 mirror://mirrors.ubuntu.com/mirrors.txt @g' /etc/apt/sources.list

# update repositories
apt-get update
apt-get upgrade -qq

echo "Setting Timezone & Locale to $3 & en_US.UTF-8"

sudo ln -sf /usr/share/zoneinfo/$3 /etc/localtime
sudo apt-get install -qq language-pack-en
sudo locale-gen en_US
sudo update-locale LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8

echo ">>> Installing Base Packages"

# Install base packages
# -qq implies -y --force-yes
sudo apt-get install -qq curl unzip zip git-core ack-grep software-properties-common build-essential telnet dnsutils cachefilesd

echo ">>> Installing *.xip.io self-signed SSL"

SSL_DIR="/etc/ssl/xip.io"
DOMAIN="*.xip.io"
PASSPHRASE="vaprobash"

SUBJ="
C=US
ST=Connecticut
O=Vaprobash
localityName=New Haven
commonName=$DOMAIN
organizationalUnitName=
emailAddress=
"

sudo mkdir -p "$SSL_DIR"

sudo openssl genrsa -out "$SSL_DIR/xip.io.key" 1024
sudo openssl req -new -subj "$(echo -n "$SUBJ" | tr "\n" "/")" -key "$SSL_DIR/xip.io.key" -out "$SSL_DIR/xip.io.csr" -passin pass:$PASSPHRASE
sudo openssl x509 -req -days 365 -in "$SSL_DIR/xip.io.csr" -signkey "$SSL_DIR/xip.io.key" -out "$SSL_DIR/xip.io.crt"

# Setting up Swap

# Disable case sensitivity
shopt -s nocasematch

if [[ ! -z $2 && ! $2 =~ false && $2 =~ ^[0-9]*$ ]]; then

    echo ">>> Setting up Swap ($2 MB)"

    # Create the Swap file
    fallocate -l $2M /swapfile

    # Set the correct Swap permissions
    chmod 600 /swapfile

    # Setup Swap space
    mkswap /swapfile

    # Enable Swap space
    swapon /swapfile

    # Make the Swap file permanent
    echo "/swapfile   none    swap    sw    0   0" | tee -a /etc/fstab

    # Add some swap settings:
    # vm.swappiness=10: Means that there wont be a Swap file until memory hits 90% useage
    # vm.vfs_cache_pressure=50: read http://rudd-o.com/linux-and-free-software/tales-from-responsivenessland-why-linux-feels-slow-and-how-to-fix-that
    printf "vm.swappiness=10\nvm.vfs_cache_pressure=50" | tee -a /etc/sysctl.conf && sysctl -p

fi

# Enable case sensitivity
shopt -u nocasematch

# Edit MOTD
echo '
__      __                   _               _
\ \    / /                  | |             | |
 \ \  / /_ _ _ __  _ __ ___ | |__   __ _ ___| |__
  \ \/ / _  |  _ \|  __/ _ \|  _ \ / _  / __|  _ \
   \  / (_| | |_) | | | (_) | |_) | (_| \__ \ | | |
    \/ \__,_| .__/|_|  \___/|_.__/ \__,_|___/_| |_|
            | |
            |_|

' > /etc/motd

# Enable cachefilesd
echo "RUN=yes" > /etc/default/cachefilesd

# Set start directory
echo "cd $4" >> /home/vagrant/.bashrc

# Add SSH fingerprint
echo ">>> adding ssh fingerprint of github.com"
ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
sudo -u vagrant ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
