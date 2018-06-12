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
        '-t',
        type=str,
        default='pdflatex',
        nargs=1,
        help='TeX engine that generates the file. [pdflatex]',
        metavar='texengine')
    parser.add_argument(
        'filelist',
        type=str,
        nargs='+',
        help='List of main_document.tex filenames to parse.',
        metavar='file')
    args = parser.parse_args()

    # Setup paths
    curdir = os.path.join(os.path.dirname(sys.argv[0]), '')
    asydir = os.path.join(curdir, args.a, '')
    srcdir = os.path.join(curdir, args.s, '')
    depdir = os.path.join(curdir, args.d, '')
    sources = { Source(x) for x in args.filelist }
    texengine = args.t[0]

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
    bibliographies = set()
    for item in sources:
        if not item.startswith('main_') or not item.endswith('.tex'):
            raise Exception('files must be of form main_document.tex')
        partiallist = set()
        FillDepList(partiallist, asydir, srcdir, srcdir+item)
        dependencies[Source(item[5:-4]+'.pdf.compile')] = partiallist
        if HasBibliography(srcdir+item):
            bibliographies.add(Source(item[5:-4]+'.pdf.compile'))
    WriteDepFile(depdir, dependencies, bibliographies, texengine)


def HasBibliography(filename):
    contents = ReadFile(filename)
    return contents.find(r'\bibliography{') != -1


def WriteDepFile(depdir, dependencies, bibliographies, texengine):
    makedepend = set()
    output = ''
    for document, deplist in dependencies.items():
        output += '$(DISTDIR)/' + document[:-12] + '.tex '
        output += '$(BUILDDIR)' + document + ':'
        for item in deplist:
            output += ' $(SRCDIR)/' + item
            if item.type() == 'asy':
                makedepend.add('$(ASYDIR)/' + item.basename())
                if item.endswith('.tex'):
                    if texengine == 'latex':
                        output += ' $(SRCDIR)/' + item.basename() + '_0.eps'
                    else:
                        output += ' $(SRCDIR)/' + item.basename() + '_0.pdf'
            else:
                makedepend.add('$(SRCDIR)/' + item)
        output += '\n\n'
        if document in bibliographies:
            output += '$(DISTDIR)/' + document[:-12] + '.tex: $(SRCDIR)/main_' + document[:-12] + '.bbl\n\n'

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
        if filename.endswith(('.asy.tex', '.asy.pdf', '.asy.eps')):
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
