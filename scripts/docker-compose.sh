#!/usr/bin/env bash

echo ">>> Installing docker-compose"

#Install docker-compose
lastReleasesUrl="https://github.com/docker/compose/releases.atom"
latestDockerComposeVersion=$(wget -q -O- $lastReleasesUrl | \
        egrep -m1 -o '/docker/compose/releases/tag/([0-9]\.[0-9]\.[0-9])' | \
        egrep -o '([0-9]\.[0-9]\.[0-9])')
curl -L -s https://github.com/docker/compose/releases/download/${latestDockerComposeVersion}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && \
        chmod +x /usr/local/bin/docker-compose