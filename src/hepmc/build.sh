#!/bin/zsh

if [[ -z "$HEP_FRAMEWORK" ]]; then
    echo "Please, first setup HEP_FRAMEWORK variable"
    exit
fi

# PREPARE ###################################################################
pkgname=hepmc
pkgver=3.0.0
pkgrel=1
basedir="$(pwd)"
srcdir="$basedir/src"
pkgdir="$basedir/pkg"
destdir="$HEP_FRAMEWORK/$pkgname-$pkgver"
source=(http://hepmc.web.cern.ch/hepmc/releases/$pkgname$pkgver.tgz)
sourcefile="$(basename $source)"

rm -rf "$srcdir" "$pkgdir"
mkdir "$srcdir" "$pkgdir"

# get source file
if [[ ! -r "$sourcefile" ]]; then
    wget "$source"
fi
cp "$basedir"/*(.) "$srcdir"
cd "$srcdir"
tar xf "$sourcefile"

# BUILD #####################################################################
cd "$srcdir/$pkgname$pkgver"

# fix config to add rpath
sed -i '/libHepMC/!s/-lHepMC/-lHepMC -Wl,-rpath,$prefix\/${CMAKE_INSTALL_LIBDIR}/' HepMC-config.in

# build and install
cd cmake
cmake -DCMAKE_INSTALL_PREFIX=$HEP_FRAMEWORK/$pkgname-$pkgver ..
sudo make -j all install
sudo chmod a+x $HEP_FRAMEWORK/hepmc-3.0.0/bin/*
sudo chmod a+x $HEP_FRAMEWORK/hepmc-3.0.0/lib/*
