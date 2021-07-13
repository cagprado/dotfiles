#!/usr/bin/env python3
# JabRef's preferences are stored as XML that includes dynamic things like the
# last opened file, window geometry and things like that.  Because of that,
# it's unfeasible to include the whole settings file in the GIT repository.
# This script aims to store the relevant settings so I can easily apply them
# on a new install.

import xml.etree.ElementTree as ET


table = {
    'AskAutoNamingPDFsAgain':                 r'false',
    'askedCollectTelemetry':                  r'true',
    'backup':                                 r'false',
    'bibLocAsPrimaryDir':                     r'true',
    'CleanUpCLEANUP_EPRINT':                  r'true',
    'CleanUpCLEAN_UP_DOI':                    r'true',
    'CleanUpCLEAN_UP_ISSN':                   r'true',
    'CleanUpCLEAN_UP_UPGRADE_EXTERNAL_LINKS': r'true',
    'CleanUpCONVERT_TO_BIBLATEX':             r'false',
    'CleanUpCONVERT_TO_BIBTEX':               r'false',
    'CleanUpFIX_FILE_LINKS':                  r'true',
    'CleanUpMAKE_PATHS_RELATIVE':             r'true',
    'CleanUpMOVE_PDF':                        r'false',
    'CleanUpRENAME_PDF':                      r'false',
    'CleanUpRENAME_PDF_ONLY_RELATIVE_PATHS':  r'false',
    'confirmDelete':                          r'false',
    'cyclePreview':                           r'Preview;american-institute-of-physics.csl',
    'defaultBibtexKeyPattern':                r'[auth]:[year][shorttitle:abbr:lower]',
    'defaultUnwantedBibtexKeyCharacters':     r'-`ʹ!;?^+',
    'downloadLinkedFiles':                    r'true',
    'externalJournalLists':                   r'/home/cagprado/usr/sync/files/library/journals.csv',
    'generateKeysBeforeSaving':               r'true',
    'importFileDirPattern':                   r'files',
    'importFileNamePattern':                  r'[bibtexkey]',
    'mainTableColumnNames':                   r'groups;files;field:author/editor;field:journal/booktitle;field:title;field:year;field:bibtexkey;field:entrytype',
    'mainTableColumnWidths':                  r'28;28;180;300;650;70;150;100',
    'mergeEntriesDiffMode':                   r'WORD',
    'previewStyle':                           r'<font face="sans-serif"><b><i>\bibtextype</i><a name="\bibtexkey">\begin{bibtexkey} (\bibtexkey)</a>\end{bibtexkey}</b><br>__NEWLINE__\begin{author} \format[Authors(Initials),HTMLChars]{\author}<BR>\end{author}__NEWLINE__\begin{editor} \format[Authors(Initials),HTMLChars]{\editor} <i>(\format[IfPlural(Eds.,Ed.)]{\editor})</i><BR>\end{editor}__NEWLINE__\begin{title} \format[HTMLChars]{\title} \end{title}<BR>__NEWLINE__\begin{chapter} \format[HTMLChars]{\chapter}<BR>\end{chapter}__NEWLINE__\begin{journal} <em>\format[HTMLChars]{\journal}, </em>\end{journal}__NEWLINE__\begin{booktitle} <em>\format[HTMLChars]{\booktitle}, </em>\end{booktitle}__NEWLINE__\begin{school} <em>\format[HTMLChars]{\school}, </em>\end{school}__NEWLINE__\begin{institution} <em>\format[HTMLChars]{\institution}, </em>\end{institution}__NEWLINE__\begin{publisher} <em>\format[HTMLChars]{\publisher}, </em>\end{publisher}__NEWLINE__\begin{volume}<b>\volume</b>\end{volume}\begin{pages}, \format[FormatPagesForHTML]{\pages} \end{pages}\begin{year} (\year)\end{year}__NEWLINE__\begin{abstract}<BR><BR><b>Abstract: </b> \format[HTMLChars]{\abstract} \end{abstract}__NEWLINE__\begin{comment}<BR><BR><b>Comment: </b> \format[Markdown,HTMLChars]{\comment} \end{comment}</dd>__NEWLINE__<p></p></font>',
    'pushToApplication':                      r'Vim',
    'reformatFileOnSaveAndExport':            r'true',
    'showLatexCitations':                     r'false',
    'showRecommendations':                    r'false',
    'warnBeforeOverwritingKey':               r'false',
}

tree = ET.parse('prefs.xml')
root = tree.getroot()

for key, value in table.items():
    child = root.find('*[@key="{}"]'.format(key))
    if child is None:
        root.append(ET.Element('entry', {'key': key, 'value': value}))
    else:
        child.attrib['value'] = value

with open('prefs.xml', 'w', encoding='UTF-8') as file:
    file.write('<?xml version="1.0" encoding="UTF-8" standalone="no"?>\n')
    file.write('<!DOCTYPE map SYSTEM "http://java.sun.com/dtd/preferences.dtd">\n')
    file.write(ET.tostring(root, encoding='unicode'))
