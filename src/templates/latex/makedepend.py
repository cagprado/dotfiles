#!/usr/bin/env python

import re
import os
import sys
import argparse


def main():
    # Parse command line arguments.
    parser = argparse.ArgumentParser(description="""Generates a dependency
        list for a latex document listing all files that are needed in order
        to generate the pdf.""")
    parser.add_argument(
        '-a',
        type=str,
        default='plots',
        nargs=1,
        help='Location of asymptote files relative to this script. [plots]',
        metavar='asydir')
    parser.add_argument(
        '-s',
        type=str,
        default='tex',
        nargs=1,
        help='Location of source dir relative to this script. [tex]',
        metavar='srcdir')
    parser.add_argument(
        '-d',
        type=str,
        default='.d',
        nargs=1,
        help='Location of dependency dir relative to this script. [.d]',
        metavar='depdir')
    parser.add_argument(
        '-f',
        type=str,
        default='pdf',
        nargs=1,
        help='Format of inline asymptote plots (eps|pdf). [pdf]',
        metavar='format')
    parser.add_argument(
        'filelist',
        type=str,
        nargs='+',
        help='List of main_document.tex filenames to parse.',
        metavar='file')
    args = parser.parse_args()

    # Setup paths
    asyext = '_0.' + args.f
    curdir = os.path.join(os.path.dirname(sys.argv[0]), '')
    asydir = os.path.join(curdir, args.a, '')
    srcdir = os.path.join(curdir, args.s, '')
    depdir = os.path.join(curdir, args.d, '')
    sources = { Source(x) for x in args.filelist }

    # Define list of commands
    comm.AddCommand('documentclass', '%.cls')
    comm.AddCommand('usepackage', '%.sty')
    comm.AddCommand('RequirePackage', '%.sty')
    comm.AddCommand('usetheme', 'beamertheme%.sty')
    comm.AddCommand('input', '%.tex')
    comm.AddCommand('include', '%.tex')
    comm.AddCommand('includegraphics', '%.png,%.pdf,%.jpg,%.jpeg,%.eps')
    comm.AddCommand('bibliography', '%.bib')
    comm.AddCommand('addbibresource', '%.bib')

    # Get dependency list for each source file
    dependencies = {}
    for item in sources:
        if not item.startswith('main_') or not item.endswith('.tex'):
            raise Exception('files must be of form main_document.tex')
        partiallist = set()
        FillDepList(partiallist, asydir, srcdir, srcdir+item)
        dependencies[Source(item[5:-4])] = partiallist
    WriteDepFile(depdir, dependencies, asyext)


