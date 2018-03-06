#!/bin/zsh

# PREPARE ###################################################################
pkgname=pythia
pkgver=8.2.30
_pkgid="${pkgname}${pkgver//./}"
pkgrel=1
basedir="$(pwd)"
srcdir="$basedir/src"
pkgdir="$basedir/pkg"
destdir="$HOME/usr/local/$pkgname-$pkgver"
source="http://home.thep.lu.se/~torbjorn/pythia8/${_pkgid}.tgz"
sourcefile="$(basename $source)"
_srcpath="${srcdir}/${_pkgid}"

rm -rf "$srcdir" "$pkgdir"
mkdir "$srcdir" "$pkgdir"

# get source file
if [[ ! -r "$sourcefile" ]]; then
    wget "$source"
fi
cp "$basedir"/*(.) "$srcdir"
cd "$srcdir"
tar xf "$sourcefile"

# prepare source files
cd "${srcdir}/${_pkgid}"
echo 'Applying patches...'
patch -p1 -i "${srcdir}/respect_lib_suffix.patch"

# BUILD #####################################################################
cd "${srcdir}/${_pkgid}"
prefix=$destdir/usr
_inc=$prefix/include/
_lib=$prefix/lib/

./configure --prefix="$prefix" \
            --prefix-include=${_inc} \
            --prefix-lib=${_lib} \
            --cxx-common="${CXXFLAGS} ${LDFLAGS} -fPIC -pthread" \
            --enable-shared \
            #--with-evtgen \
            #--with-evtgen-include=${_inc} \
            #--with-evtgen-lib=${_lib} \
            #--with-fastjet3 \
            #--with-fastjet3-include=${_inc} \
            #--with-fastjet3-lib=${_lib} \
            #--with-gzip \
            #--with-gzip-include=${_inc} \
            #--with-gzip-lib=${_lib} \
            #--with-hepmc2 \
            #--with-hepmc2-include=${_inc} \
            #--with-hepmc2-lib=${_lib} \
            #--with-hepmc3 \
            #--with-hepmc3-include=${_inc} \
            #--with-hepmc3-lib=${_lib} \
            #--with-lhapdf5 \
            #--with-lhapdf5-include=${_inc} \
            #--with-lhapdf5-lib=${_lib} \
            #--with-powheg \
            #--with-powheg-include=${_inc} \
            #--with-powheg-lib=${_lib} \
            #--with-promc \
            #--with-promc-include=${_inc} \
            #--with-promc-lib=${_lib} \
            #--with-python \
            #--with-python-include=${HOME}/usr/local/python/usr/include/python3.6m \
            #--with-python-lib=${HOME}/usr/local/python/usr/lib \
            #--with-root \
            #--with-root-include=/usr/include/root/ \
            #--with-root-lib=/usr/lib/root/

make ${MAKEFLAGS} -j


# PACKAGE ###################################################################
mkdir -p "${pkgdir}/usr"
install -Dm755 "${srcdir}/${_pkgid}/bin/pythia8-config" "${pkgdir}/usr/bin/pythia8-config"
install -D "${srcdir}/pythia.sh" "${pkgdir}/etc/profile.d/pythia.sh"

cp -r "${srcdir}/${_pkgid}/include" "${pkgdir}/usr/"
cp -r "${srcdir}/${_pkgid}/share" "${pkgdir}/usr/"
cp -r "${srcdir}/${_pkgid}/examples" "${pkgdir}/usr/share/Pythia8/"

install -Dm755 "${srcdir}/${_pkgid}/lib/libpythia8.so" "${pkgdir}/usr/lib/libpythia8.so"
install -Dm755 "${srcdir}/${_pkgid}/lib/_pythia8.so" "${pkgdir}/usr/lib/python3.6/site-packages/_pythia8.so"
install -Dm755 "${srcdir}/${_pkgid}/lib/pythia8.py" "${pkgdir}/usr/lib/python3.6/site-packages/pythia8.py"

# INSTALL ###################################################################
mv "$pkgdir" "${destdir}"
