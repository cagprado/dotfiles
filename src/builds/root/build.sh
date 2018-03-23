#!/bin/zsh

# PREPARE ###################################################################
pkgname=root
pkgver=6.12.06
pkgrel=1
basedir="$(pwd)"
srcdir="$basedir/src"
pkgdir="$basedir/pkg"
prefix="$HOME/usr/local/$pkgname-$pkgver"
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

# BUILD #####################################################################
mkdir -p "${srcdir}/build"
cd "${srcdir}/build"

echo 'Configuring...'
CFLAGS="${CFLAGS} -pthread" \
CXXFLAGS="${CXXFLAGS} -pthread" \
LDFLAGS="${LDFLAGS} -pthread -Wl,--no-undefined" \
cmake -C "${srcdir}/settings.cmake" "${srcdir}/${pkgname}-${pkgver}"

echo 'Compiling...'
make -j20

# PACKAGE ###################################################################
cd "${srcdir}/build"

echo 'Installing...'
make DESTDIR="${pkgdir}" install

install -D "${srcdir}/root.sh" \
    "${pkgdir}/etc/profile.d/root.sh"
install -D "${srcdir}/rootd" \
    "${pkgdir}/etc/rc.d/rootd"
install -D -m644 "${srcdir}/root.xml" \
    "${pkgdir}/usr/share/mime/packages/root.xml"

install -D -m644 "${srcdir}/${pkgname}-${pkgver}/build/package/debian/root-system-bin.desktop.in" \
    "${pkgdir}/usr/share/applications/root-system-bin.desktop"

# replace @prefix@ with /usr for the desktop
sed -e 's_@prefix@_/usr_' -i "${pkgdir}/usr/share/applications/root-system-bin.desktop"

# fix python env call
sed -e 's/@python@/python/' -i "${pkgdir}/usr/lib/root/cmdLineUtils.py"

install -D -m644 "${srcdir}/${pkgname}-${pkgver}/build/package/debian/root-system-bin.png" \
    "${pkgdir}/usr/share/icons/hicolor/48x48/apps/root-system-bin.png"

echo 'Updating system config...'
# use a file that pacman can track instead of adding directly to ld.so.conf
install -d "${pkgdir}/etc/ld.so.conf.d"
echo '/usr/lib/root' > "${pkgdir}/etc/ld.so.conf.d/root.conf"

echo 'Cleaning up...'
rm -rf "${pkgdir}/etc/root/daemons"
