#!/bin/sh

DIR="$HOME/.msmtp.queue/"

while SIGNAL=$(inotifywait -e delete $DIR); do
  if [[ "$SIGNAL" == "$DIR DELETE,ISDIR .lock" ]]; then
    $HOME/bin/msmtp-queue -r
  fi
done
