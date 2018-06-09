#!/bin/zsh

if [[ -z "$HEP_FRAMEWORK" ]]; then
    echo "Please, first setup HEP_FRAMEWORK variable"
    exit
fi

# PREPARE ###################################################################
pkgname=root
pkgver=6.12.06
pkgrel=1
basedir="$(pwd)"
srcdir="$basedir/src"
pkgdir="$basedir/pkg"
prefix="$HEP_FRAMEWORK/$pkgname-$pkgver"
source="https://root.cern.ch/download/root_v${pkgver}.source.tar.gz"
sourcefile="$(basename $source)"

rm -rf "$srcdir" "$pkgdir"
mkdir "$srcdir" "$pkgdir"

# get source
if [[ ! -r "$sourcefile" ]]; then
    wget "$source"
fi
cp "$basedir"/*(.) "$srcdir"
cd "$srcdir"
tar xf "$sourcefile"

# prepare the code
cd "${pkgname}-${pkgver}"
echo 'Adjusting to Python3...'
2to3 -w etc/dictpch/makepch.py  >/dev/null 2>&1

patch -p1 -i "${srcdir}/fix_const_correctness.patch"

# BUILD #####################################################################
mkdir -p "${srcdir}/build"
cd "${srcdir}/build"

echo 'Configuring...'
CFLAGS="${CFLAGS} -pthread" \
CXXFLAGS="${CXXFLAGS} -pthread" \
LDFLAGS="${LDFLAGS} -pthread -Wl,--no-undefined" \
cmake -C "${srcdir}/settings.cmake" \
    -DCMAKE_INSTALL_PREFIX=$HEP_FRAMEWORK/$pkgname-$pkgver \
    -DCMAKE_INSTALL_SYSCONFDIR=$HEP_FRAMEWORK/$pkgname-$pkgver/etc \
    -DCMAKE_INSTALL_DATAROOTDIR=$HEP_FRAMEWORK/$pkgname-$pkgver/share \
    "${srcdir}/${pkgname}-${pkgver}"

echo 'Compiling...'
make -j20

# PACKAGE ###################################################################
cd "${srcdir}/build"

echo 'Installing...'
sudo make install

sudo install -D "${srcdir}/root.sh" "${prefix}/etc/profile.d/root.sh"
sudo install -D "${srcdir}/rootd" "${prefix}/etc/rc.d/rootd"
sudo install -D -m644 "${srcdir}/root.xml" "${prefix}/share/mime/packages/root.xml"

sudo install -D -m644 "${srcdir}/${pkgname}-${pkgver}/build/package/debian/root-system-bin.desktop.in" "${prefix}/share/applications/root-system-bin.desktop"

# fix python env call
sudo sed -e 's/@python@/python/' -i "${prefix}/lib/root/cmdLineUtils.py"

sudo install -D -m644 "${srcdir}/${pkgname}-${pkgver}/build/package/debian/root-system-bin.png" "${prefix}/share/icons/hicolor/48x48/apps/root-system-bin.png"

echo 'Updating system config...'
# use a file that pacman can track instead of adding directly to ld.so.conf
sudo install -d "${prefix}/etc/ld.so.conf.d"
sudo echo '/usr/lib/root' | sudo tee "${prefix}/etc/ld.so.conf.d/root.conf" >/dev/null

echo 'Cleaning up...'
sudo rm -rf "${prefix}/etc/root/daemons"
