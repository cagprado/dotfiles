#!/bin/zsh
# This script is to be used in systemd.
# Waits for an internet connection and starts network related services.

# Waiting for a connection
while ! $(wget -q --spider www.baidu.com); do sleep 5s; done

# Have connection: start services
systemctl --user start network-services.target
