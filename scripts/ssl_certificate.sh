#!/usr/bin/env bash

DOMAIN="$1"
echo ">>> Installing custom SSL certificate with CA"

if [[ -z $2 ]]; then
    exit;
else
    CONFIG_SSL_PATH="$2"
    CA_FILENAME="$3"
fi

SYSTEM_SSL_PATH="/etc/ssl/vaprobash"

# Clean previously generated ssl folder
sudo rm -rf "$SYSTEM_SSL_PATH" && sudo mkdir "$SYSTEM_SSL_PATH"
if [ -d "$CONFIG_SSL_PATH" ]; then
	sudo cp -r "$CONFIG_SSL_PATH/*" "$SYSTEM_SSL_PATH"
fi

# Generate certificate from CA
if [[ $CA_FILENAME != "false" ]]; then
	cd "$SYSTEM_SSL_PATH"
	sudo openssl genrsa -out $DOMAIN.key 2048
	sudo openssl req -new -config $DOMAIN.conf -keyout $CA_FILENAME.key -out $DOMAIN.csr
	sudo openssl x509 -req -in $DOMAIN.csr -CA $CA_FILENAME.pem -CAkey $CA_FILENAME.key -CAcreateserial -out $DOMAIN.crt -days 1825 -sha256 -extfile $DOMAIN.ext -passin file:passphrase.txt

	sudo cp $DOMAIN.crt ../xip.io/xip.io.crt
	sudo cp $DOMAIN.csr ../xip.io/xip.io.csr
	sudo cp $DOMAIN.key ../xip.io/xip.io.key
fi