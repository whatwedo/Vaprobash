#!/usr/bin/env bash

echo ">>> Installing mkdocs"

# Update python to 2.7.9+ (SSL updates required for mkdocs dependency tornado)
add-apt-repository ppa:fkrull/deadsnakes-python2.7 && apt-get update

# Install pip
apt-get install -qq --force-yes python-pip python-dev

# Install mkdocs
pip install mkdocs
