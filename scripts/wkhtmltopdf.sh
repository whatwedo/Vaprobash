#!/usr/bin/env bash

echo ">>> Installing wkhtmltopdf"

# Install wkhtmltopdf
apt-get install -qq wkhtmltopdf xvfb xfonts-75dpi
wget https://downloads.wkhtmltopdf.org/0.12/0.12.2.1/wkhtmltox-0.12.2.1_linux-trusty-amd64.deb
dpkg -i wkhtmltox-0.12.2.1_linux-trusty-amd64.deb
rm wkhtmltox-0.12.2.1_linux-trusty-amd64.deb
