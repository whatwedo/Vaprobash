#!/usr/bin/env bash

echo ">>> Installing docker-compose"

latestDockerComposeVersion=$(wget -q -O- https://github.com/docker/compose/releases.atom | \
        egrep -m1 -o '/docker/compose/releases/tag/([0-9]*\.[0-9]*\.[0-9]*)"' | \
        egrep -o '([0-9]*\.[0-9]*\.[0-9]*)')

curl -L https://github.com/docker/compose/releases/download/${latestDockerComposeVersion}/docker-compose-`uname -s`-`uname -m` > /tmp/docker-compose && \
    mv /tmp/docker-compose /usr/local/bin && \
    chmod +x /usr/local/bin/docker-compose && \
    chown root:root /usr/local/bin/docker-compose
