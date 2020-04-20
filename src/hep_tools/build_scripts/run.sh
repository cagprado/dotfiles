#!/bin/sh
export MAKEFLAGS="-j$NUMBER_JOBS"

mkdir /tmp/cagprado
cd /tmp/cagprado
$HOME/bin/zsh/homebuild $HOME/src/$PROGRAM/PKGBUILD
mv *.pkg.tar.xz $HOME/tmp/
cd ..
rm -rf cagprado
