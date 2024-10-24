#!/usr/bin/env python
from __future__ import print_function, division, unicode_literals

__author__ = 'Pepoluan'

import sys
import codecs
import re
import datetime

import requests
from bs4 import BeautifulSoup
import bs4.element
# noinspection PyUnresolvedReferences
from html5lib import parse  # Not actually used, just to indicate to user that html5lib needs to be installed


def _get_input(what, default=None):
    print('\n{0} (default: "{1}")'.format(what, default))
    inp = raw_input('[Enter accepts default]: ').strip()
    return inp or default


class G(object):
    URL = _get_input('URL for "Timeline of Canon Media"',
                     default='http://starwars.wikia.com/wiki/Timeline_of_canon_media')
    OutFile = _get_input('Destination CSV file', default='D:\\TimelineCanon.csv')
    CSV_Sep = _get_input('CSV file separator', default=',')


class CanonMediaEntry(object):

    RE_Note = re.compile(r'\[[0-9]+\]')
    Columns = []

    def __init__(self, timeline_row, order_count):
        assert isinstance(timeline_row, bs4.element.Tag)
        self._timeline_row = timeline_row  # For debugging
        self.cells = timeline_row.find_all('td')

        assert isinstance(order_count, int)
        self.ord = str(order_count)

        self.year = self._getcleantext(0)
        self.mtype = self._getcleantext(1)
        self.title = self._getcleantext(2)
        self.writers = self._getcleantext(3)
        self.release = self._getcleantext(4)

        self.release_date = self._parse_release()
        self.asset = self._deduce_asset()

    @property
    def is_released(self):
        return 'Yes' if datetime.datetime.now().date() >= self.release_date else 'No'

    def _getcleantext(self, index):
        t = self.cells[index].text.strip()
        t = CanonMediaEntry.RE_Note.sub('', t)
        t = t.replace('\u2013', '-').replace('\u2014', '-')
        return t

    def _deduce_asset(self):
        title = self.title
        asset = ''
        if title.startswith('The Clone Wars'):
            asset = 'TCW'
        elif title.startswith('Star Wars Rebels'):
            asset = 'SWR'
        elif title.startswith('Star Wars: Kanan'):
            asset = 'Kanan'
        elif title.startswith('Star Wars: Princess Leia'):
            asset = 'Leia'
        elif title.startswith('Star Wars: Darth Vader'):
            asset = 'Vader'
        elif self.mtype == 'F' and 'Episode' in title:
            asset = 'Movies'
        return asset

    def _parse_release(self):
        dt = None
        dts = self.release.split('-')
        def_date = [9999, 12, 28]  # 28 instead of 31 because Feb might be only 28 days long
        act_date = []
        for f in dts:
            d = def_date.pop(0)
            if f and f.strip().isdigit():
                act_date.append(int(f.strip()))
            else:
                act_date.append(d)
        if len(act_date) < 3:
            act_date.extend(def_date)
        try:
            dt = datetime.date(*act_date)
        except TypeError:
            print(self._timeline_row)
        return dt

    # noinspection PyPep8Naming
    @classmethod
    def SetColumns(cls, lst):
        # IMPORTANT: Changing the headers here should be reflected in the to_list() method!
        cls.Columns = ['ChronOrd', 'Asset']
        cls.Columns.extend(lst)
        cls.Columns.append('Rls?')

    def to_list(self):
        # IMPORTANT: These should match the columns in SetColumns() classmethod!
        # That is why instead of directly building a list literal, we reflect how the statements in SetColumns()
        # are structured
        lst1 = [self.ord, self.asset]
        lst1.extend([self.year, self.mtype, self.title, self.writers, self.release])
        lst1.append(self.is_released)
        return map(lambda x: x.replace('"', '""'), lst1)


class _StringCleaner(object):

    DefaultCleaners = []

    def __init__(self, s, cleaners=None):
        """
        Initializes the StringCleaner Class

        :param s: String to clean, may be str() or unicode()
        :param cleaners: (optional) list of tuples(regex, regex_flags, replacement)
        :type cleaners: list
        """
        self.__contents = s
        __cleaners = list(_StringCleaner.DefaultCleaners)
        if cleaners:
            assert isinstance(cleaners, list)
            __cleaners.extend(cleaners)
        for c in __cleaners:
            rex = re.compile(*c[0:2])
            self.__contents = rex.sub(c[2], self.__contents)

    @property
    def text(self):
        return self.__contents

    def resub_if(self, cond, regex_param_tuple, replacement):
        if cond:
            rex = re.compile(*regex_param_tuple)
            self.__contents = rex.sub(replacement, self.__contents)

    def contains(self, s):
        return s in self.__contents

    def __str__(self):
        return self.__contents.encode('utf-8') if isinstance(self.__contents, unicode) else self.__contents


def get_timeline_article(url, replace_br=True, replace_dash=True):
    print('\nDownloading "Timeline of Canon Media" article from {0}...'.format(url), end='')
    resp = requests.get(url)
    the_page = _StringCleaner(resp.text)
    the_page.resub_if(replace_br, (r'<br\s*/?>', re.IGNORECASE), '\n')
    # Excel does not understand unicode dashes, so replace with 'standard' dash
    the_page.resub_if(replace_dash, (u'\u2013|\u2014', re.UNICODE), '-')
    if not the_page.contains('Episode IX'):
        print('ERROR!\nThe page seems to be truncated!')
        sys.exit(1)
    print(' done.')
    return the_page.text


def get_timeline_table(page):
    print('Looking for the Timeline table...', end='')
    soup = BeautifulSoup(page, 'html5lib')
    timeline_table = None
    for t in soup.find_all('table'):
        ln = str(t.tr)
        if 'Year' in ln and 'Title' in ln and 'Writer' in ln:
            timeline_table = t
            break
    if timeline_table is None:
        print('ERROR!')
        print('I can\'t find the Timeline Table!')
        sys.exit(1)
    print(' done.')
    return timeline_table


def get_timeline_entries(table):
    print('Parsing the Timeline table...', end='')
    entries = []
    linenum = 0
    for r in table.find_all('tr'):
        print('.', end='')
        if linenum == 0:
            cols = []
            col = 1
            for h in r.find_all('th'):
                head = h.string.strip()
                head = head if head else 'Col{0}'.format(col)
                col += 1
                cols.append('{0}'.format(head))
            CanonMediaEntry.SetColumns(cols)
        else:
            entries.append(
                CanonMediaEntry(timeline_row=r, order_count=linenum)
            )
        linenum += 1
    print('\nTotal {0} records processed.'.format(linenum))
    return entries


def join_enquote(lst):
    return G.CSV_Sep.join(['"{0}"'.format(i) for i in lst])


def main():
    timeline_page = get_timeline_article(G.URL)
    timeline_table = get_timeline_table(timeline_page)
    timeline_entries = get_timeline_entries(timeline_table)

    try:
        with codecs.open(G.OutFile, 'w', encoding='utf-8-sig') as fout:
            print('Saving the parsed Timeline table into file "{0}"...'.format(G.OutFile), end='')
            c = 1
            try:
                print(join_enquote(CanonMediaEntry.Columns), file=fout)
                for ent in timeline_entries:
                    assert isinstance(ent, CanonMediaEntry)
                    print(join_enquote(ent.to_list()), file=fout)
                    c += 1
                print(' {0} lines.'.format(c))
            except:
                print('ERROR!')
                raise
    except IOError:
        print('ERROR trying to open file "{0}"'.format(G.OutFile))
        print('Is it open somewhere?')
        sys.exit(1)

if '__main__' == __name__:
    main()
