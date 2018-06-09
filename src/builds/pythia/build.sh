#!/bin/zsh

if [[ -z "$HEP_FRAMEWORK" ]]; then
    echo "Please, first setup HEP_FRAMEWORK variable"
    exit
fi

# PREPARE ###################################################################
pkgname=pythia
pkgver=8.2.35
_pkgid="${pkgname}${pkgver//./}"
pkgrel=1
basedir="$(pwd)"
srcdir="$basedir/src"
pkgdir="$basedir/pkg"
destdir="$HEP_FRAMEWORK/$pkgname-$pkgver"
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

# fix config to add rpath
sed -i 's/-lpythia8/-lpythia8 -Wl,-rpath,$PREFIX_LIB/' bin/pythia8-config

prefix=$destdir
_inc=$prefix/include/
_lib=$prefix/lib/

./configure --prefix="$prefix" \
            --prefix-include=${_inc} \
            --prefix-lib=${_lib} \
            --cxx-common="${CXXFLAGS} ${LDFLAGS} -fPIC -pthread" \
            --enable-shared \
            --with-hepmc3 \
            --with-python \
            --with-python-include=$(python-config --includes | cut -d' ' -f1 | cut -d'I' -f2) \

make ${MAKEFLAGS} -j


# PACKAGE ###################################################################
install -Dm755 "${srcdir}/${_pkgid}/bin/pythia8-config" "${pkgdir}/bin/pythia8-config"
install -D "${srcdir}/pythia.sh" "${pkgdir}/etc/profile.d/pythia.sh"

cp -r "${srcdir}/${_pkgid}/include" "${pkgdir}/"
cp -r "${srcdir}/${_pkgid}/share" "${pkgdir}/"
cp -r "${srcdir}/${_pkgid}/examples" "${pkgdir}/share/Pythia8/"

install -Dm755 "${srcdir}/${_pkgid}/lib/libpythia8.so" "${pkgdir}/lib/libpythia8.so"
install -Dm755 "${srcdir}/${_pkgid}/lib/_pythia8.so" "${pkgdir}/lib/python3.6/site-packages/_pythia8.so"
install -Dm755 "${srcdir}/${_pkgid}/lib/pythia8.py" "${pkgdir}/lib/python3.6/site-packages/pythia8.py"

# INSTALL ###################################################################
sudo mv "$pkgdir" "${destdir}"
sudo chown -R root.root "${destdir}"
