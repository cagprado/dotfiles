#!/bin/sh

git clone 'https://github.com/neovim/neovim.git'
cd neovim

make -j CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/usr/local/neovim/" CMAKE_BUILD_TYPE=RelWithDebInfo
make install
