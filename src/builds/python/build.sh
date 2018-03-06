#!/bin/sh
# Verify that all GCC variables are well set, particularly LDFLAGS="-fPIC -Wl,-rpath,gcclib-path"

# Python: (it doesn't link the libstdc++ so no need to add gcc rpath but we set rpath for the python lib)
./configure --enable-shared --prefix=$HOME/usr/local/python-3.6.4/usr LDFLAGS=-Wl,-rpath=$HOME/usr/local/python/usr/lib
make -j32
make -j32 install
