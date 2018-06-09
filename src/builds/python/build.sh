#!/bin/sh
# Verify that all GCC variables are well set, particularly LDFLAGS="-fPIC -Wl,-rpath,gcclib-path"

if [[ -z "$HEP_FRAMEWORK" ]]; then
    echo "Please, first setup HEP_FRAMEWORK variable"
    exit
fi

# Python: (it doesn't link the libstdc++ so no need to add gcc rpath but we set rpath for the python lib)
./configure --enable-shared --prefix=$HEP_FRAMEWORK/python-3.6.5 LDFLAGS=-Wl,-rpath=$HEP_FRAMEWORK/python-3.6.5/lib
make -j
sudo make -j install
