#!/usr/bin/env bash

echo ">>> adding ssh fingerprint of dev.whatwedo.ch"

ssh-keyscan -t rsa dev.whatwedo.ch >> ~/.ssh/known_hosts
sudo -u vagrant sh -c "ssh-keyscan -t rsa dev.whatwedo.ch >> /home/vagrant/.ssh/known_hosts"

echo ">>> Branding VM"

echo '
            __            __                       __
 _      __ / /_   ____ _ / /_ _      __ ___   ____/ /____
| | /| / // __ \ / __ `// __/| | /| / // _ \ / __  // __ \
| |/ |/ // / / // /_/ // /_  | |/ |/ //  __// /_/ // /_/ /
|__/|__//_/ /_/ \__,_/ \__/  |__/|__/ \___/ \__,_/ \____/

           for any questions: welove@whatwedo.ch
' > /etc/motd
