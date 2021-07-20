#!/bin/zsh

# Waits for an internet connection...
while ! $(wget -q --spider ping.archlinux.org); do sleep 5s; done

# and starts network related services upon connection confirmed
systemctl --user start mail.timer

if [[ "$(hostname)" = "mredson" ]]; then
  systemctl --user start xandikos.service
  systemctl --user start vdirsyncer.timer
fi