def WriteDepFile(depdir, dependencies, asyext):
    output = ''
    makedepend = set()
    for document, deplist in dependencies.items():
        # makedepend depends on tex files and asy files
        makedepend.add('$(TEXDIR)/main_' + document + '.tex')
        for item in deplist:
            if item.type() == 'tex':
                makedepend.add('$(TEXDIR)/' + item)
            elif item.type() == 'asy':
                makedepend.add('$(ASYDIR)/' + item.basename().replace('_asy', '.asy'))

        # compile latex with all files plus the auxiliary picture for inline asy
        dlist = [ '$(TEXDIR)/'+x for x in deplist ]
        dlist += [ '$(TEXDIR)/'+x.basename()+asyext for x in deplist if x.type() == 'asy' and x.endswith('.tex') ]
        output += '$(TEXDIR)/main_' + document + '.latex: ' + ' '.join(dlist) + '\n'
        output += '.SECONDARY: $(TEXDIR)/main_' + document + '.latex\n\n'

        # create a share: same files
        output += '$(SHAREDIR)/' + document + '.make: ' + '$(TEXDIR)/main_' + document + '.tex ' + ' '.join(dlist) + '\n\n'
        # create final share: same files, but .bib, plus .bbl
        output += '$(FINALDIR)/' + document + '.make: '
        if any(item.endswith('.bib') for item in dlist):
            output += '$(TEXDIR)/main_' + document + '.bbl '
        dlist = [ x for x in dlist if not x.endswith('.bib') ]
        output += '$(TEXDIR)/main_' + document + '.tex ' + ' '.join(dlist) + '\n\n'

        # all share files depend on a generator rule
        dlist = [ '$(SHAREDIR)/' + document + '/' + x for x in deplist if not x.endswith(('.tex', '.pre')) ]
        dlist += [ '$(SHAREDIR)/' + document + '/main_' + document + '.tex' ]
        output += ' '.join(dlist) + ': $(SHAREDIR)/' + document + '.make\n\n'
        # latex share depends on all but .tex files plus .tex from latexpand
        output += document + '.share: ' + ' '.join(dlist) + '\n\n'

        # all final share files depend on a generator rule
        dlist = [ '$(FINALDIR)/' + document + '/' + x for x in deplist if not x.endswith(('.tex', '.pre', '.bib')) ]
        dlist += [ '$(FINALDIR)/' + document + '/main_' + document + '.tex' ]
        output += ' '.join(dlist) + ': $(FINALDIR)/' + document + '.make\n\n'
        # latex final depends on all but .tex files plus .tex from latexpand
        output += document + '.final: ' + ' '.join(dlist) + '\n\n'

    # add makedepend dependencies
    output += '$(DEPDIR)/makedepend: ' + ' '.join(makedepend) + '\n\n'
    for item in makedepend:
        output += item + ':\n\n'

    # write makedepend file
    try:
        os.makedirs(depdir)
    except OSError:
        if not os.path.isdir(depdir):
            raise
    with open(depdir+'makedepend', 'w') as fd:
        fd.write(output)


def FillDepList(partiallist, asydir, srcdir, filename):
    for source in FindIncludes(filename, srcdir):
        if source not in partiallist:
            if source.type() == 'asy':
                # TODO: parsing of asymptote files
                partiallist.add(source)
            elif os.path.isfile(srcdir+source):
                partiallist.add(source)
                if source.type() == 'tex':
                    FillDepList(partiallist, asydir, srcdir, srcdir+source)


def FindIncludes(filename, srcdir):
    contents = ReadFile(filename)
    includelist = []
    for m in re.findall(comm.Pattern(), contents):
        for item in comm.GetFileNames(srcdir, m):
            includelist.append(Source(item))
    return includelist


def ReadFile(tfile):
    contents = ''
    with open(tfile) as fd:
        for line in fd:
            match = re.search(r'(^%|[^\\](?:\\\\)*%)', line)
            if match:
                contents += line[:match.start(0)+1] + '\n'
            else:
                contents += line
    return contents


class Source(str):
    srctype = ''
    filename = ''

    def __new__(cls, filename):
        return str.__new__(cls, os.path.basename(filename))

    def __init__(self, filename):
        self.filename = os.path.basename(filename)
        if filename.endswith(('_asy.tex', '_asy.pdf', '_asy.eps')):
            self.srctype = 'asy'
        elif filename.endswith(('.tex', '.pre', '.cls', '.sty')):
            self.srctype = 'tex'
        else:
            self.srctype = 'other'

    def type(self):
        return self.srctype

    def basename(self):
        return os.path.splitext(self.filename)[0]


class Commands:
    comm = {}

    def AddCommand(self, command, extensions):
        extensions = extensions.split(',')
        self.comm[command] = extensions

    def GetFileNames(self, srcdir, match):
        command = match[0]
        filenames = match[1]
        filelist = []
        for filename in filenames.split(','):
            for ext in self.comm[command]:
                if os.path.isfile(srcdir + ext.replace('%', filename)):
                    filename = ext.replace('%', filename)
                    break
            filelist.append(filename)
        return filelist

    def Pattern(self):
        pattern = r'[\\]('
        for k in self.comm.keys():
            pattern += k+r'|'
        pattern = pattern[:-1] + r')(?:\[[^\]]*\])?{([^}]*)}'
        return re.compile(pattern, re.M)


if __name__ == "__main__":
    comm = Commands()
    main()
else:
    print("makedepend.py: This module is supposed to run on it's own.")
