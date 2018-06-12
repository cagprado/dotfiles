#!/usr/bin/env python

import re
import os
import sys
import argparse


def main():
    # Parse command line arguments.
    parser = argparse.ArgumentParser(description="""Generates a dependency
        list for a C/C++ program listing all '.o' files that are needed in
        order to link the final binary.""")
    parser.add_argument(
        '-I',
        type=str,
        default='include',
        nargs=1,
        help='Location of include dir relative to this script. [include]',
        metavar='incdir')
    parser.add_argument(
        '-s',
        type=str,
        default='src',
        nargs=1,
        help='Location of source dir relative to this script. [src]',
        metavar='srcdir')
    parser.add_argument(
        '-d',
        type=str,
        default='.d',
        nargs=1,
        help='Location of dependency dir relative to this script. [.d]',
        metavar='depdir')
    parser.add_argument(
        '-S',
        type=str,
        default=[],
        action='append',
        help='List of special header files that must be built prior to the compilation',
        metavar='special')
    parser.add_argument(
        'filelist',
        type=str,
        nargs='+',
        help='List of code filenames to parse.',
        metavar='file')
    args = parser.parse_args()

    # Setup paths
    curdir = os.path.join(os.path.dirname(sys.argv[0]), '')
    incdir = os.path.join(curdir, args.I, '')
    srcdir = os.path.join(curdir, args.s, '')
    depdir = os.path.join(curdir, args.d, '')
    sources = { Source(x) for x in args.filelist }
    special = { Source(x): set() for x in args.S }

    # Get dependency list for each source file
    dependencies = {}
    for item in sources:
        partiallist = set()
        FillDepList(partiallist, special, incdir, srcdir, srcdir+item.c())
        dependencies[Source(item.replace('main_',''))] = partiallist
    WriteDepFile(depdir, dependencies, special)


def WriteDepFile(depdir, dependencies, special):
    makedepend = set()
    output = ''
    for program, deplist in dependencies.items():
        output += '$(BUILDDIR)' + program + ':'
        for item in deplist:
            output += ' $(SRCDIR)/' + item.o()
            makedepend.add('$(SRCDIR)/' + item.c())
            makedepend.add('$(INCDIR)/' + item.h())
        output += '\n\n'

    for header, deplist in special.items():
        for item in deplist:
            output += '$(SRCDIR)/' + item.o() + ' '
        output += ': $(INCDIR)/' + header.h() + '\n\n'

    output += '$(DEPDIR)/makedepend: ' + ' '.join(makedepend) + '\n\n'
    for item in makedepend:
        output += item + ':\n\n'

    try:
        os.makedirs(depdir)
    except OSError:
        if not os.path.isdir(depdir):
            raise
    with open(depdir+'makedepend', 'w') as fd:
        fd.write(output)


def FillDepList(partiallist, special, incdir, srcdir, filename):
    for source in FindIncludes(special, filename):
        if source in special:
            special[source].add(Source(filename))
        elif source not in partiallist and os.path.isfile(incdir+source.h()):
            partiallist.add(source)
            FillDepList(partiallist, special, incdir, srcdir, incdir+source.h())
            FillDepList(partiallist, special, incdir, srcdir, srcdir+source.c())


def FindIncludes(special, filename):
    contents = ReadFile(filename)
    pattern = re.compile(r'^#include *[<"](.*)[">]', re.M)
    return [ Source(x) for x in re.findall(pattern, contents) ]


def ReadFile(filename):
    contents = ''
    with open(filename) as fd:
        for line in fd:
            contents += line
    return contents


class Source(str):
    srctype = ''
    filename = ''

    def __new__(cls, filename, special = False):
        return str.__new__(cls, os.path.basename(os.path.splitext(filename)[0]))

    def __init__(self, filename, special = False):
        if special:
            self.filename = os.path.basename(filename)
            self.srctype = 'special'
        else:
            self.filename, ext = os.path.splitext(filename)
            self.filename = os.path.basename(self.filename)
            if ext == '.c' or ext == '.h':
                self.srctype = 'C'
            else:
                self.srctype = 'C++'

    def Type(self):
        return self.srctype

    def o(self):
        if self.srctype == 'special':
            return self.filename
        else:
            return self.filename + '.o'

    def h(self):
        if self.srctype == 'C':
            return self.filename + '.h'
        elif self.srctype == 'C++':
            return self.filename + '.hpp'
        else:
          return self.filename

    def c(self):
        if self.srctype == 'C':
            return self.filename + '.c'
        elif self.srctype == 'C++':
            return self.filename + '.cpp'
        else:
          return self.filename


if __name__ == "__main__":
    main()
else:
    print("makedepend.py: This module is supposed to run on it's own.")
