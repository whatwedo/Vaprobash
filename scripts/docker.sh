#!/usr/bin/env bash

echo ">>> Installing Docker"

# Add Key
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

# Add Repository
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list
sudo apt-get update

# Install Docker
# -qq implies -y --force-yes
apt-get install -qq linux-image-extra-$(uname -r)
sudo apt-get install -qq docker-engine

# Make the vagrant user able to interact with docker without sudo
if [ ! -z "$1" ]; then
	if [ "$1" == "permissions" ]; then
		echo ">>> Adding vagrant user to docker group"

		sudo usermod -a -G docker vagrant

	fi # permissions
fi # arg check

echo ">>> Installing docker-compose"

#Install docker-compose
lastReleasesUrl="https://github.com/docker/compose/releases.atom"
latestDockerComposeVersion=$(wget -q -O- $lastReleasesUrl | \
        egrep -m1 -o '/docker/compose/releases/tag/([0-9]\.[0-9]\.[0-9])"' | \
        egrep -o '([0-9]\.[0-9]\.[0-9])')
curl -L -s https://github.com/docker/compose/releases/download/${latestDockerComposeVersion}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && \
        chmod +x /usr/local/bin/docker-compose

#Install docker-nuke
echo ">>> Installing docker-nuke"
curl -sSL https://gist.githubusercontent.com/n3r0-ch/30c628813b67190d309d/raw > /usr/local/bin/docker-nuke
chmod +x /usr/local/bin/docker-nuke
