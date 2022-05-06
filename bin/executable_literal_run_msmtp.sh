#!/bin/sh

DIR="/home/cagprado/.msmtp.queue/"

while SIGNAL=$(inotifywait -e delete $DIR); do
  [ "$SIGNAL" == "$DIR DELETE,ISDIR .lock" ] && /home/cagprado/bin/msmtp-queue -r
done
