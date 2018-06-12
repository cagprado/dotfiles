#!/bin/zsh
# just run it inside gcc folder after extracting source

if [[ -z "$HEP_FRAMEWORK" ]]; then
    echo "Please, first setup HEP_FRAMEWORK variable"
    exit
fi

./configure --prefix=/ --disable-multilib
make -j
sudo make DESTDIR=$HEP_FRAMEWORK install
