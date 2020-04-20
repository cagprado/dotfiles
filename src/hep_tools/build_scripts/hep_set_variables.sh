#!/bin/sh

# cleanup
unset LD_LIBRARY_PATH

# export the basedir of some programs
export HEPMC_DIR=/opt/hep_framework/hepmc
export PYTHIA8=/opt/hep_framework/pythia
export PYTHIA8DATA=$PYTHIA8/share/Pythia8/xmldoc
export ROOTSYS=/opt/hep_framework/root

# now add the installed programs to the current path
export CC="/opt/hep_framework/gcc/bin/gcc"
export CXX="/opt/hep_framework/gcc/bin/g++"
export CPP="/opt/hep_framework/gcc/bin/cpp"
export F77="/opt/hep_framework/gcc/bin/gfortran"
export FC="/opt/hep_framework/gcc/bin/gfortran"
export LDFLAGS="-fPIC -Wl,-rpath,/opt/hep_framework/gcc/lib64"
export MANPATH="/opt/hep_framework/gcc/share/man:$(manpath)"
PATH="/opt/hep_framework/gcc/bin:$PATH"
PATH="/opt/hep_framework/cmake/bin:$PATH"
PATH="/opt/hep_framework/python/bin:$PATH"
PATH="/opt/hep_framework/hepmc/bin:$PATH"
PATH="/opt/hep_framework/pythia/bin:$PATH"
PATH="/opt/hep_framework/root5/bin:$PATH"
PATH="/opt/hep_framework/root/bin:$PATH"
export PATH
